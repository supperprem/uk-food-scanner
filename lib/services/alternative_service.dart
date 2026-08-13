// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import '../services/recommendation_service.dart';

class AlternativeProduct {
  final String name;
  final String brand;
  final String imageUrl;
  final double score;
  final List<String> improvements;

  const AlternativeProduct({
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.score,
    required this.improvements,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'brand': brand,
    'imageUrl': imageUrl,
    'score': score,
    'improvements': improvements,
  };

  factory AlternativeProduct.fromJson(Map<String, dynamic> json) {
    return AlternativeProduct(
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      improvements: List<String>.from(json['improvements'] ?? []),
    );
  }
}

class AlternativeService {
  static const String _boxName = 'alternatives_cache_box';

  static Future<void> initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Future<List<AlternativeProduct>> getBetterAlternatives(
    ProductModel product,
  ) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      final cacheKey = 'alt_${product.barcode}';

      // Check cache first
      if (box.containsKey(cacheKey)) {
        final cachedData = box.get(cacheKey);
        if (cachedData is List) {
          return cachedData
              .map(
                (item) => AlternativeProduct.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      }

      // Query Open Food Facts search API for similar products
      List<AlternativeProduct> alternatives = [];
      try {
        final query = product.brand.isNotEmpty ? product.brand : product.name;
        final url = Uri.parse(
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=10',
        );
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['products'] is List) {
            for (var pJson in (data['products'] as List)) {
              try {
                final cand = ProductModel.fromJson(pJson);
                // Filter: different barcode, higher score
                if (cand.barcode != product.barcode &&
                    cand.score > product.score) {
                  List<String> improvements = [];

                  if (cand.score > product.score) {
                    improvements.add('Higher health score (${cand.score})');
                  }
                  if (cand.sugar < product.sugar) {
                    improvements.add(
                      'Lower sugar (${cand.sugar.toStringAsFixed(1)}g vs ${product.sugar.toStringAsFixed(1)}g)',
                    );
                  }
                  if (cand.protein > product.protein) {
                    improvements.add(
                      'Higher protein (${cand.protein.toStringAsFixed(1)}g)',
                    );
                  }
                  if (cand.calories < product.calories) {
                    improvements.add(
                      'Lower calories (${cand.calories.toStringAsFixed(1)} kcal)',
                    );
                  }

                  if (improvements.isNotEmpty) {
                    alternatives.add(
                      AlternativeProduct(
                        name: cand.name,
                        brand: cand.brand,
                        imageUrl: cand.imageUrl,
                        score: cand.score.toDouble(),
                        improvements: improvements,
                      ),
                    );
                  }
                }
              } catch (_) {}
            }
          }
        }
      } catch (_) {}

      // If API search yielded fewer than 3, fallback to curated RecommendationService alternatives
      if (alternatives.length < 3) {
        final curated = RecommendationService().getAlternatives(
          ProductModel(
            barcode: product.barcode,
            name: product.name,
            brand: product.brand,
            imageUrl: product.imageUrl,
            ingredients: product.ingredients,
            calories: product.calories,
            sugar: product.sugar,
            protein: product.protein,
            fat: product.fat,
            allergens: product.allergens,
            score: product.score < 60
                ? product.score
                : 40, // force trigger alternatives
            category: product.category,
          ),
        );

        for (var c in curated) {
          if (!alternatives.any((a) => a.name == c.name)) {
            List<String> improvements = [];
            if (c.sugar < product.sugar) {
              improvements.add('Lower sugar (${c.sugar.toStringAsFixed(1)}g)');
            }
            if (c.protein >= product.protein) {
              improvements.add('Good protein source');
            }
            if (improvements.isEmpty) {
              improvements.add('Better overall health choice');
            }

            alternatives.add(
              AlternativeProduct(
                name: c.name,
                brand: c.brand,
                imageUrl: c.imageUrl,
                score: c.score.toDouble(),
                improvements: improvements,
              ),
            );
          }
        }
      }

      // Take maximum 3 alternatives
      final finalAlternatives = alternatives.take(3).toList();

      // Save to cache
      await box.put(
        cacheKey,
        finalAlternatives.map((a) => a.toJson()).toList(),
      );

      return finalAlternatives;
    } catch (e) {
      print('Error fetching better alternatives: $e');
      return [];
    }
  }
}
