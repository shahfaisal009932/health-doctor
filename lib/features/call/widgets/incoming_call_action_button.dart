import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Round accept/reject button used by the incoming call screen.
class IncomingCallActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final String label;
  final VoidCallback onTap;

  const IncomingCallActionButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Icon(icon, color: Colors.white, size: 34),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Small grey hint chip shown above the caller's name.
class IncomingCallHint extends StatelessWidget {
  final String text;

  const IncomingCallHint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}
