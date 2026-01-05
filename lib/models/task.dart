import 'package:uuid/uuid.dart';

enum TaskStatus { completed, inProgress, missed }

enum TaskPriority { low, medium, high }

enum TimeFilter { today, week, month }

enum ViewType { tasks, money, analytics }

class Subtask {
  final String id;
  String title;
  bool completed;

  Subtask({
    String? id,
    required this.title,
    this.completed = false,
  }) : id = id ?? const Uuid().v4();

  Subtask copyWith({String? title, bool? completed}) {
    return Subtask(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
  };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
    id: json['id'],
    title: json['title'],
    completed: json['completed'] ?? false,
  );
}

class Task {
  final String id;
  String title;
  String? description;
  DateTime dueDate;
  TaskStatus status;
  TaskPriority priority;
  List<Subtask> subtasks;

  Task({
    String? id,
    required this.title,
    this.description,
    required this.dueDate,
    this.status = TaskStatus.inProgress,
    this.priority = TaskPriority.medium,
    List<Subtask>? subtasks,
  }) : id = id ?? const Uuid().v4(),
       subtasks = subtasks ?? [];

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    TaskPriority? priority,
    List<Subtask>? subtasks,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'status': status.index,
    'priority': priority.index,
    'subtasks': subtasks.map((s) => s.toJson()).toList(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dueDate: DateTime.parse(json['dueDate']),
    status: TaskStatus.values[json['status']],
    priority: TaskPriority.values[json['priority']],
    subtasks: (json['subtasks'] as List?)
        ?.map((s) => Subtask.fromJson(s))
        .toList() ?? [],
  );
}
