import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class StatusFilter extends StatelessWidget {
  final TaskStatus? activeStatus;
  final Function(TaskStatus?) onStatusChange;
  final bool isDarkMode;

  const StatusFilter({
    super.key,
    required this.activeStatus,
    required this.onStatusChange,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildChip(null, 'All', null),
          const SizedBox(width: 8),
          _buildChip(TaskStatus.completed, 'Completed', Icons.check_circle),
          const SizedBox(width: 8),
          _buildChip(TaskStatus.inProgress, 'In Progress', Icons.access_time),
          const SizedBox(width: 8),
          _buildChip(TaskStatus.missed, 'Missed', Icons.cancel),
        ],
      ),
    );
  }

  Widget _buildChip(TaskStatus? status, String label, IconData? icon) {
    final isActive = activeStatus == status;

    return GestureDetector(
      onTap: () => onStatusChange(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                )
              : null,
          color: isActive
              ? null
              : isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.lightPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? Colors.white
                    : isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Colors.white
                    : isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
