/// Bill/EMI use recurring monthly due dates most of the time; Task is
/// usually a one-off. All three share the same model — only the due
/// logic (recurring vs one-time) actually branches.
enum ReminderType { bill, emi, task }

class ReminderModel {
  final String id;
  final String title;
  final ReminderType type;
  final double? amount;

  /// What the bill/reminder is FOR — "Subscription", "Utility", "Rent",
  /// etc. Separate from [type] (Bill/EMI/Task), which is about the
  /// KIND of reminder, not what it's categorizing. Uses the same
  /// CategoryProvider/CategoryType system as expense and income
  /// categories — CategoryType.reminder.
  final String category;

  /// If true, this reminder repeats every month on [dueDayOfMonth] —
  /// e.g. "Rent, due on the 5th, every month". If false, it's a single
  /// one-off deadline stored in [dueDate].
  final bool isRecurringMonthly;
  final int? dueDayOfMonth; // 1–31, used only when isRecurringMonthly
  final DateTime? dueDate; // used only when NOT recurring

  /// For recurring reminders: which period ("2026-08") was last marked
  /// paid. Comparing this to the CURRENT period is what makes "Paid this
  /// month" automatically go back to unpaid once a new month starts —
  /// nothing needs to run on a timer, it's just a string comparison
  /// evaluated fresh every time the UI reads it.
  final String? lastPaidPeriod;

  /// For non-recurring reminders only: permanently done or not.
  final bool isDone;

  /// Swipe-to-delete now ARCHIVES rather than deletes — same soft-delete
  /// pattern as Budget Planner and Savings Goals. Swiping sets this true;
  /// only History screen's "Delete Permanently" actually removes data.
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

  /// "2026-08" for August 2026 — used as the key for "have we paid
  /// for THIS period yet".
  static String periodKeyFor(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  static String get currentPeriodKey => periodKeyFor(DateTime.now());

  /// Clamps a target day-of-month to however many days that month
  /// actually has — e.g. dueDayOfMonth 31 becomes the 28th/29th in
  /// February, instead of crashing or overflowing into March.
  static int _clampDay(int day, int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return day > daysInMonth ? daysInMonth : day;
  }

  /// The next actual due date. For recurring reminders, this is either
  /// this month's occurrence (if it hasn't passed yet) or next month's.
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