
/// Matches the two goal types shown on your Home screen:
/// "Budget · Food & Dining" and "Emergency Fund goal".
enum GoalType { budget, emergencyFund }

class GoalModel {
  final String id;
  final String title; // e.g. "Food & Dining" or "Emergency Fund"
  final GoalType type;
  final double targetAmount; // e.g. 500 for the $340/$500 budget bar
  final double currentAmount; // e.g. 340, or 3100 for the emergency fund
  final String? category; // only used when type == budget, e.g. "Food"

  GoalModel({
    required this.id,
    required this.title,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    this.category,
  });

  /// Handy getter — this is exactly what your progress bars need,
  /// e.g. 340 / 500 = 0.68, or the 42% shown for the emergency fund.
  double get progress =>
      targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'category': category,
    };
  }

  factory GoalModel.fromMap(String id, Map<String, dynamic> map) {
    return GoalModel(
      id: id,
      title: map['title'] ?? '',
      type: GoalType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => GoalType.budget,
      ),
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      category: map['category'],
    );
  }
}