import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'client_appointments_screen.dart';
import 'client_controller.dart';
import 'client_home_screen.dart';
import 'client_notifications_screen.dart';
import 'client_profile_screen.dart';
import 'client_tab_controller.dart';
import 'doctor_search_body.dart';
import 'widgets/client_navigation_bar.dart';

class ClientDashboardScreen extends StatelessWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabController = Get.find<ClientTabController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: tabController.currentIndex.value,
          children: const [
            ClientHomeScreen(),
            DoctorSearchBody(),
            ClientAppointmentsScreen(),
            ClientNotificationsScreen(),
            ClientProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final clientController = Get.find<ClientController>();
        final unread = clientController.unreadCount.value;
        return ClientNavigationBar(
          currentIndex: tabController.currentIndex.value,
          unreadCount: unread,
          onDestinationSelected: tabController.switchTab,
        );
      }),
    );
  }
}
