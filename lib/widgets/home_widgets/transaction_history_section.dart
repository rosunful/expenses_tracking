import 'package:expense_tracking/controllers/expenses_controller.dart';
// NOTE: assumed path — adjust to wherever TransactionModel actually lives.
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

IconData _iconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.restaurant;
    case 'transport':
      return Icons.directions_car;
    case 'shopping':
      return Icons.shopping_bag;
    case 'bills':
      return Icons.receipt_long;
    case 'entertainment':
      return Icons.movie;
    case 'salary':
      return Icons.work;
    case 'freelance':
      return Icons.laptop_mac;
    case 'business':
      return Icons.business_center;
    case 'gift':
      return Icons.card_giftcard;
    case 'investment':
      return Icons.trending_up;
    default:
      return Icons.receipt_long;
  }
}

String _relativeDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return '$diff days ago';
  return '${date.month}/${date.day}/${date.year}';
}

class TransactionHistorySection extends StatelessWidget {
  final int maxItems;
  final VoidCallback? onSeeAll;

  const TransactionHistorySection({
    super.key,
    this.maxItems = 4,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final recent = context
        .watch<ExpensesController>()
        .transactions
        .take(maxItems)
        .toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.blueColor,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                ),
                child: const Text('See all'),
              ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: context.appColors.cardsBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: recent.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < recent.length; i++) ...[
                        _TransactionRow(transaction: recent[i], colorScheme: colorScheme),
                        if (i != recent.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final ColorScheme colorScheme;

  const _TransactionRow({required this.transaction, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;

    // Same locked-to-its-own-currency behavior as the Activity screen:
    // looked up from THIS transaction's own stored currencyCode, not
    // the app's current live currency setting. Built directly here
    // rather than through formatCurrency(), since that helper's
    // internals aren't available to safely add symbol support into.
    // Live — same as ActivityScreen and DeletedTransactionsScreen, not
    // locked to whatever was active when this transaction was saved.
    final symbol = context.watch<CurrencyProvider>().selected.symbol;
    final formattedAmount =
        '${isIncome ? '+' : '-'}$symbol${transaction.amount.toStringAsFixed(2)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (isIncome ? Colors.green : colorScheme.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForCategory(transaction.category),
                  size: 18,
                  color: isIncome ? Colors.green.shade700 : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${transaction.category} · ${_relativeDay(transaction.date)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight(500),
                        color: context.appColors.paragraphColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formattedAmount,
          style: TextStyle(
            color: isIncome ? Colors.green.shade700 : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}








