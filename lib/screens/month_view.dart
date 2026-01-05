import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class MonthView extends StatefulWidget {
  final bool isDarkMode;

  const MonthView({super.key, required this.isDarkMode});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late DateTime _currentDate;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // Monthly stats
        final monthTasks = taskProvider.tasks.where((task) {
          return task.dueDate.month == _currentDate.month &&
              task.dueDate.year == _currentDate.year;
        }).toList();

        final completedCount =
            monthTasks.where((t) => t.status == TaskStatus.completed).length;
        final percentage = monthTasks.isNotEmpty
            ? (completedCount / monthTasks.length * 100).round()
            : 0;

        return Column(
          children: [
            // Monthly Progress Card
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isDarkMode
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
                  color: widget.isDarkMode
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDarkMode
                              ? const Color(0xFFD8B4FE)
                              : const Color(0xFF6366F1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.grey[900],
                        ),
                      ),
                      Text(
                        '$completedCount of ${monthTasks.length} tasks',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  // Circular Progress
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 6,
                            backgroundColor: widget.isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Month Navigation
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    '${monthNames[_currentDate.month - 1]} ${_currentDate.year}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),

            // Calendar Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.4),
                ),
              ),
              child: Column(
                children: [
                  // Day names
                  Row(
                    children: dayNames.map((day) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[500],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Calendar days
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: startingWeekday + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < startingWeekday) {
                        return const SizedBox();
                      }
                      final day = index - startingWeekday + 1;
                      final date = DateTime(
                        _currentDate.year,
                        _currentDate.month,
                        day,
                      );
                      final dayTasks = taskProvider.getTasksForDate(date);
                      final isToday = _isSameDay(date, DateTime.now());
                      final isSelected = _selectedDate != null &&
                          _isSameDay(date, _selectedDate!);

                      final completedCount = dayTasks
                          .where((t) => t.status == TaskStatus.completed)
                          .length;
                      final inProgressCount = dayTasks
                          .where((t) => t.status == TaskStatus.inProgress)
                          .length;
                      final missedCount = dayTasks
                          .where((t) => t.status == TaskStatus.missed)
                          .length;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : widget.isDarkMode
                                            ? Colors.white
                                            : Colors.grey[900],
                                  ),
                                ),
                              ),
                              if (isToday && !isSelected)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: widget.isDarkMode
                                          ? const Color(0xFFA78BFA)
                                          : const Color(0xFF6366F1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              if (dayTasks.isNotEmpty)
                                Positioned(
                                  bottom: 4,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (completedCount > 0)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (inProgressCount > 0)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF59E0B),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (missedCount > 0)
                                        Container(
                                          width: 4,
                                          height: 4,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Selected Date Tasks
            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              Text(
                DateFormat('EEEE, MMMM d').format(_selectedDate!),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildSelectedDateTasks(taskProvider),
              ),
            ] else
              const Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildSelectedDateTasks(TaskProvider taskProvider) {
    final tasks = taskProvider.getTasksForDate(_selectedDate!);

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No tasks for this day',
            style: TextStyle(
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            task: task,
            isDarkMode: widget.isDarkMode,
            compact: true,
            onDelete: () {},
            onToggleComplete: () {},
            onTap: () => taskProvider.selectTask(task.id),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
