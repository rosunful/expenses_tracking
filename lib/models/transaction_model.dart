import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { expense, income }
enum AccountType { cash, bank, card }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final AccountType account;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final bool isHidden;
  final String currencyCode;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.account,
    this.note = '',
    required this.date,
    required this.createdAt,
    this.isHidden = false,
    this.currencyCode = 'USD',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'account': account.name,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'isHidden': isHidden,
      'currencyCode': currencyCode,
    };
  }

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: map['category'] ?? 'Other',
      account: AccountType.values.firstWhere(
        (e) => e.name == map['account'],
        orElse: () => AccountType.cash,
      ),
      note: map['note'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isHidden: map['isHidden'] ?? false,
      currencyCode: map['currencyCode'] ?? 'USD',
    );
  }
}





