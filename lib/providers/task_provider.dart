import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  TimeFilter _timeFilter = TimeFilter.today;
  ViewType _viewType = ViewType.tasks;
  bool _isDarkMode = false;
  TaskStatus? _statusFilter;
  String? _selectedTaskId;

  static const String _tasksKey = 'tasks_data';

  // Getters
  List<Task> get tasks => _tasks;
  TimeFilter get timeFilter => _timeFilter;
  ViewType get viewType => _viewType;
  bool get isDarkMode => _isDarkMode;
  TaskStatus? get statusFilter => _statusFilter;
  String? get selectedTaskId => _selectedTaskId;

  Task? get selectedTask => _selectedTaskId != null
      ? _tasks.firstWhere((t) => t.id == _selectedTaskId, orElse: () => _tasks.first)
      : null;

  TaskProvider() {
    _loadTasks();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((json) => Task.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }

  // Filter tasks for today
  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return _isSameDay(task.dueDate, now);
    }).toList();
  }

  // Filter tasks for this week
  List<Task> get weekTasks {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    return _tasks.where((task) {
      return task.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
             task.dueDate.isBefore(weekEnd);
    }).toList();
  }

  // Filter tasks for this month
  List<Task> get monthTasks {
    final now = DateTime.now();
    final monthEnd = now.add(const Duration(days: 30));
    return _tasks.where((task) {
      return task.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
             task.dueDate.isBefore(monthEnd);
    }).toList();
  }

  // Get filtered tasks based on current filters
  List<Task> getFilteredTasks(List<Task> tasks) {
    if (_statusFilter == null) return tasks;
    return tasks.where((task) => task.status == _statusFilter).toList();
  }

  // Statistics
  int get completedCount => _tasks.where((t) => t.status == TaskStatus.completed).length;
  int get inProgressCount => _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get missedCount => _tasks.where((t) => t.status == TaskStatus.missed).length;
  int get totalCount => _tasks.length;

  double get completionRate => totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  int get productivityScore {
    if (totalCount == 0) return 0;
    return ((completedCount * 0.6 + inProgressCount * 0.3 - missedCount * 0.1) / totalCount * 100).round().clamp(0, 100);
  }

  // Priority counts
  int get highPriorityCount => _tasks.where((t) => t.priority == TaskPriority.high).length;
  int get mediumPriorityCount => _tasks.where((t) => t.priority == TaskPriority.medium).length;
  int get lowPriorityCount => _tasks.where((t) => t.priority == TaskPriority.low).length;

  // Actions
  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(String id, Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    if (_selectedTaskId == id) {
      _selectedTaskId = null;
    }
    _saveTasks();
    notifyListeners();
  }

  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        status: task.status == TaskStatus.completed
            ? TaskStatus.inProgress
            : TaskStatus.completed,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void setTimeFilter(TimeFilter filter) {
    _timeFilter = filter;
    notifyListeners();
  }

  void setViewType(ViewType type) {
    _viewType = type;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void selectTask(String? id) {
    _selectedTaskId = id;
    notifyListeners();
  }

  // Helper
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get tasks for a specific date
  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) => _isSameDay(task.dueDate, date)).toList();
  }

  // Set all tasks (for restore from backup)
  void setTasks(List<Task> tasks) {
    _tasks = tasks;
    _saveTasks();
    notifyListeners();
  }

  // Weekly stats
  Map<String, int> get weeklyStats {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekTasks = _tasks.where((t) => t.dueDate.isAfter(weekAgo)).toList();
    final weekCompleted = weekTasks.where((t) => t.status == TaskStatus.completed).length;
    return {'total': weekTasks.length, 'completed': weekCompleted};
  }
}
