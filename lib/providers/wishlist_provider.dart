import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_item.dart';
import '../services/image_storage_service.dart';
import 'storage_provider.dart';

class WishlistNotifier extends Notifier<List<WishlistItem>> {
  WishlistItem? _lastDeletedItem;
  int? _lastDeletedIndex;

  WishlistItem? get lastDeletedItem => _lastDeletedItem;

  @override
  List<WishlistItem> build() {
    final storageService = ref.watch(storageServiceProvider);
    final items = storageService.getWishlistItems();
    ImageStorageService.cleanupOrphanedImages(items);
    return items;
  }

  Future<void> addItem(WishlistItem item) async {
    state = [item, ...state];
    await ref.read(storageServiceProvider).saveWishlistItems(state);
  }

  Future<void> updateItem(WishlistItem updatedItem) async {
    final oldItemIndex = state.indexWhere((item) => item.id == updatedItem.id);
    if (oldItemIndex != -1) {
      final oldPath = state[oldItemIndex].imagePath;
      if (oldPath != null && oldPath != updatedItem.imagePath) {
        await ImageStorageService.deleteLocalImage(oldPath);
      }
    }
    state = [
      for (final item in state)
        if (item.id == updatedItem.id) updatedItem else item
    ];
    await ref.read(storageServiceProvider).saveWishlistItems(state);
  }

  Future<WishlistItem?> deleteItem(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index != -1) {
      // Clean up previous unrestored deleted item image if different
      if (_lastDeletedItem != null && _lastDeletedItem!.id != id) {
        await ImageStorageService.deleteLocalImage(_lastDeletedItem!.imagePath);
      }
      _lastDeletedItem = state[index];
      _lastDeletedIndex = index;
      final updated = List<WishlistItem>.from(state);
      updated.removeAt(index);
      state = updated;
      await ref.read(storageServiceProvider).saveWishlistItems(state);
      return _lastDeletedItem;
    }
    return null;
  }

  Future<bool> undoDelete() async {
    if (_lastDeletedItem != null) {
      final itemToRestore = _lastDeletedItem!;
      final index = _lastDeletedIndex ?? 0;
      final updated = List<WishlistItem>.from(state);
      final insertIndex = index <= updated.length ? index : updated.length;
      updated.insert(insertIndex, itemToRestore);
      state = updated;
      _lastDeletedItem = null;
      _lastDeletedIndex = null;
      await ref.read(storageServiceProvider).saveWishlistItems(state);
      return true;
    }
    return false;
  }

  Future<void> toggleFavorite(String id) async {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isFavorite: !item.isFavorite) else item
    ];
    await ref.read(storageServiceProvider).saveWishlistItems(state);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<WishlistItem>>(WishlistNotifier.new);

/// Returns favorite wishlist items
final favoriteItemsProvider = Provider<List<WishlistItem>>((ref) {
  final items = ref.watch(wishlistProvider);
  return items.where((item) => item.isFavorite).toList();
});

/// Returns recent wishlist items (latest 6)
final recentItemsProvider = Provider<List<WishlistItem>>((ref) {
  final items = [...ref.watch(wishlistProvider)];
  items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return items.take(6).toList();
});
