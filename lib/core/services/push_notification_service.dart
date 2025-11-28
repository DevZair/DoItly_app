import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('Получено фоновое уведомление: ${message.messageId}');
  }
}

class PushNotificationService {
  PushNotificationService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        debugPrint('Уведомления запрещены пользователем');
      }
      return;
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final apnsToken = await messaging.getAPNSToken();
    if (kDebugMode) {
      debugPrint('APNs токен: ${apnsToken ?? 'пока нет'}');
    }

    final isApplePlatform = [
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform);

    String? token;
    try {
      // На iOS/macOS выдача FCM токена возможна только после APNs токена.
      if (!isApplePlatform ||
          await messaging.getAPNSToken() != null) {
        token = await messaging.getToken();
      } else if (kDebugMode) {
        debugPrint('APNs токен ещё не получен, ждём onTokenRefresh');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Не удалось получить FCM токен сразу: $e');
      }
    }

    if (kDebugMode && token != null) {
      debugPrint('FCM токен: $token');
    }

    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint(
          'Получено уведомление в приложении: '
          '${message.notification?.title ?? ''} ${message.notification?.body ?? ''}',
        );
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        debugPrint('FCM токен обновлён: $newToken');
      }
    });

    _initialized = true;
  }
}
