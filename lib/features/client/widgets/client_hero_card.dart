import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Gradient call-to-action hero card on the client home screen.
class ClientHeroCard extends StatelessWidget {
  final VoidCallback onFindDoctor;

  const ClientHeroCard({
    super.key,
    required this.onFindDoctor,
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book a Consultation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search top doctors, pick a time slot and get treated from the comfort of your home.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: onFindDoctor,
            icon: const Icon(Icons.search),
            label: const Text('Find a Doctor'),
          ),
        ],
      ),
    );
  }
}
