import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// A reusable status chip that renders appointment status colors.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bgColor, Color textColor, IconData icon) = _resolve();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _resolve() {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
          Icons.check_circle,
        );
      case 'pending':
      case 'unconfirmed':
        return (
          AppColors.warning.withValues(alpha: 0.12),
          AppColors.warning,
          Icons.schedule,
        );
      case 'rejected':
      case 'cancelled':
        return (
          AppColors.danger.withValues(alpha: 0.12),
          AppColors.danger,
          Icons.cancel,
        );
      case 'completed':
        return (
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primary,
          Icons.videocam,
        );
      default:
        return (Colors.grey.shade200, Colors.grey, Icons.info);
    }
  }
}
