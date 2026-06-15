// lib/data/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  StorageService._();

  static const String _keySpreadsheetUrl = 'spreadsheet_url';

  /// Saves the custom Google Apps Script Web App URL to local storage.
  static Future<void> saveSpreadsheetUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySpreadsheetUrl, url.trim());
  }

  /// Retrieves the saved Google Apps Script Web App URL from local storage.
  /// Falls back to the default constant URL if not set.
  static Future<String> getSpreadsheetUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_keySpreadsheetUrl);
    if (url == null || url.trim().isEmpty) {
      return AppConstants.googleAppsScriptUrl;
    }
    return url.trim();
  }

  /// Deletes the custom URL from local storage.
  static Future<void> clearSpreadsheetUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySpreadsheetUrl);
  }
}
