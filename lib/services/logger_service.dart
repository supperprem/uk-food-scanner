// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';

class LoggerService {
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '[UKFoodScanner]';
      print('$prefix DEBUG: $message');
    }
  }

  static void info(String message, [String? tag]) {
    final prefix = tag != null ? '[$tag]' : '[UKFoodScanner]';
    print('$prefix INFO: $message');
  }

  static void warning(String message, [String? tag]) {
    final prefix = tag != null ? '[$tag]' : '[UKFoodScanner]';
    print('$prefix WARNING: $message');
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    final prefix = tag != null ? '[$tag]' : '[UKFoodScanner]';
    print('$prefix ERROR: $message');
    if (error != null) {
      print('$prefix EXCEPTION: $error');
    }
    if (stackTrace != null && kDebugMode) {
      print('$prefix STACKTRACE:\n$stackTrace');
    }
  }
}
