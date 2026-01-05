import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class MoneyProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  TransactionType? _typeFilter;
  String? _selectedTransactionId;

  List<Transaction> get transactions => _transactions;
  TransactionType? get typeFilter => _typeFilter;
  String? get selectedTransactionId => _selectedTransactionId;

  Transaction? get selectedTransaction => _selectedTransactionId != null
      ? _transactions.firstWhere((t) => t.id == _selectedTransactionId,
          orElse: () => _transactions.first)
      : null;

  MoneyProvider() {
    // Start with empty data - user will add their own
  }

  // Filtered transactions
  List<Transaction> get filteredTransactions {
    if (_typeFilter == null) return _transactions;
    return _transactions.where((t) => t.type == _typeFilter).toList();
  }

  // Sort by date (newest first)
  List<Transaction> get sortedTransactions {
    final sorted = List<Transaction>.from(filteredTransactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  // Statistics
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  int get incomeCount =>
      _transactions.where((t) => t.type == TransactionType.income).length;

  int get expenseCount =>
      _transactions.where((t) => t.type == TransactionType.expense).length;

  // This month stats
  double get thisMonthIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Category breakdown for expenses
  Map<TransactionCategory, double> get expenseByCategory {
    final map = <TransactionCategory, double>{};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // Last month stats
  double get lastMonthIncome {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == lastMonth.month &&
            t.date.year == lastMonth.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get lastMonthExpense {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == lastMonth.month &&
            t.date.year == lastMonth.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get lastMonthBalance => lastMonthIncome - lastMonthExpense;
  double get thisMonthBalance => thisMonthIncome - thisMonthExpense;

  // Month comparison - returns difference (positive = better this month)
  double get monthComparisonDifference => thisMonthBalance - lastMonthBalance;
  bool get isBetterThanLastMonth => thisMonthBalance > lastMonthBalance;

  // Yearly stats - get income for each month of current year
  Map<int, double> get monthlyIncomeThisYear {
    final now = DateTime.now();
    final map = <int, double>{};
    for (int month = 1; month <= 12; month++) {
      map[month] = _transactions
          .where((t) =>
              t.type == TransactionType.income &&
              t.date.month == month &&
              t.date.year == now.year)
          .fold(0, (sum, t) => sum + t.amount);
    }
    return map;
  }

  // Yearly stats - get expense for each month of current year
  Map<int, double> get monthlyExpenseThisYear {
    final now = DateTime.now();
    final map = <int, double>{};
    for (int month = 1; month <= 12; month++) {
      map[month] = _transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.month == month &&
              t.date.year == now.year)
          .fold(0, (sum, t) => sum + t.amount);
    }
    return map;
  }

  // Yearly stats - get balance (income - expense) for each month of current year
  Map<int, double> get monthlyBalanceThisYear {
    final income = monthlyIncomeThisYear;
    final expense = monthlyExpenseThisYear;
    final map = <int, double>{};
    for (int month = 1; month <= 12; month++) {
      map[month] = (income[month] ?? 0) - (expense[month] ?? 0);
    }
    return map;
  }

  // Best month (highest balance) this year
  MapEntry<int, double>? get bestBalanceMonth {
    final monthlyBalance = monthlyBalanceThisYear;
    // Only consider months that have any transactions
    final now = DateTime.now();
    final monthsWithData = <MapEntry<int, double>>[];
    for (final entry in monthlyBalance.entries) {
      final hasTransactions = _transactions.any((t) =>
          t.date.month == entry.key && t.date.year == now.year);
      if (hasTransactions) {
        monthsWithData.add(entry);
      }
    }
    if (monthsWithData.isEmpty) return null;
    monthsWithData.sort((a, b) => b.value.compareTo(a.value));
    return monthsWithData.first;
  }

  // Worst month (lowest balance) this year
  MapEntry<int, double>? get worstBalanceMonth {
    final monthlyBalance = monthlyBalanceThisYear;
    // Only consider months that have any transactions
    final now = DateTime.now();
    final monthsWithData = <MapEntry<int, double>>[];
    for (final entry in monthlyBalance.entries) {
      final hasTransactions = _transactions.any((t) =>
          t.date.month == entry.key && t.date.year == now.year);
      if (hasTransactions) {
        monthsWithData.add(entry);
      }
    }
    if (monthsWithData.isEmpty) return null;
    monthsWithData.sort((a, b) => a.value.compareTo(b.value));
    return monthsWithData.first;
  }

  // Legacy getters for backward compatibility
  MapEntry<int, double>? get bestIncomeMonth => bestBalanceMonth;
  MapEntry<int, double>? get worstIncomeMonth => worstBalanceMonth;

  // Get month name
  static String getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  // Actions
  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void updateTransaction(String id, Transaction updated) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    if (_selectedTransactionId == id) {
      _selectedTransactionId = null;
    }
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void selectTransaction(String? id) {
    _selectedTransactionId = id;
    notifyListeners();
  }

  // Get transactions for a specific date range
  List<Transaction> getTransactionsInRange(DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }
}
