import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';

class SpendingCategoryCard extends StatelessWidget {
  const SpendingCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = context.watch<ExpensesController>().categoryTotals;

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  
    final totalAmount = sortedEntries.fold<double>(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Spending by category",
              style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 18),
          if (sortedEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "No spending yet this month",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13),
              ),
            )
          else
            for (var i = 0; i < sortedEntries.length; i++) ...[
              _item(
                sortedEntries[i].key,
                totalAmount == 0 ? 0 : sortedEntries[i].value / totalAmount,
                '\$${sortedEntries[i].value.toStringAsFixed(2)}',
                context,
              ),
              if (i != sortedEntries.length - 1) const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }

  Widget _item(String title, double value, String amount, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(amount, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
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