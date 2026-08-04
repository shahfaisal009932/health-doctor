import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import 'role_card.dart';

/// Doctor / Patient account type selector used on the register screen.
class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am a',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RoleCard(
                icon: Icons.medical_services_outlined,
                label: 'Doctor',
                selected: selectedRole == UserRole.doctor,
                onTap: () => onRoleChanged(UserRole.doctor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoleCard(
                icon: Icons.person_outline,
                label: 'Patient / Client',
                selected: selectedRole == UserRole.client,
                onTap: () => onRoleChanged(UserRole.client),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
