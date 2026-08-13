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
  final int score; // e.g. 0-100 Nutri-Score / Yuka score equivalent
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

    // Ingredients
    List<String> ingredients = [];
    if (data['ingredients'] is List) {
      ingredients = (data['ingredients'] as List)
          .map((e) => e.toString())
          .toList();
    } else if (data['ingredients_text'] != null) {
      ingredients = data['ingredients_text']
          .toString()
          .split(',')
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

    // Score
    int score = 50;
    if (data['score'] != null) {
      score = int.tryParse(data['score'].toString()) ?? 50;
    } else {
      final nutriScore = data['nutriscore_grade']?.toString().toLowerCase();
      if (nutriScore == 'a') {
        score = 85;
      } else if (nutriScore == 'b') {
        score = 70;
      } else if (nutriScore == 'c') {
        score = 55;
      } else if (nutriScore == 'd') {
        score = 40;
      } else if (nutriScore == 'e') {
        score = 25;
      } else {
        double penalty = (sugar * 2) + (fat * 1.5);
        score = (90 - penalty).clamp(10, 95).toInt();
      }
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
      'scannedDate': (scannedDate ?? DateTime.now()).toIso8601String(),
    };
  }
}
