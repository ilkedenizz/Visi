import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_preferences.dart';
import '../../models/wish_status.dart';
import '../../models/wish_type.dart';
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
    final filterState = ref.watch(filterProvider);
    final preferences = ref.watch(preferencesProvider).asData?.value ?? const UserPreferences();
    final viewMode = preferences.defaultViewMode;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar & Title
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
                            'Dilekler',
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
                    hintText: 'Dileklerini veya öğrenmek istediklerini ara...',
                    hasActiveFilter: filterState.selectedType != null ||
                        filterState.selectedStatus != null ||
                        filterState.selectedCollectionId != null ||
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

            // Type Filter Horizontal Bar
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  CategoryChip(
                    label: 'Tümü',
                    isSelected: filterState.selectedType == null && !filterState.favoritesOnly,
                    onTap: () {
                      ref.read(filterProvider.notifier).setTypeFilter(null);
                      if (filterState.favoritesOnly) {
                        ref.read(filterProvider.notifier).toggleFavoritesOnly();
                      }
                    },
                  ),
                  ...WishType.values.map((type) {
                    return CategoryChip(
                      label: type.label,
                      isSelected: filterState.selectedType == type,
                      onTap: () {
                        ref.read(filterProvider.notifier).setTypeFilter(
                          filterState.selectedType == type ? null : type,
                        );
                      },
                    );
                  }),
                  CategoryChip(
                    label: '♡ Favoriler',
                    isSelected: filterState.favoritesOnly,
                    onTap: () {
                      ref.read(filterProvider.notifier).toggleFavoritesOnly();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Wish Items Grid / List Area
            Expanded(
              child: filteredItems.isEmpty
                  ? EmptyStateWidget.search(
                      onResetFilter: () {
                        ref.read(filterProvider.notifier).resetFilters();
                      },
                    )
                  : (viewMode == ViewMode.grid
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.76,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
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
                        )),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filterState = ref.watch(filterProvider);
    final collections = ref.watch(collectionProvider).asData?.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
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
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () {
                  ref.read(filterProvider.notifier).resetFilters();
                  Navigator.pop(context);
                },
                child: const Text('Sıfırla', style: TextStyle(color: AppColors.cherryAccent)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Filter
          Text('DURUM', style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: WishStatus.values.map((st) {
              final isSelected = filterState.selectedStatus == st;
              return ChoiceChip(
                label: Text(st.label),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(filterProvider.notifier).setStatusFilter(selected ? st : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Collection Filter
          if (collections.isNotEmpty) ...[
            Text('KOLEKSİYON', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: collections.map((col) {
                final isSelected = filterState.selectedCollectionId == col.id;
                return ChoiceChip(
                  label: Text('${col.emoji} ${col.name}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(filterProvider.notifier).setCollectionFilter(selected ? col.id : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Sort Options
          Text('SIRALAMA', style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SortOption.values.map((opt) {
              final isSelected = filterState.sortOption == opt;
              return ChoiceChip(
                label: Text(opt.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(filterProvider.notifier).setSortOption(opt);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Apply Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cherryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Sonuçları Göster', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
