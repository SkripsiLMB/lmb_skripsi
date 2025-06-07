import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FbStorageService {
  // NOTE: Singleton provider
  FbStorageService._privateConstructor();
  static final FbStorageService instance = FbStorageService._privateConstructor();

  // NOTE: Firebase variable
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // NOTE: buat upload image
  Future<String> uploadImage({
    required File imageFile,
    required String path,
    int quality = 75,
  }) async {
    final compressedFile = await _compressImage(imageFile, quality);
    final ref = _storage.ref().child(path);

    final uploadTask = await ref.putFile(compressedFile);
    return await uploadTask.ref.getDownloadURL();
  }

  // NOTE: buat compress image
  Future<File> _compressImage(File file, int quality) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );
    if (result == null) throw Exception('Image compression failed');
    return File(result.path);
  }

  // NOTE: buat ambil image
  Future<String> getDownloadUrl(String path) async {
    final ref = _storage.ref().child(path);
    return await ref.getDownloadURL();
  }

  // NOTE: buat delete image
  Future<void> deleteImage(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }
}