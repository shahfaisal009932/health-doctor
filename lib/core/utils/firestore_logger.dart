import 'package:flutter/foundation.dart';

/// Lightweight debug logger for Firestore operations.
class FirestoreLogger {
  FirestoreLogger._();

  /// Log before a Firestore operation so a failing request is identifiable.
  static void log({
    required String collection,
    required String operation,
    String? details,
  }) {
    debugPrint(
      '[Firestore] $collection.$operation${details == null ? '' : ' | $details'}',
    );
  }

  /// Log an error raised by a Firestore operation.
  static void logError({
    required String collection,
    required String operation,
    required Object error,
  }) {
    debugPrint('[Firestore] $collection.$operation FAILED | $error');
  }
}
