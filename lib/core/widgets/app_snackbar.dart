import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

/// Centralized, reusable snackbar helpers.
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  static void showError(String message, {String? title}) {
    Get.snackbar(
      title ?? "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  static void showInfo(String message, {String? title}) {
    Get.snackbar(
      title ?? "Info",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  static void showWarning(String message, {String? title}) {
    Get.snackbar(
      title ?? "Warning",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.warning_amber, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  /// Shows a generic failure snackbar from any exception.
  static void showException(Object error) {
    showError(error.toString());
  }
}
