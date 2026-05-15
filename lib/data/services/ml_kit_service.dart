// lib/data/services/ml_kit_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/utils/regex_helper.dart';
import '../models/thesis_model.dart';

class MLKitService {
  MLKitService._();

  static final MLKitService _instance = MLKitService._();
  factory MLKitService() => _instance;

  /// Latin script recognizer — fastest and most accurate for Indonesian text.
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool _isDisposed = false;

  /// Processes a single image file and returns a populated [ThesisModel].
  Future<ThesisModel> processImage(ThesisModel model) async {
    if (_isDisposed) {
      return model.copyWith(
        status: ScanStatus.failed,
        errorMessage: 'MLKitService has been disposed.',
      );
    }

    try {
      final inputImage = InputImage.fromFile(File(model.imagePath));
      final recognizedText = await _recognizer.processImage(inputImage);
      final rawText = recognizedText.text;

      if (rawText.trim().isEmpty) {
        return model.copyWith(
          status: ScanStatus.failed,
          rawOcrText: rawText,
          errorMessage: 'No text detected in image.',
        );
      }

      final extracted = RegexHelper.extractAll(rawText);

      return model.copyWith(
        rawOcrText: rawText,
        title: extracted['title'] ?? '',
        name: extracted['name'] ?? '',
        nim: extracted['nim'] ?? '',
        major: extracted['major'] ?? '',
        faculty: extracted['faculty'] ?? '',
        university: extracted['university'] ?? '',
        year: extracted['year'] ?? '',
        status: ScanStatus.success,
        errorMessage: null,
      );
    } catch (e, stack) {
      debugPrint('[MLKitService] Error processing ${model.id}: $e\n$stack');
      return model.copyWith(
        status: ScanStatus.failed,
        errorMessage: 'OCR processing error: ${e.toString()}',
      );
    }
  }

  /// Processes a batch of models, emitting progress via [onProgress].
  /// Returns a list of updated [ThesisModel] instances.
  Future<List<ThesisModel>> processBatch(
    List<ThesisModel> models, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = <ThesisModel>[];

    for (int i = 0; i < models.length; i++) {
      final result = await processImage(models[i]);
      results.add(result);
      onProgress?.call(i + 1, models.length);
    }

    return results;
  }

  /// Release the underlying ML Kit resource.
  Future<void> dispose() async {
    if (!_isDisposed) {
      await _recognizer.close();
      _isDisposed = true;
    }
  }
}
