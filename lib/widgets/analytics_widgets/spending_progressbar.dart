import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';

class SpendingCategoryCard extends StatelessWidget {
  const SpendingCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = context.watch<ExpensesController>().categoryTotals;

    // Sort categories highest-spending first, same order your
    // hardcoded version showed (Shopping, Food, Transport, Entertainment).
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Every bar's progress is relative to the top category, so the
    // biggest spender always fills the bar completely — matches your
    // original design where Shopping was visually the fullest.
    final maxAmount = sortedEntries.isEmpty ? 1.0 : sortedEntries.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Spending by category",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ),
          const SizedBox(height: 18),
          if (sortedEntries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "No spending yet this month",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            )
          else
            for (var i = 0; i < sortedEntries.length; i++) ...[
              _item(
                sortedEntries[i].key,
                sortedEntries[i].value / maxAmount,
                '\$${sortedEntries[i].value.toStringAsFixed(2)}',
              ),
              if (i != sortedEntries.length - 1) const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }

  Widget _item(String title, double value, String amount) {
    return Column(
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(amount, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade300,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}