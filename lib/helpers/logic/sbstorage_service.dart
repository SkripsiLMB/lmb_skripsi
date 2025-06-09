import 'dart:io';
import 'package:image/image.dart' as img;
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

  // NOTE: compress and crop
  Future<File> _compressImage(File file, int quality) async {
    final bytes = await file.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) throw Exception('Image decoding failed');

    final int size = originalImage.width < originalImage.height
        ? originalImage.width
        : originalImage.height;
    final int offsetX = (originalImage.width - size) ~/ 2;
    final int offsetY = (originalImage.height - size) ~/ 2;
    final squareImage = img.copyCrop(
      originalImage,
      x: offsetX,
      y: offsetY,
      width: size,
      height: size,
    );

    final jpeg = img.encodeJpg(squareImage, quality: quality);
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final compressedFile = File(targetPath)..writeAsBytesSync(jpeg);
    return compressedFile;
  }
}