import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskDetailsModal extends StatefulWidget {
  final Task task;
  final bool isDarkMode;
  final Function(Task) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const TaskDetailsModal({
    super.key,
    required this.task,
    required this.isDarkMode,
    required this.onUpdate,
    required this.onDelete,
    required this.onClose,
  });

  @override
  State<TaskDetailsModal> createState() => _TaskDetailsModalState();
}

class _TaskDetailsModalState extends State<TaskDetailsModal> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TaskStatus _status;
  late TaskPriority _priority;
  late List<Subtask> _subtasks;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _subtaskController = TextEditingController();
    _selectedDate = widget.task.dueDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.task.dueDate);
    _status = widget.task.status;
    _priority = widget.task.priority;
    _subtasks = List.from(widget.task.subtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: widget.isDarkMode
                ? const ColorScheme.dark(
                    primary: Color(0xFF8B5CF6),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF6366F1),
                    onPrimary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: widget.isDarkMode
                ? const ColorScheme.dark(
                    primary: Color(0xFF8B5CF6),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF6366F1),
                    onPrimary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addSubtask() {
    if (_subtaskController.text.trim().isEmpty) return;
    setState(() {
      _subtasks.add(Subtask(title: _subtaskController.text.trim()));
      _subtaskController.clear();
    });
  }

  void _toggleSubtask(String id) {
    setState(() {
      final index = _subtasks.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subtasks[index] = _subtasks[index].copyWith(
          completed: !_subtasks[index].completed,
        );
      }
    });
  }

  void _deleteSubtask(String id) {
    setState(() {
      _subtasks.removeWhere((s) => s.id == id);
    });
  }

  void _save() {
    final dueDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueDate: dueDate,
      status: _status,
      priority: _priority,
      subtasks: _subtasks,
    );

    widget.onUpdate(updatedTask);
    setState(() {
      _isEditing = false;
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        title: Text(
          'Delete Task',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: widget.isDarkMode
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              )
            : null,
        border: widget.isDarkMode
            ? Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              )
            : null,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing)
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.isDarkMode
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFF6366F1),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: widget.isDarkMode
                                    ? const Color(0xFF8B5CF6)
                                    : const Color(0xFF6366F1),
                                width: 2,
                              ),
                            ),
                          ),
                        )
                      else
                        Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                        ),
                      const SizedBox(height: 12),
                      _buildStatusBadge(),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500],
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  _buildSection(
                    'Description',
                    _isEditing
                        ? TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                            ),
                            decoration: _inputDecoration('Add a description...'),
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: _boxDecoration(),
                            child: Text(
                              widget.task.description ?? 'No description',
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildSection(
                          'Date',
                          GestureDetector(
                            onTap: _isEditing ? _selectDate : null,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: _boxDecoration(),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: widget.isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(
                                      _isEditing ? _selectedDate : widget.task.dueDate,
                                    ),
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.grey[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSection(
                          'Time',
                          GestureDetector(
                            onTap: _isEditing ? _selectTime : null,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: _boxDecoration(),
                              child: Text(
                                _isEditing
                                    ? _selectedTime.format(context)
                                    : DateFormat('h:mm a').format(widget.task.dueDate),
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.grey[900],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status (only in edit mode)
                  if (_isEditing) ...[
                    _buildSection(
                      'Status',
                      Row(
                        children: TaskStatus.values.map((status) {
                          final isSelected = _status == status;
                          final label = status == TaskStatus.inProgress
                              ? 'In Progress'
                              : status.name[0].toUpperCase() + status.name.substring(1);

                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: status != TaskStatus.missed ? 8 : 0,
                              ),
                              child: _buildSelectableChip(
                                label,
                                isSelected,
                                () => setState(() => _status = status),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Priority
                    _buildSection(
                      'Priority',
                      Row(
                        children: TaskPriority.values.map((priority) {
                          final isSelected = _priority == priority;
                          final label = priority.name[0].toUpperCase() +
                              priority.name.substring(1);

                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: priority != TaskPriority.high ? 8 : 0,
                              ),
                              child: _buildSelectableChip(
                                label,
                                isSelected,
                                () => setState(() => _priority = priority),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Subtasks
                  _buildSection(
                    'Subtasks',
                    Column(
                      children: [
                        ..._subtasks.map((subtask) => _buildSubtaskItem(subtask)),
                        if (_isEditing)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _subtaskController,
                                    style: TextStyle(
                                      color: widget.isDarkMode
                                          ? Colors.white
                                          : Colors.grey[900],
                                    ),
                                    decoration: _inputDecoration('Add a subtask...'),
                                    onSubmitted: (_) => _addSubtask(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _addSubtask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.isDarkMode
                                        ? const Color(0xFF8B5CF6)
                                        : const Color(0xFF6366F1),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Actions
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              children: [
                if (_isEditing) ...[
                  _buildGradientButton('Save Changes', _save),
                  const SizedBox(height: 12),
                  _buildOutlinedButton('Cancel', () {
                    setState(() {
                      _isEditing = false;
                      _initializeFields();
                    });
                  }),
                ] else ...[
                  _buildGradientButton('Edit Task', () {
                    setState(() => _isEditing = true);
                  }),
                  const SizedBox(height: 12),
                  _buildDeleteButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    switch (widget.task.status) {
      case TaskStatus.completed:
        color = AppTheme.completed;
        label = 'Completed';
        break;
      case TaskStatus.inProgress:
        color = AppTheme.inProgress;
        label = 'In Progress';
        break;
      case TaskStatus.missed:
        color = AppTheme.missed;
        label = 'Missed';
        break;
    }

    Color priorityColor;
    switch (widget.task.priority) {
      case TaskPriority.high:
        priorityColor = AppTheme.highPriority;
        break;
      case TaskPriority.medium:
        priorityColor = AppTheme.mediumPriority;
        break;
      case TaskPriority.low:
        priorityColor = AppTheme.lowPriority;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: widget.isDarkMode
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
      ),
      filled: true,
      fillColor: widget.isDarkMode
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: widget.isDarkMode
              ? const Color(0xFF8B5CF6)
              : const Color(0xFF6366F1),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildSelectableChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: widget.isDarkMode
                      ? [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected
              ? null
              : widget.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : widget.isDarkMode
                      ? Colors.grey[300]
                      : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskItem(Subtask subtask) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSubtask(subtask.id),
            child: Icon(
              subtask.completed
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: subtask.completed
                  ? AppTheme.completed
                  : widget.isDarkMode
                      ? Colors.grey[500]
                      : Colors.grey[400],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                color: subtask.completed
                    ? widget.isDarkMode
                        ? Colors.grey[500]
                        : Colors.grey[400]
                    : widget.isDarkMode
                        ? Colors.white
                        : Colors.grey[900],
                decoration: subtask.completed
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (_isEditing)
            GestureDetector(
              onTap: () => _deleteSubtask(subtask.id),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: widget.isDarkMode
                    ? Colors.grey[500]
                    : Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDarkMode
                  ? [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]
                  : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _confirmDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? const Color(0xFFEF4444).withOpacity(0.2)
                : const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'Delete Task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFDC2626),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showTaskDetailsModal(
  BuildContext context,
  Task task,
  bool isDarkMode,
  Function(Task) onUpdate,
  VoidCallback onDelete,
  VoidCallback onClose,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TaskDetailsModal(
      task: task,
      isDarkMode: isDarkMode,
      onUpdate: onUpdate,
      onDelete: onDelete,
      onClose: () {
        Navigator.pop(context);
        onClose();
      },
    ),
  );
}
