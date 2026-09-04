import 'package:visi/services/image_storage_service.dart';
import 'package:visi/core/image_repository.dart';
import 'package:visi/models/wishlist_item.dart';
import 'dart:typed_data';
import 'dart:io';

/// Android implementation of ImageRepository using the existing ImageStorageService.
class AndroidImageRepository implements ImageRepository {
  @override
  Future<String> saveImage(dynamic imageInput) async {
    // Expect a File object for Android.
    if (imageInput is File) {
      return await ImageStorageService.saveImage(imageInput);
    }
    throw ArgumentError('AndroidImageRepository expects a File input');
  }

  @override
  Future<Uint8List?> loadImage(String id) async {
    // In Android, images are stored as files with their paths.
    // The id is the file path.
    final file = File(id);
    if (await file.exists()) {
      return await file.readAsBytes();
    }
    return null;
  }

  @override
  Future<void> deleteImage(String id) async {
    await ImageStorageService.deleteLocalImage(id);
  }

  @override
  Future<void> cleanupOrphanedImages(List<WishlistItem> activeItems, {String? pendingDeletedPath}) async {
    await ImageStorageService.cleanupOrphanedImages(activeItems, pendingDeletedPath: pendingDeletedPath);
  }
}
