class ProductModel {
  final String barcode;
  final String name;
  final String brand;
  final List<String> ingredients;
  final double calories; // per 100g
  final double sugar; // per 100g in grams
  final double protein; // per 100g in grams
  final double fat; // per 100g in grams
  final int score; // e.g. 0-100 Nutri-Score / Yuka score equivalent

  const ProductModel({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.ingredients,
    required this.calories,
    required this.sugar,
    required this.protein,
    required this.fat,
    required this.score,
  });

  // Factory constructor for future JSON / API / Firebase integration
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // TODO: Future API integration - parse JSON from Open Food Facts or Firebase backend
    return ProductModel(
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      calories: (json['calories'] ?? 0.0).toDouble(),
      sugar: (json['sugar'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      score: json['score'] ?? 50,
    );
  }

  // Convert product to JSON for local caching or future backend sync
  Map<String, dynamic> toJson() {
    // TODO: Future API integration - serialize to JSON
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'ingredients': ingredients,
      'calories': calories,
      'sugar': sugar,
      'protein': protein,
      'fat': fat,
      'score': score,
    };
  }
}
