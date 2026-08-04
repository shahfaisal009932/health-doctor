import 'package:flutter/material.dart';

/// Top-left consultation badge showing the active call context.
class CallBadge extends StatelessWidget {
  final String? appointmentId;
  final String? participantName;
  final String? callId;

  const CallBadge({
    super.key,
    this.appointmentId,
    this.participantName,
    this.callId,
  });

  @override
  Widget build(BuildContext context) {
    final String displayText;
    if (appointmentId != null) {
      displayText = participantName != null && participantName!.isNotEmpty
          ? 'Consulting: $participantName'
          : 'Appointment Consultation';
    } else {
      displayText = callId == null ? 'No Active Call' : 'Call ID: $callId';
    }

    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          displayText,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}
