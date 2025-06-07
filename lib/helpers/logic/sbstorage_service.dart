import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SbStorageService {
  // NOTE: singleton setup
  SbStorageService._privateConstructor();
  static final SbStorageService instance = SbStorageService._privateConstructor();

  // NOTE: supabase var
  final SupabaseClient _client = Supabase.instance.client;

  // NOTE: buat upload
  Future<String?> uploadImage({
    required File imageFile,
    required String path,
    required String bucket,
    int quality = 75,
  }) async {
    try {
      final compressedFile = await _compressImage(imageFile, quality);
      final fileBytes = await compressedFile.readAsBytes();

      await _client.storage.from(bucket).uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      return getPublicUrl(path, bucket);
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  // NOTE: ambil url download
  String? getPublicUrl(String? path, String bucket) {
    if (path == null || path.trim().isEmpty) return null;
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // NOTE: delete gambar
  Future<void> deleteImage(String? path, String bucket) async {
    if (path == null) {
      return;
    }
    await _client.storage.from(bucket).remove([path]);
  }

  // NOTE: compress
  Future<File> _compressImage(File file, int quality) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );

    if (result == null) {
      throw Exception('Image compression failed');
    }

    return File(result.path);
  }
}