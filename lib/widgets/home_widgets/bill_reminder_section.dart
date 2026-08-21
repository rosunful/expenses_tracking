// NOTE: assumed path — adjust if ReminderProvider lives elsewhere.
import 'package:expense_tracking/providers/reminder_provider.dart';
import 'package:expense_tracking/models/reminder_model.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/home_widgets/currency_foramatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// "Due today" / "Due tomorrow" / "Due in 3d" / "Overdue by 2d" — short
/// enough to sit on one line next to the amount.
String _dueLabel(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  final diff = dueDay.difference(today).inDays;

  if (diff < 0) return 'Overdue by ${-diff}d';
  if (diff == 0) return 'Due today';
  if (diff == 1) return 'Due tomorrow';
  if (diff <= 7) return 'Due in ${diff}d';
  return 'Due ${due.month}/${due.day}';
}

IconData _iconForType(ReminderType type) {
  switch (type) {
    case ReminderType.bill:
      return Icons.receipt_long;
    case ReminderType.emi:
      return Icons.account_balance;
    case ReminderType.task:
      return Icons.task_alt;
  }
}

class BillsReminderSection extends StatelessWidget {
  final int maxItems;
  final VoidCallback? onSeeAll;

  const BillsReminderSection({super.key, this.maxItems = 3, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    // ReminderProvider.reminders is already visible-only and sorted
    // soonest-due-first, so we just need to drop anything already
    // handled for this period.
    final upcoming = context
        .watch<ReminderProvider>()
        .reminders
        .where((r) => !r.isCompletedForCurrentPeriod)
        .toList();

    final shown = upcoming.take(maxItems).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming bills',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.blueColor,
                  // 1. Removes the default 48x48 minimum touch constraint
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // 2. Resets the minimum size to zero
                  minimumSize: Size.zero,
                  // 3. Reduces or eliminates inner padding (optional)
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 1,
                  ),
                ),
                child: const Text('See all'),
              ),
          ],
        ),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.appColors.cardsBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: shown.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "Nothing due — you're all caught up",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < shown.length; i++) ...[
                        _ReminderRow(
                          reminder: shown[i],
                          colorScheme: colorScheme,
                        ),
                        if (i != shown.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final ReminderModel reminder;
  final ColorScheme colorScheme;

  const _ReminderRow({required this.reminder, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<CurrencyProvider>().selected.symbol;
    final due = reminder.nextDueDate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForType(reminder.type),
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _dueLabel(due),
                      style: TextStyle(
                        fontSize: 13,

                        //HERE WE NEEED TO CHANGE THE COLOR OF THE DUE INFO DISPALY
                        color: context.appColors.paragraphColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (reminder.amount != null)
          Text(
             formatCurrency(
      reminder.amount!,
      symbol: symbol,
    ),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}
