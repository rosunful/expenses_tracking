import 'package:expense_tracking/controllers/budget_period_controller.dart';

class BudgetModel {
  final String id;
  final String category;
  final double targetAmount;
  final BudgetPeriod period;
  final bool isHidden;

  BudgetModel({
    required this.id,
    required this.category,
    required this.targetAmount,
    required this.period,
    this.isHidden = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'targetAmount': targetAmount,
      'period': period.name,
      'isHidden': isHidden,
    };
  }

  factory BudgetModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetModel(
      id: id,
      category: map['category'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      isHidden: map['isHidden'] ?? false,
    );
  }

  /// Returns a copy with isHidden flipped, without touching anything
  /// else — used by hide/unhide so the category, amount, and period
  /// are preserved exactly.
  BudgetModel copyWith({bool? isHidden}) {
    return BudgetModel(
      id: id,
      category: category,
      targetAmount: targetAmount,
      period: period,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}








