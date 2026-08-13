import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/score_card.dart';
import 'product_detail_screen.dart';

class RecentScansScreen extends StatefulWidget {
  const RecentScansScreen({super.key});

  @override
  State<RecentScansScreen> createState() => _RecentScansScreenState();
}

class _RecentScansScreenState extends State<RecentScansScreen> {
  final ProductService _productService = ProductService();
  List<ProductModel> _scans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    setState(() => _isLoading = true);
    final scans = await _productService.getRecentScans();
    setState(() {
      _scans = scans;
      _isLoading = false;
    });
  }

  Future<void> _deleteScan(String barcode) async {
    await _productService.deleteScan(barcode);
    _loadScans();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to delete all scan history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _productService.clearAllHistory();
      _loadScans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'All Scan History',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_scans.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              tooltip: 'Clear All History',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              )
            : _scans.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Scan History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Products you scan using the camera or manual entry will appear here.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadScans,
                color: const Color(0xFF2E7D32),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _scans.length,
                  itemBuilder: (context, index) {
                    final product = _scans[index];
                    return Dismissible(
                      key: Key(product.barcode),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) => _deleteScan(product.barcode),
                      child: ScoreCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          ).then((_) => _loadScans());
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
