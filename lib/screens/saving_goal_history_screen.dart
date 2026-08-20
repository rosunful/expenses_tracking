import 'package:expense_tracking/models/saving_model.dart';
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingsGoalHistoryScreen extends StatelessWidget {
  const SavingsGoalHistoryScreen({super.key});

  Future<void> _confirmPermanentDelete(BuildContext context, SavingsGoalModel goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: Text(
          'The "${goal.title}" goal and its \$${goal.savedAmount.toStringAsFixed(0)} saved '
          'progress will be permanently removed and cannot be recovered.',
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
      await context.read<SavingsGoalProvider>().permanentlyDeleteGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiddenGoals = context.watch<SavingsGoalProvider>().hiddenGoals;

    return Scaffold(
      appBar: AppBar(title: const Text('Goal History')),
      body: SafeArea(
        child: hiddenGoals.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "No hidden goals.\nDeleted goals show up here first, "
                    "so nothing is lost by accident.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: hiddenGoals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final goal = hiddenGoals[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.appColors.cardsBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal.title, style:  TextStyle(fontWeight: FontWeight.bold ,  color: Theme.of(context).colorScheme.onSurface)),
                              Text(
                                '\$${goal.savedAmount.toStringAsFixed(0)} of \$${goal.targetAmount.toStringAsFixed(0)} saved',
                                style:  TextStyle(fontSize: 12, color: context.appColors.paragraphColor),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.read<SavingsGoalProvider>().unhideGoal(goal.id),
                          child: const Icon(Icons.history),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                          onPressed: () => _confirmPermanentDelete(context, goal),
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