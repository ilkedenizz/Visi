import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../models/collection_model.dart';
import '../../providers/collection_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/section_header.dart';
import '../../widgets/visi_feedback.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  void _showAddCollectionBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameController = TextEditingController();
    final imageController = TextEditingController();
    String selectedEmoji = '✨';

    final emojis = ['✨', '👗', '🏠', '🎧', '🎁', '✈️', '📚', '☕', '🚗', '💍'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Yeni Koleksiyon',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emoji Selector
                    Text('EMOJİ', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = emojis[index];
                          final isSelected = selectedEmoji == emoji;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() {
                                selectedEmoji = emoji;
                              });
                            },
                            child: Container(
                              width: 44,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.cherryAccent
                                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Collection Name
                    Text('KOLEKSİYON ADI', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Örn: Seyahat Hayalleri',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cover Image URL
                    Text('KAPAK GÖRSELİ (URL)', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        hintText: 'https://images.unsplash.com/...',
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          final newCol = CollectionModel(
                            id: const Uuid().v4(),
                            name: name,
                            emoji: selectedEmoji,
                            coverImage: imageController.text.trim().isNotEmpty ? imageController.text.trim() : null,
                            createdAt: DateTime.now(),
                          );

                          ref.read(collectionProvider.notifier).addCollection(newCol);
                          Navigator.pop(context);
                          VisiFeedback.showSuccess(context, 'Koleksiyon oluşturuldu ✨');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cherryAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Koleksiyon Oluştur', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionProvider).asData?.value ?? [];
    final wishlist = ref.watch(wishlistProvider).asData?.value ?? [];

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              SectionHeader(
                title: 'Koleksiyonlar',
                subtitle: 'Dileklerini temalara göre düzenle',
                trailing: IconButton.filledTonal(
                  icon: const Icon(Icons.add_rounded, color: AppColors.cherryAccent),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showAddCollectionBottomSheet(context, ref);
                  },
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: collections.isEmpty
                    ? EmptyStateWidget.collections(
                        onCreatePressed: () => _showAddCollectionBottomSheet(context, ref),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final col = collections[index];
                          final count = wishlist.where((i) => i.collectionId == col.id).length;
                          return CollectionCard(
                            collection: col,
                            itemCount: count,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.push('/collections/${col.id}');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
