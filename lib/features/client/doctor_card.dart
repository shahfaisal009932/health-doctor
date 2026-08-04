import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/doctor_model.dart';
import 'widgets/doctor_meta.dart';

/// Reusable doctor card used in search results and the home screen.
class DoctorCard extends StatelessWidget {
  final DoctorModel? doctor;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? trailing;
  final Widget? trailingExtra;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    this.doctor,
    required this.title,
    required this.subtitle,
    this.icon = Icons.medical_services_outlined,
    this.color = AppColors.primary,
    this.trailing,
    this.trailingExtra,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (doctor != null) DoctorMeta(doctor: doctor!),
              if (trailingExtra != null) ...[
                const SizedBox(height: 10),
                ?trailingExtra,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
