import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expense_tracking/models/budgets_model.dart';
import 'package:expense_tracking/repositories/budgets_repository.dart';
import 'package:expense_tracking/widgets/budget_period/budget_period.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository = BudgetRepository();

  // Every budget, hidden and visible together, as delivered by Firestore.
  List<BudgetModel> _allBudgets = [];
  StreamSubscription<List<BudgetModel>>? _subscription;

  /// What BudgetPlannerScreen's main list shows.
  List<BudgetModel> get budgets => _allBudgets.where((b) => !b.isHidden).toList();

  /// What the History screen shows — soft-deleted budgets waiting for
  /// either "Unhide" or "Delete Permanently".
  List<BudgetModel> get hiddenBudgets => _allBudgets.where((b) => b.isHidden).toList();

  BudgetProvider() {
    _subscription = _repository.streamBudgets().listen((budgets) {
      _allBudgets = budgets;
      notifyListeners();
    });
  }

  Future<void> setBudget(String category, double targetAmount, BudgetPeriod period) async {
    await _repository.setBudget(category, targetAmount, period);
  }

  Future<void> hideBudget(String category) async {
    await _repository.hideBudget(category);
  }

  Future<void> unhideBudget(String category) async {
    await _repository.unhideBudget(category);
  }

  Future<void> permanentlyDeleteBudget(String category) async {
    await _repository.permanentlyDeleteBudget(category);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}











// import 'dart:async';
// import 'package:expense_tracking/models/budgets_model.dart';
// import 'package:expense_tracking/repositories/budgets_repository.dart';
// import 'package:expense_tracking/widgets/budget_period/budget_period.dart';
// import 'package:flutter/material.dart';

// class BudgetProvider extends ChangeNotifier {
//   final BudgetRepository _repository = BudgetRepository();

//   List<BudgetModel> _budgets = [];
//   List<BudgetModel> get budgets => _budgets;
//   StreamSubscription<List<BudgetModel>>? _subscription;

//   BudgetProvider() {
//     _subscription = _repository.streamBudgets().listen((budgets) {
//       _budgets = budgets;
//       notifyListeners();
//     });
//   }

//   Future<void> setBudget(String category, double targetAmount, BudgetPeriod period) async {
//     await _repository.setBudget(category, targetAmount, period);
//   }

//   Future<void> deleteBudget(String category) async {
//     await _repository.deleteBudget(category);
//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }
// }