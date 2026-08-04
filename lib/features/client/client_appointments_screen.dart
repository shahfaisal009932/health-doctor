import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_view.dart';
import '../../data/models/appointment_model.dart';
import 'client_controller.dart';
import 'widgets/client_appointment_card.dart';

class ClientAppointmentsScreen extends GetView<ClientController> {
  const ClientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Appointment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.retryAppointments,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingAppointments.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasAppointmentsError.value) {
          return ErrorView(
            message: controller.appointmentsErrorMessage.value,
            onRetry: controller.retryAppointments,
          );
        }
        if (controller.appointments.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.calendar_month,
            title: 'No Appointments Yet',
            subtitle:
                'Search for a doctor and book your first consultation.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.retryAppointments(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.appointments.length,
            itemBuilder: (context, index) {
              final appointment = controller.appointments[index];
              return ClientAppointmentCard(
                appointment: appointment,
                onJoinCall: () => _joinCall(appointment),
                onCancel: () => _confirmCancel(appointment),
                onViewHistory: () {
                  Get.toNamed(
                    AppRoutes.videoCallHistory,
                    arguments: appointment.id,
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  void _joinCall(AppointmentModel appointment) {
    Get.toNamed(
      AppRoutes.videoCall,
      arguments: {
        'appointmentId': appointment.id,
        'callId': appointment.callId,
        'role': 'client',
      },
    );
  }

  Future<void> _confirmCancel(AppointmentModel appointment) async {
    final confirmed = await showConfirmDialog(
      title: 'Cancel Appointment',
      message: 'Are you sure you want to cancel this appointment request?',
      confirmText: 'Yes, Cancel',
      isDestructive: true,
    );
    if (confirmed) {
      controller.cancelAppointment(appointment.id);
    }
  }
}
