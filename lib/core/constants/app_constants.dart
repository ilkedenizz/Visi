class AppConstants {
  AppConstants._();

  static const String appName = 'Vişi';
  static const String appTagline = 'Senin kişisel dilek listen';

  // Storage Keys
  static const String storageKeyWishlistItems = 'visi_wishlist_items_v1';
  static const String storageKeyCollections = 'visi_collections_v1';
  static const String storageKeyPreferences = 'visi_preferences_v1';
  static const String storageKeyIsFirstLaunch = 'visi_is_first_launch_v1';

  // Default Currencies
  static const List<String> currencies = ['TRY (₺)', 'USD (\$)', 'EUR (€)', 'GBP (£)', 'JPY (¥)'];
  static const String defaultCurrency = '₺';

  // Item Priority levels
  static const String priorityLow = 'Düşük';
  static const String priorityMedium = 'Orta';
  static const String priorityHigh = 'Yüksek';

  static const List<String> priorities = [priorityLow, priorityMedium, priorityHigh];
}
