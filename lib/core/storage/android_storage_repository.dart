import 'storage_repository.dart';
import '../../models/collection_model.dart';
import '../../models/price_alert.dart';
import '../../models/user_preferences.dart';
import '../../models/wishlist_item.dart';
import '../../services/storage_service.dart';

/// Android implementation that wraps the existing `StorageService`.
class AndroidStorageRepository implements StorageRepository {
  StorageService? _service;
  Future<StorageService>? _initFuture;

  @override
  Future<void> init() async {
    await _getService();
  }

  Future<StorageService> _getService() async {
    if (_service != null) return _service!;
    _initFuture ??= StorageService.init();
    _service = await _initFuture;
    return _service!;
  }

  // ---------- Wishlist ----------
  @override
  Future<List<WishlistItem>> loadWishlistItems() async {
    final service = await _getService();
    return service.getWishlistItems();
  }

  @override
  Future<void> saveWishlistItems(List<WishlistItem> items) async {
    final service = await _getService();
    await service.saveWishlistItems(items);
  }

  // ---------- Collections ----------
  @override
  Future<List<CollectionModel>> loadCollections() async {
    final service = await _getService();
    return service.getCollections();
  }

  @override
  Future<void> saveCollections(List<CollectionModel> collections) async {
    final service = await _getService();
    await service.saveCollections(collections);
  }

  // ---------- Preferences ----------
  @override
  Future<UserPreferences> loadPreferences() async {
    final service = await _getService();
    return service.getPreferences();
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    final service = await _getService();
    await service.savePreferences(preferences);
  }

  // ---------- Price Alerts ----------
  @override
  Future<List<PriceAlert>> loadPriceAlerts() async {
    final service = await _getService();
    return service.getPriceAlerts();
  }

  @override
  Future<void> savePriceAlerts(List<PriceAlert> alerts) async {
    final service = await _getService();
    await service.savePriceAlerts(alerts);
  }

  @override
  Future<void> clearAll() async {
    final service = await _getService();
    await service.clearAllData();
  }
}
