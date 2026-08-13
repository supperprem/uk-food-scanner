import 'package:flutter/material.dart';

import 'screens/main_shell_screen.dart';
import 'services/product_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProductService.initHive();
  runApp(const UKFoodScannerApp());
}

class UKFoodScannerApp extends StatelessWidget {
  const UKFoodScannerApp({super.key});

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
        fontFamily: 'Roboto', // Default material font, can be customized
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
      home: const MainShellScreen(),
    );
  }
}
