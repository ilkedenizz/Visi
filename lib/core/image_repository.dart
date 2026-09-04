import 'dart:typed_data';
import '../models/wishlist_item.dart';

abstract class ImageRepository {
  /// Saves image data and returns a persistent identifier (e.g., id or path).
  Future<String> saveImage(dynamic imageInput);

  /// Loads image bytes for the given identifier.
  Future<Uint8List?> loadImage(String id);

  /// Deletes the image associated with the identifier.
  Future<void> deleteImage(String id);

  /// Cleans up orphaned images not referenced by any active WishlistItem.
  Future<void> cleanupOrphanedImages(List<WishlistItem> activeItems, {String? pendingDeletedPath});
}
