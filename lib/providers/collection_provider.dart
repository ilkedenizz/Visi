import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection_model.dart';
import 'storage_provider.dart';

class CollectionNotifier extends AsyncNotifier<List<CollectionModel>> {
  @override
  Future<List<CollectionModel>> build() async {
    final repository = ref.watch(storageRepositoryProvider);
    return await repository.loadCollections();
  }

  Future<void> addCollection(CollectionModel collection) async {
    final current = state.asData?.value ?? [];
    final updated = [...current, collection];
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).saveCollections(updated);
  }

  Future<void> updateCollection(CollectionModel updatedCollection) async {
    final current = state.asData?.value ?? [];
    final updated = [
      for (final col in current)
        if (col.id == updatedCollection.id) updatedCollection else col
    ];
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).saveCollections(updated);
  }

  Future<void> deleteCollection(String id) async {
    final current = state.asData?.value ?? [];
    final updated = current.where((col) => col.id != id).toList();
    state = AsyncData(updated);
    await ref.read(storageRepositoryProvider).saveCollections(updated);
  }
}

final collectionProvider = AsyncNotifierProvider<CollectionNotifier, List<CollectionModel>>(CollectionNotifier.new);
