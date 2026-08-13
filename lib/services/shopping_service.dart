// ignore_for_file: avoid_print
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import '../services/recommendation_service.dart';

class ShoppingService {
  static const String _boxName = 'shopping_session_box';

  static Future<void> initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  Future<void> addShoppingItem(ProductModel product) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      await box.put(product.barcode, product.toJson());
      print('Added product to shopping session: ${product.name}');
    } catch (e) {
      print('Error adding shopping item: $e');
    }
  }

  Future<List<ProductModel>> getShoppingItems() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      final rawData = box.values.toList();
      final List<ProductModel> products = [];
      for (var item in rawData) {
        if (item is Map) {
          try {
            final product = ProductModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            products.add(product);
          } catch (e) {
            print('Error parsing shopping item: $e');
          }
        }
      }
      return products;
    } catch (e) {
      print('Error getting shopping items: $e');
      return [];
    }
  }

  Future<void> clearShoppingSession() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      await box.clear();
      print('Cleared shopping session');
    } catch (e) {
      print('Error clearing shopping session: $e');
    }
  }

  Future<Map<String, dynamic>> getShoppingSummary() async {
    final items = await getShoppingItems();
    if (items.isEmpty) {
      return {
        'basketScore': 0,
        'totalScanned': 0,
        'avgScore': 0,
        'needsImprovement': <Map<String, dynamic>>[],
        'goodChoices': <ProductModel>[],
      };
    }

    int totalScore = 0;
    List<Map<String, dynamic>> needsImprovement = [];
    List<ProductModel> goodChoices = [];

    for (var p in items) {
      totalScore += p.score;
      if (p.score < 60) {
        // Find alternative
        final alts = RecommendationService().getAlternatives(p);
        ProductModel? bestAlt = alts.isNotEmpty ? alts.first : null;
        needsImprovement.add({'product': p, 'alternative': bestAlt});
      } else {
        goodChoices.add(p);
      }
    }

    final avgScore = (totalScore / items.length).round();

    return {
      'basketScore': avgScore,
      'totalScanned': items.length,
      'avgScore': avgScore,
      'needsImprovement': needsImprovement,
      'goodChoices': goodChoices,
    };
  }
}
