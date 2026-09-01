import 'dart:async';

/// Service interface preparing Vişi for receiving product URLs from external sources
/// (such as Android Share Sheet / Share Intents or deep links)
abstract class UrlCaptureService {
  /// Check if the app was launched with a shared URL
  Future<String?> getInitialSharedUrl();

  /// Stream of shared URLs received while the app is running
  Stream<String> get sharedUrlStream;
}

/// Default local-first stub implementation of UrlCaptureService
class DefaultUrlCaptureService implements UrlCaptureService {
  final StreamController<String> _controller = StreamController<String>.broadcast();

  @override
  Future<String?> getInitialSharedUrl() async {
    // Ready for future integration with native plugins (e.g. receive_sharing_intent)
    return null;
  }

  @override
  Stream<String> get sharedUrlStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
