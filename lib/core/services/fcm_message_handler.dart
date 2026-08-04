import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

/// Pure FCM payload dispatcher.
///
/// Decides what an incoming push should do in-app based on its `type`
/// field. The incoming-call presentation is delegated through
/// [onIncomingCall] so this handler never depends on a specific feature.
class FcmMessageHandler {
  FcmMessageHandler._();

  /// Invoked with the payload when an `incoming_call` message arrives.
  /// Registered by the IncomingCallController so navigation stays inside
  /// the call feature.
  static void Function(Map<String, String> data)? onIncomingCall;

  /// An incoming-call payload received before the app was ready to present
  /// it (e.g. cold start from a terminated notification tap). Consumed once
  /// the app finishes booting.
  static Map<String, String>? _pendingIncomingCall;

  static Map<String, String>? takePendingIncomingCall() {
    final pending = _pendingIncomingCall;
    _pendingIncomingCall = null;
    return pending;
  }

  static void rememberPendingIncomingCall(Map<String, String> data) {
    _pendingIncomingCall = data;
  }

  /// Route a received message to the correct in-app behavior.
  static void handle(RemoteMessage message) {
    // FCM data payloads arrive as string-keyed string values; normalize to a
    // Map<String, String> so downstream handlers have a stable type.
    final data = message.data.map((key, value) => MapEntry(key, value.toString()));
    switch (data['type']) {
      case 'incoming_call':
        _dispatchIncomingCall(data);
        break;
      case 'call_rejected':
        _showSnackbar(
          title: data['title'] ?? 'Call Declined',
          body: data['body'] ?? 'The patient declined your consultation call.',
          icon: Icons.phone_disabled,
          color: AppColors.warning,
        );
        break;
      case 'call_missed':
        _showSnackbar(
          title: data['title'] ?? 'Call Missed',
          body:
              data['body'] ?? 'The patient did not answer your consultation call.',
          icon: Icons.call_missed,
          color: AppColors.warning,
        );
        break;
      case 'call_ended':
        _showSnackbar(
          title: data['title'] ?? 'Call Ended',
          body: data['body'] ?? 'The doctor ended the call.',
          icon: Icons.call_end,
          color: AppColors.grey,
        );
        break;
      default:
        _showDefaultSnackbar(message);
        break;
    }
  }

  static void _dispatchIncomingCall(Map<String, String> data) {
    final handler = onIncomingCall;
    if (handler == null) {
      rememberPendingIncomingCall(data);
      return;
    }
    handler(data);
  }

  static void _showDefaultSnackbar(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    final title = data['title'] ?? notification?.title ?? 'Notification';
    final body = data['body'] ?? notification?.body ?? '';

    Get.snackbar(
      title.toString(),
      body.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.notifications_active, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  static void _showSnackbar({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
  }) {
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: true,
    );
  }
}
