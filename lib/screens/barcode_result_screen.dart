// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'product_detail_screen.dart';

class BarcodeResultScreen extends StatelessWidget {
  final ProductModel product;

  const BarcodeResultScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ProductDetailScreen(product: product);
  }
}
