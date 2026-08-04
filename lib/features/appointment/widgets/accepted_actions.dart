import 'package:flutter/material.dart';

/// Doctor-side actions shown for an accepted appointment.
class AcceptedActions extends StatelessWidget {
  final VoidCallback onStartVideoCall;
  final VoidCallback onComplete;

  const AcceptedActions({
    super.key,
    required this.onStartVideoCall,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.video_call, size: 20),
          label: const Text('Start Video Call'),
          onPressed: onStartVideoCall,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.check_circle_outline, size: 20),
          label: const Text('Mark as Completed'),
          onPressed: onComplete,
        ),
      ],
    );
  }
}
