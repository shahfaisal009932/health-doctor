import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import 'auth_controller.dart';
import 'widgets/forgot_password_form_view.dart';
import 'widgets/forgot_password_success_view.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final authController = Get.find<AuthController>();
    final success = await authController.forgotPassword(
      email: _emailController.text.trim(),
    );
    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _emailSent
                      ? ForgotPasswordSuccessView(
                          email: _emailController.text.trim(),
                          onBackToLogin: () =>
                              Get.offAllNamed(AppRoutes.login),
                          onDifferentEmail: () {
                            setState(() => _emailSent = false);
                          },
                        )
                      : Obx(
                          () => ForgotPasswordFormView(
                            formKey: _formKey,
                            emailController: _emailController,
                            isLoading: authController.isLoading,
                            onSubmit: _resetPassword,
                            onBackToLogin: () =>
                                Get.offAllNamed(AppRoutes.login),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
