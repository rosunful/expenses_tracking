import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';

class TopCategoryCard extends StatelessWidget {
  const TopCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = context.watch<ExpensesController>().categoryTotals;

    String topCategory = 'No spending yet';
    if (categoryTotals.isNotEmpty) {
      // Find the category with the highest total by comparing entries,
      // rather than sorting the whole map just to read one value.
      final topEntry = categoryTotals.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      topCategory = topEntry.key;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_circle_outline_rounded, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryTotals.isEmpty ? topCategory : 'Top category: $topCategory',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                "Based on this month's activity",
                style: TextStyle(color: context.appColors.paragraphColor, fontSize: 12),
              ),
              
            ],
          ),
          
        ],
      ),
    );
  }
}