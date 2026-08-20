import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/models/budgets_model.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/screens/budgets_palnner_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/controllers/budget_period_controller.dart';
import 'package:expense_tracking/widgets/home_widgets/currency_foramatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetProgressbarSection extends StatelessWidget {
  const BudgetProgressbarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>().budgets;
    final expenses = context.watch<ExpensesController>();
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const BudgetPlannerScreen())),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.appColors.cardsBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: budgets.isEmpty
                ? _EmptyState(colorScheme: colorScheme)
                : _MostUrgentBudget(
                    budgets: budgets,
                    expenses: expenses,
                    colorScheme: colorScheme,
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  const _EmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.pie_chart_outline, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "No budgets set yet — tap to create one",
            style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

class _MostUrgentBudget extends StatelessWidget {
  final List<BudgetModel> budgets;
  final ExpensesController expenses;
  final ColorScheme colorScheme;

  const _MostUrgentBudget({
    required this.budgets,
    required this.expenses,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total spent across ALL budgets.
    double totalSpent = 0;
    double totalTarget = 0;

    for (final budget in budgets) {
      final spentForCategory = expenses.spentForCategorySince(
        budget.category,
        periodStartFor(budget.period),
      );

      totalSpent += spentForCategory;
      totalTarget += budget.targetAmount;
    }

    // Overall progress.
    final progress = totalTarget == 0
        ? 0.0
        : (totalSpent / totalTarget).clamp(0.0, 1.0);

    final isOverBudget = totalSpent > totalTarget;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Total Budget",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '\$${totalSpent.toStringAsFixed(0)} / \$${totalTarget.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: isOverBudget
                ? colorScheme.error
                : colorScheme.primary,
          ),
        ),
      ],
    );
  }
}


// class _MostUrgentBudget extends StatelessWidget {
//   final List<BudgetModel> budgets;
//   final ExpensesController expenses;
//   final ColorScheme colorScheme;

//   const _MostUrgentBudget({
//     required this.budgets,
//     required this.expenses,
//     required this.colorScheme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // The home screen only has room for one budget, so we surface
//     // whichever one is closest to (or over) its limit — that's the
//     // one most worth the user's attention right now.

//     // Single pass over the transaction list: remember each budget's
//     // period reset date, then sum every expense into its category in one
//     // loop. Calling spentForCategorySince() per budget used to re-scan
//     // the whole list for every budget on every rebuild (O(budgets × txs)).
//     final startByCategory = <String, DateTime>{
//       for (final b in budgets) b.category: periodStartFor(b.period),
//     };
//     final spent = <String, double>{};
//     for (final e in expenses.transactions) {
//       if (e.type != TransactionType.expense) continue;
//       final start = startByCategory[e.category];
//       if (start == null || e.date.isBefore(start)) continue;
//       spent[e.category] = (spent[e.category] ?? 0) + e.amount;
//     }

//     BudgetModel? topBudget;
//     double topRatio = -1;
//     double topSpent = 0;

//     for (final budget in budgets) {
//       final spentForCategory = spent[budget.category] ?? 0;
//       final ratio = budget.targetAmount == 0
//           ? 0
//           : spentForCategory / budget.targetAmount;
//       if (ratio > topRatio) {
//         topRatio = ratio.toDouble();
//         topBudget = budget;
//         topSpent = spentForCategory;
//       }
//     }

//     if (topBudget == null) return const SizedBox.shrink();

//     final isOverBudget = topSpent > topBudget.targetAmount;
//     final progress = topBudget.targetAmount == 0
//         ? 0.0
//         : (topSpent / topBudget.targetAmount).clamp(0.0, 1.0);

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Text(
//                 "Budget · ${topBudget.category}",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style:  TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Theme.of(context).colorScheme.onSurface,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               '${formatCurrency(topSpent)} / ${formatCurrency(topBudget.targetAmount)}',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10),
//           child: LinearProgressIndicator(
//             minHeight: 6,
//             value: progress,
//             backgroundColor: colorScheme.surfaceContainerHighest,
//             color: isOverBudget ? colorScheme.error : colorScheme.primary,
//           ),
//         ),
//       ],
//     );
//   }
// }

