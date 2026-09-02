import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/wishlist_item.dart';

class ImageStorageService {
  static const String _imageFolderName = 'visi_images';

  /// Saves a picked image file into the app's local documents directory.
  /// Returns the absolute local file path string.
  static Future<String> saveImage(File imageFile) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docsDir.path}/$_imageFolderName');
    if (!imagesDir.existsSync()) {
      await imagesDir.create(recursive: true);
    }

    final ext = imageFile.path.split('.').last;
    final filename = 'wish_${const Uuid().v4()}.$ext';
    final savedPath = '${imagesDir.path}/$filename';
    final savedFile = await imageFile.copy(savedPath);
    return savedFile.path;
  }

  /// Deletes a local image file if it exists inside the local app storage directory.
  static Future<void> deleteLocalImage(String? path) async {
    if (path == null || path.trim().isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Cleans up any image files in local app storage that are no longer referenced
  /// by any active wishlist items.
  static Future<void> cleanupOrphanedImages(List<WishlistItem> activeItems, {String? pendingDeletedPath}) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docsDir.path}/$_imageFolderName');
      if (!await imagesDir.exists()) return;

      final Set<String> activePaths = activeItems
          .map((i) => i.imagePath)
          .whereType<String>()
          .where((p) => p.trim().isNotEmpty)
          .toSet();

      if (pendingDeletedPath != null && pendingDeletedPath.trim().isNotEmpty) {
        activePaths.add(pendingDeletedPath);
      }

      final files = imagesDir.listSync();
      for (final entity in files) {
        if (entity is File && !activePaths.contains(entity.path)) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }
}
