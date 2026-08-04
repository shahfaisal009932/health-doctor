import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'incoming_call_action_button.dart';

/// Full-screen incoming video call presentation (WhatsApp-style).
///
/// Stateless: receives the caller name and callbacks, never touches
/// controllers directly.
class IncomingCallView extends StatelessWidget {
  final String doctorName;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const IncomingCallView({
    super.key,
    required this.doctorName,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const IncomingCallHint(text: 'Incoming Video Call'),
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 64,
                backgroundColor: AppColors.primary.withValues(alpha: 0.25),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                doctorName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'wants to start a video consultation',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IncomingCallActionButton(
                    icon: Icons.call_end,
                    backgroundColor: AppColors.danger,
                    label: 'Decline',
                    onTap: () => onReject(),
                  ),
                  IncomingCallActionButton(
                    icon: Icons.videocam,
                    backgroundColor: AppColors.success,
                    label: 'Accept',
                    onTap: () => onAccept(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
