import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable confirmation dialog.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmText = 'Yes',
  String cancelText = 'No',
  bool isDestructive = false,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(
            confirmText,
            style: TextStyle(
              color: isDestructive ? Colors.red : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );

  return result ?? false;
}

/// Show a simple info dialog.
Future<void> showInfoDialog({
  required String title,
  required String message,
}) async {
  await Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
