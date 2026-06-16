// lib/data/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/thesis_model.dart';
import 'storage_service.dart';

class ApiResult {
  final bool success;
  final String message;
  final dynamic data;

  const ApiResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class ApiService {
  ApiService._();

  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  final _client = http.Client();

  /// Sends a single thesis record to the Google Apps Script endpoint.
  Future<ApiResult> sendThesis(ThesisModel thesis) async {
    try {
      final Map<String, dynamic> payloadMap = thesis.toApiPayload();
      final urlString = await StorageService.getSpreadsheetUrl();
      
      // KETERANGAN (Perbaikan Bug): 
      // Jika user mengatur URL Google Spreadsheet kustom di Pengaturan, masukkan ke payload.
      // Jangan melakukan POST langsung ke URL Google Spreadsheet kustom karena akan memicu error.
      // Kirim POST tetap ke Web App Google Apps Script bawaan (AppConstants.googleAppsScriptUrl).
      if (urlString.contains('docs.google.com/spreadsheets')) {
        payloadMap['spreadsheetUrl'] = urlString;
      }
      
      final payload = jsonEncode(payloadMap);

      var response = await _client
          .post(
            // Selalu lakukan POST ke perantara Web App Apps Script bawaan
            Uri.parse(AppConstants.googleAppsScriptUrl),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 302 || response.statusCode == 301 || response.statusCode == 303) {
        final location = response.headers['location'];
        if (location != null) {
          response = await _client.get(Uri.parse(location)).timeout(const Duration(seconds: 20));
        }
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>?;
        final status = body?['status'] as String? ?? 'success';
        return ApiResult(
          success: status == 'success',
          message: body?['message'] as String? ?? 'Data saved successfully.',
          data: body,
        );
      } else {
        return ApiResult(
          success: false,
          message: 'Server returned status ${response.statusCode}.',
        );
      }
    } on Exception catch (e) {
      debugPrint('[ApiService] sendThesis error: $e');
      return ApiResult(success: false, message: e.toString());
    }
  }

  /// Sends multiple thesis records in one batch POST request.
  Future<ApiResult> sendBatch(List<ThesisModel> theses) async {
    try {
      final urlString = await StorageService.getSpreadsheetUrl();
      final Map<String, dynamic> payloadMap = {
        'batch': theses.map((t) => t.toApiPayload()).toList(),
      };
      
      // KETERANGAN (Perbaikan Bug):
      // Jika user mengatur URL Google Spreadsheet kustom di Pengaturan, masukkan ke payload batch.
      // Kirim POST tetap ke Web App Google Apps Script bawaan (AppConstants.googleAppsScriptUrl).
      if (urlString.contains('docs.google.com/spreadsheets')) {
        payloadMap['spreadsheetUrl'] = urlString;
      }

      final payload = jsonEncode(payloadMap);

      var response = await _client
          .post(
            // Selalu lakukan POST ke perantara Web App Apps Script bawaan
            Uri.parse(AppConstants.googleAppsScriptUrl),
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 302 || response.statusCode == 301 || response.statusCode == 303) {
        final location = response.headers['location'];
        if (location != null) {
          response = await _client.get(Uri.parse(location)).timeout(const Duration(seconds: 30));
        }
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>?;
        final status = body?['status'] as String? ?? 'success';
        return ApiResult(
          success: status == 'success',
          message: body?['message'] as String? ?? 'Batch saved successfully.',
          data: body,
        );
      } else {
        return ApiResult(
          success: false,
          message: 'Server returned status ${response.statusCode}.',
        );
      }
    } on Exception catch (e) {
      debugPrint('[ApiService] sendBatch error: $e');
      return ApiResult(success: false, message: e.toString());
    }
  }

  void dispose() => _client.close();
}
