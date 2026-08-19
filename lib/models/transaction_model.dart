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

  /// The currency CODE ("USD", "NPR") that was selected at the moment
  /// this transaction was saved — captured once, then permanent. This
  /// is what makes each transaction stay locked to its own currency:
  /// changing the app's currency setting later only affects NEW
  /// transactions going forward, never rewrites old ones. Defaults to
  /// "USD" for any transaction saved before this field existed, since
  /// there's no way to know what was actually selected back then.
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
















// import 'package:cloud_firestore/cloud_firestore.dart';

// enum TransactionType { expense, income }
// enum AccountType { cash, bank, card }

// class TransactionModel {
//   final String id;
//   final String title;
//   final double amount;
//   final TransactionType type;
//   final String category;
//   final AccountType account;
//   final String note;
//   final DateTime date;
//   final DateTime createdAt;

//   /// Same soft-delete pattern already used for budgets/goals/reminders.
//   /// Tapping Delete in Activity sets this true rather than removing the
//   /// document — the eventual History screen will offer Undo (unhide)
//   /// or Permanent Delete from here. isHidden defaults to false so every
//   /// existing transaction you already saved is treated as visible.
//   final bool isHidden;

//   TransactionModel({
//     required this.id,
//     required this.title,
//     required this.amount,
//     required this.type,
//     required this.category,
//     required this.account,
//     this.note = '',
//     required this.date,
//     required this.createdAt,
//     this.isHidden = false,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'amount': amount,
//       'type': type.name,
//       'category': category,
//       'account': account.name,
//       'note': note,
//       'date': Timestamp.fromDate(date),
//       'createdAt': Timestamp.fromDate(createdAt),
//       'isHidden': isHidden,
//     };
//   }

//   factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
//     return TransactionModel(
//       id: id,
//       title: map['title'] ?? '',
//       amount: (map['amount'] ?? 0).toDouble(),
//       type: TransactionType.values.firstWhere(
//         (e) => e.name == map['type'],
//         orElse: () => TransactionType.expense,
//       ),
//       category: map['category'] ?? 'Other',
//       account: AccountType.values.firstWhere(
//         (e) => e.name == map['account'],
//         orElse: () => AccountType.cash,
//       ),
//       note: map['note'] ?? '',
//       date: (map['date'] as Timestamp).toDate(),
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//       isHidden: map['isHidden'] ?? false,
//     );
//   }
// }




