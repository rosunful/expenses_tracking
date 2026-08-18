import 'dart:async';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

class ExpensesController extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  // Raw data straight from Firestore — includes hidden (soft-deleted)
  // transactions too. Everything else derives a filtered view from this.
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














// import 'dart:async';
// import 'package:expense_tracking/models/transaction_model.dart';
// import 'package:expense_tracking/repositories/transaction_repository.dart';
// import 'package:flutter/material.dart';

// class ExpensesController extends ChangeNotifier {
//   final TransactionRepository _repository = TransactionRepository();

//   // Now holds live data from Firestore instead of a manually-managed list.
//   List<TransactionModel> _expenses = [];
//   StreamSubscription<List<TransactionModel>>? _subscription;

//   // Cached aggregates — recomputed ONCE per Firestore snapshot instead of
//   // being re-scanned by every widget that reads them each frame.
//   double _totalExpenses = 0;
//   double _totalIncome = 0;
//   Map<String, double> _categoryTotals = const {};

//   List<TransactionModel> get expensesNoPrivate => _expenses;

//   /// The complete, live transaction list.
//   ///
//   /// Keep this name as an alias for screens/widgets that refer to the data as
//   /// "transactions". `expensesNoPrivate` is retained so existing callers
//   /// continue to work while the app is migrated to the clearer name.
//   List<TransactionModel> get transactions => _expenses;

//   ExpensesController() {
//     _listenToTransactions();
//   }

//   /// Subscribes once, when the controller is created (which happens once,
//   /// at app startup, since it's a ChangeNotifierProvider). Every time
//   /// Firestore's data changes — from this device or any other — this
//   /// fires again and notifyListeners() rebuilds your UI automatically.
//   void _listenToTransactions() {
//     _subscription = _repository.streamTransactions().listen((transactions) {
//       _expenses = transactions;
//       _recomputeCaches();
//       notifyListeners();
//     });
//   }

//   /// One pass over the list a single time per snapshot, so getters like
//   /// [totalExpenses] cost O(1) per read instead of re-scanning everything
//   /// on every widget rebuild.
//   void _recomputeCaches() {
//     double totalExpense = 0;
//     double totalIncome = 0;
//     final Map<String, double> totals = {};
//     for (final e in _expenses) {
//       if (e.type == TransactionType.expense) {
//         totalExpense += e.amount;
//         totals[e.category] = (totals[e.category] ?? 0) + e.amount;
//       } else {
//         totalIncome += e.amount;
//       }
//     }
//     _totalExpenses = totalExpense;
//     _totalIncome = totalIncome;
//     _categoryTotals = totals;
//   }

//   /// Was synchronous before (just added to a local list). Now it's async
//   /// because it's a real network write. Note we do NOT manually add to
//   /// _expenses here — the stream above will push the update back to us
//   /// once Firestore confirms it, which keeps _expenses always matching
//   /// what's actually saved.
//   Future<void> addExpenses(TransactionModel transaction) async {
//     await _repository.addTransaction(transaction);
//   }

//   Future<void> deleteExpenses(TransactionModel transaction) async {
//     await _repository.deleteTransaction(transaction.id);
//   }

//   /// Only sums transactions where type == expense, so income entries
//   /// (like "Freelance payment" or "Salary" from your screenshots)
//   /// don't inflate this number.
//   double get totalExpenses => _totalExpenses;

//   /// Mirrors totalExpenses, but for income entries — needed for the
//   /// "Income vs Expense" bar chart on your Analytics screen.
//   double get totalIncome => _totalIncome;

//   List<TransactionModel> filterCategory(String targetCategory) {
//     return _expenses
//         .where((e) => e.category.toLowerCase() == targetCategory.toLowerCase())
//         .toList();
//   }

//   /// Same expense-only filtering here, for your "Spending by category"
//   /// analytics screen.
//   Map<String, double> get categoryTotals => _categoryTotals;

//   /// Sums expense transactions for one category, counting only those
//   /// on or after [since]. This is what powers each budget's progress bar:
//   /// Budget Planner passes in the category's own reset date (this week /
//   /// month / year), and this returns exactly what's been spent within
//   /// that window. Since this reads straight from the live _expenses list,
//   /// adding a new expense — or deleting one — updates the result on the
//   /// very next rebuild, with no extra wiring needed.
//   double spentForCategorySince(String category, DateTime since) {
//     double total = 0;
//     for (final e in _expenses) {
//       if (e.type != TransactionType.expense) continue;
//       if (e.category != category) continue;
//       if (e.date.isBefore(since)) continue;
//       total += e.amount;
//     }
//     return total;
//   }

//   /// Stops listening when this controller is destroyed, so the app
//   /// doesn't keep an open connection to Firestore after it's gone.
//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }
