import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_view.dart';
import '../../data/models/appointment_model.dart';
import '../auth/auth_controller.dart';
import 'dashboard_controller.dart';
import 'widgets/dashboard_action_card.dart';
import 'widgets/dashboard_appointment_card.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _onLogoutPressed(authController),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError) {
          return ErrorView(
            message: controller.errorMessage,
            onRetry: controller.loadDashboard,
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    '👋 ${controller.greeting}, Dr. ${controller.doctorName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Welcome back!',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Appointments",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.appointments.length} total',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Obx(() {
                  if (controller.appointments.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: EmptyStateWidget(
                          icon: Icons.calendar_today,
                          title: 'No Appointments Today',
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: controller.appointments
                        .take(3)
                        .map((appointment) => DashboardAppointmentCard(
                              appointment: appointment,
                              onReject: () => _onRejectPressed(appointment),
                              onAccept: () =>
                                  controller.acceptAppointment(appointment.id),
                              onStartVideoCall: () =>
                                  _startVideoCall(appointment),
                              onComplete: () =>
                                  controller.completeAppointment(
                                      appointment.id),
                            ))
                        .toList(),
                  );
                }),
                const SizedBox(height: 30),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.2,
                  children: [
                    DashboardActionCard(
                      icon: Icons.calendar_month,
                      title: 'Appointments',
                      color: Colors.blue,
                      onTap: () => Get.toNamed(AppRoutes.appointment),
                    ),
                    DashboardActionCard(
                      icon: Icons.note_alt,
                      title: 'Session Notes',
                      color: Colors.orange,
                      onTap: () {
                        if (controller.appointments.isNotEmpty) {
                          Get.toNamed(
                            AppRoutes.notes,
                            arguments: controller.appointments.first.id,
                          );
                        } else {
                          Get.snackbar(
                            'No Appointments',
                            'Add an appointment before creating notes.',
                          );
                        }
                      },
                    ),
                    DashboardActionCard(
                      icon: Icons.video_call,
                      title: 'Video Call',
                      color: Colors.green,
                      onTap: () => Get.toNamed(AppRoutes.videoCall),
                    ),
                    DashboardActionCard(
                      icon: Icons.logout,
                      title: 'Logout',
                      color: Colors.red,
                      onTap: () => _onLogoutPressed(authController),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
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
