import 'package:flutter/material.dart';

/// Colored pill showing an appointment status text.
class AppointmentStatusBadge extends StatelessWidget {
  final String status;

  const AppointmentStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Pending' => (Colors.orange.shade100, Colors.orange.shade900),
      'Accepted' => (Colors.green.shade100, Colors.green.shade900),
      'Rejected' => (Colors.red.shade100, Colors.red.shade900),
      'Completed' => (Colors.blue.shade100, Colors.blue.shade900),
      _ => (Colors.grey.shade200, Colors.grey.shade800),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
