
enum GoalType { budget, emergencyFund }

class GoalModel {
  final String id;
  final String title;
  final GoalType type;
  final double targetAmount; 
  final double currentAmount; 
  final String? category; 

  GoalModel({
    required this.id,
    required this.title,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    this.category,
  });

  /// e.g. 340 / 500 = 0.68, or the 42% shown for the emergency fund. (progress bars)
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