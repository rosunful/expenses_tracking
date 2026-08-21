import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/models/transaction_model.dart';

class AccountAnalyticsChart extends StatelessWidget {
  const AccountAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExpensesController>();
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

    final transactions = controller.transactions;

    double cash = 0;
    double bank = 0;
    double card = 0;

    for (final transaction in transactions) {
      if (transaction.type != TransactionType.expense) continue;

      switch (transaction.account) {
        case AccountType.cash:
          cash += transaction.amount;
          break;

        case AccountType.bank:
          bank += transaction.amount;
          break;

        case AccountType.card:
          card += transaction.amount;
          break;
      }
    }

    final largest = [cash, bank, card].reduce((a, b) => a > b ? a : b);

    const maxBarHeight = 95.0;

    final scale = largest == 0 ? 0.0 : maxBarHeight / largest;

    double barHeight(double amount) {
      if (amount == 0) return 0;

      return (amount * scale).clamp(6.0, maxBarHeight);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _bar(
                  context,
                  "Cash",
                  cash,
                  barHeight(cash),                  
                  Colors.green.shade700,
                  symbol
                ),

                _bar(context, "Bank", bank, barHeight(bank), Colors.indigo ,  symbol),

                _bar(context, "Card", card, barHeight(card), Color(0xFF1C6B47) ,symbol ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(
    BuildContext context,
    String label,
    double amount,
    double height,
    Color color,
    String symbol,
  ) {
    return Column(
      children: [
        Text(
           '$symbol${amount.toStringAsFixed(0)}',
          // '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 4),

        Container(
          width: 44,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
