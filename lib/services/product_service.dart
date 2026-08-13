import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import 'logger_service.dart';

class ProductService {
  static const String _boxName = 'scan_history_box';
  static const int maxHistorySize = 500;

  Box get _box => Hive.box(_boxName);

  static Future<void> initHive() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
      LoggerService.info(
        'Hive box "$_boxName" opened successfully.',
        'ProductService',
      );
    }
  }

  Future<List<ProductModel>> getRecentScans() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final rawData = _box.values.toList();
      final List<ProductModel> scans = [];
      final Set<String> seenBarcodes = {};

      for (var item in rawData) {
        if (item is Map) {
          try {
            final product = ProductModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (product.barcode.isNotEmpty &&
                seenBarcodes.add(product.barcode)) {
              scans.add(product);
            }
          } catch (e, stack) {
            LoggerService.error(
              'Error parsing product from Hive',
              e,
              stack,
              'ProductService',
            );
          }
        }
      }

      scans.sort(
        (a, b) => (b.scannedDate ?? DateTime.now()).compareTo(
          a.scannedDate ?? DateTime.now(),
        ),
      );

      if (scans.length > maxHistorySize) {
        final excess = scans.sublist(maxHistorySize);
        for (var p in excess) {
          await _box.delete(p.barcode);
        }
        return scans.sublist(0, maxHistorySize);
      }

      return scans;
    } catch (e, stack) {
      LoggerService.error(
        'Error loading scans from Hive',
        e,
        stack,
        'ProductService',
      );
      return [];
    }
  }

  Future<void> addRecentScan(ProductModel product) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
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
        category: product.category,
        scannedDate: DateTime.now(),
      );
      await _box.put(product.barcode, productWithDate.toJson());
      LoggerService.info(
        'Successfully saved product: ${product.name} (${product.barcode}) to Hive.',
        'ProductService',
      );

      if (_box.length > maxHistorySize) {
        final scans = await getRecentScans();
        if (scans.length > maxHistorySize) {
          for (int i = maxHistorySize; i < scans.length; i++) {
            await _box.delete(scans[i].barcode);
          }
        }
      }
    } catch (e, stack) {
      LoggerService.error(
        'Error saving product to Hive',
        e,
        stack,
        'ProductService',
      );
    }
  }

  Future<void> deleteScan(String barcode) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      await _box.delete(barcode);
      LoggerService.info(
        'Deleted scan with barcode: $barcode',
        'ProductService',
      );
    } catch (e, stack) {
      LoggerService.error('Error deleting scan', e, stack, 'ProductService');
    }
  }

  Future<void> clearAllHistory() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      await _box.clear();
      LoggerService.info('Cleared all scan history.', 'ProductService');
    } catch (e, stack) {
      LoggerService.error('Error clearing history', e, stack, 'ProductService');
    }
  }
}
