
enum ReminderType { bill, emi, task }

class ReminderModel {
  final String id;
  final String title;
  final ReminderType type;
  final double? amount;
  final String category;
  final bool isRecurringMonthly;
  final int? dueDayOfMonth; 
  final DateTime? dueDate; 
  final String? lastPaidPeriod;
  final bool isDone;
  final bool isHidden;

  ReminderModel({
    required this.id,
    required this.title,
    required this.type,
    this.amount,
    this.category = 'Other',
    this.isRecurringMonthly = false,
    this.dueDayOfMonth,
    this.dueDate,
    this.lastPaidPeriod,
    this.isDone = false,
    this.isHidden = false,
  });


  static String periodKeyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static String get currentPeriodKey => periodKeyFor(DateTime.now());


  static int _clampDay(int day, int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return day > daysInMonth ? daysInMonth : day;
  }


  DateTime get nextDueDate {
    if (isRecurringMonthly && dueDayOfMonth != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisMonthDay = _clampDay(dueDayOfMonth!, now.year, now.month);
      final thisMonthOccurrence = DateTime(now.year, now.month, thisMonthDay);

      if (!thisMonthOccurrence.isBefore(today)) {
        return thisMonthOccurrence;
      }

      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      final nextMonthDay = _clampDay(dueDayOfMonth!, nextYear, nextMonth);
      return DateTime(nextYear, nextMonth, nextMonthDay);
    }
    return dueDate ?? DateTime.now();
  }

  /// True if this reminder is "handled" for right now — paid this month
  /// (recurring) or marked done (one-off).
  bool get isCompletedForCurrentPeriod =>
      isRecurringMonthly ? lastPaidPeriod == currentPeriodKey : isDone;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type.name,
      'amount': amount,
      'category': category,
      'isRecurringMonthly': isRecurringMonthly,
      'dueDayOfMonth': dueDayOfMonth,
      'dueDate': dueDate?.toIso8601String(),
      'lastPaidPeriod': lastPaidPeriod,
      'isDone': isDone,
      'isHidden': isHidden,
    };
  }

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    return ReminderModel(
      id: id,
      title: map['title'] ?? '',
      type: ReminderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ReminderType.task,
      ),
      amount: (map['amount'] as num?)?.toDouble(),
      category: map['category'] ?? 'Other',
      isRecurringMonthly: map['isRecurringMonthly'] ?? false,
      dueDayOfMonth: map['dueDayOfMonth'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      lastPaidPeriod: map['lastPaidPeriod'],
      isDone: map['isDone'] ?? false,
      isHidden: map['isHidden'] ?? false,
    );
  }
}