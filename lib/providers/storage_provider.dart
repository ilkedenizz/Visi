import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in ProviderScope');
});
