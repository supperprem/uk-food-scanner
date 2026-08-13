import '../models/product_model.dart';

class ProductConfidence {
  final double score;
  final List<String> available;
  final List<String> missing;

  const ProductConfidence({
    required this.score,
    required this.available,
    required this.missing,
  });
}

class ConfidenceService {
  static ProductConfidence calculateConfidence(ProductModel product) {
    double score = 100.0;
    final List<String> available = [];
    final List<String> missing = [];

    // 1. Ingredients check (-20 if missing)
    if (product.ingredients.isNotEmpty) {
      available.add('Ingredients');
    } else {
      score -= 20.0;
      missing.add('Ingredients information');
    }

    // 2. Nutrition check (-20 if missing)
    bool hasNutrition =
        product.calories > 0 ||
        product.sugar > 0 ||
        product.protein > 0 ||
        product.fat > 0;
    if (hasNutrition) {
      available.add('Nutrition information');
    } else {
      score -= 20.0;
      missing.add('Nutrition information');
    }

    // 3. Allergens check (-15 if missing)
    if (product.allergens.isNotEmpty) {
      available.add('Allergens');
    } else {
      score -= 15.0;
      missing.add('Allergen declarations');
    }

    // 4. Brand check (-10 if missing/unknown)
    if (product.brand.isNotEmpty &&
        product.brand.toLowerCase() != 'unknown brand') {
      available.add('Brand details');
    } else {
      score -= 10.0;
      missing.add('Brand verification');
    }

    // 5. Image check (-10 if missing)
    if (product.imageUrl.isNotEmpty) {
      available.add('Product image');
    } else {
      score -= 10.0;
      missing.add('Product image');
    }

    // 6. Fibre check (-10 if unverified)
    score -= 10.0;
    missing.add('Fibre information');

    score = score.clamp(0.0, 100.0);

    return ProductConfidence(
      score: score,
      available: available,
      missing: missing,
    );
  }
}
