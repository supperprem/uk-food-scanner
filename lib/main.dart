import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/main_shell_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/product_service.dart';
import 'services/preferences_service.dart';
import 'services/analytics_service.dart';
import 'services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash reporting & error capture configuration
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    LoggerService.error(
      'Flutter Framework Error',
      details.exception,
      details.stack,
      'Crashlytics',
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.error('Uncaught Async Error', error, stack, 'Crashlytics');
    return true;
  };

  await ProductService.initHive();
  AnalyticsService.logAppOpen();

  final bool completedOnboarding = await PreferencesService()
      .hasCompletedOnboarding();
  runApp(UKFoodScannerApp(completedOnboarding: completedOnboarding));
}

class UKFoodScannerApp extends StatelessWidget {
  final bool completedOnboarding;

  const UKFoodScannerApp({super.key, this.completedOnboarding = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UK Food Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF43A047),
          surface: const Color(0xFFF8FAF8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAF8),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: completedOnboarding
          ? const MainShellScreen()
          : const OnboardingScreen(),
    );
  }
}
