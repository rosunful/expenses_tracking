// NOTE: assumed path — adjust if SavingsGoalProvider lives elsewhere.
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/home_widgets/currency_foramatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FundingGoalSection extends StatelessWidget {
  const FundingGoalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<SavingsGoalProvider>().goals;
    

    // If you've got an actual goal titled "Emergency Fund" prefer that;
    // otherwise fall back to whichever goal comes first so the card
    // still shows something useful.
    final goal = goals.isEmpty
        ? null
        : goals.firstWhere(
            (g) => g.title.toLowerCase().contains('emergency'),
            orElse: () => goals.first,
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.appColors.cardsBackground,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: goal == null
            ? Row(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    color: context.appColors.blueColor,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "No savings goal yet — tap to create one",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: goal.progress,
                          strokeWidth: 4,
                          backgroundColor: Colors.white,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Text(
                          '${goal.progressPercent}%',
                          style:  TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                        ),
                        Text(
                          '${formatCurrency(goal.savedAmount)} of ${formatCurrency(goal.targetAmount)} saved',
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
