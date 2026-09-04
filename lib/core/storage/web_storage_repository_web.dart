import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../models/collection_model.dart';
import '../../models/price_alert.dart';
import '../../models/user_preferences.dart';
import '../../models/wishlist_item.dart';
import 'storage_repository.dart';

/// Web implementation of [StorageRepository] using IndexedDB for large data
/// (wishlist, collections & price alerts) and `SharedPreferences` for small preferences.
/// Uses safe async initialization to prevent LateInitializationErrors.
class WebStorageRepository implements StorageRepository {
  dynamic _db;
  SharedPreferences? _prefs;
  Future<void>? _initFuture;

  static const String _dbName = 'visi_web_db';
  static const int _dbVersion = 2;
  static const String _wishlistStore = 'wishlist';
  static const String _collectionsStore = 'collections';
  static const String _imagesStore = 'images';
  static const String _priceAlertsStore = 'price_alerts';

  @override
  Future<void> init() async {
    _initFuture ??= _doInit();
    await _initFuture;
  }

  Future<void> _doInit() async {
    final idbFactory = html.window.indexedDB;
    if (idbFactory != null) {
      _db = await idbFactory.open(_dbName, version: _dbVersion,
          onUpgradeNeeded: (e) {
        final db = e.target.result;
        if (!db.objectStoreNames!.contains(_wishlistStore)) {
          db.createObjectStore(_wishlistStore, keyPath: 'id');
        }
        if (!db.objectStoreNames!.contains(_collectionsStore)) {
          db.createObjectStore(_collectionsStore, keyPath: 'id');
        }
        if (!db.objectStoreNames!.contains(_imagesStore)) {
          db.createObjectStore(_imagesStore, keyPath: 'id');
        }
        if (!db.objectStoreNames!.contains(_priceAlertsStore)) {
          db.createObjectStore(_priceAlertsStore, keyPath: 'id');
        }
      });
    }
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs!;
    await init();
    return _prefs!;
  }

  Future<dynamic> _getDb() async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  // ---------- Wishlist ----------
  @override
  Future<List<WishlistItem>> loadWishlistItems() async {
    final db = await _getDb();
    if (db == null) return [];
    final tx = db.transaction(_wishlistStore, 'readonly');
    final store = tx.objectStore(_wishlistStore);
    final records = await store.getAll(null);
    await tx.completed;
    if (records == null) return [];
    return (records as List<dynamic>)
        .map((record) => WishlistItem.fromJson(jsonEncode(record)))
        .toList();
  }

  @override
  Future<void> saveWishlistItems(List<WishlistItem> items) async {
    final db = await _getDb();
    if (db == null) return;
    final tx = db.transaction(_wishlistStore, 'readwrite');
    final store = tx.objectStore(_wishlistStore);
    await store.clear();
    for (final item in items) {
      final map = json.decode(item.toJson()) as Map<String, dynamic>;
      await store.put(map);
    }
    await tx.completed;
  }

  // ---------- Collections ----------
  @override
  Future<List<CollectionModel>> loadCollections() async {
    final db = await _getDb();
    if (db == null) return [];
    final tx = db.transaction(_collectionsStore, 'readonly');
    final store = tx.objectStore(_collectionsStore);
    final records = await store.getAll(null);
    await tx.completed;
    if (records == null) return [];
    return (records as List<dynamic>)
        .map((record) => CollectionModel.fromJson(jsonEncode(record)))
        .toList();
  }

  @override
  Future<void> saveCollections(List<CollectionModel> collections) async {
    final db = await _getDb();
    if (db == null) return;
    final tx = db.transaction(_collectionsStore, 'readwrite');
    final store = tx.objectStore(_collectionsStore);
    await store.clear();
    for (final col in collections) {
      final map = json.decode(col.toJson()) as Map<String, dynamic>;
      await store.put(map);
    }
    await tx.completed;
  }

  // ---------- Preferences ----------
  @override
  Future<UserPreferences> loadPreferences() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(AppConstants.storageKeyPreferences) ??
        prefs.getString('visi_preferences_v1');
    if (raw == null) return const UserPreferences();
    try {
      return UserPreferences.fromJson(raw);
    } catch (_) {
      return const UserPreferences();
    }
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await _getPrefs();
    final jsonStr = preferences.toJson();
    await prefs.setString(AppConstants.storageKeyPreferences, jsonStr);
    await prefs.setString('visi_preferences_v1', jsonStr);
  }

  // ---------- Price Alerts ----------
  @override
  Future<List<PriceAlert>> loadPriceAlerts() async {
    final db = await _getDb();
    if (db == null) return [];
    final tx = db.transaction(_priceAlertsStore, 'readonly');
    final store = tx.objectStore(_priceAlertsStore);
    final records = await store.getAll(null);
    await tx.completed;
    if (records == null) return [];
    return (records as List<dynamic>)
        .map((record) => PriceAlert.fromJson(jsonEncode(record)))
        .toList();
  }

  @override
  Future<void> savePriceAlerts(List<PriceAlert> alerts) async {
    final db = await _getDb();
    if (db == null) return;
    final tx = db.transaction(_priceAlertsStore, 'readwrite');
    final store = tx.objectStore(_priceAlertsStore);
    await store.clear();
    for (final alert in alerts) {
      final map = json.decode(alert.toJson()) as Map<String, dynamic>;
      await store.put(map);
    }
    await tx.completed;
  }

  // ---------- Image storage (IndexedDB blobs) ----------
  Future<void> saveImage(String id, Uint8List data) async {
    final db = await _getDb();
    if (db == null) return;
    final tx = db.transaction(_imagesStore, 'readwrite');
    final store = tx.objectStore(_imagesStore);
    final blob = html.Blob([data]);
    await store.put(blob, id);
    await tx.completed;
  }

  Future<Uint8List?> loadImage(String id) async {
    final db = await _getDb();
    if (db == null) return null;
    final tx = db.transaction(_imagesStore, 'readonly');
    final store = tx.objectStore(_imagesStore);
    final blob = await store.getObject(id) as html.Blob?;
    await tx.completed;
    if (blob == null) return null;
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();
    reader.onLoadEnd.listen((_) => completer.complete(reader.result as Uint8List));
    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  Future<void> deleteImage(String id) async {
    final db = await _getDb();
    if (db == null) return;
    final tx = db.transaction(_imagesStore, 'readwrite');
    final store = tx.objectStore(_imagesStore);
    await store.delete(id);
    await tx.completed;
  }

  // ---------- Image IDs ----------
  Future<List<String>> getAllImageIds() async {
    final db = await _getDb();
    if (db == null) return [];
    final tx = db.transaction(_imagesStore, 'readonly');
    final store = tx.objectStore(_imagesStore);
    final keys = await store.getAllKeys(null);
    await tx.completed;
    return (keys as List).cast<String>();
  }

  // ---------- Clear all ----------
  @override
  Future<void> clearAll() async {
    final db = await _getDb();
    if (db != null) {
      for (final name in [_wishlistStore, _collectionsStore, _imagesStore, _priceAlertsStore]) {
        final tx = db.transaction(name, 'readwrite');
        await tx.objectStore(name).clear();
        await tx.completed;
      }
    }
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
