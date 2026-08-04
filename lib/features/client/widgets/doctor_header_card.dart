import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/doctor_model.dart';

/// Gradient doctor profile header with avatar, name and meta stats.
class DoctorHeaderCard extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorHeaderCard({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.medical_services,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Dr. ${doctor.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            doctor.specialization,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DoctorHeaderMeta('${doctor.experience} exp'),
              const SizedBox(width: 20),
              DoctorHeaderMeta('\$${doctor.fee.toStringAsFixed(0)} / visit'),
              const SizedBox(width: 20),
              DoctorHeaderMeta(
                doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : 'New',
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single white-on-gradient meta item inside the [DoctorHeaderCard].
class DoctorHeaderMeta extends StatelessWidget {
  final String text;
  final IconData? icon;

  const DoctorHeaderMeta(
    this.text, {
    super.key,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
        ],
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}
