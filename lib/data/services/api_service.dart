// lib/data/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/thesis_model.dart';

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
      final payload = jsonEncode(thesis.toApiPayload());

      var response = await _client
          .post(
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
        return ApiResult(
          success: true,
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
      final payload = jsonEncode({
        'batch': theses.map((t) => t.toApiPayload()).toList(),
      });

      var response = await _client
          .post(
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
        return ApiResult(
          success: true,
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
