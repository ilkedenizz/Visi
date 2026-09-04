import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/wishlist_item.dart';
import '../../providers/collection_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/section_header.dart';
import '../../widgets/visi_cherry_logo.dart';
import '../../widgets/visi_image.dart';
import '../quick_add/quick_add_bottom_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final wishlist = ref.watch(wishlistProvider).asData?.value ?? [];
    final collections = ref.watch(collectionProvider).asData?.value ?? [];

    final recentItems = wishlist.take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.cherryAccent,
          onRefresh: () async {
            HapticFeedback.lightImpact();
          },
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const VisiCherryLogo(size: 14, color: AppColors.cherryAccent),
                                const SizedBox(width: 6),
                                Text(
                                  'VIŞI DILEK DEFTERI',
                                  style: TextStyle(
                                    color: isDark ? AppColors.cherryAccentDark : AppColors.cherryAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bir gün yapmak istediklerini unutma.',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${wishlist.length} dilek · ${collections.length} koleksiyon',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => context.go('/profile'),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.blushPink,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                            ),
                          ),
                          child: const VisiCherryLogo(size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Empty State or Featured & Dashboard Sections
              if (wishlist.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget.wishlist(
                    onAddPressed: () => context.push('/add-item'),
                  ),
                )
              else ...[
                // Sleek Quick Add Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        QuickAddBottomSheet.show(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.blushPink,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : AppColors.cherryAccent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.cherryAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yeni Dilek Ekle',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bir gün yapmak, öğrenmek veya görmek istediğin şey...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Recent Wishes Horizontal List Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: SectionHeader(
                      title: 'Son Eklenenler',
                      subtitle: 'Listenizdeki en yeni dilekler',
                      onTap: () => context.go('/wishlist'),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: recentItems.length,
                      itemBuilder: (context, index) {
                        final item = recentItems[index];
                        return _buildRecentWishCard(context, ref, item, isDark, theme);
                      },
                    ),
                  ),
                ),

                // Collections Section
                if (collections.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: SectionHeader(
                        title: 'Koleksiyonlar',
                        subtitle: 'Moodboard ve kategorilerin',
                        onTap: () => context.go('/collections'),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final col = collections[index];
                          final count = wishlist.where((i) => i.collectionId == col.id).length;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: SizedBox(
                              width: 170,
                              child: CollectionCard(
                                collection: col,
                                itemCount: count,
                                onTap: () => context.push('/collections/${col.id}'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentWishCard(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          onTap: () => context.push('/item/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    VisiImage(imageUrl: item.imagePath),
                    Positioned(
                      top: 6,
                      left: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black87 : Colors.white).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.type.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    if (item.price > 0)
                      Text(
                        '${item.currency}${item.price % 1 == 0 ? item.price.toInt() : item.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.cherryAccent),
                      )
                    else
                      Text(
                        item.status.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
