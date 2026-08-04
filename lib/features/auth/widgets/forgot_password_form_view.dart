import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common_button.dart';
import '../../../core/widgets/custom_text_field.dart';

/// Email input form shown on the forgot-password screen.
class ForgotPasswordFormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const ForgotPasswordFormView({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.lock_reset, color: Colors.white, size: 45),
          ),
          const SizedBox(height: 24),
          const Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your email address and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 35),
          CustomTextField(
            controller: emailController,
            label: 'Email',
            hintText: 'doctor@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 30),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            CommonButton(
              text: 'Send Reset Link',
              onPressed: onSubmit,
            ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onBackToLogin,
            child: const Text('Back to Login'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
