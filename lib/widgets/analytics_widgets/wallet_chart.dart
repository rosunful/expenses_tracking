import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';

class AccountSpendingChart extends StatelessWidget {
  const AccountSpendingChart({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions =
        context.watch<ExpensesController>().transactions;

    // Calculate total expense for each account.
    final accountTotals = <AccountType, double>{
      AccountType.cash: 0,
      AccountType.bank: 0,
      AccountType.card: 0,
    };

    for (final transaction in transactions) {
      // We only want expenses here.
      if (transaction.type != TransactionType.expense) continue;

      accountTotals[transaction.account] =
          (accountTotals[transaction.account] ?? 0) +
              transaction.amount;
    }

    final cash = accountTotals[AccountType.cash] ?? 0;
    final bank = accountTotals[AccountType.bank] ?? 0;
    final card = accountTotals[AccountType.card] ?? 0;

    final largest = [
      cash,
      bank,
      card,
    ].reduce((a, b) => a > b ? a : b);

    const maxBarHeight = 100.0;

    final scale = largest == 0
        ? 0.0
        : maxBarHeight / largest;

    double barHeight(double amount) {
      if (amount == 0) return 0;

      return (amount * scale).clamp(
        6.0,
        maxBarHeight,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: context.appColors.cardsBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Spending by account",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface,
              ),
            ),
      
            const SizedBox(height: 24),
      
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(
                  context: context,
                  height: barHeight(cash),
                  label: "Cash",
                  amount: cash,
                  icon: Icons.payments_outlined,
                ),
      
                _bar(
                  context: context,
                  height: barHeight(bank),
                  label: "Bank",
                  amount: bank,
                  icon: Icons.account_balance_outlined,
                ),
      
                _bar(
                  context: context,
                  height: barHeight(card),
                  label: "Card",
                  amount: card,
                  icon: Icons.credit_card_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({
    required BuildContext context,
    required double height,
    required String label,
    required double amount,
    required IconData icon,
  }) {
    return Column(
      children: [
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context)
                .colorScheme
                .onSurface,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          width: 44,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: 8),

        Icon(
          icon,
          size: 18,
          color: Theme.of(context)
              .colorScheme
              .onSurface,
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurface,
          ),
        ),
      ],
    );
  }
}