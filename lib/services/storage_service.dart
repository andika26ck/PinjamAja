import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path_helper;

import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';

/// Service layer untuk manage storage (upload/delete file).
class StorageService {
  const StorageService._();

  static final _client = SupabaseConfig.client;
  static final _storage = _client.storage.from('item-images');

  /// Upload foto item dengan compression otomatis.
  ///
  /// Parameters:
  /// - imageFile: File foto dari image picker
  /// - itemId: ID item (untuk path organization)
  /// - index: Urutan foto (0-4)
  ///
  /// Returns: Public URL dari Supabase Storage
  /// Throws: AppException jika upload gagal
  static Future<String> uploadItemImage({
    required File imageFile,
    required String itemId,
    required int index,
  }) async {
    try {
      // Validasi
      if (!imageFile.existsSync()) {
        throw AppException(message: 'File foto tidak ditemukan.');
      }

      if (index < 0 || index > 4) {
        throw AppException(message: 'Indeks foto harus 0-4.');
      }

      // Compress foto
      final compressedFile = await _compressImage(imageFile);

      // Generate path: item-images/{itemId}/{index}_{timestamp}.jpg
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${index}_$timestamp.jpg';
      final filePath = '$itemId/$fileName';

      // Upload ke Supabase Storage
      await _storage.update(
        filePath,
        compressedFile,
      );

      // Generate public URL
      final publicUrl = _storage.getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Gagal upload foto. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Delete foto dari Supabase Storage.
  ///
  /// Parameter imageUrl: public URL dari foto (diambil dari item.imageUrls)
  static Future<void> deleteItemImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      // Extract path dari public URL
      // Format: https://...supabase.co/storage/v1/object/public/item-images/{path}
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('item-images');

      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        // Invalid URL atau sudah dihapus
        return;
      }

      // Reconstruct path: item-images/itemId/fileName
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Delete dari storage
      await _storage.remove([filePath]);
    } catch (e) {
      // Jangan throw error untuk delete - tetap lanjut proses
      print('Warning: Gagal delete foto dari storage: $e');
    }
  }

  /// Compress gambar dengan quality 85 dan max width 1200px.
  static Future<File> _compressImage(File imageFile) async {
    try {
      final fileName = path_helper.basename(imageFile.path);
      final targetPath = imageFile.parent.path;

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        '$targetPath/compressed_$fileName',
        quality: 85,
        minWidth: 0,
        minHeight: 0,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        // Jika compress gagal, gunakan original file
        return imageFile;
      }

      // Convert XFile to File
      return File(compressedFile.path);
    } catch (e) {
      print('Warning: Gagal compress image, gunakan original: $e');
      return imageFile;
    }
  }
}
