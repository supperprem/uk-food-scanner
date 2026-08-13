import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyHealthGoal = 'health_goal';
  static const String _keyAllergens = 'user_allergens';
  static const String _keyOnboarding = 'has_completed_onboarding';

  // Save health goal
  Future<void> saveHealthGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHealthGoal, goal);
  }

  // Get health goal (default 'eat_healthier')
  Future<String> getHealthGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyHealthGoal) ?? 'eat_healthier';
  }

  // Save allergens list
  Future<void> saveAllergens(List<String> allergens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyAllergens, allergens);
  }

  // Get allergens list (default common ones or empty)
  Future<List<String>> getAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyAllergens) ?? [];
  }

  // Toggle individual allergen
  Future<List<String>> toggleAllergen(String allergen, bool selected) async {
    final current = await getAllergens();
    final normalized = allergen.toLowerCase();
    List<String> updated = List.from(current);
    if (selected) {
      if (!updated.contains(normalized)) {
        updated.add(normalized);
      }
    } else {
      updated.remove(normalized);
    }
    await saveAllergens(updated);
    return updated;
  }

  // Check if product allergens conflict with user preferences
  Future<List<String>> getConflictingAllergens(
    List<String> productAllergens,
  ) async {
    final userAllergens = await getAllergens();
    List<String> conflicts = [];

    for (var prodAlg in productAllergens) {
      final prodAlgLower = prodAlg.toLowerCase();
      for (var userAlg in userAllergens) {
        if (prodAlgLower.contains(userAlg) || userAlg.contains(prodAlgLower)) {
          conflicts.add(prodAlg);
          break;
        }
      }
    }
    return conflicts;
  }

  // Onboarding status
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  Future<void> setCompletedOnboarding(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, completed);
  }
}
