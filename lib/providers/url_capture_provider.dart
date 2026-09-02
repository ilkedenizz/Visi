import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/url_capture_service.dart';

final urlCaptureServiceProvider = Provider<UrlCaptureService>((ref) {
  final service = MethodChannelUrlCaptureService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
