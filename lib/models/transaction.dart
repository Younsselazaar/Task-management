import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  salary,
  freelance,
  investment,
  gift,
  food,
  transport,
  shopping,
  bills,
  entertainment,
  health,
  other,
}

class Transaction {
  final String id;
  String title;
  String? description;
  double amount;
  DateTime date;
  TransactionType type;
  TransactionCategory category;
  String? customCategory;

  Transaction({
    String? id,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    required this.type,
    this.category = TransactionCategory.other,
    this.customCategory,
  }) : id = id ?? const Uuid().v4();

  Transaction copyWith({
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
    String? customCategory,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'date': date.toIso8601String(),
    'type': type.index,
    'category': category.index,
    'customCategory': customCategory,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    amount: json['amount'],
    date: DateTime.parse(json['date']),
    type: TransactionType.values[json['type']],
    category: TransactionCategory.values[json['category']],
    customCategory: json['customCategory'],
  );
}
