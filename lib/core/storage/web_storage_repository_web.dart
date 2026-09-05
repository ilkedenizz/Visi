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
import '../../services/mock_data.dart';
import 'storage_repository.dart';

/// Web implementation of [StorageRepository] featuring dual persistence across
/// `SharedPreferences` / `window.localStorage` and `IndexedDB`.
/// Guarantees data durability on iOS Safari, PWA Standalone, and desktop Web.
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
      try {
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
      } catch (_) {
        _db = null;
      }
    }

    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    }

    // Perform initial seed check on fresh Web launch if storage is completely empty
    try {
      final isFirstLaunch = _prefs?.getBool(AppConstants.storageKeyIsFirstLaunch) ??
          (html.window.localStorage[AppConstants.storageKeyIsFirstLaunch] == null);
      const seedVersionKey = 'seed_version_v1.0_journal';
      final hasV1Seed = _prefs?.getBool(seedVersionKey) ??
          (html.window.localStorage[seedVersionKey] == 'true');

      if (isFirstLaunch || !hasV1Seed) {
        await saveCollections(MockData.sampleCollections);
        await saveWishlistItems(MockData.sampleItems);
        await savePreferences(const UserPreferences());

        try {
          await _prefs?.setBool(AppConstants.storageKeyIsFirstLaunch, false);
          await _prefs?.setBool(seedVersionKey, true);
        } catch (_) {}
        try {
          html.window.localStorage[AppConstants.storageKeyIsFirstLaunch] = 'false';
          html.window.localStorage[seedVersionKey] = 'true';
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) return _prefs;
    try {
      await init();
    } catch (_) {}
    return _prefs;
  }

  Future<dynamic> _getDb() async {
    if (_db != null) return _db;
    try {
      await init();
    } catch (_) {}
    return _db;
  }

  // ---------- Wishlist ----------
  @override
  Future<List<WishlistItem>> loadWishlistItems() async {
    String? raw;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        raw = prefs.getString(AppConstants.storageKeyWishlistItems) ??
            prefs.getString('visi_wishlist_items_v1');
      }
    } catch (_) {}

    if (raw == null || raw.isEmpty) {
      try {
        raw = html.window.localStorage[AppConstants.storageKeyWishlistItems] ??
            html.window.localStorage['visi_wishlist_items_v1'] ??
            html.window.localStorage['flutter.${AppConstants.storageKeyWishlistItems}'] ??
            html.window.localStorage['flutter.visi_wishlist_items_v1'];
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          final items = decoded.map((e) {
            if (e is String) return WishlistItem.fromJson(e);
            return WishlistItem.fromJson(json.encode(e));
          }).toList();
          return items;
        }
      } catch (_) {}
    }

    // Fallback to IndexedDB
    try {
      final db = await _getDb();
      if (db != null) {
        final tx = db.transaction(_wishlistStore, 'readonly');
        final store = tx.objectStore(_wishlistStore);
        final records = await store.getAll(null);
        await tx.completed;
        if (records is List && records.isNotEmpty) {
          final items = records
              .map((record) => WishlistItem.fromJson(jsonEncode(record)))
              .toList();
          await saveWishlistItems(items);
          return items;
        }
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<void> saveWishlistItems(List<WishlistItem> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    final jsonStr = json.encode(jsonList);

    // 1. SharedPreferences
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(AppConstants.storageKeyWishlistItems, jsonStr);
        await prefs.setString('visi_wishlist_items_v1', jsonStr);
      }
    } catch (_) {}

    // 2. Direct html.window.localStorage
    try {
      html.window.localStorage[AppConstants.storageKeyWishlistItems] = jsonStr;
      html.window.localStorage['visi_wishlist_items_v1'] = jsonStr;
      html.window.localStorage['flutter.${AppConstants.storageKeyWishlistItems}'] = jsonStr;
      html.window.localStorage['flutter.visi_wishlist_items_v1'] = jsonStr;
    } catch (_) {}

    // 3. IndexedDB
    try {
      final db = await _getDb();
      if (db != null) {
        final tx = db.transaction(_wishlistStore, 'readwrite');
        final store = tx.objectStore(_wishlistStore);
        await store.clear();
        for (final item in items) {
          final map = json.decode(item.toJson()) as Map<String, dynamic>;
          await store.put(map);
        }
        await tx.completed;
      }
    } catch (_) {}
  }

  // ---------- Collections ----------
  @override
  Future<List<CollectionModel>> loadCollections() async {
    String? raw;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        raw = prefs.getString(AppConstants.storageKeyCollections) ??
            prefs.getString('visi_collections_v1');
      }
    } catch (_) {}

    if (raw == null || raw.isEmpty) {
      try {
        raw = html.window.localStorage[AppConstants.storageKeyCollections] ??
            html.window.localStorage['visi_collections_v1'] ??
            html.window.localStorage['flutter.${AppConstants.storageKeyCollections}'] ??
            html.window.localStorage['flutter.visi_collections_v1'];
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          final collections = decoded.map((e) {
            if (e is String) return CollectionModel.fromJson(e);
            return CollectionModel.fromJson(json.encode(e));
          }).toList();
          return collections;
        }
      } catch (_) {}
    }

    // Fallback to IndexedDB
    try {
      final db = await _getDb();
      if (db != null) {
        final tx = db.transaction(_collectionsStore, 'readonly');
        final store = tx.objectStore(_collectionsStore);
        final records = await store.getAll(null);
        await tx.completed;
        if (records is List && records.isNotEmpty) {
          final collections = records
              .map((record) => CollectionModel.fromJson(jsonEncode(record)))
              .toList();
          await saveCollections(collections);
          return collections;
        }
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<void> saveCollections(List<CollectionModel> collections) async {
    final jsonList = collections.map((col) => col.toJson()).toList();
    final jsonStr = json.encode(jsonList);

    // 1. SharedPreferences
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(AppConstants.storageKeyCollections, jsonStr);
        await prefs.setString('visi_collections_v1', jsonStr);
      }
    } catch (_) {}

    // 2. Direct html.window.localStorage
    try {
      html.window.localStorage[AppConstants.storageKeyCollections] = jsonStr;
      html.window.localStorage['visi_collections_v1'] = jsonStr;
      html.window.localStorage['flutter.${AppConstants.storageKeyCollections}'] = jsonStr;
      html.window.localStorage['flutter.visi_collections_v1'] = jsonStr;
    } catch (_) {}

    // 3. IndexedDB
    try {
      final db = await _getDb();
      if (db != null) {
        final tx = db.transaction(_collectionsStore, 'readwrite');
        final store = tx.objectStore(_collectionsStore);
        await store.clear();
        for (final col in collections) {
          final map = json.decode(col.toJson()) as Map<String, dynamic>;
          await store.put(map);
        }
        await tx.completed;
      }
    } catch (_) {}
  }

  // ---------- Preferences ----------
  @override
  Future<UserPreferences> loadPreferences() async {
    String? raw;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        raw = prefs.getString(AppConstants.storageKeyPreferences) ??
            prefs.getString('visi_preferences_v1');
      }
    } catch (_) {}

    if (raw == null || raw.isEmpty) {
      try {
        raw = html.window.localStorage[AppConstants.storageKeyPreferences] ??
            html.window.localStorage['visi_preferences_v1'] ??
            html.window.localStorage['flutter.${AppConstants.storageKeyPreferences}'] ??
            html.window.localStorage['flutter.visi_preferences_v1'];
      } catch (_) {}
    }

    if (raw == null || raw.isEmpty) return const UserPreferences();
    try {
      return UserPreferences.fromJson(raw);
    } catch (_) {
      return const UserPreferences();
    }
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    final jsonStr = preferences.toJson();
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(AppConstants.storageKeyPreferences, jsonStr);
        await prefs.setString('visi_preferences_v1', jsonStr);
      }
    } catch (_) {}

    try {
      html.window.localStorage[AppConstants.storageKeyPreferences] = jsonStr;
      html.window.localStorage['visi_preferences_v1'] = jsonStr;
      html.window.localStorage['flutter.${AppConstants.storageKeyPreferences}'] = jsonStr;
      html.window.localStorage['flutter.visi_preferences_v1'] = jsonStr;
    } catch (_) {}
  }

  // ---------- Price Alerts ----------
  @override
  Future<List<PriceAlert>> loadPriceAlerts() async {
    String? raw;
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        raw = prefs.getString(AppConstants.storageKeyPriceAlerts) ??
            prefs.getString('visi_price_alerts_v1');
      }
    } catch (_) {}

    if (raw == null || raw.isEmpty) {
      try {
        raw = html.window.localStorage[AppConstants.storageKeyPriceAlerts] ??
            html.window.localStorage['visi_price_alerts_v1'] ??
            html.window.localStorage['flutter.${AppConstants.storageKeyPriceAlerts}'] ??
            html.window.localStorage['flutter.visi_price_alerts_v1'];
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw);
        if (decoded is List) {
          return decoded.map((e) {
            if (e is String) return PriceAlert.fromJson(e);
            return PriceAlert.fromJson(json.encode(e));
          }).toList();
        }
      } catch (_) {}
    }

    try {
      final db = await _getDb();
      if (db != null) {
        final tx = db.transaction(_priceAlertsStore, 'readonly');
        final store = tx.objectStore(_priceAlertsStore);
        final records = await store.getAll(null);
        await tx.completed;
        if (records is List && records.isNotEmpty) {
          final alerts = records
              .map((record) => PriceAlert.fromJson(jsonEncode(record)))
              .toList();
          await savePriceAlerts(alerts);
          return alerts;
        }
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<void> savePriceAlerts(List<PriceAlert> alerts) async {
    final jsonList = alerts.map((alert) => alert.toJson()).toList();
    final jsonStr = json.encode(jsonList);

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.setString(AppConstants.storageKeyPriceAlerts, jsonStr);
        await prefs.setString('visi_price_alerts_v1', jsonStr);
      }
    } catch (_) {}

    try {
      html.window.localStorage[AppConstants.storageKeyPriceAlerts] = jsonStr;
      html.window.localStorage['visi_price_alerts_v1'] = jsonStr;
      html.window.localStorage['flutter.${AppConstants.storageKeyPriceAlerts}'] = jsonStr;
      html.window.localStorage['flutter.visi_price_alerts_v1'] = jsonStr;
    } catch (_) {}

    try {
      final db = await _getDb();
      if (db != null) {
        final tx = db.transaction(_priceAlertsStore, 'readwrite');
        final store = tx.objectStore(_priceAlertsStore);
        await store.clear();
        for (final alert in alerts) {
          final map = json.decode(alert.toJson()) as Map<String, dynamic>;
          await store.put(map);
        }
        await tx.completed;
      }
    } catch (_) {}
  }

  // ---------- Image storage (IndexedDB blobs) ----------
  Future<void> saveImage(String id, Uint8List data) async {
    final db = await _getDb();
    if (db == null) return;
    try {
      final tx = db.transaction(_imagesStore, 'readwrite');
      final store = tx.objectStore(_imagesStore);
      final blob = html.Blob([data]);
      await store.put(blob, id);
      await tx.completed;
    } catch (_) {}
  }

  Future<Uint8List?> loadImage(String id) async {
    final db = await _getDb();
    if (db == null) return null;
    try {
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
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteImage(String id) async {
    final db = await _getDb();
    if (db == null) return;
    try {
      final tx = db.transaction(_imagesStore, 'readwrite');
      final store = tx.objectStore(_imagesStore);
      await store.delete(id);
      await tx.completed;
    } catch (_) {}
  }

  // ---------- Image IDs ----------
  Future<List<String>> getAllImageIds() async {
    final db = await _getDb();
    if (db == null) return [];
    try {
      final tx = db.transaction(_imagesStore, 'readonly');
      final store = tx.objectStore(_imagesStore);
      final keys = await store.getAllKeys(null);
      await tx.completed;
      return (keys as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  // ---------- Clear all ----------
  @override
  Future<void> clearAll() async {
    try {
      final db = await _getDb();
      if (db != null) {
        for (final name in [_wishlistStore, _collectionsStore, _imagesStore, _priceAlertsStore]) {
          final tx = db.transaction(name, 'readwrite');
          await tx.objectStore(name).clear();
          await tx.completed;
        }
      }
    } catch (_) {}

    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.clear();
      }
    } catch (_) {}

    try {
      html.window.localStorage.clear();
    } catch (_) {}
  }
}

