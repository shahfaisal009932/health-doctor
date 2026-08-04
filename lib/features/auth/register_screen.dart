import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/common_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_controller.dart';
import 'widgets/role_selector.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = UserRole.doctor;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final authController = Get.find<AuthController>();
    await authController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _role == UserRole.client ? _phoneController.text.trim() : '',
      role: _role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 45,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Register to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 28),
                        RoleSelector(
                          selectedRole: _role,
                          onRoleChanged: (role) {
                            setState(() => _role = role);
                          },
                        ),
                        const SizedBox(height: 28),
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hintText: 'Enter full name',
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'you@email.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 20),
                        if (_role == UserRole.client) ...[
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hintText: 'Enter 10 digit mobile number',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: Validators.validatePhone,
                          ),
                          const SizedBox(height: 20),
                        ],
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter password',
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hintText: 'Re-enter password',
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: 30),
                        Obx(
                          () => authController.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CommonButton(
                                  text: 'Register',
                                  onPressed: _register,
                                ),
                        ),
                        const SizedBox(height: 25),
                        const Divider(),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Get.offAllNamed(AppRoutes.login);
                          },
                          child: const Text(
                            'Already have an account? Login',
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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
