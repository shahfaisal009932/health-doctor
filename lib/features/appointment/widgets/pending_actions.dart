import 'package:flutter/material.dart';

/// Doctor-side actions shown for a pending appointment request.
class PendingActions extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onAccept;

  const PendingActions({
    super.key,
    required this.onReject,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Reject'),
            onPressed: onReject,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Accept'),
            onPressed: onAccept,
          ),
        ),
      ],
    );
  }
}
