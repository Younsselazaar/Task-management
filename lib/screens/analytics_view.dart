import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/money_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsView extends StatefulWidget {
  final bool isDarkMode;

  const AnalyticsView({super.key, required this.isDarkMode});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  int _selectedTab = 0; // 0 = Tasks, 1 = Money

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Switcher
        _buildTabSwitcher(),
        const SizedBox(height: 16),
        // Content
        Expanded(
          child: _selectedTab == 0
              ? _buildTasksAnalytics()
              : _buildMoneyAnalytics(),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? const Color(0xFF6366F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 18,
                      color: _selectedTab == 0
                          ? Colors.white
                          : widget.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tasks',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 0
                            ? Colors.white
                            : widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 18,
                      color: _selectedTab == 1
                          ? Colors.white
                          : widget.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Money',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 1
                            ? Colors.white
                            : widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MONEY ANALYTICS ====================
  Widget _buildMoneyAnalytics() {
    return Consumer<MoneyProvider>(
      builder: (context, moneyProvider, child) {
        final totalIncome = moneyProvider.totalIncome;
        final totalExpense = moneyProvider.totalExpense;
        final total = totalIncome + totalExpense;
        final incomePercent = total > 0 ? (totalIncome / total * 100) : 0.0;
        final expensePercent = total > 0 ? (totalExpense / total * 100) : 0.0;
        final balance = moneyProvider.balance;
        final isWinning = balance >= 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Win/Lose Status Card
              _buildWinLoseCard(isWinning, balance, incomePercent, expensePercent),
              const SizedBox(height: 16),

              // Income vs Expense Stats
              Row(
                children: [
                  Expanded(
                    child: _buildMoneyStatCard(
                      'Total Income',
                      '${totalIncome.toStringAsFixed(2)} DH',
                      Icons.arrow_downward,
                      const Color(0xFF10B981),
                      '${incomePercent.toStringAsFixed(1)}%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMoneyStatCard(
                      'Total Expense',
                      '${totalExpense.toStringAsFixed(2)} DH',
                      Icons.arrow_upward,
                      const Color(0xFFEF4444),
                      '${expensePercent.toStringAsFixed(1)}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Income/Expense Progress Bars
              _buildIncomeExpenseComparison(incomePercent, expensePercent),
              const SizedBox(height: 16),

              // This Month Stats
              _buildThisMonthCard(moneyProvider),
              const SizedBox(height: 16),

              // Month Comparison (This Month vs Last Month)
              _buildMonthComparisonCard(moneyProvider),
              const SizedBox(height: 16),

              // Year Overview (Best & Worst Month)
              _buildYearOverviewCard(moneyProvider),
              const SizedBox(height: 16),

              // Money Tips
              _buildMoneyTipsCard(isWinning, incomePercent, expensePercent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWinLoseCard(bool isWinning, double balance, double incomePercent, double expensePercent) {
    final String emoji;
    final String status;
    final String message;

    if (balance > 0) {
      emoji = '💰';
      status = 'You\'re Winning!';
      message = 'Great job! You earn more than you spend.';
    } else if (balance < 0) {
      emoji = '📉';
      status = 'You\'re Losing';
      message = 'Be careful! You spend more than you earn.';
    } else {
      emoji = '⚖️';
      status = 'Balanced';
      message = 'Your income and expenses are equal.';
    }

    final List<Color> gradientColors;
    final Color shadowColor;

    if (balance > 0) {
      gradientColors = [
        const Color(0xFF10B981).withOpacity(widget.isDarkMode ? 0.3 : 0.8),
        const Color(0xFF059669).withOpacity(widget.isDarkMode ? 0.3 : 0.8),
      ];
      shadowColor = const Color(0xFF10B981);
    } else if (balance < 0) {
      gradientColors = [
        const Color(0xFFEF4444).withOpacity(widget.isDarkMode ? 0.3 : 0.8),
        const Color(0xFFDC2626).withOpacity(widget.isDarkMode ? 0.3 : 0.8),
      ];
      shadowColor = const Color(0xFFEF4444);
    } else {
      gradientColors = [
        const Color(0xFF6366F1).withOpacity(widget.isDarkMode ? 0.3 : 0.8),
        const Color(0xFF8B5CF6).withOpacity(widget.isDarkMode ? 0.3 : 0.8),
      ];
      shadowColor = const Color(0xFF6366F1);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Balance: ${balance.toStringAsFixed(2)} DH',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String percent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  percent,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseComparison(double incomePercent, double expensePercent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income vs Expense',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 20),
          // Income Bar
          _buildPercentBar('Income', incomePercent, const Color(0xFF10B981)),
          const SizedBox(height: 16),
          // Expense Bar
          _buildPercentBar('Expense', expensePercent, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildPercentBar(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThisMonthCard(MoneyProvider moneyProvider) {
    final monthIncome = moneyProvider.thisMonthIncome;
    final monthExpense = moneyProvider.thisMonthExpense;
    final monthBalance = monthIncome - monthExpense;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          _buildMonthStatRow('Income', '${monthIncome.toStringAsFixed(2)} DH', const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildMonthStatRow('Expense', '${monthExpense.toStringAsFixed(2)} DH', const Color(0xFFEF4444)),
          const Divider(height: 24),
          _buildMonthStatRow(
            'Balance',
            '${monthBalance.toStringAsFixed(2)} DH',
            monthBalance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthComparisonCard(MoneyProvider moneyProvider) {
    final thisMonthBalance = moneyProvider.thisMonthBalance;
    final lastMonthBalance = moneyProvider.lastMonthBalance;
    final difference = moneyProvider.monthComparisonDifference;
    final isBetter = moneyProvider.isBetterThanLastMonth;

    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final thisMonthName = MoneyProvider.getMonthName(now.month);
    final lastMonthName = MoneyProvider.getMonthName(lastMonth.month);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Month Comparison',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBetter
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : thisMonthBalance == lastMonthBalance
                          ? const Color(0xFF6366F1).withOpacity(0.15)
                          : const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBetter
                          ? Icons.trending_up
                          : thisMonthBalance == lastMonthBalance
                              ? Icons.trending_flat
                              : Icons.trending_down,
                      size: 14,
                      color: isBetter
                          ? const Color(0xFF10B981)
                          : thisMonthBalance == lastMonthBalance
                              ? const Color(0xFF6366F1)
                              : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBetter
                          ? 'Better'
                          : thisMonthBalance == lastMonthBalance
                              ? 'Same'
                              : 'Worse',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isBetter
                            ? const Color(0xFF10B981)
                            : thisMonthBalance == lastMonthBalance
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lastMonthName,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lastMonthBalance.toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: lastMonthBalance >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: widget.isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      thisMonthName,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${thisMonthBalance.toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: thisMonthBalance >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Difference: ',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(2)} DH',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: difference > 0
                      ? const Color(0xFF10B981)
                      : difference < 0
                          ? const Color(0xFFEF4444)
                          : widget.isDarkMode
                              ? Colors.white
                              : Colors.grey[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearOverviewCard(MoneyProvider moneyProvider) {
    final bestMonth = moneyProvider.bestBalanceMonth;
    final worstMonth = moneyProvider.worstBalanceMonth;
    final now = DateTime.now();

    return Container(
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
                  const Color(0xFFF5F3FF),
                  const Color(0xFFEEF2FF),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? const Color(0xFF8B5CF6).withOpacity(0.3)
              : const Color(0xFF8B5CF6).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: widget.isDarkMode
                    ? const Color(0xFFA5B4FC)
                    : const Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              Text(
                '${now.year} Year Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Best Month
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best Balance Month',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      bestMonth != null
                          ? MoneyProvider.getMonthName(bestMonth.key)
                          : 'No data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                bestMonth != null
                    ? '${bestMonth.value.toStringAsFixed(2)} DH'
                    : '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Worst Month
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_down,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lowest Balance Month',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      worstMonth != null
                          ? MoneyProvider.getMonthName(worstMonth.key)
                          : 'No data',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                worstMonth != null
                    ? '${worstMonth.value.toStringAsFixed(2)} DH'
                    : '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyTipsCard(bool isWinning, double incomePercent, double expensePercent) {
    final tips = <String>[];

    if (!isWinning) {
      tips.add('Try to reduce your expenses to balance your budget.');
    }
    if (expensePercent > 70) {
      tips.add('Your expenses are ${expensePercent.toStringAsFixed(0)}% of total. Consider saving more.');
    }
    if (isWinning && incomePercent > 60) {
      tips.add('Great financial health! Consider investing your savings.');
    }
    if (tips.isEmpty) {
      tips.add('Keep tracking your income and expenses for better insights!');
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkMode
              ? [
                  const Color(0xFF6366F1).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.2),
                ]
              : [
                  const Color(0xFFEEF2FF),
                  const Color(0xFFF5F3FF),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? const Color(0xFF6366F1).withOpacity(0.3)
              : const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? const Color(0xFF6366F1).withOpacity(0.3)
                  : const Color(0xFF6366F1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: widget.isDarkMode
                  ? const Color(0xFFA5B4FC)
                  : const Color(0xFF4F46E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Money Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode
                        ? const Color(0xFFA5B4FC)
                        : const Color(0xFF3730A3),
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $tip',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDarkMode
                              ? const Color(0xFFC7D2FE).withOpacity(0.8)
                              : const Color(0xFF4338CA),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TASKS ANALYTICS ====================
  Widget _buildTasksAnalytics() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final productivityScore = taskProvider.productivityScore;
        final completionRate = taskProvider.completionRate.round();
        final weeklyStats = taskProvider.weeklyStats;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Productivity Score Card
              _buildProductivityScoreCard(productivityScore),
              const SizedBox(height: 16),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Tasks',
                      taskProvider.totalCount.toString(),
                      Icons.calendar_today,
                      const LinearGradient(
                        colors: [Color(0xFF818CF8), Color(0xFF8B5CF6)],
                      ),
                      widget.isDarkMode
                          ? const Color(0xFF6366F1).withOpacity(0.2)
                          : const Color(0xFF6366F1).withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      taskProvider.completedCount.toString(),
                      Icons.check_circle,
                      const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                      ),
                      widget.isDarkMode
                          ? AppTheme.completed.withOpacity(0.2)
                          : AppTheme.completed.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'In Progress',
                      taskProvider.inProgressCount.toString(),
                      Icons.access_time,
                      const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                      ),
                      widget.isDarkMode
                          ? AppTheme.inProgress.withOpacity(0.2)
                          : AppTheme.inProgress.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Missed',
                      taskProvider.missedCount.toString(),
                      Icons.cancel,
                      const LinearGradient(
                        colors: [Color(0xFFF87171), Color(0xFFEF4444)],
                      ),
                      widget.isDarkMode
                          ? AppTheme.missed.withOpacity(0.2)
                          : AppTheme.missed.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Completion Rate
              _buildCompletionRateCard(completionRate),
              const SizedBox(height: 16),

              // Weekly Performance
              _buildWeeklyPerformanceCard(weeklyStats),
              const SizedBox(height: 16),

              // Priority Breakdown
              _buildPriorityBreakdownCard(taskProvider),
              const SizedBox(height: 16),

              // Tips Card
              _buildTipsCard(taskProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductivityScoreCard(int score) {
    String emoji = score >= 80 ? '🚀' : score >= 60 ? '💪' : '📈';
    String message = score >= 70 ? 'Great work!' : 'Keep going!';

    return Container(
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
                'Productivity Score',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDarkMode
                      ? const Color(0xFFD8B4FE)
                      : const Color(0xFF6366F1),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  Text(
                    ' / 100',
                    style: TextStyle(
                      fontSize: 18,
                      color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: score >= 70
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    LinearGradient gradient,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateCard(int rate) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Completion Rate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              Text(
                '$rate%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: rate / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPerformanceCard(Map<String, int> stats) {
    final weeklyRate = stats['total']! > 0
        ? (stats['completed']! / stats['total']! * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Week's Performance",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Tasks Created', '${stats['total']}'),
          const SizedBox(height: 12),
          _buildStatRow('Tasks Completed', '${stats['completed']}'),
          const SizedBox(height: 12),
          _buildStatRow('Completion Rate', '$weeklyRate%'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBreakdownCard(TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          _buildPriorityRow(
            'High Priority',
            taskProvider.highPriorityCount,
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          _buildPriorityRow(
            'Medium Priority',
            taskProvider.mediumPriorityCount,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 12),
          _buildPriorityRow(
            'Low Priority',
            taskProvider.lowPriorityCount,
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(TaskProvider taskProvider) {
    final tips = <String>[];

    if (taskProvider.missedCount > 0) {
      tips.add(
          'You have ${taskProvider.missedCount} missed task${taskProvider.missedCount > 1 ? 's' : ''}. Consider reviewing and rescheduling.');
    }
    if (taskProvider.highPriorityCount > 3) {
      tips.add('Focus on high-priority tasks first to maximize impact.');
    }
    if (taskProvider.completionRate >= 80) {
      tips.add('Great job! Keep up the excellent work! 🎉');
    }
    if (taskProvider.completionRate < 50) {
      tips.add('Break down large tasks into smaller, manageable subtasks.');
    }

    if (tips.isEmpty) {
      tips.add("You're doing great! Keep up the good work!");
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDarkMode
              ? [
                  const Color(0xFF10B981).withOpacity(0.2),
                  const Color(0xFF14B8A6).withOpacity(0.2),
                ]
              : [
                  const Color(0xFFECFDF5),
                  const Color(0xFFF0FDFA),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isDarkMode
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFF10B981).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.track_changes,
              color: widget.isDarkMode
                  ? const Color(0xFF6EE7B7)
                  : const Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productivity Tips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isDarkMode
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $tip',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isDarkMode
                              ? const Color(0xFFA7F3D0).withOpacity(0.8)
                              : const Color(0xFF047857),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
