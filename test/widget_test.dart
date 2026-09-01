import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visi/models/collection_model.dart';
import 'package:visi/models/wishlist_item.dart';
import 'package:visi/services/storage_service.dart';
import 'package:visi/widgets/visi_cherry_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vişi Models Test', () {
    test('WishlistItem json serialization and copyWith works correctly', () {
      final now = DateTime.now();
      final item = WishlistItem(
        id: 'test_1',
        title: 'Leica Camera',
        price: 150000,
        currency: '₺',
        store: 'Leica',
        collectionId: 'col_dream',
        priority: ItemPriority.high,
        isFavorite: true,
        createdAt: now,
      );

      final jsonStr = item.toJson();
      final restored = WishlistItem.fromJson(jsonStr);

      expect(restored.id, equals('test_1'));
      expect(restored.title, equals('Leica Camera'));
      expect(restored.price, equals(150000));
      expect(restored.isFavorite, isTrue);
      expect(restored.priority, equals(ItemPriority.high));

      final updated = item.copyWith(isFavorite: false, price: 160000);
      expect(updated.isFavorite, isFalse);
      expect(updated.price, equals(160000));
      expect(updated.title, equals('Leica Camera'));
    });

    test('CollectionModel json serialization works correctly', () {
      final col = CollectionModel(
        id: 'col_1',
        name: 'Fashion',
        emoji: '👗',
        createdAt: DateTime.now(),
      );

      final jsonStr = col.toJson();
      final restored = CollectionModel.fromJson(jsonStr);

      expect(restored.id, equals('col_1'));
      expect(restored.name, equals('Fashion'));
      expect(restored.emoji, equals('👗'));
    });
  });

  group('Vişi StorageService Test', () {
    test('StorageService initializes seed data on first launch', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      final items = storage.getWishlistItems();
      final collections = storage.getCollections();

      expect(items.isNotEmpty, isTrue);
      expect(collections.isNotEmpty, isTrue);
    });
  });

  group('Vişi Widgets Test', () {
    testWidgets('VisiCherryLogo renders custom painter without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VisiCherryLogo(size: 40),
            ),
          ),
        ),
      );

      expect(find.byType(VisiCherryLogo), findsOneWidget);
    });
  });
}
