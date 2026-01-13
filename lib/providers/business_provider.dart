import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business.dart';

class BusinessProvider extends ChangeNotifier {
  List<Business> _businesses = [];
  String? _selectedBusinessId;

  static const String _businessesKey = 'businesses_data';

  List<Business> get businesses => _businesses;
  String? get selectedBusinessId => _selectedBusinessId;

  Business? get selectedBusiness => _selectedBusinessId != null
      ? _businesses.firstWhere(
          (b) => b.id == _selectedBusinessId,
          orElse: () => _businesses.first,
        )
      : null;

  BusinessProvider() {
    _loadData();
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final businessesJson = prefs.getString(_businessesKey);
    if (businessesJson != null) {
      final List<dynamic> decoded = jsonDecode(businessesJson);
      _businesses = decoded.map((json) => Business.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveBusinesses() async {
    final prefs = await SharedPreferences.getInstance();
    final businessesJson = jsonEncode(_businesses.map((b) => b.toJson()).toList());
    await prefs.setString(_businessesKey, businessesJson);
  }

  // Overall statistics across all businesses
  double get totalProfit => _businesses.fold(0, (sum, b) => sum + b.profit);

  int get ecomBusinessCount => _businesses.where((b) => b.type == BusinessType.ecom).length;
  int get salaryBusinessCount => _businesses.where((b) => b.type == BusinessType.salary).length;

  // Business CRUD
  void addBusiness(Business business) {
    _businesses.add(business);
    _saveBusinesses();
    notifyListeners();
  }

  void updateBusiness(String id, Business updated) {
    final index = _businesses.indexWhere((b) => b.id == id);
    if (index != -1) {
      _businesses[index] = updated;
      _saveBusinesses();
      notifyListeners();
    }
  }

  void deleteBusiness(String id) {
    _businesses.removeWhere((b) => b.id == id);
    if (_selectedBusinessId == id) {
      _selectedBusinessId = null;
    }
    _saveBusinesses();
    notifyListeners();
  }

  void selectBusiness(String? id) {
    _selectedBusinessId = id;
    notifyListeners();
  }

  // Order operations for selected business
  void addOrder(Order order) {
    if (_selectedBusinessId == null) return;
    final index = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (index != -1) {
      _businesses[index].orders.add(order);
      _saveBusinesses();
      notifyListeners();
    }
  }

  void updateOrder(String orderId, Order updated) {
    if (_selectedBusinessId == null) return;
    final businessIndex = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (businessIndex != -1) {
      final orderIndex = _businesses[businessIndex].orders.indexWhere((o) => o.id == orderId);
      if (orderIndex != -1) {
        _businesses[businessIndex].orders[orderIndex] = updated;
        _saveBusinesses();
        notifyListeners();
      }
    }
  }

  void deleteOrder(String orderId) {
    if (_selectedBusinessId == null) return;
    final index = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (index != -1) {
      _businesses[index].orders.removeWhere((o) => o.id == orderId);
      _saveBusinesses();
      notifyListeners();
    }
  }

  // Expense operations for selected business
  void addExpense(Expense expense) {
    if (_selectedBusinessId == null) return;
    final index = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (index != -1) {
      _businesses[index].expenses.add(expense);
      _saveBusinesses();
      notifyListeners();
    }
  }

  void updateExpense(String expenseId, Expense updated) {
    if (_selectedBusinessId == null) return;
    final businessIndex = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (businessIndex != -1) {
      final expenseIndex = _businesses[businessIndex].expenses.indexWhere((e) => e.id == expenseId);
      if (expenseIndex != -1) {
        _businesses[businessIndex].expenses[expenseIndex] = updated;
        _saveBusinesses();
        notifyListeners();
      }
    }
  }

  void deleteExpense(String expenseId) {
    if (_selectedBusinessId == null) return;
    final index = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (index != -1) {
      _businesses[index].expenses.removeWhere((e) => e.id == expenseId);
      _saveBusinesses();
      notifyListeners();
    }
  }

  // Income operations for selected business (salary/freelance type)
  void addIncome(Income income) {
    if (_selectedBusinessId == null) return;
    final index = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (index != -1) {
      _businesses[index].incomes.add(income);
      _saveBusinesses();
      notifyListeners();
    }
  }

  void updateIncome(String incomeId, Income updated) {
    if (_selectedBusinessId == null) return;
    final businessIndex = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (businessIndex != -1) {
      final incomeIndex = _businesses[businessIndex].incomes.indexWhere((i) => i.id == incomeId);
      if (incomeIndex != -1) {
        _businesses[businessIndex].incomes[incomeIndex] = updated;
        _saveBusinesses();
        notifyListeners();
      }
    }
  }

  void deleteIncome(String incomeId) {
    if (_selectedBusinessId == null) return;
    final index = _businesses.indexWhere((b) => b.id == _selectedBusinessId);
    if (index != -1) {
      _businesses[index].incomes.removeWhere((i) => i.id == incomeId);
      _saveBusinesses();
      notifyListeners();
    }
  }

  // For backup/restore
  void setBusinesses(List<Business> businesses) {
    _businesses = businesses;
    _saveBusinesses();
    notifyListeners();
  }
}
