import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductApiService {
  // Fetch product from Open Food Facts API v2
  Future<ProductModel?> fetchProduct(String barcode) async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Check if status is 1 (product found)
        final status = data['status'];
        if (status == 1 || status == '1' || data['product'] != null) {
          return ProductModel.fromJson(data);
        }
      }
      return null; // Product not found or error status
    } catch (e) {
      // Handle network errors, timeouts, etc.
      return null;
    }
  }
}
