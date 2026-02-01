import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles FCM: foreground and background.
/// UI/Cubits never touch Firebase Messaging; only this service and main (setup).
/// Background handler must be top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message (e.g. log, persist, no UI).
}

class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  /// Request permission (iOS). Call once after app start or before subscribing.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return true;
  }

  /// FCM token for backend (e.g. send to API after login).
  Future<String?> getToken() => _messaging.getToken();

  /// Foreground: listen to messages (show in-app or snackbar via stream/callback).
  void onMessage(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessage.listen(handler);
  }

  /// When user taps notification that opened the app.
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  /// Initial message if app was opened from terminated state via notification.
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();
}
