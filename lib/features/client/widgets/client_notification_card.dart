import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/notification_model.dart';

/// Single notification card in the client notifications list.
class ClientNotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final VoidCallback onTap;

  const ClientNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (notification.type) {
      'accepted' => (Icons.check_circle, AppColors.success),
      'rejected' => (Icons.cancel, AppColors.danger),
      'completed' => (Icons.videocam, AppColors.primary),
      'booking' => (Icons.event_available, Colors.orange),
      _ => (Icons.notifications, AppColors.primary),
    };

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.read ? Colors.white : AppColors.lightBlue,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.read
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormatter.timeAgo(notification.createdAt),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
