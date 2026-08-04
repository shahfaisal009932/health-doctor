import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_view.dart';
import '../../data/models/session_note_model.dart';
import 'note_controller.dart';
import 'widgets/session_note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NoteController controller;

  String get _appointmentId =>
      Get.arguments is String ? Get.arguments as String : '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<NoteController>();
    Future.microtask(() {
      if (mounted) controller.getNotes(_appointmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Session Notes')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Get.toNamed(AppRoutes.addNote, arguments: _appointmentId);
          controller.getNotes(_appointmentId);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError) {
          return ErrorView(
            message: controller.errorMessage,
            onRetry: () => controller.getNotes(_appointmentId),
          );
        }
        if (controller.notes.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.note_alt,
            title: 'No Session Notes Found',
            subtitle: 'Tap the button below to add a note',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.getNotes(_appointmentId),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: controller.notes.length,
            itemBuilder: (context, index) {
              final note = controller.notes[index];
              return SessionNoteCard(
                note: note,
                index: index,
                onEdit: () => _showEditDialog(note),
                onDelete: () => _confirmDelete(note),
              );
            },
          ),
        );
      }),
    );
  }

  void _showEditDialog(SessionNoteModel note) {
    final editController = TextEditingController(text: note.note);
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Note'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: editController,
            maxLines: 6,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter session note';
              }
              if (value.trim().length < 10) {
                return 'Note is too short';
              }
              return null;
            },
            inputFormatters: [LengthLimitingTextInputFormatter(1000)],
            decoration: InputDecoration(
              hintText: 'Write diagnosis, medicines, observations...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final success = await controller.updateNote(
                noteId: note.id,
                note: editController.text.trim(),
                appointmentId: _appointmentId,
              );
              if (!success) return;
              Get.back();
              AppSnackbar.showSuccess('Session note updated.');
              controller.getNotes(_appointmentId);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(SessionNoteModel note) async {
    final confirmed = await showConfirmDialog(
      title: 'Delete Note',
      message: 'Are you sure you want to delete this note?',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed) {
      final success = await controller.deleteNote(
        noteId: note.id,
        appointmentId: _appointmentId,
      );
      if (success) {
        AppSnackbar.showInfo('Session note deleted.');
        controller.getNotes(_appointmentId);
      }
    }
  }
}
