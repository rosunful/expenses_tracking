import 'package:expense_tracking/controllers/transaction_type.dart';
import 'package:flutter/material.dart';


class TransactionProvider extends ChangeNotifier {
  TransactionType _selected = TransactionType.expense;

  TransactionType get selected => _selected;

  bool get isExpense => _selected == TransactionType.expense;

  void selectExpense() {
    _selected = TransactionType.expense;
    notifyListeners();
  }

  void selectIncome() {
    _selected = TransactionType.income;
    notifyListeners();
  }
}