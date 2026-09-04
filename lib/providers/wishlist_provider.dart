import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_item.dart';
import 'storage_provider.dart';
import 'image_repository_provider.dart';

class WishlistNotifier extends AsyncNotifier<List<WishlistItem>> {
  WishlistItem? _lastDeletedItem;
  int? _lastDeletedIndex;

  WishlistItem? get lastDeletedItem => _lastDeletedItem;

  @override
  Future<List<WishlistItem>> build() async {
    final repository = ref.watch(storageRepositoryProvider);
    final items = await repository.loadWishlistItems();
    // Cleanup orphaned images using ImageRepository (web) or ImageStorageService (android)
    final imageRepo = ref.read(imageRepositoryProvider);
    await imageRepo.cleanupOrphanedImages(items);
    return items;
  }

  Future<void> addItem(WishlistItem item) async {
    final current = state.asData?.value ?? [];
    final updated = [item, ...current];
    state = AsyncData(updated);
    final repo = ref.read(storageRepositoryProvider);
    await repo.saveWishlistItems(updated);
  }

  Future<void> updateItem(WishlistItem updatedItem) async {
    final current = state.asData?.value ?? [];
    final oldItemIndex = current.indexWhere((i) => i.id == updatedItem.id);
    if (oldItemIndex != -1) {
      final oldPath = current[oldItemIndex].imagePath;
      if (oldPath != null && oldPath != updatedItem.imagePath) {
        final imgRepo = ref.read(imageRepositoryProvider);
        await imgRepo.deleteImage(oldPath);
      }
    }
    final updated = [
      for (final item in current)
        if (item.id == updatedItem.id) updatedItem else item
    ];
    state = AsyncData(updated);
    final repo = ref.read(storageRepositoryProvider);
    await repo.saveWishlistItems(updated);
  }

  Future<WishlistItem?> deleteItem(String id) async {
    final current = state.asData?.value ?? [];
    final index = current.indexWhere((i) => i.id == id);
    if (index != -1) {
      final pendingDeletePath = _lastDeletedItem?.imagePath;
      if (pendingDeletePath != null) {
        final imgRepo = ref.read(imageRepositoryProvider);
        await imgRepo.deleteImage(pendingDeletePath);
      }
      _lastDeletedItem = current[index];
      _lastDeletedIndex = index;
      final updated = List<WishlistItem>.from(current)..removeAt(index);
      state = AsyncData(updated);
      final repo = ref.read(storageRepositoryProvider);
      await repo.saveWishlistItems(updated);
      return _lastDeletedItem;
    }
    return null;
  }

  Future<bool> undoDelete() async {
    if (_lastDeletedItem != null) {
      final current = state.asData?.value ?? [];
      final insertIndex = _lastDeletedIndex ?? current.length;
      final updated = List<WishlistItem>.from(current)
        ..insert(insertIndex, _lastDeletedItem!);
      state = AsyncData(updated);
      _lastDeletedItem = null;
      _lastDeletedIndex = null;
      final repo = ref.read(storageRepositoryProvider);
      await repo.saveWishlistItems(updated);
      return true;
    }
    return false;
  }

  Future<void> toggleFavorite(String id) async {
    final current = state.asData?.value ?? [];
    final updated = [
      for (final item in current)
        if (item.id == id) item.copyWith(isFavorite: !item.isFavorite) else item
    ];
    state = AsyncData(updated);
    final repo = ref.read(storageRepositoryProvider);
    await repo.saveWishlistItems(updated);
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<WishlistItem>>(WishlistNotifier.new);

/// Returns favorite wishlist items
final favoriteItemsProvider = Provider<List<WishlistItem>>((ref) {
  final items = ref.watch(wishlistProvider).asData?.value ?? [];
  return items.where((item) => item.isFavorite).toList();
});

/// Returns recent wishlist items (latest 6)
final recentItemsProvider = Provider<List<WishlistItem>>((ref) {
  final items = [...?ref.watch(wishlistProvider).asData?.value];
  items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return items.take(6).toList();
});
