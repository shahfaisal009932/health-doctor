import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../data/models/appointment_model.dart';
import '../../appointment/widgets/accepted_actions.dart';
import '../../appointment/widgets/appointment_status_message.dart';
import '../../appointment/widgets/pending_actions.dart';
import 'dashboard_info_item.dart';

/// Compact doctor-side appointment preview card for the dashboard.
class DashboardAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final VoidCallback onStartVideoCall;
  final VoidCallback onComplete;

  const DashboardAppointmentCard({
    super.key,
    required this.appointment,
    required this.onReject,
    required this.onAccept,
    required this.onStartVideoCall,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.clientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        appointment.symptoms,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusChip(status: appointment.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                DashboardInfoItem(
                  icon: Icons.cake,
                  text: 'Age: ${appointment.age}',
                ),
                const SizedBox(width: 12),
                DashboardInfoItem(icon: Icons.phone, text: appointment.phone),
              ],
            ),
            const SizedBox(height: 8),
            DashboardInfoItem(
              icon: Icons.access_time,
              text: appointment.formattedDateTime,
            ),
            const SizedBox(height: 12),
            if (appointment.isPending)
              PendingActions(onReject: onReject, onAccept: onAccept),
            if (appointment.isAccepted)
              AcceptedActions(
                onStartVideoCall: onStartVideoCall,
                onComplete: onComplete,
              ),
            AppointmentStatusMessage(appointment: appointment),
          ],
        ),
      ),
    );
  }
}
