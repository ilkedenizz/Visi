import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visi/core/utils/url_validator.dart';
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
        productUrl: 'https://leica.com/camera',
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
      expect(restored.productUrl, equals('https://leica.com/camera'));
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

  group('Vişi Quick Add & UrlValidator Test', () {
    test('UrlValidator correctly validates valid HTTP/HTTPS URLs', () {
      final res1 = UrlValidator.validate('https://zara.com/tr/tr/elbise-p0123.html');
      expect(res1.isValid, isTrue);
      expect(res1.formattedUrl, equals('https://zara.com/tr/tr/elbise-p0123.html'));

      final res2 = UrlValidator.validate('http://amazon.com.tr/dp/B08N5WRWNW');
      expect(res2.isValid, isTrue);
      expect(res2.formattedUrl, equals('http://amazon.com.tr/dp/B08N5WRWNW'));
    });

    test('UrlValidator automatically prepends https:// when scheme is missing', () {
      final res = UrlValidator.validate('zara.com/tr/tr/elbise-p0123.html');
      expect(res.isValid, isTrue);
      expect(res.formattedUrl, equals('https://zara.com/tr/tr/elbise-p0123.html'));
    });

    test('UrlValidator rejects empty and malformed input gracefully', () {
      final resEmpty = UrlValidator.validate('   ');
      expect(resEmpty.isValid, isFalse);
      expect(resEmpty.errorMessage, contains('Lütfen bir bağlantı adresi girin'));

      final resInvalid = UrlValidator.validate('not_a_url');
      expect(resInvalid.isValid, isFalse);
      expect(resInvalid.errorMessage, contains('Geçerli bir'));
    });

    test('UrlValidator normalizes URLs for duplicate detection', () {
      final norm1 = UrlValidator.normalizeForComparison('https://Zara.com/dress/');
      final norm2 = UrlValidator.normalizeForComparison('zara.com/dress');

      expect(norm1, equals(norm2));
    });
  });

  group('Vişi StorageService & Persistence Test', () {
    test('StorageService initializes seed data on first launch', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      final items = storage.getWishlistItems();
      final collections = storage.getCollections();

      expect(items.isNotEmpty, isTrue);
      expect(collections.isNotEmpty, isTrue);
    });

    test('StorageService persists Quick Add item with productUrl correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      final newItem = WishlistItem(
        id: 'quick_add_1',
        title: 'Yeni dilek',
        price: 0,
        currency: '₺',
        productUrl: 'https://beymen.com/p_parfum_123',
        collectionId: 'col_dream',
        createdAt: DateTime.now(),
      );

      final current = storage.getWishlistItems();
      await storage.saveWishlistItems([...current, newItem]);

      final reloadedStorage = await StorageService.init();
      final reloadedItems = reloadedStorage.getWishlistItems();

      final found = reloadedItems.firstWhere((i) => i.id == 'quick_add_1');
      expect(found.title, equals('Yeni dilek'));
      expect(found.productUrl, equals('https://beymen.com/p_parfum_123'));
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
