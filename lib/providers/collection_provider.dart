import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection_model.dart';
import 'storage_provider.dart';

class CollectionNotifier extends Notifier<List<CollectionModel>> {
  @override
  List<CollectionModel> build() {
    final storageService = ref.watch(storageServiceProvider);
    return storageService.getCollections();
  }

  Future<void> addCollection(CollectionModel collection) async {
    state = [...state, collection];
    await ref.read(storageServiceProvider).saveCollections(state);
  }

  Future<void> updateCollection(CollectionModel updatedCollection) async {
    state = [
      for (final col in state)
        if (col.id == updatedCollection.id) updatedCollection else col
    ];
    await ref.read(storageServiceProvider).saveCollections(state);
  }

  Future<void> deleteCollection(String id) async {
    state = state.where((col) => col.id != id).toList();
    await ref.read(storageServiceProvider).saveCollections(state);
  }
}

final collectionProvider = NotifierProvider<CollectionNotifier, List<CollectionModel>>(CollectionNotifier.new);
