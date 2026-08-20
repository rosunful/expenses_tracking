import 'package:expense_tracking/controllers/budget_period_controller.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/models/budgets_model.dart';

class BudgetHistoryScreen extends StatelessWidget {
  const BudgetHistoryScreen({super.key});

  Future<void> _confirmPermanentDelete(BuildContext context, BudgetModel budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: Text(
          'The "${budget.category}" budget will be permanently removed and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<BudgetProvider>().permanentlyDeleteBudget(budget.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiddenBudgets = context.watch<BudgetProvider>().hiddenBudgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget History')),
      body: SafeArea(
        child: hiddenBudgets.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "No hidden budgets.\nDeleted budgets show up here first, "
                    "so nothing is lost by accident.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: hiddenBudgets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final budget = hiddenBudgets[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:context.appColors.cardsBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                budget.category,
                                style:  TextStyle(fontWeight: FontWeight.bold , color: Theme.of(context).colorScheme.onSurface,)
                              ),
                              Text(
                                '\$${budget.targetAmount.toStringAsFixed(0)} · ${budget.period.shortLabel}',
                                style:  TextStyle(fontSize: 12, color: context.appColors.paragraphColor),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.read<BudgetProvider>().unhideBudget(budget.category),
                          child: const Icon(Icons.history),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                          onPressed: () => _confirmPermanentDelete(context, budget),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}