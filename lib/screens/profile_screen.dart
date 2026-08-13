// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../services/history_service.dart';
import '../services/favourite_service.dart';
import 'favourites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PreferencesService _preferencesService = PreferencesService();
  final HistoryService _historyService = HistoryService();
  final FavouriteService _favouriteService = FavouriteService();

  String _selectedGoal = 'eat_healthier';
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  int _versionTapCount = 0;

  final List<Map<String, String>> _goals = [
    {'id': 'eat_healthier', 'name': 'Eat healthier'},
    {'id': 'weight_loss', 'name': 'Weight loss'},
    {'id': 'muscle_gain', 'name': 'Muscle gain'},
    {'id': 'family_shopping', 'name': 'Family shopping'},
  ];

  final List<Map<String, dynamic>> _allergies = [
    {'id': 'milk', 'name': 'Dairy / Lactose', 'selected': false},
    {'id': 'gluten', 'name': 'Gluten / Wheat', 'selected': false},
    {'id': 'nuts', 'name': 'Nuts / Peanuts', 'selected': false},
    {'id': 'soy', 'name': 'Soy', 'selected': false},
    {'id': 'eggs', 'name': 'Eggs', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final goal = await _preferencesService.getHealthGoal();
    final allergens = await _preferencesService.getAllergens();

    if (mounted) {
      setState(() {
        _selectedGoal = goal;
        for (var allergy in _allergies) {
          allergy['selected'] = allergens.contains(allergy['id']);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _onGoalChanged(String goalId) async {
    setState(() {
      _selectedGoal = goalId;
    });
    await _preferencesService.saveHealthGoal(goalId);
    print('Saved health goal: $goalId');
  }

  Future<void> _onAllergyChanged(String allergyId, bool selected) async {
    setState(() {
      for (var allergy in _allergies) {
        if (allergy['id'] == allergyId) {
          allergy['selected'] = selected;
        }
      }
    });
    await _preferencesService.toggleAllergen(allergyId, selected);
    print('Toggled allergen $allergyId: $selected');
  }

  Future<void> _clearHistoryPrompt() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Scan History'),
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
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan history cleared successfully.')),
      );
    }
  }

  Future<void> _clearFavouritesPrompt() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Saved Products'),
        content: const Text(
          'Are you sure you want to remove all saved products?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final favs = await _favouriteService.getFavourites();
      for (var f in favs) {
        await _favouriteService.toggleFavourite(f);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved products cleared successfully.')),
      );
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'UK Food Scanner',
      applicationVersion: '1.0.0+1',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 32),
      ),
      children: [
        const SizedBox(height: 10),
        const Text(
          'UK Food Scanner helps you scan food items, evaluate UK nutritional scores, detect allergens, and discover healthier alternatives using data provided by Open Food Facts.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        const Text(
          'Data Source:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const Text(
          'Open Food Facts - Open database providing food product data worldwide.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 12),
        const Text(
          'Privacy Explanation:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const Text(
          '• Camera: Used strictly and only for barcode scanning.\n• Data: Stored locally on your device unless you enable future sync features.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
      ],
    );
  }

  void _showDeveloperOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Options (Test Mode)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: const Text('Clear Hive Data'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                await _historyService.clearHistory();
                final favs = await _favouriteService.getFavourites();
                for (var f in favs) {
                  await _favouriteService.toggleFavourite(f);
                }
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('All Hive local data cleared.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.orange),
              title: const Text('Reset Onboarding'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                await _preferencesService.setCompletedOnboarding(false);
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Onboarding reset. Restart app to view.'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cleaning_services, color: Colors.blue),
              title: const Text('Clear Cache'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully.')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
          'Profile & Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User account card header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF2E7D32)
                                .withValues(alpha: 0.15),
                            child: const Icon(
                              Icons.person,
                              size: 36,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UK Food Scanner User',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Preferences Synced & Active',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FavouritesScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 28,
                            ),
                            tooltip: 'View Saved Products',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // User Goal Section
                    const Text(
                      'Primary Health Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tailor your scanner scoring and insights to your objective.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: _goals.map((goal) {
                          final goalId = goal['id']!;
                          final goalName = goal['name']!;
                          final isSelected = _selectedGoal == goalId;
                          return InkWell(
                            onTap: () => _onGoalChanged(goalId),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? const Color(0xFF2E7D32)
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    goalName,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF2E7D32)
                                          : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Allergies Section
                    const Text(
                      'Allergies & Dietary Restrictions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Get instant warnings when scanned products contain your allergens.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allergies.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          final allergy = _allergies[index];
                          final allergyId = allergy['id'] as String;
                          final allergyName = allergy['name'] as String;
                          final isSelected = allergy['selected'] as bool;
                          return CheckboxListTile(
                            title: Text(
                              allergyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: isSelected,
                            activeColor: const Color(0xFF2E7D32),
                            onChanged: (bool? value) {
                              _onAllergyChanged(allergyId, value ?? false);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Settings Section
                    const Text(
                      'Settings & App Data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text(
                              'Push Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: const Text(
                              'Receive nutritional tips and alerts',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            value: _notificationsEnabled,
                            activeTrackColor: const Color(0xFF2E7D32),
                            onChanged: (val) {
                              setState(() => _notificationsEnabled = val);
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(
                              Icons.star_outline,
                              color: Colors.amber,
                            ),
                            title: const Text('View Saved Products'),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FavouritesScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            title: const Text(
                              'Clear Scan History',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: _clearHistoryPrompt,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(
                              Icons.cleaning_services_outlined,
                              color: Colors.red,
                            ),
                            title: const Text(
                              'Clear Saved Products',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: _clearFavouritesPrompt,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(
                              Icons.info_outline,
                              color: Color(0xFF2E7D32),
                            ),
                            title: const Text('About Open Food Facts'),
                            subtitle: const Text(
                              'Open database providing food product data',
                            ),
                            onTap: _showAboutDialog,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          ListTile(
                            leading: const Icon(
                              Icons.phone_android,
                              color: Colors.grey,
                            ),
                            title: const Text('App Version'),
                            trailing: const Text(
                              '1.0.0+1',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _versionTapCount++;
                              });
                              if (_versionTapCount >= 5) {
                                _versionTapCount = 0;
                                _showDeveloperOptionsDialog();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
      ),
    );
  }
}
