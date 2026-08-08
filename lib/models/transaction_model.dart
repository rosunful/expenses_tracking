import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of a transaction — matches the Expense / Income toggle in your
/// "Add Transaction" screen.
enum TransactionType { expense, income }

/// Which account the money moved through — matches the Cash / Bank / Card
/// chips in your "Add Transaction" screen.
enum AccountType { cash, bank, card }

class TransactionModel {
  final String id;
  final String title; // e.g. "Whole Foods Market"
  final double amount;
  final TransactionType type;
  final String category; // e.g. "Food", "Transport", "Shopping"
  final AccountType account;
  final String note;
  final DateTime date;
  final DateTime createdAt;

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
  });

  /// Converts this object into a Map so it can be saved to Firestore.
  /// Firestore stores documents as key-value maps, similar to JSON.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name, // enums are stored as their string name
      'category': category,
      'account': account.name,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Builds a TransactionModel back from Firestore data.
  /// [id] comes from the document ID, not from inside the map.
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
    );
  }
}