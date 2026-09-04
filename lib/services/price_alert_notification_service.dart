import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class PriceAlertNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'price_alerts';
  static const String channelName = 'Fiyat Düşüşleri';
  static const String channelDescription =
      'Takip ettiğin ürünlerde fiyat düştüğünde bildirim gönderir.';

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );

    // Request permissions on Android 13+
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    _initialized = true;
  }

  static Future<void> showPriceDrop({
    required String title,
    required String body,
    int? notificationId,
    String? payload,
    bool? overrideNotificationsEnabled,
  }) async {
    if (kIsWeb) return;

    // Check user preferences
    if (overrideNotificationsEnabled == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawPrefs = prefs.getString(AppConstants.storageKeyPreferences);
        if (rawPrefs != null && rawPrefs.contains('"notificationsEnabled":false')) {
          return; // Notifications disabled by user
        }
      } catch (_) {}
    } else if (!overrideNotificationsEnabled) {
      return;
    }

    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final id = notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
