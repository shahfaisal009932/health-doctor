import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_message_handler.dart';

/// Handles Firebase Cloud Messaging: token management and message routing.
///
/// Foreground messages, background-tap openings and cold-start (terminated)
/// launches are all routed through [FcmMessageHandler], which dispatches
/// them to the correct in-app behavior (snackbars, incoming-call screen).
/// The background handler is registered at the library level (see
/// [firebaseMessagingBackgroundHandler]).
class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Present notifications in the foreground on supported platforms.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(FcmMessageHandler.handle);

    // App was in the background when the user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen(FcmMessageHandler.handle);

    // App was terminated when the user tapped the notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      FcmMessageHandler.handle(initialMessage);
    }
  }

  /// Request the current FCM registration token.
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Watch for token refreshes so the stored token stays in sync.
  static Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}

/// Required background message handler (must be a top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI work allowed here; logging only. Payload is delivered via the
  // system notification tray automatically.
  // ignore: avoid_print
  print('Background FCM message: ${message.messageId}');
}
