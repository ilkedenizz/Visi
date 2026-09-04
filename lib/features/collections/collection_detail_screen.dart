import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/collection_model.dart';
import '../../providers/collection_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/visi_feedback.dart';
import '../../widgets/wishlist_card.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final String collectionId;

  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
  });

  void _confirmDeleteCollection(BuildContext context, WidgetRef ref, CollectionModel col) {
    HapticFeedback.warningNotification();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Koleksiyonu Sil'),
        content: Text('"${col.name}" koleksiyonu silinsin mi? İçindeki dilekler silinmeyecektir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(collectionProvider.notifier).deleteCollection(col.id);
              context.pop();
              VisiFeedback.showInfo(context, 'Koleksiyon silindi');
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.cherryAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionProvider).asData?.value ?? [];
    final allItems = ref.watch(wishlistProvider).asData?.value ?? [];

    final collection = collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () => CollectionModel(
        id: '',
        name: 'Bulunamadı',
        emoji: '✨',
        createdAt: DateTime.now(),
      ),
    );

    if (collection.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Koleksiyon')),
        body: const Center(child: Text('Koleksiyon bulunamadı')),
      );
    }

    final collectionItems = allItems.where((item) => item.collectionId == collection.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(collection.emoji),
            const SizedBox(width: 8),
            Text(collection.name),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.cherryAccent),
            onPressed: () => _confirmDeleteCollection(context, ref, collection),
          ),
        ],
      ),
      body: SafeArea(
        child: collectionItems.isEmpty
            ? EmptyStateWidget.wishlist(
                onAddPressed: () => context.push('/add-item'),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemCount: collectionItems.length,
                itemBuilder: (context, index) {
                  final item = collectionItems[index];
                  return WishlistCard(
                    item: item,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.push('/item/${item.id}');
                    },
                    onFavoriteToggle: () {
                      ref.read(wishlistProvider.notifier).toggleFavorite(item.id);
                    },
                  );
                },
              ),
      ),
    );
  }
}
