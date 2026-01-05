import 'package:flutter/material.dart';
import '../models/task.dart';

class ProgressOverview extends StatelessWidget {
  final List<Task> tasks;
  final TimeFilter timeFilter;
  final bool isDarkMode;

  const ProgressOverview({
    super.key,
    required this.tasks,
    required this.timeFilter,
    required this.isDarkMode,
  });

  List<Task> _getRelevantTasks() {
    final now = DateTime.now();
    return tasks.where((task) {
      final taskDate = task.dueDate;
      switch (timeFilter) {
        case TimeFilter.today:
          return taskDate.year == now.year &&
              taskDate.month == now.month &&
              taskDate.day == now.day;
        case TimeFilter.week:
          final weekFromNow = now.add(const Duration(days: 7));
          return taskDate.isAfter(now.subtract(const Duration(days: 1))) &&
              taskDate.isBefore(weekFromNow);
        case TimeFilter.month:
          final monthFromNow = now.add(const Duration(days: 30));
          return taskDate.isAfter(now.subtract(const Duration(days: 1))) &&
              taskDate.isBefore(monthFromNow);
      }
    }).toList();
  }

  String _getProgressTitle() {
    switch (timeFilter) {
      case TimeFilter.today:
        return "Today's Progress";
      case TimeFilter.week:
        return "This Week's Progress";
      case TimeFilter.month:
        return "This Month's Progress";
    }
  }

  String _getEmoji(double percentage) {
    if (percentage == 100) return '🎉';
    if (percentage >= 50) return '💪';
    return '📝';
  }

  @override
  Widget build(BuildContext context) {
    final relevantTasks = _getRelevantTasks();
    final completedTasks = relevantTasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final totalTasks = relevantTasks.length;
    final progressPercentage =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                  const Color(0xFF6366F1).withOpacity(0.2),
                ]
              : [
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0.4),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getProgressTitle(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? const Color(0xFFD8B4FE)
                          : const Color(0xFF6366F1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedTasks/$totalTasks',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                ],
              ),
              Text(
                _getEmoji(progressPercentage),
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressPercentage == 100
                ? 'All tasks completed! 🎊'
                : '${progressPercentage.round()}% complete',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
