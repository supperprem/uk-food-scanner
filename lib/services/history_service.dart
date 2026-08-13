import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import 'logger_service.dart';

class HistoryService {
  static const String _boxName = 'scan_history_box';
  static const int maxHistorySize = 500;

  static Future<void> initHive() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
      LoggerService.info(
        'Hive box "$_boxName" opened successfully.',
        'HistoryService',
      );
    }
  }

  Future<List<ProductModel>> getHistory() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      final rawData = box.values.toList();
      final List<ProductModel> products = [];
      final Set<String> seenBarcodes = {};

      for (var item in rawData) {
        if (item is Map) {
          try {
            final product = ProductModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (product.barcode.isNotEmpty &&
                seenBarcodes.add(product.barcode)) {
              products.add(product);
            }
          } catch (e, stack) {
            LoggerService.error(
              'Product conversion error in history',
              e,
              stack,
              'HistoryService',
            );
          }
        }
      }

      // Sort by latest scanned date
      products.sort(
        (a, b) => (b.scannedDate ?? DateTime.now()).compareTo(
          a.scannedDate ?? DateTime.now(),
        ),
      );

      // Enforce max history size limit (500 items)
      if (products.length > maxHistorySize) {
        final excess = products.sublist(maxHistorySize);
        for (var p in excess) {
          await box.delete(p.barcode);
        }
        return products.sublist(0, maxHistorySize);
      }

      return products;
    } catch (e, stack) {
      LoggerService.error('Error getting history', e, stack, 'HistoryService');
      return [];
    }
  }

  Future<void> saveScan(ProductModel product) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);

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

      await box.put(product.barcode, productWithDate.toJson());
      LoggerService.info(
        'Successfully saved scan: ${product.barcode}',
        'HistoryService',
      );

      // Check max size
      if (box.length > maxHistorySize) {
        final currentHistory = await getHistory();
        if (currentHistory.length > maxHistorySize) {
          for (int i = maxHistorySize; i < currentHistory.length; i++) {
            await box.delete(currentHistory[i].barcode);
          }
        }
      }
    } catch (e, stack) {
      LoggerService.error('Error saving scan', e, stack, 'HistoryService');
    }
  }

  Future<void> deleteScan(String barcode) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      await box.delete(barcode);
      LoggerService.info(
        'Deleted scan with barcode: $barcode',
        'HistoryService',
      );
    } catch (e, stack) {
      LoggerService.error('Error deleting scan', e, stack, 'HistoryService');
    }
  }

  Future<void> clearHistory() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      await box.clear();
      LoggerService.info('Cleared all history', 'HistoryService');
    } catch (e, stack) {
      LoggerService.error('Error clearing history', e, stack, 'HistoryService');
    }
  }
}
