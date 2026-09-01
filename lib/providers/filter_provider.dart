import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist_item.dart';
import 'wishlist_provider.dart';

enum SortOption { dateNewest, dateOldest, priceLowToHigh, priceHighToLow, titleAsc }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.dateNewest:
        return 'En Yeni';
      case SortOption.dateOldest:
        return 'En Eski';
      case SortOption.priceLowToHigh:
        return 'Fiyat: Düşükten Yükseğe';
      case SortOption.priceHighToLow:
        return 'Fiyat: Yüksekten Düşüğe';
      case SortOption.titleAsc:
        return 'İsim (A-Z)';
    }
  }
}

class FilterState {
  final String searchQuery;
  final String? selectedCollectionId;
  final ItemPriority? selectedPriority;
  final SortOption sortOption;
  final bool favoritesOnly;

  const FilterState({
    this.searchQuery = '',
    this.selectedCollectionId,
    this.selectedPriority,
    this.sortOption = SortOption.dateNewest,
    this.favoritesOnly = false,
  });

  FilterState copyWith({
    String? searchQuery,
    String? selectedCollectionId,
    bool clearCollection = false,
    ItemPriority? selectedPriority,
    bool clearPriority = false,
    SortOption? sortOption,
    bool? favoritesOnly,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCollectionId: clearCollection ? null : (selectedCollectionId ?? this.selectedCollectionId),
      selectedPriority: clearPriority ? null : (selectedPriority ?? this.selectedPriority),
      sortOption: sortOption ?? this.sortOption,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

class FilterNotifier extends Notifier<FilterState> {
  @override
  FilterState build() => const FilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCollectionFilter(String? collectionId) {
    if (collectionId == null) {
      state = state.copyWith(clearCollection: true);
    } else {
      state = state.copyWith(selectedCollectionId: collectionId);
    }
  }

  void setPriorityFilter(ItemPriority? priority) {
    if (priority == null) {
      state = state.copyWith(clearPriority: true);
    } else {
      state = state.copyWith(selectedPriority: priority);
    }
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void toggleFavoritesOnly() {
    state = state.copyWith(favoritesOnly: !state.favoritesOnly);
  }

  void resetFilters() {
    state = const FilterState();
  }
}

final filterProvider = NotifierProvider<FilterNotifier, FilterState>(FilterNotifier.new);

/// Computes filtered and sorted wishlist items
final filteredWishlistProvider = Provider<List<WishlistItem>>((ref) {
  final allItems = ref.watch(wishlistProvider);
  final filter = ref.watch(filterProvider);

  var result = [...allItems];

  // 1. Search Query Filter
  if (filter.searchQuery.trim().isNotEmpty) {
    final query = filter.searchQuery.trim().toLowerCase();
    result = result.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query);
      final storeMatch = item.store?.toLowerCase().contains(query) ?? false;
      final notesMatch = item.notes?.toLowerCase().contains(query) ?? false;
      return titleMatch || storeMatch || notesMatch;
    }).toList();
  }

  // 2. Collection Filter
  if (filter.selectedCollectionId != null) {
    result = result.where((item) => item.collectionId == filter.selectedCollectionId).toList();
  }

  // 3. Priority Filter
  if (filter.selectedPriority != null) {
    result = result.where((item) => item.priority == filter.selectedPriority).toList();
  }

  // 4. Favorites Filter
  if (filter.favoritesOnly) {
    result = result.where((item) => item.isFavorite).toList();
  }

  // 5. Sorting
  switch (filter.sortOption) {
    case SortOption.dateNewest:
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOption.dateOldest:
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortOption.priceLowToHigh:
      result.sort((a, b) => a.price.compareTo(b.price));
      break;
    case SortOption.priceHighToLow:
      result.sort((a, b) => b.price.compareTo(a.price));
      break;
    case SortOption.titleAsc:
      result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      break;
  }

  return result;
});
