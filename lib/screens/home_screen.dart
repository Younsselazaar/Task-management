import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/money_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/header.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/task_details_modal.dart';
import '../widgets/add_transaction_modal.dart';
import 'today_view.dart';
import 'week_view.dart';
import 'month_view.dart';
import 'analytics_view.dart';
import 'money_view.dart';
import 'settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isModalShowing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final isDarkMode = taskProvider.isDarkMode;

        // Show task details modal when a task is selected
        if (taskProvider.selectedTask != null && !_isModalShowing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && taskProvider.selectedTask != null && !_isModalShowing) {
              _showTaskDetails(context, taskProvider);
            }
          });
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? AppTheme.darkBackgroundGradient
                  : AppTheme.lightBackgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppHeader(
                      isDarkMode: isDarkMode,
                      onToggleDarkMode: taskProvider.toggleDarkMode,
                      title: _getHeaderTitle(taskProvider.viewType),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildContent(context, taskProvider, isDarkMode),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            activeView: taskProvider.viewType,
            onViewChange: taskProvider.setViewType,
            isDarkMode: isDarkMode,
          ),
          floatingActionButton: (taskProvider.viewType == ViewType.tasks ||
                  taskProvider.viewType == ViewType.money)
              ? FloatingActionButton(
                  onPressed: () {
                    if (taskProvider.viewType == ViewType.tasks) {
                      _showAddTaskModal(context, taskProvider);
                    } else if (taskProvider.viewType == ViewType.money) {
                      _showAddTransactionModal(context, taskProvider.isDarkMode);
                    }
                  },
                  elevation: 8,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: taskProvider.viewType == ViewType.money
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            )
                          : AppTheme.primaryGradient(isDarkMode),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: taskProvider.viewType == ViewType.money
                              ? const Color(0xFF10B981).withOpacity(0.4)
                              : const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    TaskProvider taskProvider,
    bool isDarkMode,
  ) {
    if (taskProvider.viewType == ViewType.analytics) {
      return AnalyticsView(isDarkMode: isDarkMode);
    }

    if (taskProvider.viewType == ViewType.money) {
      return MoneyView(isDarkMode: isDarkMode);
    }

    if (taskProvider.viewType == ViewType.settings) {
      return SettingsView(isDarkMode: isDarkMode);
    }

    return Column(
      children: [
        FilterTabs(
          activeFilter: taskProvider.timeFilter,
          onFilterChange: taskProvider.setTimeFilter,
          isDarkMode: isDarkMode,
        ),
        Expanded(
          child: _buildView(taskProvider, isDarkMode),
        ),
      ],
    );
  }

  Widget _buildView(TaskProvider taskProvider, bool isDarkMode) {
    switch (taskProvider.timeFilter) {
      case TimeFilter.today:
        return TodayView(isDarkMode: isDarkMode);
      case TimeFilter.week:
        return WeekView(isDarkMode: isDarkMode);
      case TimeFilter.month:
        return MonthView(isDarkMode: isDarkMode);
    }
  }

  String _getHeaderTitle(ViewType viewType) {
    switch (viewType) {
      case ViewType.tasks:
        return 'My Tasks';
      case ViewType.money:
        return 'My Money';
      case ViewType.analytics:
        return 'Analytics';
      case ViewType.settings:
        return 'Settings';
    }
  }

  void _showAddTaskModal(BuildContext context, TaskProvider taskProvider) {
    showAddTaskModal(
      context,
      taskProvider.isDarkMode,
      (task) => taskProvider.addTask(task),
    );
  }

  void _showAddTransactionModal(BuildContext context, bool isDarkMode) {
    final moneyProvider = Provider.of<MoneyProvider>(context, listen: false);
    showAddTransactionModal(
      context,
      isDarkMode,
      (transaction) => moneyProvider.addTransaction(transaction),
    );
  }

  void _showTaskDetails(BuildContext context, TaskProvider taskProvider) {
    final task = taskProvider.selectedTask;
    if (task == null) return;

    setState(() {
      _isModalShowing = true;
    });

    showTaskDetailsModal(
      context,
      task,
      taskProvider.isDarkMode,
      (updatedTask) => taskProvider.updateTask(task.id, updatedTask),
      () {
        taskProvider.deleteTask(task.id);
        Navigator.pop(context);
      },
      () {
        setState(() {
          _isModalShowing = false;
        });
        taskProvider.selectTask(null);
      },
    );
  }
}
