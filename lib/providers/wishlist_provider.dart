import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_item.dart';
import 'storage_provider.dart';

class WishlistNotifier extends Notifier<List<WishlistItem>> {
  @override
  List<WishlistItem> build() {
    final storageService = ref.watch(storageServiceProvider);
    return storageService.getWishlistItems();
  }

  Future<void> addItem(WishlistItem item) async {
    state = [item, ...state];
    await ref.read(storageServiceProvider).saveWishlistItems(state);
  }

  Future<void> updateItem(WishlistItem updatedItem) async {
    state = [
      for (final item in state)
        if (item.id == updatedItem.id) updatedItem else item
    ];
    await ref.read(storageServiceProvider).saveWishlistItems(state);
  }

  Future<void> deleteItem(String id) async {
    state = state.where((item) => item.id != id).toList();
    await ref.read(storageServiceProvider).saveWishlistItems(state);
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
