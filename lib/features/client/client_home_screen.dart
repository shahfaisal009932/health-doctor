import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../auth/auth_controller.dart';
import 'client_controller.dart';
import 'client_tab_controller.dart';
import 'widgets/client_appointment_tile.dart';
import 'widgets/client_hero_card.dart';
import 'widgets/client_quick_stats.dart';

class ClientHomeScreen extends GetView<ClientController> {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${controller.clientName}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'How can we help you today?',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _onLogoutPressed(authController),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClientHeroCard(
              onFindDoctor: () {
                Get.find<ClientTabController>().switchTab(1);
              },
            ),
            const SizedBox(height: 24),
            ClientQuickStats(appointments: controller.appointments),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Appointments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Get.find<ClientTabController>().switchTab(2);
                  },
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.appointments.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Icon(Icons.event_note, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No appointments yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: controller.appointments
                    .take(3)
                    .map((a) => ClientAppointmentTile(appointment: a))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _onLogoutPressed(AuthController authController) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (confirmed == true) {
      await authController.logout();
    }
  }
}
