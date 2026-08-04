import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../data/models/appointment_model.dart';
import 'client_appointment_actions.dart';
import 'client_appointment_info_row.dart';

/// Client-side appointment card with doctor info and status actions.
class ClientAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onJoinCall;
  final VoidCallback onCancel;
  final VoidCallback onViewHistory;

  const ClientAppointmentCard({
    super.key,
    required this.appointment,
    required this.onJoinCall,
    required this.onCancel,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${appointment.doctorName}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.doctorSpecialization,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: appointment.status),
              ],
            ),
            const SizedBox(height: 14),
            ClientAppointmentInfoRow(
              icon: Icons.event,
              text:
                  '${appointment.formattedDate} • ${appointment.appointmentTime}',
            ),
            if (appointment.symptoms.isNotEmpty)
              ClientAppointmentInfoRow(
                icon: Icons.notes,
                text: appointment.symptoms,
              ),
            const SizedBox(height: 16),
            ClientAppointmentActions(
              appointment: appointment,
              onJoinCall: onJoinCall,
              onCancel: onCancel,
              onViewHistory: onViewHistory,
            ),
          ],
        ),
      ),
    );
  }
}
