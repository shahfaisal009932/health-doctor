import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Horizontal list of filter chips for the doctor search screen.
class DoctorSearchFilters extends StatelessWidget {
  final bool onlyAvailable;
  final String selectedSpecialization;
  final List<String> specializations;
  final ValueChanged<bool> onAvailableOnlyChanged;
  final ValueChanged<String> onSpecializationChanged;

  const DoctorSearchFilters({
    super.key,
    required this.onlyAvailable,
    required this.selectedSpecialization,
    required this.specializations,
    required this.onAvailableOnlyChanged,
    required this.onSpecializationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('Available Only'),
            selected: onlyAvailable,
            onSelected: onAvailableOnlyChanged,
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          ...specializations.map((spec) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(spec),
                selected: selectedSpecialization == spec,
                onSelected: (value) =>
                    onSpecializationChanged(value ? spec : ''),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
              ),
            );
          }),
        ],
      ),
    );
  }
}
