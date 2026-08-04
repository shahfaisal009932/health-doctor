import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/appointment_model.dart';

/// Status-specific actions/messages shown inside a client appointment card.
class ClientAppointmentActions extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onJoinCall;
  final VoidCallback onCancel;
  final VoidCallback onViewHistory;

  const ClientAppointmentActions({
    super.key,
    required this.appointment,
    required this.onJoinCall,
    required this.onCancel,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (appointment.isAccepted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Appointment accepted. You can now join the video consultation.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.videocam, size: 20),
            label: const Text('Join Video Call'),
            onPressed: onJoinCall,
          ),
        ],
      );
    }
    if (appointment.isPending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Waiting for the doctor to confirm your appointment.',
            style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            icon: const Icon(Icons.cancel_outlined, size: 20),
            label: const Text('Cancel Request'),
            onPressed: onCancel,
          ),
        ],
      );
    }
    if (appointment.isRejected) {
      return Text(
        'The doctor could not accept this appointment.',
        style: TextStyle(
          fontSize: 13,
          color: Colors.red.shade700,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    if (appointment.isCompleted) {
      return Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Consultation completed',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onViewHistory,
            child: const Text('History'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
