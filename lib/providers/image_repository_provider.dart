import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:visi/core/image_repository.dart';
import 'package:visi/core/android_image_repository.dart';
import 'package:visi/core/web_image_repository.dart';
import 'package:visi/core/storage/web_storage_repository.dart';
import 'package:visi/providers/storage_provider.dart';

/// Platform‑aware provider for image handling.
final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  if (kIsWeb) {
    final storageRepo = ref.read(storageRepositoryProvider);
    if (storageRepo is WebStorageRepository) {
      return WebImageRepository(storageRepo);
    }
    throw UnsupportedError('WebStorageRepository not available');
  } else {
    return AndroidImageRepository();
  }
});
