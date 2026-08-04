import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../data/models/appointment_model.dart';
import 'accepted_actions.dart';
import 'appointment_info_row.dart';
import 'appointment_status_message.dart';
import 'pending_actions.dart';

/// Full doctor-side appointment card with patient details and actions.
class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onReject;
  final VoidCallback onAccept;
  final VoidCallback onStartVideoCall;
  final VoidCallback onComplete;
  final VoidCallback onViewNotes;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onReject,
    required this.onAccept,
    required this.onStartVideoCall,
    required this.onComplete,
    required this.onViewNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.symptoms,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
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
            const SizedBox(height: 16),
            AppointmentInfoRow(
              icon: Icons.badge,
              label: 'Patient ID',
              value: appointment.clientId,
            ),
            AppointmentInfoRow(
              icon: Icons.cake,
              label: 'Age',
              value: '${appointment.age}',
            ),
            AppointmentInfoRow(
              icon: Icons.phone,
              label: 'Phone',
              value: appointment.phone,
            ),
            AppointmentInfoRow(
              icon: Icons.access_time,
              label: 'Date/Time',
              value: appointment.formattedDateTime,
            ),
            const SizedBox(height: 20),
            if (appointment.isPending)
              PendingActions(onReject: onReject, onAccept: onAccept),
            if (appointment.isAccepted)
              AcceptedActions(
                onStartVideoCall: onStartVideoCall,
                onComplete: onComplete,
              ),
            AppointmentStatusMessage(appointment: appointment),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.note_alt, size: 18),
                label: const Text('View Session Notes'),
                onPressed: onViewNotes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
