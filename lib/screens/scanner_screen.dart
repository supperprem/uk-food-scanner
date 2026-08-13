import 'package:flutter/material.dart';

import '../widgets/scan_button.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();

    return Scaffold(
      backgroundColor: const Color(
        0xFF1E2923,
      ), // Darker immersive mode for scanner placeholder
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scanner view finder simulation box
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF43A047), width: 3),
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 96,
                      color: Color(0xFF43A047),
                    ),
                    // Corner accents
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white, width: 3),
                            left: BorderSide(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white, width: 3),
                            right: BorderSide(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white, width: 3),
                            left: BorderSide(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white, width: 3),
                            right: BorderSide(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Ready to scan your product',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Align barcode within the frame to automatically retrieve UK product nutrition & ingredients.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ScanButton(
                onPressed: () async {
                  // TODO: Future camera / barcode scanner integration (e.g. mobile_scanner or flutter_barcode_scanner)
                  // For MVP 0.1 simulation, simulate scanning a product and adding to recent scans
                  final simulatedProduct = const ProductModel(
                    barcode: '5000184055271',
                    name: 'British Semi-Skimmed Milk',
                    brand: 'M&S',
                    ingredients: ['Semi-Skimmed Milk'],
                    calories: 48.0,
                    sugar: 4.8,
                    protein: 3.6,
                    fat: 1.8,
                    score: 82,
                  );
                  productService.addRecentScan(simulatedProduct);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Successfully scanned M&S British Semi-Skimmed Milk!',
                      ),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                  Navigator.pop(context);
                },
                label: 'Start Scan',
                icon: Icons.camera,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
