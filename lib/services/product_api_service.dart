import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import 'logger_service.dart';

class ProductApiException implements Exception {
  final String message;
  final ApiErrorType type;
  ProductApiException(this.message, this.type);

  @override
  String toString() => message;
}

enum ApiErrorType { noInternet, apiFailure, productNotFound, timeout }

class ProductApiService {
  Future<ProductModel?> fetchProduct(String barcode) async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        if (status == 1 || status == '1' || data['product'] != null) {
          return ProductModel.fromJson(data);
        } else {
          LoggerService.warning(
            'Product not found for barcode: $barcode',
            'ProductApiService',
          );
          throw ProductApiException(
            'Product not found in Open Food Facts database.',
            ApiErrorType.productNotFound,
          );
        }
      } else {
        LoggerService.error(
          'API failure with status code: ${response.statusCode}',
          null,
          null,
          'ProductApiService',
        );
        throw ProductApiException(
          'Server error (${response.statusCode}). Please try again later.',
          ApiErrorType.apiFailure,
        );
      }
    } on SocketException catch (e, stack) {
      LoggerService.error(
        'No internet connection',
        e,
        stack,
        'ProductApiService',
      );
      throw ProductApiException(
        'No internet connection. Please check your network and try again.',
        ApiErrorType.noInternet,
      );
    } catch (e, stack) {
      if (e is ProductApiException) rethrow;
      LoggerService.error(
        'Network timeout or unexpected error',
        e,
        stack,
        'ProductApiService',
      );
      throw ProductApiException(
        'Network timeout or error connecting to Open Food Facts.',
        ApiErrorType.timeout,
      );
    }
  }
}
