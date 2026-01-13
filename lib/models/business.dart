import 'package:uuid/uuid.dart';

enum BusinessType { ecom, salary }

enum OrderStatus { pending, completed, cancelled }

enum ExpenseType { fixed, perOrder }

class Business {
  final String id;
  String name;
  BusinessType type;
  List<Order> orders;
  List<Expense> expenses;
  List<Income> incomes; // For salary/freelance type

  Business({
    String? id,
    required this.name,
    required this.type,
    List<Order>? orders,
    List<Expense>? expenses,
    List<Income>? incomes,
  })  : id = id ?? const Uuid().v4(),
        orders = orders ?? [],
        expenses = expenses ?? [],
        incomes = incomes ?? [];

  Business copyWith({
    String? name,
    BusinessType? type,
    List<Order>? orders,
    List<Expense>? expenses,
    List<Income>? incomes,
  }) {
    return Business(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      orders: orders ?? this.orders,
      expenses: expenses ?? this.expenses,
      incomes: incomes ?? this.incomes,
    );
  }

  // Calculations for ecom
  double get totalRevenue => orders
      .where((o) => o.status == OrderStatus.completed)
      .fold(0, (sum, o) => sum + o.netPrice);

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);

  double get totalDeliveryCommissions => orders
      .where((o) => o.status == OrderStatus.completed)
      .fold(0, (sum, o) => sum + o.deliveryCommission);

  // Calculations for salary
  double get totalIncome => incomes.fold(0, (sum, i) => sum + i.amount);

  // Profit calculation
  double get profit => type == BusinessType.ecom
      ? totalRevenue - totalExpenses
      : totalIncome - totalExpenses;

  bool get isWinning => profit >= 0;

  double get profitPercentage {
    final total = type == BusinessType.ecom ? totalRevenue : totalIncome;
    if (total <= 0) return 0;
    return (profit / total) * 100;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'orders': orders.map((o) => o.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'incomes': incomes.map((i) => i.toJson()).toList(),
      };

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json['id'],
        name: json['name'],
        type: BusinessType.values[json['type']],
        orders: (json['orders'] as List?)
                ?.map((o) => Order.fromJson(o))
                .toList() ??
            [],
        expenses: (json['expenses'] as List?)
                ?.map((e) => Expense.fromJson(e))
                .toList() ??
            [],
        incomes: (json['incomes'] as List?)
                ?.map((i) => Income.fromJson(i))
                .toList() ??
            [],
      );
}

class Order {
  final String id;
  String customerName;
  String description;
  double price;
  double deliveryCommission;
  DateTime date;
  OrderStatus status;

  Order({
    String? id,
    required this.customerName,
    required this.description,
    required this.price,
    this.deliveryCommission = 0,
    required this.date,
    this.status = OrderStatus.pending,
  }) : id = id ?? const Uuid().v4();

  // Net price after deducting delivery commission
  double get netPrice => price - deliveryCommission;

  Order copyWith({
    String? customerName,
    String? description,
    double? price,
    double? deliveryCommission,
    DateTime? date,
    OrderStatus? status,
  }) {
    return Order(
      id: id,
      customerName: customerName ?? this.customerName,
      description: description ?? this.description,
      price: price ?? this.price,
      deliveryCommission: deliveryCommission ?? this.deliveryCommission,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'description': description,
        'price': price,
        'deliveryCommission': deliveryCommission,
        'date': date.toIso8601String(),
        'status': status.index,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        customerName: json['customerName'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        deliveryCommission: (json['deliveryCommission'] as num?)?.toDouble() ?? 0,
        date: DateTime.parse(json['date']),
        status: OrderStatus.values[json['status']],
      );
}

class Expense {
  final String id;
  String title;
  double amount;
  DateTime date;
  ExpenseType type;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  }) : id = id ?? const Uuid().v4();

  Expense copyWith({
    String? title,
    double? amount,
    DateTime? date,
    ExpenseType? type,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'type': type.index,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        title: json['title'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        type: ExpenseType.values[json['type']],
      );
}

class Income {
  final String id;
  String title;
  String? description;
  double amount;
  DateTime date;

  Income({
    String? id,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
  }) : id = id ?? const Uuid().v4();

  Income copyWith({
    String? title,
    String? description,
    double? amount,
    DateTime? date,
  }) {
    return Income(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory Income.fromJson(Map<String, dynamic> json) => Income(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
      );
}
