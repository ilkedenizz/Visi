import '../../models/collection_model.dart';
import '../../models/price_alert.dart';
import '../../models/user_preferences.dart';
import '../../models/wishlist_item.dart';

/// Abstract interface for persistence operations used by the app.
/// Implementations exist for Android (using SharedPreferences) and
/// Web (using IndexedDB wrapper).
abstract class StorageRepository {
  /// Initialise any platform‑specific resources.
  Future<void> init();

  // ---------- Wishlist ----------
  Future<List<WishlistItem>> loadWishlistItems();
  Future<void> saveWishlistItems(List<WishlistItem> items);

  // ---------- Collections ----------
  Future<List<CollectionModel>> loadCollections();
  Future<void> saveCollections(List<CollectionModel> collections);

  // ---------- Preferences ----------
  Future<UserPreferences> loadPreferences();
  Future<void> savePreferences(UserPreferences preferences);

  // ---------- Price Alerts ----------
  Future<List<PriceAlert>> loadPriceAlerts();
  Future<void> savePriceAlerts(List<PriceAlert> alerts);

  /// Clears all persisted data – used for integration tests and user reset.
  Future<void> clearAll();
}
