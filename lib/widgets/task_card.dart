import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final VoidCallback? onTap;
  final bool isDarkMode;
  final bool compact;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    this.onTap,
    required this.isDarkMode,
    this.compact = false,
  });

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.completed:
        return AppTheme.completed;
      case TaskStatus.inProgress:
        return AppTheme.inProgress;
      case TaskStatus.missed:
        return AppTheme.missed;
    }
  }

  String _getStatusLabel() {
    switch (task.status) {
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.missed:
        return 'Missed';
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.inProgress:
        return Icons.access_time;
      case TaskStatus.missed:
        return Icons.cancel;
    }
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.high:
        return AppTheme.highPriority;
      case TaskPriority.medium:
        return AppTheme.mediumPriority;
      case TaskPriority.low:
        return AppTheme.lowPriority;
    }
  }

  String _getPriorityLabel() {
    switch (task.priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Slidable(
      enabled: !compact,
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppTheme.missed,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onToggleComplete(),
            backgroundColor: AppTheme.completed,
            foregroundColor: Colors.white,
            icon: task.status == TaskStatus.completed
                ? Icons.undo
                : Icons.check,
            label: task.status == TaskStatus.completed ? 'Undo' : 'Done',
            borderRadius: BorderRadius.circular(20),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggleComplete,
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  child: Icon(
                    task.status == TaskStatus.completed
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: task.status == TaskStatus.completed
                        ? statusColor
                        : isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[400],
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: task.status == TaskStatus.completed
                            ? isDarkMode
                                ? Colors.grey[600]
                                : Colors.grey[400]
                            : isDarkMode
                                ? Colors.white
                                : Colors.grey[900],
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Meta info
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        // Date & Time
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatDate(task.dueDate)} - ${_formatTime(task.dueDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                size: 14,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getStatusLabel(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Priority
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getPriorityLabel(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Edit button
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                ),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
