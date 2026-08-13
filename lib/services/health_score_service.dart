import 'package:flutter/material.dart';

class HealthScoreResult {
  final int score;
  final String category;
  final Color color;
  final List<String> positiveReasons;
  final List<String> warningReasons;

  const HealthScoreResult({
    required this.score,
    required this.category,
    required this.color,
    required this.positiveReasons,
    required this.warningReasons,
  });
}

class HealthScoreService {
  static HealthScoreResult calculateScore({
    required double sugar, // per 100g
    required double fat, // per 100g
    required double saturatedFat, // per 100g
    required double salt, // per 100g
    required double protein, // per 100g
    required double fibre, // per 100g
    required double calories, // per 100g
  }) {
    int score = 80;
    final List<String> positives = [];
    final List<String> warnings = [];

    // Protein evaluation
    if (protein >= 10.0) {
      score += 10;
      positives.add('High protein');
    } else if (protein >= 5.0) {
      score += 5;
      positives.add('Good source of protein');
    }

    // Fibre evaluation
    if (fibre >= 5.0) {
      score += 10;
      positives.add('High in fibre');
    } else if (fibre >= 3.0) {
      score += 5;
      positives.add('Source of fibre');
    }

    // Sugar evaluation
    if (sugar > 22.5) {
      score -= 25;
      warnings.add('High sugar content');
    } else if (sugar > 10.0) {
      score -= 15;
      warnings.add('Moderate to high sugar');
    } else if (sugar <= 5.0) {
      score += 5;
      positives.add('Low sugar');
    }

    // Saturated Fat evaluation
    if (saturatedFat > 5.0) {
      score -= 20;
      warnings.add('High saturated fat');
    } else if (saturatedFat <= 1.5) {
      positives.add('Low saturated fat');
    }

    // Salt evaluation
    if (salt > 1.5) {
      score -= 20;
      warnings.add('High salt (sodium)');
    } else if (salt <= 0.3) {
      positives.add('Low salt content');
    }

    // Calories penalty for extreme density if not offset
    if (calories > 450 && protein < 5 && fibre < 3) {
      score -= 10;
      warnings.add('High calorie density');
    }

    score = score.clamp(5, 98);

    String category;
    Color color;

    if (score >= 75) {
      category = 'Good Choice';
      color = const Color(0xFF2E7D32); // Green
    } else if (score >= 50) {
      category = 'Average Choice';
      color = const Color(0xFFF57C00); // Orange
    } else {
      category = 'Poor Choice';
      color = const Color(0xFFD32F2F); // Red
    }

    if (positives.isEmpty) {
      positives.add('Standard nutritional profile');
    }
    if (warnings.isEmpty) {
      warnings.add('No major nutritional warnings');
    }

    return HealthScoreResult(
      score: score,
      category: category,
      color: color,
      positiveReasons: positives,
      warningReasons: warnings,
    );
  }
}
