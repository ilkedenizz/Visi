import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/collection_model.dart';
import '../models/price_alert.dart';
import '../models/user_preferences.dart';
import '../models/wishlist_item.dart';
import 'mock_data.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);
    await storage._ensureInitialSeedData();
    return storage;
  }

  Future<void> _ensureInitialSeedData() async {
    const seedVersionKey = 'seed_version_v1.0_journal';
    final isFirstLaunch = _prefs.getBool(AppConstants.storageKeyIsFirstLaunch) ?? true;
    final hasV1Seed = _prefs.getBool(seedVersionKey) ?? false;

    if (isFirstLaunch || !hasV1Seed) {
      // Seed initial sample collections
      await saveCollections(MockData.sampleCollections);
      // Seed initial sample items
      await saveWishlistItems(MockData.sampleItems);
      // Seed default preferences
      await savePreferences(const UserPreferences());

      await _prefs.setBool(AppConstants.storageKeyIsFirstLaunch, false);
      await _prefs.setBool(seedVersionKey, true);
    }
  }

  // --- Wishlist Items ---
  List<WishlistItem> getWishlistItems() {
    final rawList = _prefs.getStringList(AppConstants.storageKeyWishlistItems);
    if (rawList == null || rawList.isEmpty) return [];

    try {
      return rawList.map((jsonStr) => WishlistItem.fromJson(jsonStr)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveWishlistItems(List<WishlistItem> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    return await _prefs.setStringList(AppConstants.storageKeyWishlistItems, jsonList);
  }

  // --- Collections ---
  List<CollectionModel> getCollections() {
    final rawList = _prefs.getStringList(AppConstants.storageKeyCollections);
    if (rawList == null || rawList.isEmpty) return [];

    try {
      return rawList.map((jsonStr) => CollectionModel.fromJson(jsonStr)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCollections(List<CollectionModel> collections) async {
    final jsonList = collections.map((col) => col.toJson()).toList();
    return await _prefs.setStringList(AppConstants.storageKeyCollections, jsonList);
  }

  // --- Preferences ---
  UserPreferences getPreferences() {
    final rawJson = _prefs.getString(AppConstants.storageKeyPreferences);
    if (rawJson == null) return const UserPreferences();

    try {
      return UserPreferences.fromJson(rawJson);
    } catch (_) {
      return const UserPreferences();
    }
  }

  Future<bool> savePreferences(UserPreferences preferences) async {
    return await _prefs.setString(AppConstants.storageKeyPreferences, preferences.toJson());
  }

  // --- Price Alerts ---
  List<PriceAlert> getPriceAlerts() {
    final rawList = _prefs.getStringList(AppConstants.storageKeyPriceAlerts);
    if (rawList == null || rawList.isEmpty) return [];

    try {
      return rawList.map((jsonStr) => PriceAlert.fromJson(jsonStr)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> savePriceAlerts(List<PriceAlert> alerts) async {
    final jsonList = alerts.map((alert) => alert.toJson()).toList();
    return await _prefs.setStringList(AppConstants.storageKeyPriceAlerts, jsonList);
  }

  Future<void> clearAllData() async {
    await _prefs.remove(AppConstants.storageKeyWishlistItems);
    await _prefs.remove(AppConstants.storageKeyCollections);
    await _prefs.remove(AppConstants.storageKeyPreferences);
    await _prefs.remove(AppConstants.storageKeyPriceAlerts);
    await _prefs.setBool(AppConstants.storageKeyIsFirstLaunch, true);
  }
}
