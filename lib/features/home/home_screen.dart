import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/collection_model.dart';
import '../../models/wishlist_item.dart';
import '../../providers/collection_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/collection_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/section_header.dart';
import '../../widgets/visi_cherry_logo.dart';
import '../../widgets/visi_image.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatPrice(double price, String currency) {
    final formatter = NumberFormat('#,##0.##', 'tr_TR');
    return '$currency${formatter.format(price)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final wishlist = ref.watch(wishlistProvider);
    final collections = ref.watch(collectionProvider);

    final featuredItem = wishlist.isNotEmpty
        ? (wishlist.any((i) => i.isFavorite)
            ? wishlist.firstWhere((i) => i.isFavorite)
            : wishlist.first)
        : null;

    final recentItems = wishlist.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.cherryAccent,
          onRefresh: () async {
            HapticFeedback.lightImpact();
          },
          child: CustomScrollView(
            slivers: [
              // Editorial Header Bar Section
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
                                  'VIŞI JOURNAL',
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
                              'Bugün neyi istiyorsun?',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                // Hero Featured Wishlist Card Section
                if (featuredItem != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            title: 'Öne Çıkan Dilek',
                            subtitle: 'Günün ilham veren parçası',
                          ),
                          const SizedBox(height: 8),
                          _buildHeroCard(context, ref, featuredItem, collections, isDark, theme),
                        ],
                      ),
                    ),
                  ),

                // "Son Eklenenler" Horizontal Scroll Section
                if (recentItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SectionHeader(
                              title: 'Son Eklenenler',
                              subtitle: 'Listenizdeki en yeni dilekler',
                              trailing: TextButton(
                                onPressed: () => context.go('/wishlist'),
                                child: Text(
                                  'Tümünü Gör',
                                  style: TextStyle(
                                    color: isDark ? AppColors.cherryAccentDark : AppColors.cherryAccent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 226,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: recentItems.length,
                              itemBuilder: (context, index) {
                                final item = recentItems[index];
                                return _buildRecentItemCard(context, ref, item, isDark, theme);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // "Koleksiyonlarım" Section
                if (collections.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Koleksiyonlar',
                            subtitle: 'Moodboard ve kategorilerin',
                            trailing: TextButton(
                              onPressed: () => context.go('/collections'),
                              child: Text(
                                'Tümünü Gör',
                                style: TextStyle(
                                  color: isDark ? AppColors.cherryAccentDark : AppColors.cherryAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.25,
                            ),
                            itemCount: collections.take(4).length,
                            itemBuilder: (context, index) {
                              final col = collections[index];
                              final count = wishlist.where((i) => i.collectionId == col.id).length;
                              return CollectionCard(
                                collection: col,
                                itemCount: count,
                                onTap: () => context.push('/collections/${col.id}'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Refined Editorial Hero Featured Wishlist Card
  Widget _buildHeroCard(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
    List<CollectionModel> collections,
    bool isDark,
    ThemeData theme,
  ) {
    final col = collections.firstWhere(
      (c) => c.id == item.collectionId,
      orElse: () => CollectionModel(id: '', name: 'Genel', emoji: '✨', createdAt: DateTime.now()),
    );

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadowColor : AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/item/${item.id}');
          },
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: VisiImage(imageUrl: item.imagePath),
              ),

              // Editorial Multi-stage Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Collection Tag (Top Left)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    children: [
                      Text(col.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text(
                        col.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Favorite Heart Button (Top Right)
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(wishlistProvider.notifier).toggleFavorite(item.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                            CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                          ),
                          child: child,
                        ),
                        child: Icon(
                          item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey(item.isFavorite),
                          size: 20,
                          color: item.isFavorite ? AppColors.cherryAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Details Overlay Text
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const VisiCherryLogo(size: 12, color: AppColors.cherryAccent),
                        const SizedBox(width: 6),
                        if (item.store != null)
                          Text(
                            item.store!.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.blushPink,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(item.price, item.currency),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
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

  // Refined Recent Item Horizontal Card
  Widget _buildRecentItemCard(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      width: 156,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadowColor : AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/item/${item.id}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              SizedBox(
                height: 116,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: VisiImage(imageUrl: item.imagePath),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(wishlistProvider.notifier).toggleFavorite(item.id);
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.87),
                          child: Icon(
                            item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 13,
                            color: item.isFavorite
                                ? AppColors.cherryAccent
                                : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                          ),
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
                    if (item.store != null && item.store!.isNotEmpty) ...[
                      Text(
                        item.store!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isDark ? AppColors.cherryAccentDark : AppColors.cherryAccent,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(item.price, item.currency),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
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
