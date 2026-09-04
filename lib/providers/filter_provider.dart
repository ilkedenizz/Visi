import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_status.dart';
import '../models/wish_type.dart';
import '../models/wishlist_item.dart';
import 'wishlist_provider.dart';

enum SortOption { dateNewest, dateOldest, priorityHighToLow, titleAsc }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.dateNewest:
        return 'En Yeni';
      case SortOption.dateOldest:
        return 'En Eski';
      case SortOption.priorityHighToLow:
        return 'Öncelik: Yüksekten Düşüğe';
      case SortOption.titleAsc:
        return 'İsim (A-Z)';
    }
  }
}

/// Normalizes Turkish characters for friendly search matching
String normalizeTurkishText(String text) {
  var result = text.toLowerCase();
  result = result
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ğ', 'g')
      .replaceAll('Ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('Ü', 'u')
      .replaceAll('ş', 's')
      .replaceAll('Ş', 's')
      .replaceAll('ö', 'o')
      .replaceAll('Ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll('Ç', 'c');
  return result;
}

class FilterState {
  final String searchQuery;
  final WishType? selectedType;
  final WishStatus? selectedStatus;
  final String? selectedCollectionId;
  final ItemPriority? selectedPriority;
  final SortOption sortOption;
  final bool favoritesOnly;

  const FilterState({
    this.searchQuery = '',
    this.selectedType,
    this.selectedStatus,
    this.selectedCollectionId,
    this.selectedPriority,
    this.sortOption = SortOption.dateNewest,
    this.favoritesOnly = false,
  });

  FilterState copyWith({
    String? searchQuery,
    WishType? selectedType,
    bool clearType = false,
    WishStatus? selectedStatus,
    bool clearStatus = false,
    String? selectedCollectionId,
    bool clearCollection = false,
    ItemPriority? selectedPriority,
    bool clearPriority = false,
    SortOption? sortOption,
    bool? favoritesOnly,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
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

  void setTypeFilter(WishType? type) {
    if (type == null) {
      state = state.copyWith(clearType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
  }

  void setStatusFilter(WishStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
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
  final allItems = ref.watch(wishlistProvider).asData?.value ?? [];
  final filter = ref.watch(filterProvider);

  var result = [...allItems];

  // 1. Search Query Filter with Turkish Normalization
  if (filter.searchQuery.trim().isNotEmpty) {
    final rawQuery = filter.searchQuery.trim().toLowerCase();
    final normQuery = normalizeTurkishText(filter.searchQuery.trim());

    result = result.where((item) {
      final rawTitle = item.title.toLowerCase();
      final normTitle = normalizeTurkishText(item.title);
      final rawType = item.type.label.toLowerCase();
      final normType = normalizeTurkishText(item.type.label);
      final rawStore = item.store?.toLowerCase() ?? '';
      final normStore = normalizeTurkishText(item.store ?? '');
      final rawNotes = item.notes?.toLowerCase() ?? '';
      final normNotes = normalizeTurkishText(item.notes ?? '');

      final titleMatch = rawTitle.contains(rawQuery) || normTitle.contains(normQuery);
      final typeMatch = rawType.contains(rawQuery) || normType.contains(normQuery);
      final storeMatch = rawStore.contains(rawQuery) || normStore.contains(normQuery);
      final notesMatch = rawNotes.contains(rawQuery) || normNotes.contains(normQuery);

      return titleMatch || typeMatch || storeMatch || notesMatch;
    }).toList();
  }

  // 2. Type Filter
  if (filter.selectedType != null) {
    result = result.where((item) => item.type == filter.selectedType).toList();
  }

  // 3. Status Filter
  if (filter.selectedStatus != null) {
    result = result.where((item) => item.status == filter.selectedStatus).toList();
  }

  // 4. Collection Filter
  if (filter.selectedCollectionId != null) {
    result = result.where((item) => item.collectionId == filter.selectedCollectionId).toList();
  }

  // 5. Priority Filter
  if (filter.selectedPriority != null) {
    result = result.where((item) => item.priority == filter.selectedPriority).toList();
  }

  // 6. Favorites Filter
  if (filter.favoritesOnly) {
    result = result.where((item) => item.isFavorite).toList();
  }

  // 7. Sorting
  switch (filter.sortOption) {
    case SortOption.dateNewest:
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOption.dateOldest:
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortOption.priorityHighToLow:
      result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      break;
    case SortOption.titleAsc:
      result.sort((a, b) => normalizeTurkishText(a.title).compareTo(normalizeTurkishText(b.title)));
      break;
  }

  return result;
});
