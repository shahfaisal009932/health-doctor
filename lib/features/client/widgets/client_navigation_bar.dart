import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Bottom navigation bar for the client dashboard.
class ClientNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int unreadCount;
  final ValueChanged<int> onDestinationSelected;

  const ClientNavigationBar({
    super.key,
    required this.currentIndex,
    required this.unreadCount,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppColors.primary),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search, color: AppColors.primary),
          label: 'Search',
        ),
        const NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary),
          label: 'Appointments',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child: const Icon(Icons.notifications_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            child:
                const Icon(Icons.notifications, color: AppColors.primary),
          ),
          label: 'Alerts',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}
