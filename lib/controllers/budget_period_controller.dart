/// How often a budget's "spent" amount resets to zero.
enum BudgetPeriod { weekly, monthly, yearly }

extension BudgetPeriodLabel on BudgetPeriod {
  String get label => switch (this) {
        BudgetPeriod.weekly => 'Resets weekly',
        BudgetPeriod.monthly => 'Resets monthly',
        BudgetPeriod.yearly => 'Resets yearly',
      };

  String get shortLabel => switch (this) {
        BudgetPeriod.weekly => 'Weekly',
        BudgetPeriod.monthly => 'Monthly',
        BudgetPeriod.yearly => 'Yearly',
      };
}

/// Returns the start of the CURRENT period for a given BudgetPeriod,
/// based on today's date. Spending is only counted from this date
/// forward — this is what makes a budget "reset": once today crosses
/// into a new period, this function returns a later date, and older
/// transactions naturally fall outside the sum.
DateTime periodStartFor(BudgetPeriod period) {
  final now = DateTime.now();

  switch (period) {
    case BudgetPeriod.weekly:
      // Calendar week starting Monday. DateTime.weekday is 1=Mon..7=Sun.
      final daysSinceMonday = now.weekday - 1;
      return DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: daysSinceMonday));
    case BudgetPeriod.monthly:
      return DateTime(now.year, now.month, 1);
    case BudgetPeriod.yearly:
      return DateTime(now.year, 1, 1);
  }
}