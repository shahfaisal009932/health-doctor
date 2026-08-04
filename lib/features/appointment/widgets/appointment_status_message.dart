import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/appointment_model.dart';

/// Terminal status text (Completed / Rejected) for an appointment card.
class AppointmentStatusMessage extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentStatusMessage({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    if (appointment.isCompleted) {
      return const Center(
        child: Text(
          'Consultation Completed',
          style: TextStyle(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (appointment.isRejected || appointment.isCancelled) {
      return const Center(
        child: Text(
          'Appointment Rejected',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
