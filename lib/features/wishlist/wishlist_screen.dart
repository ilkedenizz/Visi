import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_preferences.dart';
import '../../models/wishlist_item.dart';
import '../../providers/collection_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/wishlist_card.dart';
import '../../widgets/wishlist_list_tile.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredItems = ref.watch(filteredWishlistProvider);
    final collections = ref.watch(collectionProvider);
    final filterState = ref.watch(filterProvider);
    final preferences = ref.watch(preferencesProvider);
    final viewMode = preferences.defaultViewMode;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar & View Switch
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wishlist',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '${filteredItems.length} dilek kaydetmişsin',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // View Switcher (Grid vs List)
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.grid_view_rounded,
                                    size: 18,
                                    color: viewMode == ViewMode.grid
                                        ? AppColors.cherryAccent
                                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                  ),
                                  onPressed: () {
                                    ref.read(preferencesProvider.notifier).updateDefaultViewMode(ViewMode.grid);
                                  },
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.format_list_bulleted_rounded,
                                    size: 18,
                                    color: viewMode == ViewMode.list
                                        ? AppColors.cherryAccent
                                        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                                  ),
                                  onPressed: () {
                                    ref.read(preferencesProvider.notifier).updateDefaultViewMode(ViewMode.list);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Search Bar with Filter Modal Trigger
                  SearchBarWidget(
                    hintText: 'Dileklerini veya mağazaları ara...',
                    hasActiveFilter: filterState.selectedCollectionId != null ||
                        filterState.selectedPriority != null ||
                        filterState.favoritesOnly ||
                        filterState.sortOption != SortOption.dateNewest,
                    onChanged: (val) {
                      ref.read(filterProvider.notifier).setSearchQuery(val);
                    },
                    onFilterTap: () => _showFilterBottomSheet(context, ref),
                  ),
                ],
              ),
            ),

            // Collection Quick Filter Horizontal Scroll
            if (collections.isNotEmpty)
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    CategoryChip(
                      label: 'Tümü',
                      isSelected: filterState.selectedCollectionId == null && !filterState.favoritesOnly,
                      onTap: () {
                        ref.read(filterProvider.notifier).setCollectionFilter(null);
                        if (filterState.favoritesOnly) {
                          ref.read(filterProvider.notifier).toggleFavoritesOnly();
                        }
                      },
                    ),
                    CategoryChip(
                      label: 'Favoriler',
                      emoji: '❤️',
                      isSelected: filterState.favoritesOnly,
                      onTap: () {
                        ref.read(filterProvider.notifier).toggleFavoritesOnly();
                      },
                    ),
                    for (final col in collections)
                      CategoryChip(
                        label: col.name,
                        emoji: col.emoji,
                        isSelected: filterState.selectedCollectionId == col.id,
                        onTap: () {
                          if (filterState.selectedCollectionId == col.id) {
                            ref.read(filterProvider.notifier).setCollectionFilter(null);
                          } else {
                            ref.read(filterProvider.notifier).setCollectionFilter(col.id);
                          }
                        },
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Wishlist Content (Grid or List)
            Expanded(
              child: filteredItems.isEmpty
                  ? (filterState.favoritesOnly
                      ? EmptyStateWidget.favorites()
                      : filterState.searchQuery.isNotEmpty
                          ? EmptyStateWidget.search()
                          : EmptyStateWidget.wishlist(
                              onAddPressed: () => context.push('/add-item'),
                            ))
                  : viewMode == ViewMode.grid
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return WishlistCard(
                              item: item,
                              onTap: () => context.push('/item/${item.id}'),
                              onFavoriteToggle: () {
                                ref.read(wishlistProvider.notifier).toggleFavorite(item.id);
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return WishlistListTile(
                              item: item,
                              onTap: () => context.push('/item/${item.id}'),
                              onFavoriteToggle: () {
                                ref.read(wishlistProvider.notifier).toggleFavorite(item.id);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter & Sort Bottom Sheet Modal
  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filterState = ref.read(filterProvider);

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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Handle bar
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrele & Sırala',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(filterProvider.notifier).resetFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Sıfırla'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sort Options
                  Text(
                    'SIRALAMA',
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SortOption.values.map((option) {
                      final isSelected = filterState.sortOption == option;
                      return ChoiceChip(
                        label: Text(option.label),
                        selected: isSelected,
                        selectedColor: AppColors.cherryAccent,
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontSize: 13,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(filterProvider.notifier).setSortOption(option);
                            setModalState(() {});
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Priority Options
                  Text(
                    'ÖNCELİK',
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ItemPriority.values.map((priority) {
                      final isSelected = filterState.selectedPriority == priority;
                      return ChoiceChip(
                        label: Text(priority.label),
                        selected: isSelected,
                        selectedColor: AppColors.cherryAccent,
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontSize: 13,
                        ),
                        onSelected: (selected) {
                          ref.read(filterProvider.notifier).setPriorityFilter(selected ? priority : null);
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cherryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Sonuçları Uygula', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
