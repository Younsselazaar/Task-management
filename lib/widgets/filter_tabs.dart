import 'package:flutter/material.dart';
import '../models/task.dart';

class FilterTabs extends StatelessWidget {
  final TimeFilter activeFilter;
  final Function(TimeFilter) onFilterChange;
  final bool isDarkMode;

  const FilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterChange,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab(TimeFilter.today, 'Today'),
          _buildTab(TimeFilter.week, 'This Week'),
          _buildTab(TimeFilter.month, 'This Month'),
        ],
      ),
    );
  }

  Widget _buildTab(TimeFilter filter, String label) {
    final isActive = activeFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChange(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: isDarkMode
                        ? [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]
                        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
