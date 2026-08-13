// ignore_for_file: avoid_print
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
    String healthGoal = 'eat_healthier',
  }) {
    int score = 80;
    final List<String> positives = [];
    final List<String> warnings = [];

    // Protein evaluation (higher bonus for muscle_gain goal)
    if (protein >= 15.0) {
      score += (healthGoal == 'muscle_gain' ? 20 : 12);
      positives.add('High protein (${protein.toStringAsFixed(1)}g per 100g)');
    } else if (protein >= 10.0) {
      score += (healthGoal == 'muscle_gain' ? 15 : 10);
      positives.add(
        'Good protein content (${protein.toStringAsFixed(1)}g per 100g)',
      );
    } else if (protein >= 5.0) {
      score += 5;
      positives.add(
        'Source of protein (${protein.toStringAsFixed(1)}g per 100g)',
      );
    } else {
      warnings.add(
        'Low protein content (${protein.toStringAsFixed(1)}g per 100g)',
      );
    }

    // Fibre evaluation
    if (fibre >= 5.0) {
      score += 10;
      positives.add('High in fibre');
    } else if (fibre >= 3.0) {
      score += 5;
      positives.add('Source of fibre');
    } else {
      warnings.add('Limited fibre information or low fibre');
    }

    // Sugar evaluation (harsher penalty for weight_loss goal)
    if (sugar > 22.5) {
      score -= (healthGoal == 'weight_loss' ? 30 : 25);
      warnings.add(
        'High sugar content (${sugar.toStringAsFixed(1)}g per 100g)',
      );
    } else if (sugar > 10.0) {
      score -= (healthGoal == 'weight_loss' ? 20 : 15);
      warnings.add(
        'Moderate to high sugar (${sugar.toStringAsFixed(1)}g per 100g)',
      );
    } else if (sugar <= 5.0) {
      score += 5;
      positives.add('Low sugar (${sugar.toStringAsFixed(1)}g per 100g)');
    }

    // Saturated Fat evaluation
    if (saturatedFat > 5.0) {
      score -= 20;
      warnings.add(
        'High saturated fat level (${saturatedFat.toStringAsFixed(1)}g per 100g)',
      );
    } else if (saturatedFat <= 1.5) {
      positives.add(
        'Low saturated fat (${saturatedFat.toStringAsFixed(1)}g per 100g)',
      );
    } else {
      warnings.add(
        'Moderate saturated fat (${saturatedFat.toStringAsFixed(1)}g per 100g)',
      );
    }

    // Salt evaluation
    if (salt > 1.5) {
      score -= 20;
      warnings.add(
        'High salt / sodium content (${salt.toStringAsFixed(1)}g per 100g)',
      );
    } else if (salt <= 0.3) {
      positives.add('Low salt content (${salt.toStringAsFixed(1)}g per 100g)');
    }

    // Calories penalty (harsher penalty for weight_loss goal)
    if (calories > 450 && protein < 5 && fibre < 3) {
      score -= (healthGoal == 'weight_loss' ? 20 : 10);
      warnings.add(
        'High calorie density (${calories.toStringAsFixed(1)} kcal per 100g)',
      );
    } else if (healthGoal == 'weight_loss' && calories > 350) {
      score -= 10;
      warnings.add('Elevated calories for weight loss objective');
    } else {
      positives.add(
        'Energy density: ${calories.toStringAsFixed(1)} kcal per 100g',
      );
    }

    score = score.clamp(0, 100);

    print("CALCULATED SCORE (Goal: $healthGoal): $score");

    String category;
    Color color;

    if (score >= 85) {
      category = 'Excellent';
      color = const Color(0xFF2E7D32); // Green
    } else if (score >= 70) {
      category = 'Good';
      color = const Color(0xFF43A047); // Green
    } else if (score >= 50) {
      category = 'Fair';
      color = const Color(0xFF689F38); // Light Green / Olive
    } else if (score >= 30) {
      category = 'Needs Improvement';
      color = const Color(0xFFF57C00); // Orange
    } else {
      category = 'Poor';
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
