import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state_widget.dart';
import 'client_controller.dart';
import 'widgets/client_notification_card.dart';

class ClientNotificationsScreen extends GetView<ClientController> {
  const ClientNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: controller.markAllNotificationsRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.notifications_none,
            title: 'No Notifications',
            subtitle: 'Updates about your appointments will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return ClientNotificationCard(
                notification: notification,
                onTap: () {
                  if (!notification.read) {
                    controller.markNotificationRead(notification.id);
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }
}
