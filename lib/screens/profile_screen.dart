import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User goal state
  String _selectedGoal = 'Eat healthier';
  final List<String> _goals = [
    'Eat healthier',
    'Weight loss',
    'Muscle gain',
    'Family shopping',
  ];

  // Allergies placeholder state
  final List<Map<String, dynamic>> _allergies = [
    {'name': 'Gluten / Wheat', 'selected': false},
    {'name': 'Dairy / Lactose', 'selected': false},
    {'name': 'Nuts / Peanuts', 'selected': true},
    {'name': 'Soy', 'selected': false},
    {'name': 'Eggs', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Profile & Preferences',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                            'Free Account • Version 0.1',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
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
                    final isSelected = _selectedGoal == goal;
                    return RadioListTile<String>(
                      title: Text(
                        goal,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.black87,
                        ),
                      ),
                      value: goal,
                      groupValue: _selectedGoal,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (value) {
                        setState(() {
                          _selectedGoal = value!;
                        });
                        // TODO: Future Firebase sync - save user goal to user profile document
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),

              // Allergies Section Placeholder
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
                'Get alerts when scanned products contain your allergens.',
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
                    return CheckboxListTile(
                      title: Text(
                        allergy['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      value: allergy['selected'],
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (bool? value) {
                        setState(() {
                          _allergies[index]['selected'] = value ?? false;
                        });
                        // TODO: Future Firebase sync - save allergies preference
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 36),

              // Future Firebase / Account Actions Placeholder
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Future Firebase Auth integration - Sign in / Sign out
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Firebase Auth integration coming in Version 0.2!',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(
                      color: Color(0xFF2E7D32),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.cloud_sync_outlined),
                  label: const Text('Sync with Firebase Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
