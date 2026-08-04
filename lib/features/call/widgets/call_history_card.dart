import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/call_history_model.dart';

/// Card displaying a single recorded consultation.
class CallHistoryCard extends StatelessWidget {
  final CallHistoryModel call;

  const CallHistoryCard({
    super.key,
    required this.call,
  });

  @override
  Widget build(BuildContext context) {
    final duration = call.durationSeconds;
    final minutes = (duration / 60).floor();
    final seconds = (duration % 60);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.videocam,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatDateTime(call.startedAt),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${minutes}m ${seconds}s',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: AppColors.success),
          ],
        ),
      ),
    );
  }
}
