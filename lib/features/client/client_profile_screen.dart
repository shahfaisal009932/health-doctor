import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/common_button.dart';
import '../auth/auth_controller.dart';
import 'client_controller.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/profile_info_tile.dart';

class ClientProfileScreen extends GetView<ClientController> {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Obx(
            () => Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  controller.clientName.value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.clientEmail.value,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Card(
            child: Column(
              children: [
                Obx(
                  () => ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: controller.clientPhone.value.isEmpty
                        ? 'Not set'
                        : controller.clientPhone.value,
                  ),
                ),
                const Divider(height: 1),
                const ProfileInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: 'Patient',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
            onPressed: _showEditProfileDialog,
          ),
          const SizedBox(height: 12),
          CommonButton(
            text: 'Logout',
            icon: Icons.logout,
            backgroundColor: AppColors.danger,
            onPressed: () => _onLogoutPressed(authController),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'CareConnect v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLogoutPressed(AuthController authController) async {
    final confirmed = await showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to log out?',
      confirmText: 'Yes',
      cancelText: 'No',
      isDestructive: true,
    );
    if (confirmed) {
      await authController.logout();
    }
  }

  void _showEditProfileDialog() {
    final nameController =
        TextEditingController(text: controller.clientName.value);
    final phoneController =
        TextEditingController(text: controller.clientPhone.value);
    final formKey = GlobalKey<FormState>();
    final saving = false.obs;
    final errorMessage = ''.obs;

    Get.dialog(
      EditProfileDialog(
        formKey: formKey,
        nameController: nameController,
        phoneController: phoneController,
        saving: saving,
        errorMessage: errorMessage,
        onCancel: () => Get.back(),
        onSave: () => _saveProfile(
          formKey: formKey,
          nameController: nameController,
          phoneController: phoneController,
          saving: saving,
          errorMessage: errorMessage,
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _saveProfile({
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required RxBool saving,
    required RxString errorMessage,
  }) async {
    if (!formKey.currentState!.validate()) return;
    saving.value = true;
    errorMessage.value = '';
    try {
      final result = await controller.updateProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      if (result.success) {
        // Close the dialog first, then confirm, so a snackbar can never
        // block the close or mask an error.
        Get.back();
        AppSnackbar.showSuccess('Profile updated successfully.');
      } else {
        errorMessage.value =
            result.error ?? 'Could not update profile. Please try again.';
      }
    } catch (e) {
      errorMessage.value = FirebaseErrorMapper.map(e).message;
    } finally {
      saving.value = false;
    }
  }
}
