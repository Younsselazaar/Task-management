import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/progress_overview.dart';
import '../widgets/status_filter.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';

class WeekView extends StatefulWidget {
  final bool isDarkMode;

  const WeekView({super.key, required this.isDarkMode});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late int _selectedDayIndex;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _initializeWeek();
  }

  void _initializeWeek() {
    final now = DateTime.now();
    _selectedDayIndex = now.weekday % 7; // Sunday = 0
    _weekDates = _getWeekDates();
  }

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday % 7; // Sunday = 0
    final startOfWeek = now.subtract(Duration(days: dayOfWeek));

    return List.generate(7, (index) {
      return DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final selectedDate = _weekDates[_selectedDayIndex];
        final dayTasks = taskProvider.getTasksForDate(selectedDate);
        final filteredTasks = taskProvider.getFilteredTasks(dayTasks);

        return Column(
          children: [
            ProgressOverview(
              tasks: taskProvider.tasks,
              timeFilter: TimeFilter.week,
              isDarkMode: widget.isDarkMode,
            ),
            // Week Calendar
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(7, (index) {
                    final date = _weekDates[index];
                    final isToday = _isSameDay(date, DateTime.now());
                    final isSelected = index == _selectedDayIndex;
                    final taskCount =
                        taskProvider.getTasksForDate(date).length;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDayIndex = index;
                          });
                        },
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 64,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: widget.isDarkMode
                                            ? [
                                                const Color(0xFF8B5CF6),
                                                const Color(0xFF6366F1)
                                              ]
                                            : [
                                                const Color(0xFF6366F1),
                                                const Color(0xFF8B5CF6)
                                              ],
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : widget.isDarkMode
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF6366F1)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayNames[index],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.8)
                                          : widget.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : widget.isDarkMode
                                              ? Colors.white
                                              : Colors.grey[900],
                                    ),
                                  ),
                                  if (isToday && !isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: widget.isDarkMode
                                            ? const Color(0xFFA78BFA)
                                            : const Color(0xFF6366F1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (taskCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$taskCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            StatusFilter(
              activeStatus: taskProvider.statusFilter,
              onStatusChange: taskProvider.setStatusFilter,
              isDarkMode: widget.isDarkMode,
            ),
            Expanded(
              child: filteredTasks.isEmpty
                  ? SingleChildScrollView(
                      child: EmptyState(isDarkMode: widget.isDarkMode),
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
                            isDarkMode: widget.isDarkMode,
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
