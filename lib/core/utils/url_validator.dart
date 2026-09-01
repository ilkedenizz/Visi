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

/// Helper for Quick Add URL Validation & Normalization
class UrlValidator {
  UrlValidator._();

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
