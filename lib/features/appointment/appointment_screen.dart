import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_view.dart';
import '../../data/models/appointment_model.dart';
import 'appointment_controller.dart';
import 'widgets/appointment_card.dart';
import 'widgets/appointment_error_banner.dart';

class AppointmentScreen extends GetView<AppointmentController> {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Patient Appointments')),
      body: Obx(() {
        if (controller.isLoading && controller.appointments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError && controller.appointments.isEmpty) {
          return ErrorView(
            message: controller.errorMessage,
            onRetry: controller.retry,
          );
        }
        if (controller.appointments.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.calendar_today,
            title: 'No Appointments Found',
            subtitle: 'Appointment requests will appear here in real time.',
          );
        }

        return Column(
          children: [
            if (controller.hasError)
              AppointmentErrorBanner(
                message: controller.errorMessage,
                onRetry: controller.retry,
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.appointments.length,
                itemBuilder: (context, index) {
                  final appointment = controller.appointments[index];
                  return AppointmentCard(
                    appointment: appointment,
                    onReject: () => _onRejectPressed(appointment),
                    onAccept: () =>
                        controller.acceptAppointment(appointment.id),
                    onStartVideoCall: () => _startVideoCall(appointment),
                    onComplete: () =>
                        controller.completeAppointment(appointment.id),
                    onViewNotes: () {
                      Get.toNamed(AppRoutes.notes, arguments: appointment.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _onRejectPressed(AppointmentModel appointment) async {
    final confirmed = await showConfirmDialog(
      title: 'Reject Appointment',
      message: 'Reject the appointment request from ${appointment.clientName}?',
      confirmText: 'Yes, Reject',
      isDestructive: true,
    );
    if (confirmed) {
      controller.rejectAppointment(appointment.id);
    }
  }

  void _startVideoCall(AppointmentModel appointment) {
    Get.toNamed(
      AppRoutes.videoCall,
      arguments: {
        'appointmentId': appointment.id,
        'role': 'doctor',
        'participantName': appointment.clientName,
        'clientId': appointment.clientId,
      },
    );
  }
}
