import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Edit-profile dialog shown from the client profile screen.
class EditProfileDialog extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final RxBool saving;
  final RxString errorMessage;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditProfileDialog({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.saving,
    required this.errorMessage,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameController,
              label: 'Full Name',
              hintText: 'Enter your name',
              prefixIcon: Icons.person_outline,
              validator: Validators.validateName,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: phoneController,
              label: 'Phone Number',
              hintText: 'Enter your number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.validatePhone,
            ),
            Obx(
              () => errorMessage.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        errorMessage.value,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving.value ? null : onCancel,
          child: const Text('Cancel'),
        ),
        Obx(
          () => ElevatedButton(
            onPressed: saving.value ? null : onSave,
            child: saving.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ),
      ],
    );
  }
}
