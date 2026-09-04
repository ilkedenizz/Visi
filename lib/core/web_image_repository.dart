import 'dart:convert';
import 'dart:typed_data';
import 'package:visi/core/image_repository.dart';
import 'package:visi/core/storage/web_storage_repository.dart';
import 'package:visi/models/wishlist_item.dart';

/// Web implementation of [ImageRepository] delegating to [WebStorageRepository].
class WebImageRepository implements ImageRepository {
  final WebStorageRepository _storage;

  WebImageRepository(this._storage);

  @override
  Future<String> saveImage(dynamic imageInput) async {
    // Accept Uint8List bytes or base64 string.
    final Uint8List bytes;
    if (imageInput is Uint8List) {
      bytes = imageInput;
    } else if (imageInput is String) {
      bytes = Uint8List.fromList(base64Decode(imageInput));
    } else {
      throw ArgumentError('Unsupported image input type');
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.saveImage(id, bytes);
    return id;
  }

  @override
  Future<Uint8List?> loadImage(String id) async => await _storage.loadImage(id);

  @override
  Future<void> deleteImage(String id) async => await _storage.deleteImage(id);

  @override
  Future<void> cleanupOrphanedImages(List<WishlistItem> activeItems, {String? pendingDeletedPath}) async {
    final Set<String> referenced = {};
    for (final item in activeItems) {
      if (item.imageId != null) {
        referenced.add(item.imageId!);
      } else if (item.imagePath != null) {
        referenced.add(item.imagePath!);
      }
    }
    if (pendingDeletedPath != null) referenced.add(pendingDeletedPath);
    final allIds = await _storage.getAllImageIds();
    for (final id in allIds) {
      if (!referenced.contains(id)) {
        await _storage.deleteImage(id);
      }
    }
  }
}
