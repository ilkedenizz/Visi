import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

enum PriceCheckStatus {
  success,
  unsupported,
  networkError,
  parseError,
}

class PriceCheckResult {
  final double? price;
  final String? currency;
  final PriceCheckStatus status;
  final String? errorMessage;

  const PriceCheckResult({
    this.price,
    this.currency,
    required this.status,
    this.errorMessage,
  });

  bool get isSuccess => status == PriceCheckStatus.success && price != null;
}

class PriceCheckerService {
  static Future<PriceCheckResult> checkPrice(
    String url, {
    http.Client? client,
  }) async {
    // Web / CORS restriction
    if (kIsWeb) {
      return const PriceCheckResult(
        status: PriceCheckStatus.unsupported,
        errorMessage: 'Bu site web üzerinden otomatik kontrol edilemiyor.',
      );
    }

    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      return const PriceCheckResult(
        status: PriceCheckStatus.parseError,
        errorMessage: 'Geçersiz ürün bağlantısı.',
      );
    }

    final uri = Uri.tryParse(cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl');
    if (uri == null || !uri.hasAuthority) {
      return const PriceCheckResult(
        status: PriceCheckStatus.parseError,
        errorMessage: 'Geçersiz URL formatı.',
      );
    }

    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        return PriceCheckResult(
          status: PriceCheckStatus.networkError,
          errorMessage: 'Sunucudan yanıt alınamadı (HTTP ${response.statusCode}).',
        );
      }

