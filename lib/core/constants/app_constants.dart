// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  /// Replace this with your deployed Google Apps Script Web App URL.
  /// Steps to get this URL:
  /// 1. Open Google Sheets → Extensions → Apps Script
  /// 2. Paste the Code.gs content
  /// 3. Deploy → New Deployment → Web App
  /// 4. Set "Who has access" to "Anyone"
  /// 5. Copy the Web App URL here
  static const String googleAppsScriptUrl =
      'https://script.google.com/macros/s/YOUR_SCRIPT_ID/exec';

  static const String appName = 'SkripsiScan';
  static const String appVersion = '1.0.0';

  // OCR Processing
  static const int maxBatchSize = 20;
  static const Duration ocrTimeout = Duration(seconds: 30);

  // UI
  static const double defaultPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
}
