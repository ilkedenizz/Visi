import 'storage_repository.dart';
import '../../models/collection_model.dart';
import '../../models/price_alert.dart';
import '../../models/user_preferences.dart';
import '../../models/wishlist_item.dart';
import '../../services/storage_service.dart';

/// Android implementation that wraps the existing `StorageService`.
class AndroidStorageRepository implements StorageRepository {
  late final StorageService _service;

  @override
  Future<void> init() async {
    _service = await StorageService.init();
  }

  // ---------- Wishlist ----------
  @override
  Future<List<WishlistItem>> loadWishlistItems() async => _service.getWishlistItems();

  @override
  Future<void> saveWishlistItems(List<WishlistItem> items) async {
    await _service.saveWishlistItems(items);
  }

  // ---------- Collections ----------
  @override
  Future<List<CollectionModel>> loadCollections() async => _service.getCollections();

  @override
  Future<void> saveCollections(List<CollectionModel> collections) async {
    await _service.saveCollections(collections);
  }

  // ---------- Preferences ----------
  @override
  Future<UserPreferences> loadPreferences() async => _service.getPreferences();

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    await _service.savePreferences(preferences);
  }

  // ---------- Price Alerts ----------
  @override
  Future<List<PriceAlert>> loadPriceAlerts() async => _service.getPriceAlerts();

  @override
  Future<void> savePriceAlerts(List<PriceAlert> alerts) async {
    await _service.savePriceAlerts(alerts);
  }

  @override
  Future<void> clearAll() async => await _service.clearAllData();
}
