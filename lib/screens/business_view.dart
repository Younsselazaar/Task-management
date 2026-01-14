import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/business.dart';
import '../providers/business_provider.dart';
import '../widgets/empty_state.dart';
import 'business_detail_view.dart';

class BusinessView extends StatefulWidget {
  final bool isDarkMode;

  const BusinessView({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<BusinessView> createState() => _BusinessViewState();
}

class _BusinessViewState extends State<BusinessView> {
  DateTime? _selectedMonth;

  // Filter helpers
  bool _isInSelectedMonth(DateTime date) {
    if (_selectedMonth == null) return true;
    return date.year == _selectedMonth!.year && date.month == _selectedMonth!.month;
  }

  double _getFilteredProfit(Business business) {
    if (_selectedMonth == null) return business.profit;

    final isEcom = business.type == BusinessType.ecom;

    if (isEcom) {
      final revenue = business.orders
          .where((o) => o.status == OrderStatus.completed && _isInSelectedMonth(o.date))
          .fold(0.0, (sum, o) => sum + o.netPrice);
      final expenses = business.expenses
          .where((e) => _isInSelectedMonth(e.date))
          .fold(0.0, (sum, e) => sum + e.amount);
      return revenue - expenses;
    } else {
      final income = business.incomes
          .where((i) => _isInSelectedMonth(i.date))
          .fold(0.0, (sum, i) => sum + i.amount);
      final expenses = business.expenses
          .where((e) => _isInSelectedMonth(e.date))
          .fold(0.0, (sum, e) => sum + e.amount);
      return income - expenses;
    }
  }

  double _getTotalFilteredProfit(List<Business> businesses) {
    return businesses.fold(0.0, (sum, b) => sum + _getFilteredProfit(b));
  }

  int _getFilteredOrderCount(Business business) {
    if (_selectedMonth == null) return business.orders.length;
    return business.orders.where((o) => _isInSelectedMonth(o.date)).length;
  }

  int _getFilteredIncomeCount(Business business) {
    if (_selectedMonth == null) return business.incomes.length;
    return business.incomes.where((i) => _isInSelectedMonth(i.date)).length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, child) {
        // If a business is selected, show detail view
        if (provider.selectedBusinessId != null && provider.selectedBusiness != null) {
          return BusinessDetailView(
            business: provider.selectedBusiness!,
            isDarkMode: widget.isDarkMode,
            onBack: () => provider.selectBusiness(null),
          );
        }

        // Show businesses list
        return Column(
          children: [
            // Summary card
            _buildSummaryCard(provider),
            const SizedBox(height: 12),
            // Month filter
            _buildMonthFilter(),
            const SizedBox(height: 12),
            // Businesses list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Businesses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                Text(
                  '${provider.businesses.length} total',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Businesses list
            Expanded(
              child: provider.businesses.isEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          EmptyState(
                            isDarkMode: widget.isDarkMode,
                            title: 'No businesses yet',
                            message: 'Create your first business to start tracking',
                            icon: Icons.business_center_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildAddButton(context, 'Add Business', Icons.add_business),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 600;
                        if (isDesktop) {
                          // Grid layout for desktop
                          final crossAxisCount = constraints.maxWidth >= 1000 ? 3 : 2;
                          return GridView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 2.2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: provider.businesses.length,
                            itemBuilder: (context, index) {
                              final business = provider.businesses[index];
                              return _buildBusinessCard(context, business, provider);
                            },
                          );
                        }
                        // List layout for mobile
                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: provider.businesses.length,
                          itemBuilder: (context, index) {
                            final business = provider.businesses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildBusinessCard(context, business, provider),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Time', null),
          const SizedBox(width: 8),
          _buildFilterChip('This Month', DateTime.now()),
          const SizedBox(width: 8),
          _buildMonthPickerChip(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DateTime? month) {
    final bool isSelected;
    if (month == null) {
      isSelected = _selectedMonth == null;
    } else {
      final now = DateTime.now();
      isSelected = _selectedMonth != null &&
          _selectedMonth!.year == now.year &&
          _selectedMonth!.month == now.month &&
          month.year == now.year &&
          month.month == now.month;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedMonth = month),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthPickerChip() {
    final isSelected = _selectedMonth != null &&
        !(_selectedMonth!.year == DateTime.now().year && _selectedMonth!.month == DateTime.now().month);
    final label = isSelected ? DateFormat('MMM yyyy').format(_selectedMonth!) : 'Pick Month';

    return GestureDetector(
      onTap: _showMonthPicker,
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

  void _showMonthPicker() {
    final now = DateTime.now();
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
                      setState(() => _selectedMonth = month);
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

  Widget _buildSummaryCard(BusinessProvider provider) {
    final totalProfit = _getTotalFilteredProfit(provider.businesses);
    final isWinning = totalProfit >= 0;
    final Color statusColor = isWinning ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final convertedProfit = provider.convertAmount(totalProfit);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkMode
              ? [
                  const Color(0xFF6366F1).withOpacity(0.3),
                  const Color(0xFF8B5CF6).withOpacity(0.15),
                ]
              : [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isWinning ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _selectedMonth == null ? 'TOTAL PROFIT' : 'PROFIT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1,
                      ),
                    ),
                    if (_selectedMonth != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('MMM yy').format(_selectedMonth!),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      provider.isUsd
                          ? '${isWinning ? '+' : ''}\$${convertedProfit.toStringAsFixed(2)}'
                          : '${isWinning ? '+' : ''}${convertedProfit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (!provider.isUsd)
                      const Text(
                        ' DH',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Currency toggle button
              GestureDetector(
                onTap: () => provider.toggleCurrency(),
                onLongPress: () => provider.refreshExchangeRate(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (provider.isLoadingRate)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        Text(
                          provider.isUsd ? '\$' : 'DH',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.swap_horiz, size: 14, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              if (provider.isUsd) ...[
                const SizedBox(height: 2),
                Text(
                  '1 DH = \$${provider.currentRate.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              _buildTypeCount(Icons.store, provider.ecomBusinessCount, 'Ecom'),
              const SizedBox(height: 4),
              _buildTypeCount(Icons.work, provider.salaryBusinessCount, 'Salary'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCount(IconData icon, int count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(BuildContext context, Business business, BusinessProvider provider) {
    final isEcom = business.type == BusinessType.ecom;
    final typeColor = isEcom ? const Color(0xFF6366F1) : const Color(0xFFF59E0B);
    final profit = _getFilteredProfit(business);
    final isWinning = profit >= 0;
    final orderCount = _getFilteredOrderCount(business);
    final incomeCount = _getFilteredIncomeCount(business);

    return Dismissible(
      key: Key(business.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context, business.name),
      onDismissed: (_) => provider.deleteBusiness(business.id),
      child: GestureDetector(
        onTap: () => provider.selectBusiness(business.id),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isEcom ? Icons.store : Icons.work,
                  color: typeColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isEcom ? 'E-Commerce' : 'Salary/Freelance',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isEcom) ...[
                          Icon(Icons.receipt, size: 12, color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '$orderCount orders',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ] else ...[
                          Icon(Icons.payments, size: 12, color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '$incomeCount incomes',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    provider.formatAmount(profit, showSign: true),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isWinning ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String businessName) async {
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
              'Delete Business?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.grey[900],
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$businessName"? All orders, incomes, and expenses will be lost.',
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

  Widget _buildAddButton(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () => _showAddBusinessModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBusinessModal(BuildContext context) {
    final nameController = TextEditingController();
    BusinessType selectedType = BusinessType.ecom;

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
                      color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Business Name
              Text(
                'Business Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.grey[900]),
                decoration: InputDecoration(
                  hintText: 'e.g., My Online Store',
                  hintStyle: TextStyle(color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[400]),
                  prefixIcon: Icon(Icons.business, color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  filled: true,
                  fillColor: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Business Type
              Text(
                'Business Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      context,
                      'E-Commerce',
                      'Online store, dropshipping',
                      Icons.store,
                      BusinessType.ecom,
                      selectedType,
                      const Color(0xFF6366F1),
                      () => setState(() => selectedType = BusinessType.ecom),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeOption(
                      context,
                      'Salary/Freelance',
                      'Job, freelance work',
                      Icons.work,
                      BusinessType.salary,
                      selectedType,
                      const Color(0xFFF59E0B),
                      () => setState(() => selectedType = BusinessType.salary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Submit Button
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
                      type: selectedType,
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

  Widget _buildTypeOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    BusinessType type,
    BusinessType selectedType,
    Color color,
    VoidCallback onTap,
  ) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[600]), size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : (widget.isDarkMode ? Colors.white : Colors.grey[900]),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
