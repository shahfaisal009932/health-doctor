import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/doctor_model.dart';

/// "About" card for the doctor detail screen.
class DoctorAboutCard extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorAboutCard({
    super.key,
    required this.doctor,
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
              'About',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              doctor.bio.isEmpty
                  ? 'Experienced healthcare professional dedicated to providing quality care.'
                  : doctor.bio,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.5,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            if (doctor.degree.isNotEmpty)
              DoctorInfoRow(icon: Icons.school_outlined, text: doctor.degree),
            DoctorInfoRow(
              icon: Icons.work_outline,
              text: '${doctor.experience} experience',
            ),
            DoctorInfoRow(
              icon: Icons.medical_information_outlined,
              text: doctor.specialization,
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon + text detail row used inside the doctor about card.
class DoctorInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const DoctorInfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
