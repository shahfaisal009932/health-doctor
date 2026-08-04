import 'package:flutter/material.dart';

/// Compact icon + text item used inside the dashboard appointment card.
class DashboardInfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const DashboardInfoItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
