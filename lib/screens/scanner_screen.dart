// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/scanner_overlay.dart';
import '../services/product_api_service.dart';
import '../services/product_service.dart';
import '../services/logger_service.dart';
import 'product_detail_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.itf,
    ],
  );

  final ProductApiService _apiService = ProductApiService();
  final ProductService _productService = ProductService();

  bool _isProcessing = false;
  String _scannerStateText = 'Align barcode within frame';
  DateTime? _lastScanTime;

  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -120.0, end: 120.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _isValidBarcode(String code) {
    final len = code.length;
    return len == 8 ||
        len == 12 ||
        len == 13 ||
        len == 14 ||
        (len >= 6 && len <= 8);
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final now = DateTime.now();
    if (_lastScanTime != null &&
        now.difference(_lastScanTime!) < const Duration(milliseconds: 750)) {
      return;
    }

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!.trim();

        if (!_isValidBarcode(code)) {
          LoggerService.warning(
            'Rejected invalid barcode length: $code',
            'ScannerScreen',
          );
          continue;
        }

        HapticFeedback.heavyImpact();

        _lastScanTime = now;
        setState(() {
          _isProcessing = true;
          _scannerStateText = 'Barcode detected! Loading...';
        });

        await _fetchAndOpenProduct(code);
        break;
      }
    }
  }

  Future<void> _fetchAndOpenProduct(String code) async {
    setState(() {
      _scannerStateText = 'Fetching nutritional information...';
    });

    try {
      final product = await _apiService.fetchProduct(code);

      if (!mounted) return;

      if (product != null) {
        await _productService.addRecentScan(product);

        if (!mounted) return;

        setState(() {
          _isProcessing = false;
          _scannerStateText = 'Align barcode within frame';
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });
      } else {
        _showErrorDialog(
          'Product Not Found',
          'We couldn\'t find nutritional information for this barcode ($code).',
        );
      }
    } on ProductApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _scannerStateText = 'Align barcode within frame';
      });
      String title = 'Scanning Error';
      if (e.type == ApiErrorType.noInternet) {
        title = 'No Internet Connection';
      } else if (e.type == ApiErrorType.productNotFound) {
        title = 'Product Not Found';
      } else if (e.type == ApiErrorType.apiFailure) {
        title = 'Server Error';
      } else if (e.type == ApiErrorType.timeout) {
        title = 'Connection Timeout';
      }
      _showErrorDialog(title, e.message);
    } catch (e, stack) {
      LoggerService.error('Unexpected scan error', e, stack, 'ScannerScreen');
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _scannerStateText = 'Align barcode within frame';
      });
      _showErrorDialog(
        'Unexpected Error',
        'An unexpected error occurred while fetching product data. Please check your connection and try again.',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
                _scannerStateText = 'Align barcode within frame';
              });
            },
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
                if (!_isValidBarcode(code)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Invalid barcode length. Must be 8, 12, 13, or 14 digits.',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                setState(() {
                  _isProcessing = true;
                  _scannerStateText = 'Fetching nutritional information...';
                });
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
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 64,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Camera Permission Denied or Unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please grant camera permissions in your device settings or use manual entry below.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showManualEntryDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_outlined),
                        label: const Text('Enter Barcode Manually'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const ScannerOverlay(),
          // Animated Scanning Line Overlay
          Center(
            child: AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _scanAnimation.value),
                  child: Container(
                    width: 240,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF43A047).withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
                'Scan Barcode',
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
          // Bottom scanner state & manual entry button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    _scannerStateText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
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
