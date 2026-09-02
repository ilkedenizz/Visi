import 'dart:async';
import 'package:flutter/services.dart';

/// Service interface for receiving shared text/URLs from external sources
/// (such as Android Share Sheet / Share Intents)
abstract class UrlCaptureService {
  /// Check if the app was launched with a shared URL (Cold Start)
  Future<String?> getInitialSharedUrl();

  /// Stream of shared URLs received while the app is running (Warm Start)
  Stream<String> get sharedUrlStream;

  void dispose();
}

/// Production MethodChannel implementation of UrlCaptureService for Android Share Intent
class MethodChannelUrlCaptureService implements UrlCaptureService {
  static const MethodChannel _channel = MethodChannel('com.visi.app/share_intent');
  final StreamController<String> _controller = StreamController<String>.broadcast();

  MethodChannelUrlCaptureService() {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    if (call.method == 'onSharedTextReceived') {
      final String? text = call.arguments as String?;
      if (text != null && text.isNotEmpty) {
        _controller.add(text);
      }
    }
  }

  @override
  Future<String?> getInitialSharedUrl() async {
    try {
      final String? initialText = await _channel.invokeMethod<String>('getInitialSharedText');
      return initialText;
    } on PlatformException catch (_) {
      return null;
    }
  }

  @override
  Stream<String> get sharedUrlStream => _controller.stream;

  @override
  void dispose() {
    _controller.close();
  }
}
