import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:path_provider/path_provider.dart';

class MediaCompressor {
  static const int maxSizeBytes = 25 * 1024 * 1024;

  static const int _maxImageQuality = 85;
  static const int _minImageQuality = 35;

  static const List<int> _videoBitrates = [
    2500,
    1800,
    1200,
    900,
    700,
  ];

  /// Main function.
  ///
  /// Files <= 25 MB are returned as they are.
  /// Files > 25 MB are compressed.
  static Future<List<File>> compressFiles(
      List<File> files,
      ) async {
    final List<File> result = [];

    for (final file in files) {
      final compressedFile = await compressFile(file);

      if (compressedFile != null) {
        result.add(compressedFile);
      }
    }

    return result;
  }

  static Future<File?> compressFile(File file) async {
    if (!await file.exists()) {
      return null;
    }

    final int originalSize = await file.length();

    // Already within the API limit.
    if (originalSize <= maxSizeBytes) {
      return file;
    }

    if (_isImage(file)) {
      return _compressImage(file);
    }

    if (_isVideo(file)) {
      return _compressVideo(file);
    }

    // Unsupported file type.
    return null;
  }

  // ============================================================
  // IMAGE
  // ============================================================

  static Future<File?> _compressImage(File file) async {
    final Directory tempDirectory =
    await getTemporaryDirectory();

    final String extension =
    file.path.split('.').last.toLowerCase();

    final String outputPath =
        '${tempDirectory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    int quality = _maxImageQuality;

    File? compressedFile;

    while (quality >= _minImageQuality) {
      final XFile? result =
      await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outputPath,
        quality: quality,
        format: CompressFormat.jpeg,
        minWidth: 1920,
        minHeight: 1920,
      );

      if (result == null) {
        return null;
      }

      final File outputFile = File(result.path);

      if (!await outputFile.exists()) {
        return null;
      }

      final int size = await outputFile.length();

      compressedFile = outputFile;

      if (size <= maxSizeBytes) {
        return outputFile;
      }

      quality -= 10;
    }

    // Compression was not enough.
    if (compressedFile != null &&
        await compressedFile.length() <= maxSizeBytes) {
      return compressedFile;
    }

    return null;
  }

  // ============================================================
  // VIDEO
  // ============================================================

  static Future<File?> _compressVideo(File file) async {
    final Directory tempDirectory =
    await getTemporaryDirectory();

    final String outputPath =
        '${tempDirectory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.mp4';

    File? compressedFile;

    for (final bitrate in _videoBitrates) {
      final String command =
          '-i "${file.path}" '
          '-c:v libx264 '
          '-b:v ${bitrate}k '
          '-preset medium '
          '-c:a aac '
          '-b:a 128k '
          '-movflags +faststart '
          '"$outputPath"';

      final session = await FFmpegKit.execute(command);

      final returnCode = await session.getReturnCode();

      if (returnCode == null || !returnCode.isValueSuccess()) {
        continue;
      }

      final outputFile = File(outputPath);

      if (!await outputFile.exists()) {
        continue;
      }

      final int size = await outputFile.length();

      compressedFile = outputFile;

      if (size <= maxSizeBytes) {
        return outputFile;
      }

      // Delete this version before trying a lower bitrate.
      try {
        await outputFile.delete();
      } catch (_) {}
    }

    return null;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static bool _isImage(File file) {
    final extension =
    file.path.split('.').last.toLowerCase();

    return [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'heic',
      'heif',
    ].contains(extension);
  }

  static bool _isVideo(File file) {
    final extension =
    file.path.split('.').last.toLowerCase();

    return [
      'mp4',
      'mov',
      'avi',
      'mkv',
      'webm',
      '3gp',
    ].contains(extension);
  }

  static Future<double> getSizeInMb(File file) async {
    final bytes = await file.length();

    return bytes / (1024 * 1024);
  }
}