import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/appointment_model.dart';
import '../doctor_card.dart';
import 'appointment_status_badge.dart';

/// Compact appointment tile shown in the client home "Recent Appointments".
class ClientAppointmentTile extends StatelessWidget {
  final AppointmentModel appointment;

  const ClientAppointmentTile({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return DoctorCard(
      title: appointment.doctorName,
      subtitle: appointment.doctorSpecialization,
      icon: Icons.calendar_month,
      color: AppColors.primary,
      trailing: AppointmentStatusBadge(status: appointment.status),
      onTap: null,
      trailingExtra: Text(
        DateFormatter.formatDateTime(
          appointment.appointmentDate ?? DateTime.now(),
        ),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
