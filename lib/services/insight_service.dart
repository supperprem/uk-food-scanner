import '../models/product_model.dart';

class ProductInsight {
  final List<String> positives;
  final List<String> warnings;
  final List<String> suggestions;

  const ProductInsight({
    required this.positives,
    required this.warnings,
    required this.suggestions,
  });
}

class InsightService {
  static ProductInsight generateInsight({
    required ProductModel product,
    required String healthGoal,
    required List<String> allergens,
  }) {
    final List<String> positives = [];
    final List<String> warnings = [];
    final List<String> suggestions = [];

    final goal = healthGoal.toLowerCase();
    final satFat = product.fat * 0.4;

    // Goal-specific rules
    if (goal == 'weight_loss') {
      if (product.sugar < 5.0) {
        positives.add(
          'Low sugar (${product.sugar.toStringAsFixed(1)}g per 100g)',
        );
      }
      if (product.calories < 100.0) {
        positives.add(
          'Low calories (${product.calories.toStringAsFixed(1)} kcal per 100g)',
        );
      }

      if (product.calories > 300.0) {
        warnings.add(
          'High calories (${product.calories.toStringAsFixed(1)} kcal per 100g)',
        );
      }
      if (product.sugar > 15.0) {
        warnings.add(
          'High sugar content (${product.sugar.toStringAsFixed(1)}g per 100g)',
        );
      }

      suggestions.add('Try a lower sugar alternative');
      suggestions.add('Good option for calorie control');
    } else if (goal == 'muscle_gain') {
      if (product.protein >= 10.0) {
        positives.add(
          'High protein (${product.protein.toStringAsFixed(1)}g per 100g)',
        );
      } else {
        warnings.add(
          'Low protein (${product.protein.toStringAsFixed(1)}g per 100g)',
        );
      }

      suggestions.add('Good option after exercise');
      suggestions.add('Pair with complex carbs for optimal muscle recovery');
    } else if (goal == 'family_shopping') {
      if (product.sugar < 10.0) {
        positives.add('Low sugar level');
      }
      if (product.ingredients.length <= 6) {
        positives.add(
          'Simple ingredients (${product.ingredients.length} ingredients)',
        );
      }

      // Check allergens for family
      for (var alg in allergens) {
        final algLower = alg.toLowerCase();
        for (var prodAlg in product.allergens) {
          if (prodAlg.toLowerCase().contains(algLower)) {
            warnings.add('Contains allergen: $prodAlg');
          }
        }
      }

      suggestions.add('Suitable for family sharing');
      suggestions.add('Check allergen warnings before serving');
    } else {
      // Eat healthier (default)
      if (product.sugar < 5.0) {
        positives.add(
          'Low sugar (${product.sugar.toStringAsFixed(1)}g per 100g)',
        );
      }
      if (satFat < 1.5) {
        positives.add(
          'Low saturated fat (${satFat.toStringAsFixed(1)}g per 100g)',
        );
      }
      if (product.protein >= 5.0) {
        positives.add(
          'Good protein source (${product.protein.toStringAsFixed(1)}g per 100g)',
        );
      }

      if (product.sugar > 15.0) {
        warnings.add(
          'High sugar content (${product.sugar.toStringAsFixed(1)}g per 100g)',
        );
      }
      if (satFat > 5.0) {
        warnings.add(
          'High saturated fat level (${satFat.toStringAsFixed(1)}g per 100g)',
        );
      }

      suggestions.add('Balanced nutritional choice for daily meals');
      suggestions.add('Enjoy in moderation as part of a varied diet');
    }

    if (positives.isEmpty) {
      positives.add('Standard nutritional profile');
    }
    if (warnings.isEmpty) {
      warnings.add('No major nutritional warnings for this goal');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Make mindful dietary choices');
    }

    return ProductInsight(
      positives: positives,
      warnings: warnings,
      suggestions: suggestions,
    );
  }
}
