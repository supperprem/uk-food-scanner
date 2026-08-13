// ignore_for_file: avoid_print
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';

class HistoryService {
  static const String _boxName = 'scan_history_box';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
      print('[HistoryService] Hive box "$_boxName" opened successfully.');
    }
  }

  Future<List<ProductModel>> getHistory() async {
    try {
      print('Loading history');
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);

      print("HIVE BOX LENGTH: ${box.length}");
      for (var item in box.values) {
        print("HIVE ITEM: $item");
      }

      final rawData = box.values.toList();
      print('History found: ${rawData.length} items');
      final List<ProductModel> products = [];
      for (var item in rawData) {
        if (item is Map) {
          try {
            final product = ProductModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            products.add(product);
          } catch (e, stack) {
            print("PRODUCT CONVERSION ERROR: $e");
            print(stack);
          }
        }
      }
      products.sort(
        (a, b) => (b.scannedDate ?? DateTime.now()).compareTo(
          a.scannedDate ?? DateTime.now(),
        ),
      );
      print("RETURNING HISTORY COUNT: ${products.length}");
      return products;
    } catch (e) {
      print('History found: 0 items');
      print("RETURNING HISTORY COUNT: 0");
      return [];
    }
  }

  Future<void> saveScan(ProductModel product) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      final currentHistory = await getHistory();
      print('History before save: ${currentHistory.length} items');
      print('Saving item: ${product.barcode}');

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

      await box.put(product.barcode, productWithDate.toJson());
      print('History saved successfully');
    } catch (e) {
      print('Error saving to Hive: $e');
    }
  }

  Future<void> deleteScan(String barcode) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      await box.delete(barcode);
      print('Deleted scan with barcode: $barcode');
    } catch (e) {
      print('Error deleting scan: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      await box.clear();
      print('Cleared all history');
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}
