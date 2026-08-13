import 'logger_service.dart';

class AnalyticsService {
  static void logAppOpen() {
    LoggerService.info('Event: app_open', 'AnalyticsService');
  }

  static void logScanStarted() {
    LoggerService.info('Event: scan_started', 'AnalyticsService');
  }

  static void logBarcodeDetected(String barcode) {
    LoggerService.info(
      'Event: barcode_detected ($barcode)',
      'AnalyticsService',
    );
  }

  static void logProductFound(String barcode) {
    LoggerService.info('Event: product_found ($barcode)', 'AnalyticsService');
  }

  static void logProductNotFound(String barcode) {
    LoggerService.info(
      'Event: product_not_found ($barcode)',
      'AnalyticsService',
    );
  }

  static void logAlternativeViewed(String productName) {
    LoggerService.info(
      'Event: alternative_viewed ($productName)',
      'AnalyticsService',
    );
  }

  static void logProductSaved(String productName) {
    LoggerService.info(
      'Event: product_saved ($productName)',
      'AnalyticsService',
    );
  }

  static void logShoppingSummaryOpened() {
    LoggerService.info('Event: shopping_summary_opened', 'AnalyticsService');
  }
}
