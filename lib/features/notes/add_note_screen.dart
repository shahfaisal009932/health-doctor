import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/common_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'note_controller.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  String get _appointmentId =>
      Get.arguments is String ? Get.arguments as String : '';

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_appointmentId.isEmpty) {
      Get.snackbar('Error', 'Appointment ID missing.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<NoteController>();
    if (controller.isLoading) return;

    final success = await controller.addNote(
      appointmentId: _appointmentId,
      note: _noteController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      // Close first, then confirm, so a snackbar can never block the pop.
      Get.back();
      AppSnackbar.showSuccess('Session note saved.');
      controller.getNotes(_appointmentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NoteController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Session Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doctor Session Note',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Write the consultation summary below.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              CustomTextField(
                controller: _noteController,
                label: 'Session Note',
                hintText: 'Write diagnosis, medicines, observations...',
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                validator: Validators.validateNote,
              ),
              const SizedBox(height: 30),
              Obx(
                () => controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CommonButton(text: 'Save Note', onPressed: _saveNote),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
