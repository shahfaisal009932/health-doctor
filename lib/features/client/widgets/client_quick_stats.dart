import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/appointment_model.dart';
import 'client_stat_card.dart';

/// Row of appointment statistics computed from the client's appointments.
class ClientQuickStats extends StatelessWidget {
  final RxList<AppointmentModel> appointments;

  const ClientQuickStats({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final upcoming = appointments
          .where((a) => a.isPending || a.isAccepted)
          .length;
      final completed = appointments.where((a) => a.isCompleted).length;
      final consult = appointments.where((a) => a.isAccepted).length;

      return Row(
        children: [
          Expanded(
            child: ClientStatCard(
              icon: Icons.pending_actions,
              color: Colors.orange,
              value: '$upcoming',
              label: 'Upcoming',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClientStatCard(
              icon: Icons.check_circle,
              color: Colors.green,
              value: '$completed',
              label: 'Completed',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClientStatCard(
              icon: Icons.videocam,
              color: AppColors.primary,
              value: '$consult',
              label: 'Consult',
            ),
          ),
        ],
      );
    });
  }
}
