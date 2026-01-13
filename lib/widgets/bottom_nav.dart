import 'package:flutter/material.dart';
import '../models/task.dart';

class BottomNavBar extends StatelessWidget {
  final ViewType activeView;
  final Function(ViewType) onViewChange;
  final bool isDarkMode;

  const BottomNavBar({
    super.key,
    required this.activeView,
    required this.onViewChange,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF0F172A).withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.grid_view_rounded,
                label: 'Tasks',
                isActive: activeView == ViewType.tasks,
                onTap: () => onViewChange(ViewType.tasks),
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Money',
                isActive: activeView == ViewType.money,
                onTap: () => onViewChange(ViewType.money),
              ),
              _buildNavItem(
                icon: Icons.business_center_rounded,
                label: 'Business',
                isActive: activeView == ViewType.business,
                onTap: () => onViewChange(ViewType.business),
              ),
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Analytics',
                isActive: activeView == ViewType.analytics,
                onTap: () => onViewChange(ViewType.analytics),
              ),
              _buildNavItem(
                icon: Icons.settings_rounded,
                label: 'More',
                isActive: activeView == ViewType.settings || activeView == ViewType.profile,
                onTap: () => onViewChange(ViewType.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = isDarkMode
        ? const Color(0xFFA78BFA)
        : const Color(0xFF6366F1);
    final inactiveColor = isDarkMode
        ? Colors.grey[600]
        : Colors.grey[400];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode
                  ? const Color(0xFF8B5CF6).withOpacity(0.2)
                  : const Color(0xFF6366F1).withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
