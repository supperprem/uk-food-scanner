// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/history_service.dart';
import '../widgets/scan_button.dart';
import '../widgets/score_card.dart';
import 'scanner_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'barcode_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HistoryService _historyService = HistoryService();
  List<ProductModel> _recentScans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    final scans = await _historyService.getHistory();
    print('HOME HISTORY COUNT: ${scans.length}');
    if (mounted) {
      setState(() {
        _recentScans = scans;
        _isLoading = false;
      });
    }
  }

  void _navigateToScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerScreen()),
    ).then((_) {
      _loadRecentScans();
    });
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    ).then((_) {
      _loadRecentScans();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show only top 3 recent scans on Home screen
    final displayedScans = _recentScans.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF8),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'UK Food Scanner',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToProfile(context),
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            tooltip: 'Profile & Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecentScans,
          color: const Color(0xFF2E7D32),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header & Subtitle
                const Text(
                  'Scan products. Understand ingredients. Make better choices.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Main Scan Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Scan your product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Instant UK nutritional scores & additives check',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ScanButton(
                        onPressed: () => _navigateToScanner(context),
                        label: 'Start Scanning',
                        icon: Icons.camera_alt_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. User Goal Card
                InkWell(
                  onTap: () => _navigateToProfile(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.track_changes,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your goal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Eat healthier',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Recent Scans Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Scans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToHistory(context),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recent Scans List
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      )
                    : displayedScans.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No scans yet. Start scanning products.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedScans.length,
                        itemBuilder: (context, index) {
                          final product = displayedScans[index];
                          return ScoreCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BarcodeResultScreen(product: product),
                                ),
                              ).then((_) => _loadRecentScans());
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
