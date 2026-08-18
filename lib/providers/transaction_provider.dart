import 'package:expense_tracking/models/transaction_model.dart';
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