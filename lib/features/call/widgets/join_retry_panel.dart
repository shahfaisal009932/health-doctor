import 'package:flutter/material.dart';

/// Panel shown when the client failed to join the appointment call.
class JoinRetryPanel extends StatelessWidget {
  final String? joinError;
  final bool isLoading;
  final VoidCallback onRetry;

  const JoinRetryPanel({
    super.key,
    this.joinError,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 210,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, color: Colors.white70, size: 32),
            const SizedBox(height: 10),
            Text(
              joinError ?? 'Waiting for the doctor...',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Join'),
              onPressed: isLoading ? null : onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
