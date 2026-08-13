// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/health_score_service.dart';
import '../services/history_service.dart';

class BarcodeResultScreen extends StatelessWidget {
  final ProductModel product;

  const BarcodeResultScreen({super.key, required this.product});

  Color _getScoreColor(int score) {
    if (score >= 75) return const Color(0xFF2E7D32); // Excellent / Green
    if (score >= 60) return const Color(0xFF689F38); // Good / Light Green
    if (score >= 40) return const Color(0xFFF57C00); // Average / Orange
    return const Color(0xFFD32F2F); // Poor / Red
  }

  String _getScoreCategory(int score) {
    if (score >= 75) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Average';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    print('Saving product to history: ${product.name}');
    // Automatically save scan to local history via SharedPreferences
    HistoryService().saveScan(product);

    final healthResult = HealthScoreService.calculateScore(
      sugar: product.sugar,
      fat: product.fat,
      saturatedFat: product.fat * 0.4,
      salt: 0.5,
      protein: product.protein,
      fibre: 2.0,
      calories: product.calories,
    );

    final scoreColor = _getScoreColor(healthResult.score);
    final category = _getScoreCategory(healthResult.score);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Nutrition Analysis',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Header Card
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.fastfood,
                                      color: Color(0xFF2E7D32),
                                      size: 28,
                                    ),
                              ),
                            )
                          : const Icon(
                              Icons.fastfood,
                              color: Color(0xFF2E7D32),
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.brand,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Barcode: ${product.barcode}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Yuka-Inspired Circular Health Score Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scoreColor.withValues(alpha: 0.1),
                            border: Border.all(color: scoreColor, width: 4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${healthResult.score}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                              const Text(
                                '/100',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: scoreColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Health Score',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                healthResult.category,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Positive Factors Section
              if (healthResult.positiveReasons.isNotEmpty) ...[
                const Text(
                  'Positive Factors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: healthResult.positiveReasons.map((reason) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF2E7D32),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Warning Factors Section
              if (healthResult.warningReasons.isNotEmpty) ...[
                const Text(
                  'Nutritional Warnings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: healthResult.warningReasons.map((warning) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                warning,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Nutrition Analysis Cards (Energy, Sugar, Protein, Fat, Salt, Saturated Fat)
              const Text(
                'Nutrition Analysis (per 100g)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildNutritionBar(
                      'Energy',
                      '${product.calories.toInt()} kcal',
                      product.calories / 500,
                      Colors.orange,
                    ),
                    const Divider(height: 20),
                    _buildNutritionBar(
                      'Sugars',
                      '${product.sugar}g',
                      product.sugar / 25,
                      product.sugar > 10 ? Colors.red : Colors.green,
                      rating: product.sugar > 10 ? 'High' : 'Low',
                    ),
                    const Divider(height: 20),
                    _buildNutritionBar(
                      'Protein',
                      '${product.protein}g',
                      product.protein / 20,
                      Colors.blue,
                      rating: product.protein >= 10 ? 'High' : 'Moderate',
                    ),
                    const Divider(height: 20),
                    _buildNutritionBar(
                      'Fat',
                      '${product.fat}g',
                      product.fat / 30,
                      product.fat > 17.5 ? Colors.orange : Colors.green,
                      rating: product.fat > 17.5 ? 'High' : 'Low',
                    ),
                    const Divider(height: 20),
                    _buildNutritionBar(
                      'Saturated Fat',
                      '${(product.fat * 0.4).toStringAsFixed(1)}g',
                      (product.fat * 0.4) / 10,
                      Colors.orange,
                      rating: 'Moderate',
                    ),
                    const Divider(height: 20),
                    _buildNutritionBar(
                      'Salt',
                      '0.5g',
                      0.5 / 2,
                      Colors.green,
                      rating: 'Low',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Expandable "How we calculate this score" section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ExpansionTile(
                  title: const Text(
                    'How we calculate this score',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  leading: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2E7D32),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        'Our health score is calculated using UK nutritional guidelines based on 100g of product. Points are awarded for positive nutritional elements such as high protein and fibre, while points are deducted for excessive sugar, saturated fat, sodium (salt), and calorie density.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionBar(
    String label,
    String value,
    double progress,
    Color color, {
    String? rating,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                if (rating != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rating,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
