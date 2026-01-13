import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/business.dart';
import '../providers/business_provider.dart';
import '../widgets/empty_state.dart';

class BusinessDetailView extends StatefulWidget {
  final Business business;
  final bool isDarkMode;
  final VoidCallback onBack;

  const BusinessDetailView({
    super.key,
    required this.business,
    required this.isDarkMode,
    required this.onBack,
  });

  @override
  State<BusinessDetailView> createState() => _BusinessDetailViewState();
}

enum BusinessTimeFilter { all, today, month, year }

class _BusinessDetailViewState extends State<BusinessDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  BusinessTimeFilter _timeFilter = BusinessTimeFilter.all;
  DateTime? _selectedMonth; // null means current filter applies, otherwise filter by this specific month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.business.type == BusinessType.ecom ? 2 : 2,
      vsync: this,
    );
  }

  bool _isInTimeRange(DateTime date) {
    // If a specific month is selected, filter by that month
    if (_selectedMonth != null) {
      return date.year == _selectedMonth!.year && date.month == _selectedMonth!.month;
    }

    final now = DateTime.now();
    switch (_timeFilter) {
      case BusinessTimeFilter.all:
        return true;
      case BusinessTimeFilter.today:
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case BusinessTimeFilter.month:
        return date.year == now.year && date.month == now.month;
      case BusinessTimeFilter.year:
        return date.year == now.year;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, child) {
        final business = provider.selectedBusiness ?? widget.business;
        final isEcom = business.type == BusinessType.ecom;

        return Column(
          children: [
            // Back button and title
            Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: widget.isDarkMode ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                        ),
                      ),
                      Text(
                        isEcom ? 'E-Commerce' : 'Salary/Freelance',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Profit card
            _buildProfitCard(business),
            const SizedBox(height: 10),
            // Month comparison
            _buildMonthComparison(business),
            const SizedBox(height: 10),
            // Time filter
            _buildTimeFilter(business),
            const SizedBox(height: 10),
            // Summary row
            _buildSummaryRow(business),
            const SizedBox(height: 10),
            // Tab bar
            _buildTabBar(isEcom),
            const SizedBox(height: 8),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: isEcom
                    ? [
                        _buildOrdersList(business, provider),
                        _buildExpensesList(business, provider),
                      ]
                    : [
                        _buildIncomesList(business, provider),
                        _buildExpensesList(business, provider),
                      ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Filtered calculations
  double _getFilteredRevenue(Business business) {
    return business.orders
        .where((o) => o.status == OrderStatus.completed && _isInTimeRange(o.date))
        .fold(0.0, (sum, o) => sum + o.netPrice);
  }

  double _getFilteredIncome(Business business) {
    return business.incomes
        .where((i) => _isInTimeRange(i.date))
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  double _getFilteredExpenses(Business business) {
    return business.expenses
        .where((e) => _isInTimeRange(e.date))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double _getFilteredProfit(Business business) {
    final isEcom = business.type == BusinessType.ecom;
    return isEcom
        ? _getFilteredRevenue(business) - _getFilteredExpenses(business)
        : _getFilteredIncome(business) - _getFilteredExpenses(business);
  }

  int _getFilteredOrderCount(Business business) {
    return business.orders.where((o) => _isInTimeRange(o.date)).length;
  }

  int _getFilteredIncomeCount(Business business) {
    return business.incomes.where((i) => _isInTimeRange(i.date)).length;
  }

  // Last month calculations
  bool _isInLastMonth(DateTime date) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return date.year == lastMonth.year && date.month == lastMonth.month;
  }

  double _getLastMonthRevenue(Business business) {
    return business.orders
        .where((o) => o.status == OrderStatus.completed && _isInLastMonth(o.date))
        .fold(0.0, (sum, o) => sum + o.netPrice);
  }

  double _getLastMonthIncome(Business business) {
    return business.incomes
        .where((i) => _isInLastMonth(i.date))
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  double _getLastMonthExpenses(Business business) {
    return business.expenses
        .where((e) => _isInLastMonth(e.date))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  int _getLastMonthOrderCount(Business business) {
    return business.orders.where((o) => _isInLastMonth(o.date)).length;
  }

  int _getLastMonthIncomeCount(Business business) {
    return business.incomes.where((i) => _isInLastMonth(i.date)).length;
  }

  // This month calculations
  bool _isInThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  double _getThisMonthRevenue(Business business) {
    return business.orders
        .where((o) => o.status == OrderStatus.completed && _isInThisMonth(o.date))
        .fold(0.0, (sum, o) => sum + o.netPrice);
  }

  double _getThisMonthIncome(Business business) {
    return business.incomes
        .where((i) => _isInThisMonth(i.date))
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  int _getThisMonthOrderCount(Business business) {
    return business.orders.where((o) => _isInThisMonth(o.date)).length;
  }

  int _getThisMonthIncomeCount(Business business) {
    return business.incomes.where((i) => _isInThisMonth(i.date)).length;
  }

  Widget _buildTimeFilter(Business business) {
    final isEcom = business.type == BusinessType.ecom;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', BusinessTimeFilter.all, isEcom ? business.orders.length : null),
          const SizedBox(width: 8),
          _buildFilterChip('Today', BusinessTimeFilter.today, isEcom ? _getCountForFilter(business, BusinessTimeFilter.today) : null),
          const SizedBox(width: 8),
          _buildFilterChip('Month', BusinessTimeFilter.month, isEcom ? _getCountForFilter(business, BusinessTimeFilter.month) : null),
          const SizedBox(width: 8),
          _buildFilterChip('Year', BusinessTimeFilter.year, isEcom ? _getCountForFilter(business, BusinessTimeFilter.year) : null),
          const SizedBox(width: 8),
          _buildMonthPickerChip(business, isEcom),
        ],
      ),
    );
  }

  Widget _buildMonthPickerChip(Business business, bool isEcom) {
    final isSelected = _selectedMonth != null;
    final label = isSelected ? DateFormat('MMM yyyy').format(_selectedMonth!) : 'Pick Month';

    int? count;
    if (isSelected && isEcom) {
      count = business.orders.where((o) =>
        o.date.year == _selectedMonth!.year && o.date.month == _selectedMonth!.month
      ).length;
    }

    return GestureDetector(
      onTap: () => _showMonthPicker(business),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)])
              : null,
          color: isSelected ? null : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : (widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month, size: 14, color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[700])),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[700]),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
            if (isSelected) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() => _selectedMonth = null),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(Business business) {
    final now = DateTime.now();
    // Generate last 24 months
    final months = List.generate(24, (i) => DateTime(now.year, now.month - i, 1));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(
              'Select Month',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = months[index];
                  final isSelected = _selectedMonth != null &&
                      _selectedMonth!.year == month.year &&
                      _selectedMonth!.month == month.month;
                  final isCurrentMonth = month.year == now.year && month.month == now.month;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMonth = month;
                        _timeFilter = BusinessTimeFilter.all; // Reset other filter
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)])
                            : null,
                        color: isSelected
                            ? null
                            : (isCurrentMonth
                                ? (widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200)
                                : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          DateFormat('MMM yy').format(month),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected || isCurrentMonth ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (widget.isDarkMode ? Colors.white : Colors.grey[800]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  int _getCountForFilter(Business business, BusinessTimeFilter filter) {
    final isEcom = business.type == BusinessType.ecom;
    final now = DateTime.now();

    bool inRange(DateTime date) {
      switch (filter) {
        case BusinessTimeFilter.all:
          return true;
        case BusinessTimeFilter.today:
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case BusinessTimeFilter.month:
          return date.year == now.year && date.month == now.month;
        case BusinessTimeFilter.year:
          return date.year == now.year;
      }
    }

    if (isEcom) {
      return business.orders.where((o) => inRange(o.date)).length;
    } else {
      return business.incomes.where((i) => inRange(i.date)).length;
    }
  }

  Widget _buildFilterChip(String label, BusinessTimeFilter filter, int? count) {
    final isSelected = _timeFilter == filter && _selectedMonth == null;
    return GestureDetector(
      onTap: () => setState(() {
        _timeFilter = filter;
        _selectedMonth = null; // Clear month picker when using preset filters
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
              : null,
          color: isSelected ? null : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : (widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[700]),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : (widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthComparison(Business business) {
    final isEcom = business.type == BusinessType.ecom;
    final now = DateTime.now();
    final thisMonthName = DateFormat('MMM').format(now);
    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthName = DateFormat('MMM').format(lastMonth);

    final thisMonthMoney = isEcom ? _getThisMonthRevenue(business) : _getThisMonthIncome(business);
    final lastMonthMoney = isEcom ? _getLastMonthRevenue(business) : _getLastMonthIncome(business);
    final thisMonthCount = isEcom ? _getThisMonthOrderCount(business) : _getThisMonthIncomeCount(business);
    final lastMonthCount = isEcom ? _getLastMonthOrderCount(business) : _getLastMonthIncomeCount(business);

    final moneyDiff = lastMonthMoney > 0 ? ((thisMonthMoney - lastMonthMoney) / lastMonthMoney * 100) : (thisMonthMoney > 0 ? 100 : 0);
    final countDiff = lastMonthCount > 0 ? ((thisMonthCount - lastMonthCount) / lastMonthCount * 100) : (thisMonthCount > 0 ? 100 : 0);

    final isMoneyUp = thisMonthMoney >= lastMonthMoney;
    final isCountUp = thisMonthCount >= lastMonthCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lastMonthName,
                style: TextStyle(fontSize: 11, color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[500]),
              ),
              Icon(Icons.arrow_forward, size: 12, color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[500]),
              Text(
                thisMonthName,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.isDarkMode ? Colors.white : Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildComparisonItem(
                  isEcom ? 'Orders' : 'Incomes',
                  thisMonthCount,
                  lastMonthCount,
                  countDiff.toDouble(),
                  isCountUp,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
              ),
              Expanded(
                child: _buildComparisonItem(
                  isEcom ? 'Revenue' : 'Income',
                  thisMonthMoney.toInt(),
                  lastMonthMoney.toInt(),
                  moneyDiff.toDouble(),
                  isMoneyUp,
                  isMoney: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String label, int thisMonth, int lastMonth, double percentage, bool isUp, {bool isMoney = false}) {
    final color = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$thisMonth',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                if (isMoney)
                  Text(' DH', style: TextStyle(fontSize: 10, color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[600])),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, size: 10, color: color),
                Text(
                  '${percentage.abs().toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitCard(Business business) {
    final profit = _getFilteredProfit(business);
    final isWinning = profit >= 0;
    final total = business.type == BusinessType.ecom ? _getFilteredRevenue(business) : _getFilteredIncome(business);
    final percentage = total > 0 ? (profit / total) * 100 : 0.0;
    final statusColor = isWinning ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkMode
              ? [statusColor.withOpacity(0.3), statusColor.withOpacity(0.15)]
              : [statusColor.withOpacity(0.8), statusColor],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isWinning ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWinning ? 'WINNING' : 'LOSING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${isWinning ? '+' : ''}${profit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      ' DH',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(Business business) {
    final isEcom = business.type == BusinessType.ecom;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            isEcom ? 'Revenue' : 'Income',
            isEcom ? _getFilteredRevenue(business) : _getFilteredIncome(business),
            isEcom ? Icons.payments_outlined : Icons.account_balance_wallet,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            'Expenses',
            _getFilteredExpenses(business),
            Icons.receipt_long_outlined,
            const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(2)} DH',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isEcom) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: [
          Tab(text: isEcom ? 'Orders' : 'Incomes'),
          const Tab(text: 'Expenses'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(Business business, BusinessProvider provider) {
    final orders = business.orders
        .where((o) => _isInTimeRange(o.date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (orders.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            EmptyState(
              isDarkMode: widget.isDarkMode,
              title: 'No orders yet',
              message: 'Add orders to track your sales',
              icon: Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 16),
            _buildAddButton('Add Order', () => _showAddOrderModal(context, provider)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildOrderCard(order, provider),
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: _buildAddButton('Add Order', () => _showAddOrderModal(context, provider)),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order, BusinessProvider provider) {
    Color statusColor;
    String statusText;

    switch (order.status) {
      case OrderStatus.completed:
        statusColor = const Color(0xFF10B981);
        statusText = 'Completed';
        break;
      case OrderStatus.pending:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Pending';
        break;
      case OrderStatus.cancelled:
        statusColor = const Color(0xFFEF4444);
        statusText = 'Cancelled';
        break;
    }

    return Dismissible(
      key: Key(order.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context, 'order'),
      onDismissed: (_) => provider.deleteOrder(order.id),
      child: GestureDetector(
        onTap: () => _showOrderStatusModal(context, order, provider),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDarkMode ? Colors.white.withOpacity(0.15) : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shopping_bag, color: statusColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    Text(
                      '${order.description} • ${_formatDate(order.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${order.netPrice.toStringAsFixed(0)} DH',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomesList(Business business, BusinessProvider provider) {
    final incomes = business.incomes
        .where((i) => _isInTimeRange(i.date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (incomes.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            EmptyState(
              isDarkMode: widget.isDarkMode,
              title: 'No incomes yet',
              message: 'Add income to track your earnings',
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 16),
            _buildAddButton('Add Income', () => _showAddIncomeModal(context, provider)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: incomes.length,
          itemBuilder: (context, index) {
            final income = incomes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildIncomeCard(income, provider),
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: _buildAddButton('Add Income', () => _showAddIncomeModal(context, provider)),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeCard(Income income, BusinessProvider provider) {
    return Dismissible(
      key: Key(income.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context, 'income'),
      onDismissed: (_) => provider.deleteIncome(income.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDarkMode ? Colors.white.withOpacity(0.15) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payments, color: Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    income.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  if (income.description != null && income.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      income.description!,
                      style: TextStyle(fontSize: 13, color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(income.date),
                    style: TextStyle(fontSize: 12, color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Text(
              '+${income.amount.toStringAsFixed(2)} DH',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(Business business, BusinessProvider provider) {
    final expenses = business.expenses
        .where((e) => _isInTimeRange(e.date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (expenses.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            EmptyState(
              isDarkMode: widget.isDarkMode,
              title: 'No expenses yet',
              message: 'Add expenses to track your costs',
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 16),
            _buildAddButton('Add Expense', () => _showAddExpenseModal(context, provider)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildExpenseCard(expense, provider),
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: _buildAddButton('Add Expense', () => _showAddExpenseModal(context, provider)),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseCard(Expense expense, BusinessProvider provider) {
    final isFixed = expense.type == ExpenseType.fixed;
    final typeColor = isFixed ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context, 'expense'),
      onDismissed: (_) => provider.deleteExpense(expense.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isDarkMode ? Colors.white.withOpacity(0.15) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isFixed ? Icons.repeat : Icons.shopping_cart, color: typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isFixed ? 'Fixed' : 'Per-Order',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: typeColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(expense.date),
                        style: TextStyle(fontSize: 12, color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '-${expense.amount.toStringAsFixed(2)} DH',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String itemType) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete $itemType?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this $itemType? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildAddButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  void _showAddOrderModal(BuildContext context, BusinessProvider provider) {
    final customerController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final commissionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    OrderStatus selectedStatus = OrderStatus.pending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalHeader('Add Order', context),
                const SizedBox(height: 16),
                _buildTextField('Price', priceController, 'Enter price', widget.isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildTextField('Delivery Commission', commissionController, '0.00', widget.isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildTextField('Customer Name', customerController, 'Enter customer name', widget.isDarkMode),
                const SizedBox(height: 12),
                _buildTextField('Description', descriptionController, 'What was ordered?', widget.isDarkMode),
                const SizedBox(height: 12),
                _buildDatePicker('Date', selectedDate, widget.isDarkMode, (date) => setState(() => selectedDate = date)),
                const SizedBox(height: 16),
                _buildSubmitButton('Add Order', const Color(0xFF6366F1), () {
                  if (customerController.text.trim().isEmpty || priceController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in required fields')),
                    );
                    return;
                  }
                  final price = double.tryParse(priceController.text) ?? 0;
                  final commission = double.tryParse(commissionController.text) ?? 0;
                  provider.addOrder(Order(
                    customerName: customerController.text.trim(),
                    description: descriptionController.text.trim(),
                    price: price,
                    deliveryCommission: commission,
                    date: selectedDate,
                    status: selectedStatus,
                  ));
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddIncomeModal(BuildContext context, BusinessProvider provider) {
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
            color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalHeader('Add Income', context),
                const SizedBox(height: 16),
                _buildTextField('Amount', amountController, 'Enter amount', widget.isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildTextField('Title', titleController, 'e.g., Monthly salary', widget.isDarkMode),
                const SizedBox(height: 12),
                _buildTextField('Description (optional)', descriptionController, 'Add details', widget.isDarkMode),
                const SizedBox(height: 12),
                _buildDatePicker('Date', selectedDate, widget.isDarkMode, (date) => setState(() => selectedDate = date)),
                const SizedBox(height: 16),
                _buildSubmitButton('Add Income', const Color(0xFF10B981), () {
                  if (titleController.text.trim().isEmpty || amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in required fields')),
                    );
                    return;
                  }
                  final amount = double.tryParse(amountController.text) ?? 0;
                  provider.addIncome(Income(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                    amount: amount,
                    date: selectedDate,
                  ));
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context, BusinessProvider provider) {
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
            color: widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalHeader('Add Expense', context),
                const SizedBox(height: 16),
                _buildTextField('Amount', amountController, 'Enter amount', widget.isDarkMode, isNumber: true, suffix: 'DH'),
                const SizedBox(height: 12),
                _buildTextField('Title', titleController, 'e.g., Materials, Rent', widget.isDarkMode),
                const SizedBox(height: 12),
                Text('Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildExpenseTypeChip('Per-Order', ExpenseType.perOrder, selectedType, const Color(0xFFF59E0B), () => setState(() => selectedType = ExpenseType.perOrder)),
                    const SizedBox(width: 8),
                    _buildExpenseTypeChip('Fixed', ExpenseType.fixed, selectedType, const Color(0xFF8B5CF6), () => setState(() => selectedType = ExpenseType.fixed)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDatePicker('Date', selectedDate, widget.isDarkMode, (date) => setState(() => selectedDate = date)),
                const SizedBox(height: 16),
                _buildSubmitButton('Add Expense', const Color(0xFFEF4444), () {
                  if (titleController.text.trim().isEmpty || amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in required fields')),
                    );
                    return;
                  }
                  final amount = double.tryParse(amountController.text) ?? 0;
                  provider.addExpense(Expense(
                    title: titleController.text.trim(),
                    amount: amount,
                    date: selectedDate,
                    type: selectedType,
                  ));
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderStatusModal(BuildContext context, Order order, BusinessProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Update Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.grey[900])),
            const SizedBox(height: 16),
            _buildStatusOption('Pending', OrderStatus.pending, order.status, const Color(0xFFF59E0B), () {
              provider.updateOrder(order.id, order.copyWith(status: OrderStatus.pending));
              Navigator.pop(context);
            }),
            const SizedBox(height: 8),
            _buildStatusOption('Completed', OrderStatus.completed, order.status, const Color(0xFF10B981), () {
              provider.updateOrder(order.id, order.copyWith(status: OrderStatus.completed));
              Navigator.pop(context);
            }),
            const SizedBox(height: 8),
            _buildStatusOption('Cancelled', OrderStatus.cancelled, order.status, const Color(0xFFEF4444), () {
              provider.updateOrder(order.id, order.copyWith(status: OrderStatus.cancelled));
              Navigator.pop(context);
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String label, OrderStatus status, OrderStatus currentStatus, Color color, VoidCallback onTap) {
    final isSelected = currentStatus == status;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? color : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : (widget.isDarkMode ? Colors.white : Colors.grey[900]))),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.grey[900])),
        IconButton(icon: Icon(Icons.close, color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500]), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, bool isDark, {bool isNumber = false, String? suffix}) {
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

  Widget _buildDatePicker(String label, DateTime date, bool isDark, Function(DateTime) onDateChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.grey[300] : Colors.grey[700])),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onDateChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 10),
                Text(DateFormat('EEEE, MMM d, yyyy').format(date), style: TextStyle(color: isDark ? Colors.white : Colors.grey[900])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _buildExpenseTypeChip(String label, ExpenseType type, ExpenseType selectedType, Color color, VoidCallback onTap) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[600]))),
      ),
    );
  }
}
