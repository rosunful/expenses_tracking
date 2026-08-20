// NOTE: assumed path — adjust if SavingsGoalProvider lives elsewhere.
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class FundingGoalSection extends StatelessWidget {
  const FundingGoalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<SavingsGoalProvider>().goals;

    final totalGoals = goals.length;

    final completedGoals = goals.where(
      (goal) => goal.savedAmount >= goal.targetAmount,
    ).length;

    final progress = totalGoals == 0
        ? 0.0
        : completedGoals / totalGoals;

    final progressPercent = (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.appColors.cardsBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: Colors.white,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    '$progressPercent%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Savings Goals',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    totalGoals == 0
                        ? 'No savings goals yet'
                        : '$completedGoals of $totalGoals goals completed',
                    style: TextStyle(
                      color: context.appColors.paragraphColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
