import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

/// Maps Firebase authentication error codes to user-friendly messages.
class FirebaseErrorMapper {
  FirebaseErrorMapper._();

  /// Converts any thrown object into a user-friendly [AppException].
  static AppException map(dynamic error) {
    if (error is FirebaseAuthException) {
      return _mapAuthException(error);
    }
    if (error is FirebaseException) {
      return AppException(_mapFirestoreCode(error.code));
    }
    if (error is AppException) {
      return error;
    }
    if (error is String) {
      return AppException(error);
    }
    return AppException("Something went wrong. Please try again.");
  }

  static AppException _mapAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return const AppException(
          "Invalid email address. Please enter a valid email.",
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AppException(
          "This account has been disabled. Contact support.",
          code: 'user-disabled',
        );
      case 'user-not-found':
        return const AppException(
          "No account found with this email. Please check or register.",
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AppException(
          "Incorrect password. Please try again.",
          code: 'wrong-password',
        );
      case 'invalid-credential':
        return const AppException(
          "Incorrect email or password. Please try again.",
          code: 'invalid-credential',
        );
      case 'email-already-in-use':
        return const AppException(
          "This email is already registered. Please log in instead.",
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AppException(
          "Password is too weak. Use at least 6 characters.",
          code: 'weak-password',
        );
      case 'operation-not-allowed':
        return const AppException(
          "Email/password sign-in is not enabled. Contact support.",
          code: 'operation-not-allowed',
        );
      case 'too-many-requests':
        return const AppException(
          "Too many attempts. Please wait a while and try again.",
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return const AppException(
          "Network error. Please check your internet connection.",
          code: 'network-request-failed',
        );
      case 'requires-recent-login':
        return const AppException(
          "This action requires recent login. Please log in again.",
          code: 'requires-recent-login',
        );
      default:
        return AppException(
          error.message ?? "Authentication failed. Please try again.",
          code: error.code,
        );
    }
  }

  static String _mapFirestoreCode(String code) {
    switch (code) {
      case 'permission-denied':
        return "You don't have permission to perform this action.";
      case 'not-found':
        return "The requested data was not found.";
      case 'already-exists':
        return "The record already exists.";
      case 'resource-exhausted':
        return "Too many requests. Please try again later.";
      case 'unavailable':
        return "Service is unavailable. Please try again later.";
      default:
        return "Something went wrong. Please try again.";
    }
  }
}
