import 'package:expense_tracking/models/saving_model.dart';
import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/amount_display.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/number_pad.dart';

class AddGoalContributionScreen extends StatefulWidget {
  final SavingsGoalModel goal;
  const AddGoalContributionScreen({super.key, required this.goal});

  @override
  State<AddGoalContributionScreen> createState() =>
      _AddGoalContributionScreenState();
}

class _AddGoalContributionScreenState extends State<AddGoalContributionScreen> {
  String amount = "0";
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void _handleKeyPress(String key) {
    setState(() {
      if (key == "⌫") {
        amount = amount.length > 1
            ? amount.substring(0, amount.length - 1)
            : "0";
      } else if (key == ".") {
        if (!amount.contains(".")) amount += ".";
      } else {
        amount = amount == "0" ? key : amount + key;
      }
    });
  }

  Future<void> _saveContribution() async {
    final parsedAmount = double.tryParse(amount) ?? 0;
    if (parsedAmount <= 0) {
      context.read<NotifyingProvider>().showMessage("Enter an amount first. ");
    }

    // Firestore's increment handles the math server-side — we don't
    // need to know the goal's current savedAmount to add to it.
    await context.read<SavingsGoalProvider>().contribute(
      widget.goal.id,
      parsedAmount,
    );

    if (!mounted) return;
    context.read<NotifyingProvider>().showMessage(
      "Added \$${parsedAmount.toStringAsFixed(2)} to ${widget.goal.title}",
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // watch() so if a contribution is made and the same goal is
    // re-opened, this screen reflects the freshest saved/target amounts.
    final goal = context.watch<SavingsGoalProvider>().goals.firstWhere(
      (g) => g.id == widget.goal.id,
      orElse: () => widget.goal,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Set Goal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  goal.title,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height:4),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '\$${goal.savedAmount.toStringAsFixed(0)} '
                  'of \$${goal.targetAmount.toStringAsFixed(0)} saved',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),

              const SizedBox(height: 10),

              AmountDisplay(amount: amount),

              const SizedBox(height: 20),

              NumberPad(onKeyPressed: _handleKeyPress),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 52.0, vertical: 24),
                child: Container(
                  decoration: BoxDecoration(
                     color : const Color(0xFF1C6B47),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: double.infinity,
                  
                  child: InkWell(
                    onTap: _saveContribution,
                    child: Center(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Add to Goal" , style: TextStyle(fontSize: 18, fontWeight: FontWeight(600)  ,color: Colors.white),),
                    ))),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
