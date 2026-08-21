import 'package:expense_tracking/models/saving_model.dart';
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/amount_display.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/number_pad.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/note_field.dart';


class AddGoalContributionScreen extends StatefulWidget {
  final SavingsGoalModel goal;
  const AddGoalContributionScreen({super.key, required this.goal});

  @override
  State<AddGoalContributionScreen> createState() => _AddGoalContributionScreenState();
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
        amount = amount.length > 1 ? amount.substring(0, amount.length - 1) : "0";
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter an amount first")),
      );
      return;
    }


    await context.read<SavingsGoalProvider>().contribute(widget.goal.id, parsedAmount);

    if (!mounted) return;
    final symbol = context.read<CurrencyProvider>().selected.symbol;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Added $symbol${parsedAmount.toStringAsFixed(2)} to ${widget.goal.title}")),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final goal = context.watch<SavingsGoalProvider>().goals.firstWhere(
          (g) => g.id == widget.goal.id,
          orElse: () => widget.goal,
        );
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

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
                        goal.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 , color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$symbol${goal.savedAmount.toStringAsFixed(0)} of $symbol${goal.targetAmount.toStringAsFixed(0)} saved',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AmountDisplay(amount: amount),
                    const SizedBox(height: 20),
                    NoteField(controller: noteController),
                    const SizedBox(height: 20),
                    NumberPad(onKeyPressed: _handleKeyPress),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveContribution,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C6B47),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Add to Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






