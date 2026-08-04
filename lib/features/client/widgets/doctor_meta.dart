import 'package:flutter/material.dart';

import '../../../../data/models/doctor_model.dart';

/// Row of doctor meta stats (experience, fee, rating) in a doctor card.
class DoctorMeta extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorMeta({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          DoctorMetaItem(icon: Icons.work_outline, text: doctor.experience),
          const SizedBox(width: 16),
          DoctorMetaItem(
            icon: Icons.monetization_on_outlined,
            text: '\$${doctor.fee.toStringAsFixed(0)}',
          ),
          const SizedBox(width: 16),
          DoctorMetaItem(
            icon: Icons.star,
            text: doctor.rating > 0 ? doctor.rating.toStringAsFixed(1) : 'New',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }
}

/// Single icon + text meta item inside a [DoctorMeta] row.
class DoctorMetaItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const DoctorMetaItem({
    super.key,
    required this.icon,
    required this.text,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
