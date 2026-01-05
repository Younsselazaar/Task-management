import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/money_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/empty_state.dart';

class MoneyView extends StatelessWidget {
  final bool isDarkMode;

  const MoneyView({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoneyProvider>(
      builder: (context, moneyProvider, child) {
        final transactions = moneyProvider.sortedTransactions;

        return Column(
          children: [
            // Balance Card
            _buildBalanceCard(moneyProvider),
            const SizedBox(height: 16),
            // Income/Expense Summary
            _buildSummaryRow(moneyProvider),
            const SizedBox(height: 16),
            // Filter Chips
            _buildFilterChips(moneyProvider),
            const SizedBox(height: 16),
            // Transactions List
            Expanded(
              child: transactions.isEmpty
                  ? SingleChildScrollView(
                      child: EmptyState(
                        isDarkMode: isDarkMode,
                        title: 'No transactions yet',
                        message: 'Start tracking your money by adding your first transaction',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TransactionCard(
                            transaction: transaction,
                            isDarkMode: isDarkMode,
                            onDelete: () =>
                                moneyProvider.deleteTransaction(transaction.id),
                            onTap: () =>
                                moneyProvider.selectTransaction(transaction.id),
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

  Widget _buildBalanceCard(MoneyProvider provider) {
    final balance = provider.balance;

    final IconData statusIcon;
    final String statusText;

    if (balance > 0) {
      statusIcon = Icons.trending_up;
      statusText = 'Positive Balance';
    } else if (balance < 0) {
      statusIcon = Icons.trending_down;
      statusText = 'Negative Balance';
    } else {
      statusIcon = Icons.balance;
      statusText = 'Balanced';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF8B5CF6).withOpacity(0.3),
                  const Color(0xFF6366F1).withOpacity(0.3),
                ]
              : [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (balance < 0)
                const Text(
                  '-',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              Text(
                '${balance.abs().toStringAsFixed(2)} ',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'DH',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(MoneyProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Income',
            provider.totalIncome,
            Icons.arrow_downward,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Expense',
            provider.totalExpense,
            Icons.arrow_upward,
            const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.6),
        ),
      ),
      child: Row(
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  '${amount.toStringAsFixed(2)} DH',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(MoneyProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            'All',
            provider.typeFilter == null,
            () => provider.setTypeFilter(null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Income',
            provider.typeFilter == TransactionType.income,
            () => provider.setTypeFilter(TransactionType.income),
            icon: Icons.arrow_downward,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Expense',
            provider.typeFilter == TransactionType.expense,
            () => provider.setTypeFilter(TransactionType.expense),
            icon: Icons.arrow_upward,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isActive,
    VoidCallback onTap, {
    IconData? icon,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xFF8B5CF6), const Color(0xFF6366F1)]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                )
              : null,
          color: isActive
              ? null
              : isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive
                    ? Colors.white
                    : color ?? (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Colors.white
                    : isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
