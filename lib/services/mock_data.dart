import '../models/collection_model.dart';
import '../models/wish_status.dart';
import '../models/wish_type.dart';
import '../models/wishlist_item.dart';

class MockData {
  MockData._();

  static final List<CollectionModel> sampleCollections = [
    CollectionModel(
      id: 'col_dream',
      name: 'Hayallerim',
      emoji: '✨',
      accentColorHex: '#B8324A',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    CollectionModel(
      id: 'col_learn',
      name: 'Öğrenilecekler',
      emoji: '🧠',
      accentColorHex: '#E29578',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    CollectionModel(
      id: 'col_travel',
      name: 'Seyahat Hayalleri',
      emoji: '🌍',
      accentColorHex: '#7A9E9F',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    CollectionModel(
      id: 'col_to_own',
      name: 'Sahip Olmak İstediğim Parçalar',
      emoji: '🛍️',
      accentColorHex: '#8A9A86',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  static final List<WishlistItem> sampleItems = [
    WishlistItem(
      id: 'item_1',
      title: 'Gitar çalmayı öğrenmek',
      type: WishType.toLearn,
      status: WishStatus.starting,
      collectionId: 'col_learn',
      notes: 'Akustik gitar ile temel akorları öğrenip en sevdiğim şarkıları çalmak istiyorum.',
      priority: ItemPriority.high,
      isFavorite: true,
      targetDate: DateTime(2027),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WishlistItem(
      id: 'item_2',
      title: 'Japonya\'ya gitmek',
      type: WishType.toVisit,
      status: WishStatus.wishing,
      collectionId: 'col_travel',
      notes: 'Tokyo, Kyoto ve Osaka\'yı kiraz çiçekleri mevsiminde gezmek.',
      priority: ItemPriority.high,
      isFavorite: true,
      targetDate: DateTime(2027, 4),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    WishlistItem(
      id: 'item_3',
      title: 'Tenis oynamaya başlamak',
      type: WishType.toDo,
      status: WishStatus.starting,
      collectionId: 'col_dream',
      notes: 'Haftada iki gün kortta antrenman yapmak ve temel vuruşları geliştirmek.',
      priority: ItemPriority.medium,
      isFavorite: false,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    WishlistItem(
      id: 'item_4',
      title: 'Bang & Olufsen Beoplay H95 Kulaklık',
      type: WishType.toOwn,
      status: WishStatus.wishing,
      price: 32900.0,
      currency: '₺',
      store: 'Bang & Olufsen TR',
      productUrl: 'https://www.bang-olufsen.com',
      collectionId: 'col_to_own',
      notes: 'Odaklanma saatleri ve seyahatler için premium kulaklık.',
      priority: ItemPriority.medium,
      isFavorite: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WishlistItem(
      id: 'item_5',
      title: 'Kendi dijital uygulamasını yayınlamak',
      type: WishType.dream,
      status: WishStatus.fulfilled,
      collectionId: 'col_dream',
      notes: 'İnsanların hayatına dokunan estetik ve işlevsel bir uygulama geliştirmek. ✨',
      priority: ItemPriority.high,
      isFavorite: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];
}
