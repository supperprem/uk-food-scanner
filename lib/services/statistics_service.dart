// ignore_for_file: avoid_print
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import 'history_service.dart';

class StatisticsService {
  static const String _boxName = 'scan_statistics_box';

  static Future<void> initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  // Compute statistics dynamically from history service or local box
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final HistoryService historyService = HistoryService();
      final scans = await historyService.getHistory();

      if (scans.isEmpty) {
        return {
          'totalScans': 0,
          'avgScore': 0,
          'avgSugar': 0.0,
          'avgCalories': 0.0,
          'avgProtein': 0.0,
          'topChoices': <ProductModel>[],
          'categories': <String, int>{},
        };
      }

      int totalScans = scans.length;
      double totalScore = 0;
      double totalSugar = 0;
      double totalCalories = 0;
      double totalProtein = 0;
      final Map<String, int> categories = {};

      for (var p in scans) {
        totalScore += p.score;
        totalSugar += p.sugar;
        totalCalories += p.calories;
        totalProtein += p.protein;

        // Categorize based on category name or keywords
        String cat = p.category.isNotEmpty ? p.category : 'General';
        if (cat == 'Excellent' ||
            cat == 'Good' ||
            cat == 'Fair' ||
            cat == 'Poor' ||
            cat == 'Needs Improvement') {
          // Determine food category from name/brand if category is score grade
          final nameL = p.name.toLowerCase();
          if (nameL.contains('milk') ||
              nameL.contains('cheese') ||
              nameL.contains('yogurt')) {
            cat = 'Dairy';
          } else if (nameL.contains('cola') ||
              nameL.contains('drink') ||
              nameL.contains('juice') ||
              nameL.contains('tea')) {
            cat = 'Drinks';
          } else if (nameL.contains('chocolate') ||
              nameL.contains('crisps') ||
              nameL.contains('snack') ||
              nameL.contains('biscuit')) {
            cat = 'Snacks';
          } else if (nameL.contains('bread') ||
              nameL.contains('cereal') ||
              nameL.contains('oats')) {
            cat = 'Bakery & Cereal';
          } else {
            cat = 'Groceries';
          }
        }

        categories[cat] = (categories[cat] ?? 0) + 1;
      }

      final avgScore = (totalScore / totalScans).round();
      final avgSugar = totalSugar / totalScans;
      final avgCalories = totalCalories / totalScans;
      final avgProtein = totalProtein / totalScans;

      // Top 3 highest scoring products
      final sortedScans = List<ProductModel>.from(scans);
      sortedScans.sort((a, b) => b.score.compareTo(a.score));
      final topChoices = sortedScans.take(3).toList();

      return {
        'totalScans': totalScans,
        'avgScore': avgScore,
        'avgSugar': avgSugar,
        'avgCalories': avgCalories,
        'avgProtein': avgProtein,
        'topChoices': topChoices,
        'categories': categories,
      };
    } catch (e) {
      print('Error computing statistics: $e');
      return {
        'totalScans': 0,
        'avgScore': 0,
        'avgSugar': 0.0,
        'avgCalories': 0.0,
        'avgProtein': 0.0,
        'topChoices': <ProductModel>[],
        'categories': <String, int>{},
      };
    }
  }
}
