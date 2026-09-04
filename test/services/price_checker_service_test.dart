import 'package:flutter_test/flutter_test.dart';
import 'package:visi/models/price_alert.dart';
import 'package:visi/services/price_checker_service.dart';

void main() {
  group('PriceCheckerService - Price String Parsing & Normalization', () {
    test('parses Turkish standard format 1.299,99 ₺', () {
      final price = PriceCheckerService.parsePriceString('1.299,99 ₺');
      expect(price, equals(1299.99));
    });

    test('parses comma decimal format 1299,99', () {
      final price = PriceCheckerService.parsePriceString('1299,99');
      expect(price, equals(1299.99));
    });

    test('parses US dot format 1,299.99', () {
      final price = PriceCheckerService.parsePriceString('1,299.99');
      expect(price, equals(1299.99));
    });

    test('parses plain numeric string 1299.99', () {
      final price = PriceCheckerService.parsePriceString('1299.99');
      expect(price, equals(1299.99));
    });

    test('parses symbol leading format ₺1.299,99', () {
      final price = PriceCheckerService.parsePriceString('₺1.299,99');
      expect(price, equals(1299.99));
    });

    test('parses Euro format €99,99', () {
      final price = PriceCheckerService.parsePriceString('€99,99');
      expect(price, equals(99.99));
    });

    test('parses Dollar format \$99.99', () {
      final price = PriceCheckerService.parsePriceString(r'$99.99');
      expect(price, equals(99.99));
    });

    test('normalizes currency codes and symbols', () {
      expect(PriceCheckerService.normalizeCurrency('TRY'), equals('₺'));
      expect(PriceCheckerService.normalizeCurrency('TL'), equals('₺'));
      expect(PriceCheckerService.normalizeCurrency('USD'), equals(r'$'));
      expect(PriceCheckerService.normalizeCurrency('EUR'), equals('€'));
      expect(PriceCheckerService.normalizeCurrency('GBP'), equals('£'));
    });
  });

  group('PriceCheckerService - HTML Parsing (JSON-LD & OpenGraph)', () {
    test('parses HTML with JSON-LD Product & Offer', () {
      const html = '''
        <!DOCTYPE html>
        <html>
        <head>
          <script type="application/ld+json">
          {
            "@context": "https://schema.org/",
            "@type": "Product",
            "name": "Spor Ayakkabı",
            "offers": {
              "@type": "Offer",
              "priceCurrency": "TRY",
              "price": "2499.90"
            }
          }
          </script>
        </head>
        <body></body>
        </html>
      ''';

      final result = PriceCheckerService.parseHtmlContent(html);
      expect(result.status, equals(PriceCheckStatus.success));
      expect(result.price, equals(2499.90));
      expect(result.currency, equals('₺'));
    });

    test('parses HTML with OpenGraph meta tags', () {
      const html = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta property="og:price:amount" content="1899.00" />
          <meta property="og:price:currency" content="TRY" />
        </head>
        <body></body>
        </html>
      ''';

      final result = PriceCheckerService.parseHtmlContent(html);
      expect(result.status, equals(PriceCheckStatus.success));
      expect(result.price, equals(1899.00));
      expect(result.currency, equals('₺'));
    });

    test('returns unsupported for HTML without price metadata', () {
      const html = '''
        <!DOCTYPE html>
        <html>
        <head><title>Sadece Başlık</title></head>
        <body><p>Ürün açıklaması burada duruyor.</p></body>
        </html>
      ''';

      final result = PriceCheckerService.parseHtmlContent(html);
      expect(result.status, equals(PriceCheckStatus.unsupported));
      expect(result.price, isNull);
    });

    test('PriceAlert model tracks price drop state correctly', () {
      final alert = PriceAlert(
        wishId: 'w1',
        enabled: true,
        lastKnownPrice: 1000.0,
        status: PriceAlertStatus.idle,
      );

      final updated = alert.copyWith(
        lastKnownPrice: 850.0,
        status: PriceAlertStatus.priceDrop,
      );

      expect(updated.status, equals(PriceAlertStatus.priceDrop));
      expect(updated.lastKnownPrice, equals(850.0));
    });
  });
}
