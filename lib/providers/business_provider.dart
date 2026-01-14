import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business.dart';
import '../services/exchange_rate_service.dart';

enum Currency { mad, usd }

class BusinessProvider extends ChangeNotifier {
  List<Business> _businesses = [];
  String? _selectedBusinessId;
  Currency _currency = Currency.mad;
  double _madToUsdRate = 0.099; // Default rate, will be updated from API
  DateTime? _lastRateUpdate;
  bool _isLoadingRate = false;

  static const String _businessesKey = 'businesses_data';
  static const String _currencyKey = 'selected_currency';

  List<Business> get businesses => _businesses;
  String? get selectedBusinessId => _selectedBusinessId;
  Currency get currency => _currency;
  String get currencySymbol => _currency == Currency.mad ? 'DH' : '\$';
  bool get isUsd => _currency == Currency.usd;
  double get currentRate => _madToUsdRate;
  DateTime? get lastRateUpdate => _lastRateUpdate;
  bool get isLoadingRate => _isLoadingRate;

  Business? get selectedBusiness => _selectedBusinessId != null
      ? _businesses.firstWhere(
          (b) => b.id == _selectedBusinessId,
          orElse: () => _businesses.first,
        )
      : null;

  // Convert amount based on selected currency
  double convertAmount(double amountInMad) {
    return _currency == Currency.usd ? amountInMad * _madToUsdRate : amountInMad;
  }

  // Format amount with currency symbol
  String formatAmount(double amountInMad, {bool showSign = false}) {
    final converted = convertAmount(amountInMad);
    final sign = showSign && converted >= 0 ? '+' : '';
    if (_currency == Currency.usd) {
      return '$sign\$${converted.toStringAsFixed(2)}';
    }
    return '$sign${converted.toStringAsFixed(2)} DH';
  }

  // Toggle currency and fetch latest rate if switching to USD
  void toggleCurrency() {
    _currency = _currency == Currency.mad ? Currency.usd : Currency.mad;
    _saveCurrency();
    if (_currency == Currency.usd) {
      refreshExchangeRate(); // Refresh rate when switching to USD
    }
    notifyListeners();
  }

  // Fetch latest exchange rate from API
  Future<void> refreshExchangeRate() async {
    if (_isLoadingRate) return;

    _isLoadingRate = true;
    notifyListeners();

    try {
      _madToUsdRate = await ExchangeRateService.fetchMadToUsdRate();
      _lastRateUpdate = await ExchangeRateService.getLastUpdateTime();
    } catch (e) {
      // Keep existing rate on error
    }

    _isLoadingRate = false;
    notifyListeners();
  }

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
    }
    // Load currency preference
    final currencyStr = prefs.getString(_currencyKey);
    if (currencyStr == 'usd') {
      _currency = Currency.usd;
    }

    // Load cached exchange rate first for instant display
    _madToUsdRate = await ExchangeRateService.getCachedOrFallbackRate();
    _lastRateUpdate = await ExchangeRateService.getLastUpdateTime();

    notifyListeners();

    // Then fetch fresh rate in background
    refreshExchangeRate();
  }

  // Save data to SharedPreferences
  Future<void> _saveBusinesses() async {
    final prefs = await SharedPreferences.getInstance();
    final businessesJson = jsonEncode(_businesses.map((b) => b.toJson()).toList());
    await prefs.setString(_businessesKey, businessesJson);
  }

  // Save currency preference
  Future<void> _saveCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, _currency == Currency.usd ? 'usd' : 'mad');
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
