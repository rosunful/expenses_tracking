import 'package:expense_tracking/controllers/expenses_controller.dart';
// NOTE: assumed path — adjust to wherever TransactionModel actually lives.
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/home_widgets/currency_foramatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Maps a category name to a representative icon so list rows aren't
/// all the same person icon. Falls back to a generic receipt icon for
/// anything custom/unrecognized.
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
    // If your ExpensesController exposes the raw list under a different
    // name (e.g. allTransactions), this is the one line to change.
    final allTransactions = List<TransactionModel>.from(
      context.watch<ExpensesController>().transactions,
    )..sort((a, b) => b.date.compareTo(a.date));

    final recent = allTransactions.take(maxItems).toList();
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
                  // 1. Removes the default 48x48 minimum touch constraint
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // 2. Resets the minimum size to zero
                  minimumSize: Size.zero,
                  // 3. Reduces or eliminates inner padding (optional)
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
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
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (int i = 0; i < recent.length; i++) ...[
                        _TransactionRow(
                          transaction: recent[i],
                          colorScheme: colorScheme,
                        ),
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
                  color: (isIncome ? Colors.green : colorScheme.primary)
                      .withValues(alpha: 0.12),
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

                      //HERE WE NEED TO ADD COLOR FOR THE SUB TITLE COLOR LIKE GREY
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
          isIncome
              ? formatCurrency(transaction.amount, showSign: true)
              : '-${formatCurrency(transaction.amount)}',
          style: TextStyle(
            color: isIncome ? Colors.green.shade700 : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
