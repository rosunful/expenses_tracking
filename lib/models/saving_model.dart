/// Unlike TransactionModel or BudgetModel, a goal's savedAmount IS
/// stored directly — there's no "category" to compute it from live.
/// It only changes when the user explicitly contributes money on the
/// Add Contribution screen, so storing it is the correct source of
/// truth here (not a workaround, unlike budgets' currentAmount would
/// have been).
class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;

  /// Same soft-delete pattern as BudgetModel — hiding a goal doesn't
  /// erase it. Only History screen's "Delete Permanently" does that.
  final bool isHidden;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    this.isHidden = false,
  });

  double get progress =>
      targetAmount == 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  int get progressPercent => (progress * 100).round();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'isHidden': isHidden,
    };
  }

  factory SavingsGoalModel.fromMap(String id, Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: id,
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      savedAmount: (map['savedAmount'] ?? 0).toDouble(),
      isHidden: map['isHidden'] ?? false,
    );
  }
}