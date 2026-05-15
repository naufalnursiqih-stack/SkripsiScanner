// lib/core/utils/image_processor.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessor {
  ImageProcessor._();

  /// Compresses an image file to improve OCR speed & accuracy.
  /// Returns the path to the compressed file.
  static Future<File> compress(File imageFile, {int quality = 85}) async {
    try {
      final targetPath = '${imageFile.parent.path}/compressed_${imageFile.uri.pathSegments.last}';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1280,
        minHeight: 1280,
      );

      return result != null ? File(result.path) : imageFile;
    } catch (e) {
      debugPrint('[ImageProcessor] Compression failed: $e — using original');
      return imageFile;
    }
  }

  /// Returns the image dimensions for diagnostic purposes.
  static Future<ui.Size> getImageSize(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    return ui.Size(image.width.toDouble(), image.height.toDouble());
  }
}
