import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Small pill indicating whether a doctor is currently available.
class AvailabilityChip extends StatelessWidget {
  final bool available;

  const AvailabilityChip({
    super.key,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available
            ? AppColors.success.withValues(alpha: 0.12)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'Available' : 'Busy',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: available ? AppColors.success : Colors.grey,
        ),
      ),
    );
  }
}
