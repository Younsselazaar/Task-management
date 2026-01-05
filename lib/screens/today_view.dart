import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/progress_overview.dart';
import '../widgets/status_filter.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';

class TodayView extends StatelessWidget {
  final bool isDarkMode;

  const TodayView({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final todayTasks = taskProvider.todayTasks;
        final filteredTasks = taskProvider.getFilteredTasks(todayTasks);

        return Column(
          children: [
            ProgressOverview(
              tasks: taskProvider.tasks,
              timeFilter: TimeFilter.today,
              isDarkMode: isDarkMode,
            ),
            StatusFilter(
              activeStatus: taskProvider.statusFilter,
              onStatusChange: taskProvider.setStatusFilter,
              isDarkMode: isDarkMode,
            ),
            Expanded(
              child: filteredTasks.isEmpty
                  ? SingleChildScrollView(
                      child: EmptyState(isDarkMode: isDarkMode),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            isDarkMode: isDarkMode,
                            onDelete: () => taskProvider.deleteTask(task.id),
                            onToggleComplete: () =>
                                taskProvider.toggleComplete(task.id),
                            onTap: () => taskProvider.selectTask(task.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
