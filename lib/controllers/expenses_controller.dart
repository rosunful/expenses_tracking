import 'dart:async';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

class ExpensesController extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();


  List<TransactionModel> _allExpenses = [];
  StreamSubscription<List<TransactionModel>>? _subscription;

  /// What every screen should actually display and calculate against —
  /// hidden transactions excluded. This is the same visible/hidden split
  /// already used for budgets, goals, and reminders.
  List<TransactionModel> get expensesNoPrivate =>
      _allExpenses.where((e) => !e.isHidden).toList();

  /// Alias — some part of the app calls .transactions instead of
  /// .expensesNoPrivate. Kept as a thin wrapper rather than renaming
  /// expensesNoPrivate everywhere else that already depends on it.
  List<TransactionModel> get transactions => expensesNoPrivate;

  /// For the future History screen — soft-deleted transactions waiting
  /// for Undo or Permanent Delete.
  List<TransactionModel> get hiddenExpenses =>
      _allExpenses.where((e) => e.isHidden).toList();

  ExpensesController() {
    _listenToTransactions();
  }

  void _listenToTransactions() {
    _subscription = _repository.streamTransactions().listen((transactions) {
      _allExpenses = transactions;
      notifyListeners();
    });
  }

  Future<void> addExpenses(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
  }

  /// Hard delete — kept as-is, for whenever the future History screen's
  /// "Delete Permanently" needs it. Activity's Delete button uses
  /// hideExpense() below instead.
  Future<void> deleteExpenses(TransactionModel transaction) async {
    await _repository.deleteTransaction(transaction.id);
  }

  /// The soft delete — what Activity's Delete button actually calls.
  /// Moves the transaction out of expensesNoPrivate (and therefore out
  /// of every total/chart/streak calculation below) without erasing it.
  Future<void> hideExpense(TransactionModel transaction) async {
    await _repository.hideTransaction(transaction.id);
  }

  /// For the future History screen's Undo action.
  Future<void> unhideExpense(String transactionId) async {
    await _repository.unhideTransaction(transactionId);
  }

  /// Only sums transactions where type == expense, so income entries
  /// don't inflate this number. Now reads expensesNoPrivate, so a
  /// hidden transaction stops counting immediately.
  double get totalExpenses {
    double total = 0;
    for (final e in expensesNoPrivate) {
      if (e.type == TransactionType.expense) total += e.amount;
    }
    return total;
  }

  double get totalIncome {
    double total = 0;
    for (final e in expensesNoPrivate) {
      if (e.type == TransactionType.income) total += e.amount;
    }
    return total;
  }

  List<TransactionModel> filterCategory(String targetCategory) {
    return expensesNoPrivate
        .where((e) => e.category.toLowerCase() == targetCategory.toLowerCase())
        .toList();
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final e in expensesNoPrivate) {
      if (e.type != TransactionType.expense) continue;
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  double spentForCategorySince(String category, DateTime since) {
    double total = 0;
    for (final e in expensesNoPrivate) {
      if (e.type != TransactionType.expense) continue;
      if (e.category != category) continue;
      if (e.date.isBefore(since)) continue;
      total += e.amount;
    }
    return total;
  }

  int get currentStreak {
    final activeDays = expensesNoPrivate
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!activeDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (activeDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}




