import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/storage/android_storage_repository.dart';
import '../core/storage/web_storage_repository.dart';
import '../core/storage/storage_repository.dart';

/// Provides a platform‑aware StorageRepository implementation.
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  if (kIsWeb) {
    return WebStorageRepository()..init();
  } else {
    return AndroidStorageRepository()..init();
  }
});

