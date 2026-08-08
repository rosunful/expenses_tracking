// NOTE: assumed path — adjust if TransactionProvider lives elsewhere
// (it's the class with selectExpense()/selectIncome() you shared).
import 'package:expense_tracking/providers/transaction_provider.dart';
import 'package:expense_tracking/screens/add_expenses_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddingExpenseSection extends StatelessWidget {
  const AddingExpenseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.remove_circle_outline,
            label: "Add\nExpense",
            onTap: () {
              context.read<TransactionProvider>().selectExpense();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpensesScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.add_circle_outline,
            label: "Add\nIncome",
            onTap: () {
              context.read<TransactionProvider>().selectIncome();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpensesScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.swap_horiz,
            label: "Transfer",
            onTap: () {
              // No transfer screen yet — swap this for a real
              // Navigator.push once you build one.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transfers are coming soon')),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.qr_code_scanner,
            label: "Scan",
            onTap: () {
              // No receipt-scan screen yet — same as above.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt scanning is coming soon')),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.cardsBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 16, color: colorScheme.primary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface)
              ),
            ],
          ),
        ),
      ),
    );
  }
}