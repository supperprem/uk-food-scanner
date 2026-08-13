import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';

class ProductService {
  static const String _boxName = 'scan_history_box';

  // Get Hive box instance
  Box get _box => Hive.box(_boxName);

  // Initialize Hive and open box
  static Future<void> initHive() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
      debugPrint('[ProductService] Hive box "$_boxName" opened successfully.');
    }
  }

  // Fetch recent scans from Hive local database
  Future<List<ProductModel>> getRecentScans() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final rawData = _box.values.toList();
      debugPrint('[ProductService] Loaded ${rawData.length} scans from Hive.');
      final List<ProductModel> scans = [];
      for (var item in rawData) {
        if (item is Map) {
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(item);
          scans.add(ProductModel.fromJson(jsonMap));
        }
      }
      // Sort by scannedDate descending (newest first)
      scans.sort(
        (a, b) => (b.scannedDate ?? DateTime.now()).compareTo(
          a.scannedDate ?? DateTime.now(),
        ),
      );
      return scans;
    } catch (e) {
      debugPrint('[ProductService] Error loading scans from Hive: $e');
      return [];
    }
  }

  // Add product to recent scans in Hive local database
  Future<void> addRecentScan(ProductModel product) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      // Use barcode as key so duplicates update to top
      final productWithDate = ProductModel(
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
        score: product.score,
        scannedDate: DateTime.now(),
      );
      await _box.put(product.barcode, productWithDate.toJson());
      debugPrint(
        '[ProductService] Successfully saved product: ${product.name} (${product.barcode}) to Hive.',
      );
    } catch (e) {
      debugPrint('[ProductService] Error saving product to Hive: $e');
    }
  }

  // Delete a specific scan by barcode
  Future<void> deleteScan(String barcode) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      await _box.delete(barcode);
      debugPrint('[ProductService] Deleted scan with barcode: $barcode');
    } catch (e) {
      debugPrint('[ProductService] Error deleting scan: $e');
    }
  }

  // Clear all scan history
  Future<void> clearAllHistory() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      await _box.clear();
      debugPrint('[ProductService] Cleared all scan history.');
    } catch (e) {
      debugPrint('[ProductService] Error clearing history: $e');
    }
  }
}