      final htmlContent = response.body;
      return parseHtmlContent(htmlContent);
    } catch (e) {
      return PriceCheckResult(
        status: PriceCheckStatus.networkError,
        errorMessage: 'Bağlantı hatası: ${e.toString()}',
      );
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  static PriceCheckResult parseHtmlContent(String htmlContent) {
    if (htmlContent.trim().isEmpty) {
      return const PriceCheckResult(
        status: PriceCheckStatus.parseError,
        errorMessage: 'Boş içerik alındı.',
      );
    }

    final document = html_parser.parse(htmlContent);

    // 1. Check JSON-LD / Schema.org
    final jsonLdScripts = document.querySelectorAll('script[type="application/ld+json"]');
    for (final script in jsonLdScripts) {
      final text = script.text.trim();
      if (text.isEmpty) continue;

      try {
        final decoded = json.decode(text);
        final result = _searchJsonLdForPrice(decoded);
        if (result != null && result.price != null && result.price! > 0) {
          return PriceCheckResult(
            price: result.price,
            currency: result.currency ?? '₺',
            status: PriceCheckStatus.success,
          );
        }
      } catch (_) {
        // Skip invalid JSON-LD blocks
      }
    }

    // 2. Check OpenGraph / Meta Tags
    final metaAmount = document
            .querySelector('meta[property="og:price:amount"]')
            ?.attributes['content'] ??
        document
            .querySelector('meta[property="product:price:amount"]')
            ?.attributes['content'] ??
        document
            .querySelector('meta[name="twitter:data1"]')
            ?.attributes['content'] ??
        document
            .querySelector('meta[itemprop="price"]')
            ?.attributes['content'];

    final metaCurrencyRaw = document
            .querySelector('meta[property="og:price:currency"]')
            ?.attributes['content'] ??
        document
            .querySelector('meta[property="product:price:currency"]')
            ?.attributes['content'] ??
        document
            .querySelector('meta[itemprop="priceCurrency"]')
            ?.attributes['content'];

    if (metaAmount != null && metaAmount.isNotEmpty) {
      final parsedPrice = parsePriceString(metaAmount);
      if (parsedPrice != null && parsedPrice > 0) {
        final currency = normalizeCurrency(metaCurrencyRaw ?? extractCurrencySymbol(metaAmount));
        return PriceCheckResult(
          price: parsedPrice,
          currency: currency,
          status: PriceCheckStatus.success,
        );
      }
    }

    return const PriceCheckResult(
      status: PriceCheckStatus.unsupported,
      errorMessage: 'Bu siteden fiyat otomatik okunamıyor.',
    );
  }

  static _ParsedPriceResult? _searchJsonLdForPrice(dynamic jsonObj) {
    if (jsonObj == null) return null;

    if (jsonObj is List) {
      for (final item in jsonObj) {
        final res = _searchJsonLdForPrice(item);
        if (res != null) return res;
      }
      return null;
    }

    if (jsonObj is Map<String, dynamic>) {
      final type = jsonObj['@type']?.toString();

      // If this object is an Offer or AggregateOffer
      if (type == 'Offer' || type == 'AggregateOffer') {
        final priceRaw = jsonObj['price'] ?? jsonObj['lowPrice'];
        final currRaw = jsonObj['priceCurrency']?.toString();
        if (priceRaw != null) {
          final p = parsePriceString(priceRaw.toString());
          if (p != null && p > 0) {
            return _ParsedPriceResult(p, normalizeCurrency(currRaw));
          }
        }
      }

      // If Product with offers
      if (jsonObj.containsKey('offers')) {
        final res = _searchJsonLdForPrice(jsonObj['offers']);
        if (res != null) return res;
      }

      // Recursive search in values
      for (final value in jsonObj.values) {
        if (value is Map || value is List) {
          final res = _searchJsonLdForPrice(value);
          if (res != null) return res;
        }
      }
    }

    return null;
  }

  static double? parsePriceString(String raw) {
    if (raw.trim().isEmpty) return null;

    // Remove any non-numeric/punctuation chars except digits, dots, commas
    final cleaned = raw.replaceAll(RegExp(r'[^\d.,]'), '').trim();
    if (cleaned.isEmpty) return null;

    try {
      // Handle Turkish format "1.299,99" -> "1299.99"
      if (cleaned.contains('.') && cleaned.contains(',')) {
        final lastDot = cleaned.lastIndexOf('.');
        final lastComma = cleaned.lastIndexOf(',');
        if (lastComma > lastDot) {
          // Thousand separator is dot, decimal is comma: 1.299,99
          final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
          return double.tryParse(normalized);
        } else {
          // Thousand separator is comma, decimal is dot: 1,299.99
          final normalized = cleaned.replaceAll(',', '');
          return double.tryParse(normalized);
        }
      }

      // Handle comma decimal format "1299,99"
      if (cleaned.contains(',') && !cleaned.contains('.')) {
        final parts = cleaned.split(',');
        if (parts.length == 2 && parts[1].length <= 2) {
          final normalized = cleaned.replaceAll(',', '.');
          return double.tryParse(normalized);
        } else {
          // E.g. "1,299" -> 1299
          final normalized = cleaned.replaceAll(',', '');
          return double.tryParse(normalized);
        }
      }

      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }

  static String normalizeCurrency(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '₺';
    final upper = raw.trim().toUpperCase();

    if (upper.contains('TRY') || upper.contains('TL') || upper.contains('₺')) {
      return '₺';
    }
    if (upper.contains('USD') || upper.contains('\$')) {
      return '\$';
    }
    if (upper.contains('EUR') || upper.contains('€')) {
      return '€';
    }
    if (upper.contains('GBP') || upper.contains('£')) {
      return '£';
    }
    if (upper.contains('JPY') || upper.contains('¥')) {
      return '¥';
    }

    return raw.trim();
  }

  static String? extractCurrencySymbol(String raw) {
    if (raw.contains('₺') || raw.toUpperCase().contains('TL') || raw.toUpperCase().contains('TRY')) {
      return '₺';
    }
    if (raw.contains('\$') || raw.toUpperCase().contains('USD')) {
      return '\$';
    }
    if (raw.contains('€') || raw.toUpperCase().contains('EUR')) {
      return '€';
    }
    if (raw.contains('£') || raw.toUpperCase().contains('GBP')) {
      return '£';
    }
    if (raw.contains('¥') || raw.toUpperCase().contains('JPY')) {
      return '¥';
    }
    return null;
  }
}

class _ParsedPriceResult {
  final double? price;
  final String? currency;

  _ParsedPriceResult(this.price, this.currency);
}
