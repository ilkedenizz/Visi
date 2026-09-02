/// Result of validating a URL for Quick Add
class UrlValidationResult {
  final bool isValid;
  final String? formattedUrl;
  final String? errorMessage;

  const UrlValidationResult({
    required this.isValid,
    this.formattedUrl,
    this.errorMessage,
  });

  factory UrlValidationResult.valid(String url) {
    return UrlValidationResult(
      isValid: true,
      formattedUrl: url,
    );
  }

  factory UrlValidationResult.invalid(String message) {
    return UrlValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }
}

/// Helper for Quick Add & Share Intent URL Extraction, Validation & Normalization
class UrlValidator {
  UrlValidator._();

  /// Extracts a valid product URL from arbitrary text (e.g. Android Share Sheet EXTRA_TEXT)
  static String? extractUrl(String? text) {
    if (text == null || text.trim().isEmpty) return null;

    final trimmed = text.trim();

    // 1. Direct validation check if input has no spaces (raw URL)
    if (!trimmed.contains(' ') && !trimmed.contains('\n') && !trimmed.contains('\r')) {
      final directCheck = validate(trimmed);
      if (directCheck.isValid) {
        return directCheck.formattedUrl;
      }
    }

    // 2. Regex search for HTTP/HTTPS URLs or domain-like URL paths inside shared text
    final urlRegExp = RegExp(
      r'(https?:\/\/[^\s]+|[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\/[^\s]*)?)',
      caseSensitive: false,
    );

    final matches = urlRegExp.allMatches(trimmed);
    for (final match in matches) {
      final candidate = match.group(0);
      if (candidate != null) {
        // Strip common trailing punctuation in shared text (like . , ! ? ) ] " ')
        var cleaned = candidate.replaceAll(RegExp(r'[\.,!?)"\]]+$'), '');
        final validation = validate(cleaned);
        if (validation.isValid) {
          return validation.formattedUrl;
        }
      }
    }

    return null;
  }

  /// Validates and normalizes a product URL string
  static UrlValidationResult validate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return UrlValidationResult.invalid('Lütfen bir bağlantı adresi girin.');
    }

    var cleaned = input.trim();

    // If missing scheme, prepend https://
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'https://$cleaned';
    }

    final uri = Uri.tryParse(cleaned);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      return UrlValidationResult.invalid('Geçerli bir internet adresi girin (örn: https://zara.com/...)');
    }

    // Basic domain check: host must contain at least one dot or localhost
    if (!uri.host.contains('.') && uri.host != 'localhost') {
      return UrlValidationResult.invalid('Geçerli bir alan adı adresi girin (örn: site.com)');
    }

    return UrlValidationResult.valid(cleaned);
  }

  /// Quick boolean check if a string looks like a valid URL (e.g. for clipboard check)
  static bool isValidUrl(String? input) {
    final result = validate(input);
    return result.isValid;
  }

  /// Normalizes a URL for duplicate comparison (lowercasing, removing trailing slash & fragment)
  static String normalizeForComparison(String url) {
    var cleaned = url.trim().toLowerCase();
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'https://$cleaned';
    }
    final uri = Uri.tryParse(cleaned);
    if (uri != null) {
      var path = uri.path;
      if (path.endsWith('/') && path.length > 1) {
        path = path.substring(0, path.length - 1);
      }
      return '${uri.scheme}://${uri.host}$path${uri.hasQuery ? '?${uri.query}' : ''}';
    }
    return cleaned;
  }
}
