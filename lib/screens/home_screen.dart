import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/business.dart';
import '../providers/task_provider.dart';
import '../providers/money_provider.dart';
import '../providers/business_provider.dart';
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
import 'business_view.dart';
import 'settings_view.dart';
import 'profile_view.dart';
import 'meeting_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isModalShowing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, BusinessProvider>(
      builder: (context, taskProvider, businessProvider, child) {
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
                  // Hide header when inside business detail view
                  if (!(taskProvider.viewType == ViewType.business && businessProvider.selectedBusinessId != null))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppHeader(
                        isDarkMode: isDarkMode,
                        onToggleDarkMode: taskProvider.toggleDarkMode,
                        title: _getHeaderTitle(taskProvider.viewType),
                        onProfileTap: () => taskProvider.setViewType(ViewType.profile),
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
          floatingActionButton: _buildFAB(context, taskProvider, isDarkMode),
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

    if (taskProvider.viewType == ViewType.meetings) {
      return MeetingView(isDarkMode: isDarkMode);
    }

    if (taskProvider.viewType == ViewType.business) {
      return BusinessView(isDarkMode: isDarkMode);
    }

    if (taskProvider.viewType == ViewType.profile) {
      return ProfileView(isDarkMode: isDarkMode);
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
      case ViewType.business:
        return 'My Business';
      case ViewType.meetings:
        return 'Meetings';
      case ViewType.analytics:
        return 'Analytics';
      case ViewType.profile:
        return 'Profile';
      case ViewType.settings:
        return 'Settings';
    }
  }

  Widget? _buildFAB(BuildContext context, TaskProvider taskProvider, bool isDarkMode) {
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    // Check if we're inside a business detail view
    if (taskProvider.viewType == ViewType.business && businessProvider.selectedBusinessId != null) {
      final business = businessProvider.selectedBusiness;
      if (business != null) {
        return FloatingActionButton(
          onPressed: () => _showBusinessAddOptions(context, isDarkMode, business.type),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(isDarkMode),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        );
      }
    }

    // Regular FAB for tasks, money, and business list
    if (taskProvider.viewType == ViewType.tasks ||
        taskProvider.viewType == ViewType.money ||
        taskProvider.viewType == ViewType.business) {
      return FloatingActionButton(
        onPressed: () {
          if (taskProvider.viewType == ViewType.tasks) {
            _showAddTaskModal(context, taskProvider);
          } else if (taskProvider.viewType == ViewType.money) {
            _showAddTransactionModal(context, taskProvider.isDarkMode);
          } else if (taskProvider.viewType == ViewType.business) {
            _showAddBusinessModal(context, taskProvider.isDarkMode);
          }
        },
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: taskProvider.viewType == ViewType.money
                ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
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
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      );
    }

    return null;
  }

  void _showBusinessAddOptions(BuildContext context, bool isDarkMode, BusinessType businessType) {
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Add to Business', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.grey[900])),
            const SizedBox(height: 20),
            // Add Order/Income option
            _buildAddOption(
              context,
              businessType == BusinessType.ecom ? 'Add Order' : 'Add Income',
              businessType == BusinessType.ecom ? Icons.shopping_bag : Icons.payments,
              const Color(0xFF10B981),
              isDarkMode,
              () {
                Navigator.pop(context);
                if (businessType == BusinessType.ecom) {
                  _showAddOrderModal(context, isDarkMode, businessProvider);
                } else {
                  _showAddIncomeModal(context, isDarkMode, businessProvider);
                }
              },
            ),
            const SizedBox(height: 12),
            // Add Expense option
            _buildAddOption(
              context,
              'Add Expense',
              Icons.receipt_long,
              const Color(0xFFEF4444),
              isDarkMode,
              () {
                Navigator.pop(context);
                _showAddExpenseModal(context, isDarkMode, businessProvider);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(BuildContext context, String label, IconData icon, Color color, bool isDarkMode, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : Colors.grey[900])),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showAddOrderModal(BuildContext context, bool isDarkMode, BusinessProvider provider) {
    final customerController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final commissionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.grey[900])),
                    IconButton(icon: Icon(Icons.close, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField('Price', priceController, 'Enter price', isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildInputField('Delivery Commission', commissionController, '0.00', isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildInputField('Customer Name', customerController, 'Enter customer name', isDarkMode),
                const SizedBox(height: 12),
                _buildInputField('Description', descriptionController, 'What was ordered?', isDarkMode),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (customerController.text.trim().isEmpty || priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in required fields')));
                        return;
                      }
                      provider.addOrder(Order(
                        customerName: customerController.text.trim(),
                        description: descriptionController.text.trim(),
                        price: double.tryParse(priceController.text) ?? 0,
                        deliveryCommission: double.tryParse(commissionController.text) ?? 0,
                        date: selectedDate,
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Add Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddIncomeModal(BuildContext context, bool isDarkMode, BusinessProvider provider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Income', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.grey[900])),
                    IconButton(icon: Icon(Icons.close, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField('Amount', amountController, 'Enter amount', isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildInputField('Title', titleController, 'e.g., Monthly salary', isDarkMode),
                const SizedBox(height: 12),
                _buildInputField('Description (optional)', descriptionController, 'Add details', isDarkMode),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty || amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in required fields')));
                        return;
                      }
                      provider.addIncome(Income(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                        amount: double.tryParse(amountController.text) ?? 0,
                        date: selectedDate,
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Add Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context, bool isDarkMode, BusinessProvider provider) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    ExpenseType selectedType = ExpenseType.perOrder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Add Expense', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.grey[900])),
                    IconButton(icon: Icon(Icons.close, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField('Amount', amountController, 'Enter amount', isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildInputField('Title', titleController, 'e.g., Materials, Rent', isDarkMode),
                const SizedBox(height: 12),
                Text('Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildExpenseTypeChip('Per-Order', ExpenseType.perOrder, selectedType, const Color(0xFFF59E0B), isDarkMode, () => setState(() => selectedType = ExpenseType.perOrder)),
                    const SizedBox(width: 8),
                    _buildExpenseTypeChip('Fixed', ExpenseType.fixed, selectedType, const Color(0xFF8B5CF6), isDarkMode, () => setState(() => selectedType = ExpenseType.fixed)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty || amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in required fields')));
                        return;
                      }
                      provider.addExpense(Expense(
                        title: titleController.text.trim(),
                        amount: double.tryParse(amountController.text) ?? 0,
                        date: selectedDate,
                        type: selectedType,
                      ));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Add Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, bool isDark, {bool isNumber = false, String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[300] : Colors.grey[700])),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: TextStyle(color: isDark ? Colors.white : Colors.grey[900], fontSize: isNumber ? 20 : 16, fontWeight: isNumber ? FontWeight.bold : FontWeight.normal),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
            suffixText: suffix,
            suffixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTypeChip(String label, ExpenseType type, ExpenseType selectedType, Color color, bool isDarkMode, VoidCallback onTap) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[400] : Colors.grey[600]))),
      ),
    );
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

  void _showAddBusinessModal(BuildContext context, bool isDarkMode) {
    final nameController = TextEditingController();
    var selectedType = 0; // 0 = ecom, 1 = salary

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Business',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Business Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.grey[900]),
                decoration: InputDecoration(
                  hintText: 'e.g., My Online Store',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                  prefixIcon: Icon(Icons.business, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Business Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedType = 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedType == 0
                              ? const Color(0xFF6366F1).withOpacity(0.15)
                              : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedType == 0 ? const Color(0xFF6366F1) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.store, color: selectedType == 0 ? const Color(0xFF6366F1) : (isDarkMode ? Colors.grey[400] : Colors.grey[600]), size: 32),
                            const SizedBox(height: 8),
                            Text('E-Commerce', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selectedType == 0 ? const Color(0xFF6366F1) : (isDarkMode ? Colors.white : Colors.grey[900]))),
                            const SizedBox(height: 4),
                            Text('Online store', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.grey[500] : Colors.grey[500])),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedType = 1),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedType == 1
                              ? const Color(0xFFF59E0B).withOpacity(0.15)
                              : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedType == 1 ? const Color(0xFFF59E0B) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.work, color: selectedType == 1 ? const Color(0xFFF59E0B) : (isDarkMode ? Colors.grey[400] : Colors.grey[600]), size: 32),
                            const SizedBox(height: 8),
                            Text('Salary/Freelance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selectedType == 1 ? const Color(0xFFF59E0B) : (isDarkMode ? Colors.white : Colors.grey[900]))),
                            const SizedBox(height: 4),
                            Text('Job, freelance', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.grey[500] : Colors.grey[500])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter business name')),
                      );
                      return;
                    }
                    final provider = Provider.of<BusinessProvider>(context, listen: false);
                    provider.addBusiness(Business(
                      name: nameController.text.trim(),
                      type: selectedType == 0 ? BusinessType.ecom : BusinessType.salary,
                    ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Create Business',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
