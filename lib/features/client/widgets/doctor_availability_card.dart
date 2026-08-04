import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/doctor_model.dart';

/// Availability slot picker card for the doctor detail screen.
class DoctorAvailabilityCard extends StatelessWidget {
  final DoctorModel doctor;
  final String? selectedTime;
  final ValueChanged<String?> onTimeSelected;

  static const List<String> _defaultSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
  ];

  const DoctorAvailabilityCard({
    super.key,
    required this.doctor,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final slots = doctor.availability.isNotEmpty
        ? doctor.availability
        : _defaultSlots;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Available Time Slots',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: doctor.isAvailable
                        ? AppColors.success.withValues(alpha: 0.12)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.isAvailable ? 'Available' : 'Currently Busy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: doctor.isAvailable
                          ? AppColors.success
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots
                  .map(
                    (slot) => ChoiceChip(
                      label: Text(slot),
                      selected: selectedTime == slot,
                      onSelected: (value) =>
                          onTimeSelected(value ? slot : null),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
