import 'dart:typed_data';
import '../../models/collection_model.dart';
import '../../models/price_alert.dart';
import '../../models/user_preferences.dart';
import '../../models/wishlist_item.dart';
import 'storage_repository.dart';

/// Non-web stub implementation of [WebStorageRepository].
class WebStorageRepository implements StorageRepository {
  @override
  Future<void> init() async {}

  @override
  Future<List<WishlistItem>> loadWishlistItems() async => [];

  @override
  Future<void> saveWishlistItems(List<WishlistItem> items) async {}

  @override
  Future<List<CollectionModel>> loadCollections() async => [];

  @override
  Future<void> saveCollections(List<CollectionModel> collections) async {}

  @override
  Future<UserPreferences> loadPreferences() async => const UserPreferences();

  @override
  Future<void> savePreferences(UserPreferences preferences) async {}

  @override
  Future<List<PriceAlert>> loadPriceAlerts() async => [];

  @override
  Future<void> savePriceAlerts(List<PriceAlert> alerts) async {}

  Future<void> saveImage(String id, Uint8List data) async {}

  Future<Uint8List?> loadImage(String id) async => null;

  Future<void> deleteImage(String id) async {}

  Future<List<String>> getAllImageIds() async => [];

  @override
  Future<void> clearAll() async {}
}
