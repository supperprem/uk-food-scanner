// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ScoreCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ScoreCard({super.key, required this.product, this.onTap});

  Color _getScoreColor(int score) {
    if (score >= 85) {
      return const Color(0xFF2E7D32); // Excellent
    }
    if (score >= 70) {
      return const Color(0xFF43A047); // Good
    }
    if (score >= 50) {
      return const Color(0xFF689F38); // Fair
    }
    if (score >= 30) {
      return const Color(0xFFF57C00); // Needs Improvement
    }
    return const Color(0xFFD32F2F); // Poor
  }

  @override
  Widget build(BuildContext context) {
    print("DISPLAYING SAVED SCORE: ${product.score}");
    final scoreColor = _getScoreColor(product.score);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Product Image / Thumbnail with rounded corners
                Hero(
                  tag: 'product_image_${product.barcode}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.fastfood_outlined,
                                    color: Color(0xFF2E7D32),
                                    size: 26,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.fastfood_outlined,
                            color: Color(0xFF2E7D32),
                            size: 26,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Product Name & Brand (clutter-free feed design)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Health Score & Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scoreColor, width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${product.score}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
