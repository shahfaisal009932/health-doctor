import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

/// Appointment booking form card for the doctor detail screen.
class DoctorBookingCard extends StatelessWidget {
  final DateTime selectedDate;
  final TextEditingController symptomsController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final bool isBooking;
  final VoidCallback onPickDate;
  final VoidCallback onBook;

  const DoctorBookingCard({
    super.key,
    required this.selectedDate,
    required this.symptomsController,
    required this.ageController,
    required this.phoneController,
    required this.isBooking,
    required this.onPickDate,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book Appointment',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event, color: AppColors.primary),
              title: const Text(
                'Select Date',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              subtitle: Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: onPickDate,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: symptomsController,
              label: 'Symptoms',
              hintText: 'Describe your symptoms briefly',
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: ageController,
                    label: 'Age',
                    hintText: 'e.g. 28',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.cake_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: phoneController,
                    label: 'Phone',
                    hintText: 'Your number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CommonButton(
              text: 'Book Appointment',
              icon: Icons.calendar_month,
              isLoading: isBooking,
              onPressed: onBook,
            ),
          ],
        ),
      ),
    );
  }
}
