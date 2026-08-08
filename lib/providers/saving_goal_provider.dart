import 'dart:async';
import 'package:expense_tracking/models/saving_model.dart';
import 'package:expense_tracking/repositories/saving_goal_repository.dart';
import 'package:flutter/material.dart';

class SavingsGoalProvider extends ChangeNotifier {
  final SavingsGoalRepository _repository = SavingsGoalRepository();

  List<SavingsGoalModel> _allGoals = [];
  StreamSubscription<List<SavingsGoalModel>>? _subscription;

  List<SavingsGoalModel> get goals => _allGoals.where((g) => !g.isHidden).toList();
  List<SavingsGoalModel> get hiddenGoals => _allGoals.where((g) => g.isHidden).toList();

  SavingsGoalProvider() {
    _subscription = _repository.streamGoals().listen((goals) {
      _allGoals = goals;
      notifyListeners();
    });
  }

  Future<void> addGoal(String title, double targetAmount) async {
    await _repository.addGoal(title, targetAmount);
  }

  Future<void> updateGoal(String id, String title, double targetAmount) async {
    await _repository.updateGoal(id, title, targetAmount);
  }

  Future<void> contribute(String id, double amount) async {
    await _repository.contribute(id, amount);
  }

  Future<void> hideGoal(String id) async {
    await _repository.hideGoal(id);
  }

  Future<void> unhideGoal(String id) async {
    await _repository.unhideGoal(id);
  }

  Future<void> permanentlyDeleteGoal(String id) async {
    await _repository.permanentlyDeleteGoal(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}