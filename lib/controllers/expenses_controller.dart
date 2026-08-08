import 'dart:async';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

class ExpensesController extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  // Now holds live data from Firestore instead of a manually-managed list.
  List<TransactionModel> _expenses = [];
  StreamSubscription<List<TransactionModel>>? _subscription;

  List<TransactionModel> get expensesNoPrivate => _expenses;

  /// The complete, live transaction list.
  ///
  /// Keep this name as an alias for screens/widgets that refer to the data as
  /// "transactions". `expensesNoPrivate` is retained so existing callers
  /// continue to work while the app is migrated to the clearer name.
  List<TransactionModel> get transactions => _expenses;

  ExpensesController() {
    _listenToTransactions();
  }

  /// Subscribes once, when the controller is created (which happens once,
  /// at app startup, since it's a ChangeNotifierProvider). Every time
  /// Firestore's data changes — from this device or any other — this
  /// fires again and notifyListeners() rebuilds your UI automatically.
  void _listenToTransactions() {
    _subscription = _repository.streamTransactions().listen((transactions) {
      _expenses = transactions;
      notifyListeners();
    });
  }

  /// Was synchronous before (just added to a local list). Now it's async
  /// because it's a real network write. Note we do NOT manually add to
  /// _expenses here — the stream above will push the update back to us
  /// once Firestore confirms it, which keeps _expenses always matching
  /// what's actually saved.
  Future<void> addExpenses(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
  }

  Future<void> deleteExpenses(TransactionModel transaction) async {
    await _repository.deleteTransaction(transaction.id);
  }

  /// Only sums transactions where type == expense, so income entries
  /// (like "Freelance payment" or "Salary" from your screenshots)
  /// don't inflate this number.
  double get totalExpenses {
    double total = 0;
    for (final e in _expenses) {
      if (e.type == TransactionType.expense) {
        total += e.amount;
      }
    }
    return total;
  }

  /// Mirrors totalExpenses, but for income entries — needed for the
  /// "Income vs Expense" bar chart on your Analytics screen.
  double get totalIncome {
    double total = 0;
    for (final e in _expenses) {
      if (e.type == TransactionType.income) {
        total += e.amount;
      }
    }
    return total;
  }

  List<TransactionModel> filterCategory(String targetCategory) {
    return _expenses
        .where((e) => e.category.toLowerCase() == targetCategory.toLowerCase())
        .toList();
  }

  /// Same expense-only filtering here, for your "Spending by category"
  /// analytics screen.
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final e in _expenses) {
      if (e.type != TransactionType.expense) continue;
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  /// Sums expense transactions for one category, counting only those
  /// on or after [since]. This is what powers each budget's progress bar:
  /// Budget Planner passes in the category's own reset date (this week /
  /// month / year), and this returns exactly what's been spent within
  /// that window. Since this reads straight from the live _expenses list,
  /// adding a new expense — or deleting one — updates the result on the
  /// very next rebuild, with no extra wiring needed.
  double spentForCategorySince(String category, DateTime since) {
    double total = 0;
    for (final e in _expenses) {
      if (e.type != TransactionType.expense) continue;
      if (e.category != category) continue;
      if (e.date.isBefore(since)) continue;
      total += e.amount;
    }
    return total;
  }

  /// Stops listening when this controller is destroyed, so the app
  /// doesn't keep an open connection to Firestore after it's gone.
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
