import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/scanner_overlay.dart';
import '../services/product_api_service.dart';
import '../services/product_service.dart';
import 'barcode_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  final ProductApiService _apiService = ProductApiService();
  final ProductService _productService = ProductService();
  bool _isScanned = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isScanned || _isLoading) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        await _fetchAndOpenProduct(code);
        break;
      }
    }
  }

  Future<void> _fetchAndOpenProduct(String code) async {
    setState(() {
      _isScanned = true;
      _isLoading = true;
    });

    final product = await _apiService.fetchProduct(code);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (product != null) {
      // Save to Hive scan history explicitly before navigating
      await _productService.addRecentScan(product);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BarcodeResultScreen(product: product),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isScanned = false;
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product not found ($code). You can add it later.'),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 3),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isScanned = false;
          });
        }
      });
    }
  }

  void _showManualEntryDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Barcode Manually'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'e.g. 5000112637952',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                await _fetchAndOpenProduct(code);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Scanner View
          MobileScanner(controller: _controller, onDetect: _handleBarcode),
          // Viewfinder Overlay
          const ScannerOverlay(),
          // Top AppBar / Header overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Scan UK Food Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _controller.toggleTorch(),
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  tooltip: 'Toggle Flash',
                ),
                IconButton(
                  onPressed: () => _controller.switchCamera(),
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  tooltip: 'Switch Camera',
                ),
              ],
            ),
          ),
          // Loading Indicator Overlay when fetching API
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF43A047)),
                    SizedBox(height: 16),
                    Text(
                      'Fetching product from Open Food Facts...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Bottom instructions & Manual Entry Button
          if (!_isLoading)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  const Text(
                    'Align barcode within frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fetching live nutritional scores & ingredients',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showManualEntryDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_outlined),
                      label: const Text('Enter Barcode Manually'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
