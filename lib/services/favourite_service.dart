import 'package:hive_flutter/hive_flutter.dart';

import '../models/product_model.dart';
import 'logger_service.dart';

class FavouriteService {
  static const String _boxName = 'favourite_products_box';

  static Future<void> initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
      LoggerService.info(
        'Hive box "$_boxName" opened successfully.',
        'FavouriteService',
      );
    }
  }

  Future<List<ProductModel>> getFavourites() async {
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
              'Error parsing favourite product',
              e,
              stack,
              'FavouriteService',
            );
          }
        }
      }
      return products;
    } catch (e, stack) {
      LoggerService.error(
        'Error getting favourites',
        e,
        stack,
        'FavouriteService',
      );
      return [];
    }
  }

  Future<bool> isFavourite(String barcode) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      return box.containsKey(barcode);
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleFavourite(ProductModel product) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      if (box.containsKey(product.barcode)) {
        await box.delete(product.barcode);
        LoggerService.info(
          'Removed favourite: ${product.barcode}',
          'FavouriteService',
        );
      } else {
        await box.put(product.barcode, product.toJson());
        LoggerService.info(
          'Saved favourite: ${product.barcode}',
          'FavouriteService',
        );
      }
    } catch (e, stack) {
      LoggerService.error(
        'Error toggling favourite',
        e,
        stack,
        'FavouriteService',
      );
    }
  }
}
