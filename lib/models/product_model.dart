import '../services/health_score_service.dart';

class ProductModel {
  final String barcode;
  final String name;
  final String brand;
  final String imageUrl;
  final List<String> ingredients;
  final double calories; // per 100g
  final double sugar; // per 100g in grams
  final double protein; // per 100g in grams
  final double fat; // per 100g in grams
  final List<String> allergens;
  final int score; // e.g. 0-100
  final String category; // e.g. Excellent, Good, Fair, Needs Improvement, Poor
  final DateTime? scannedDate;

  const ProductModel({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.ingredients,
    required this.calories,
    required this.sugar,
    required this.protein,
    required this.fat,
    required this.allergens,
    required this.score,
    required this.category,
    this.scannedDate,
  });

  // Factory constructor robustly handling both Hive stored format and Open Food Facts API JSON structure
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final data = json['product'] is Map ? json['product'] : json;

    final String barcode =
        data['code']?.toString() ?? data['barcode']?.toString() ?? '';
    final String name =
        data['product_name']?.toString() ??
        data['name']?.toString() ??
        'Unknown Product';
    final String brand =
        data['brands']?.toString() ??
        data['brand']?.toString() ??
        'Unknown Brand';
    final String imageUrl =
        data['image_front_url']?.toString() ??
        data['image_url']?.toString() ??
        data['imageUrl']?.toString() ??
        '';

    // Ingredients parsing supporting Format 1 (list of maps), Format 2 (list of strings), Format 3 (ingredients_text)
    List<String> ingredients = [];
    if (data['ingredients'] is List) {
      for (var item in (data['ingredients'] as List)) {
        if (item is Map) {
          final text = item['text'] ?? item['name'] ?? item['id'];
          if (text != null) {
            String cleanText = text.toString();
            if (cleanText.startsWith('en:')) {
              cleanText = cleanText.replaceFirst('en:', '');
            }
            cleanText = cleanText.replaceAll('-', ' ').trim();
            if (cleanText.isNotEmpty && !cleanText.startsWith('ciqual')) {
              ingredients.add(cleanText);
            }
          }
        } else if (item is String) {
          String cleanText = item;
          if (cleanText.startsWith('{') && cleanText.contains('text:')) {
            final match = RegExp(r'text:\s*([^,}]+)').firstMatch(cleanText);
            if (match != null) {
              cleanText = match.group(1)?.trim() ?? cleanText;
            }
          }
          if (cleanText.startsWith('en:')) {
            cleanText = cleanText.replaceFirst('en:', '');
          }
          cleanText = cleanText.replaceAll('-', ' ').trim();
          if (cleanText.isNotEmpty && !cleanText.contains('ciqual_proxy')) {
            ingredients.add(cleanText);
          }
        }
      }
    } else if (data['ingredients_text'] != null) {
      ingredients = data['ingredients_text']
          .toString()
          .split(',')
          .map((e) => e.trim())
          .map(
            (e) => e.replaceAll(
              RegExp(r'(_)?id:en:[^,\s]+', caseSensitive: false),
              '',
            ),
          )
          .map(
            (e) => e.replaceAll(RegExp(r'ciqual_proxy_food_code:[^\s,]+'), ''),
          )
          .map((e) => e.replaceAll(RegExp(r'[{}]'), ''))
          .map((e) => e.replaceAll(RegExp(r'text:'), ''))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Nutriments / Numeric values
    final nutriments = data['nutriments'] is Map ? data['nutriments'] : {};
    double parseNum(dynamic val, [double fallback = 0.0]) {
      if (val == null) return fallback;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? fallback;
    }

    final double calories = parseNum(
      data['calories'] ??
          nutriments['energy-kcal_100g'] ??
          nutriments['energy-kcal'] ??
          nutriments['energy'],
    );
    final double sugar = parseNum(
      data['sugar'] ?? nutriments['sugars_100g'] ?? nutriments['sugars'],
    );
    final double protein = parseNum(
      data['protein'] ?? nutriments['proteins_100g'] ?? nutriments['proteins'],
    );
    final double fat = parseNum(
      data['fat'] ?? nutriments['fat_100g'] ?? nutriments['fat'],
    );

    // Allergens
    List<String> allergens = [];
    if (data['allergens'] is List) {
      allergens = (data['allergens'] as List).map((e) => e.toString()).toList();
    } else if (data['allergens_tags'] is List) {
      allergens = (data['allergens_tags'] as List)
          .map(
            (e) => e
                .toString()
                .replaceAll('en:', '')
                .replaceAll('-', ' ')
                .toUpperCase(),
          )
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (data['allergens'] != null) {
      allergens = data['allergens']
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Calculate score & category using HealthScoreService if not provided
    int score = 50;
    String category = 'Fair';

    if (data['score'] != null && data['category'] != null) {
      score = int.tryParse(data['score'].toString()) ?? 50;
      category = data['category'].toString();
    } else {
      final healthRes = HealthScoreService.calculateScore(
        sugar: sugar,
        fat: fat,
        saturatedFat: fat * 0.4,
        salt: 0.5,
        protein: protein,
        fibre: 2.0,
        calories: calories,
      );
      score = healthRes.score;
      category = healthRes.category;
    }

    // Scanned Date
    DateTime? scannedDate;
    if (data['scannedDate'] != null) {
      scannedDate = DateTime.tryParse(data['scannedDate'].toString());
    }

    return ProductModel(
      barcode: barcode,
      name: name,
      brand: brand,
      imageUrl: imageUrl,
      ingredients: ingredients,
      calories: calories,
      sugar: sugar,
      protein: protein,
      fat: fat,
      allergens: allergens,
      score: score,
      category: category,
      scannedDate: scannedDate ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'calories': calories,
      'sugar': sugar,
      'protein': protein,
      'fat': fat,
      'allergens': allergens,
      'score': score,
      'category': category,
      'scannedDate': (scannedDate ?? DateTime.now()).toIso8601String(),
    };
  }
}
