import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common_button.dart';

/// Success panel shown after a reset email is sent.
class ForgotPasswordSuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;
  final VoidCallback onDifferentEmail;

  const ForgotPasswordSuccessView({
    super.key,
    required this.email,
    required this.onBackToLogin,
    required this.onDifferentEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.success,
          child: Icon(Icons.mark_email_read, color: Colors.white, size: 45),
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Sent!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'A password reset link has been sent to\n$email',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check your inbox and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 30),
        CommonButton(
          text: 'Back to Login',
          onPressed: onBackToLogin,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onDifferentEmail,
          child: const Text('Send to a different email'),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
