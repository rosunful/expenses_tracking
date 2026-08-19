import 'package:expense_tracking/controllers/date_formatter_controller.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/models/currency_model.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows soft-deleted transactions (isHidden == true) with Restore
/// and Delete Permanently actions. Manual cleanup only — nothing here
/// auto-purges, so items stay until the user acts on them.
class DeletedTransactionsScreen extends StatefulWidget {
  const DeletedTransactionsScreen({super.key});

  @override
  State<DeletedTransactionsScreen> createState() => _DeletedTransactionsScreenState();
}

class _DeletedTransactionsScreenState extends State<DeletedTransactionsScreen> {
  String? _expandedTransactionId;

  void _toggleExpanded(String transactionId) {
    setState(() {
      _expandedTransactionId = _expandedTransactionId == transactionId ? null : transactionId;
    });
  }

  void _collapse() {
    if (_expandedTransactionId != null) {
      setState(() => _expandedTransactionId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deleted = context.watch<ExpensesController>().hiddenExpenses;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Deleted Transactions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _collapse,
        child: SafeArea(
          child: deleted.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No deleted transactions',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: deleted.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _DeletedTransactionTile(
                    tx: deleted[index],
                    isExpanded: _expandedTransactionId == deleted[index].id,
                    onToggle: () => _toggleExpanded(deleted[index].id),
                  ),
                ),
        ),
      ),
    );
  }
}

class _DeletedTransactionTile extends StatefulWidget {
  final TransactionModel tx;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DeletedTransactionTile({
    required this.tx,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<_DeletedTransactionTile> createState() => _DeletedTransactionTileState();
}

class _DeletedTransactionTileState extends State<_DeletedTransactionTile> {
  bool _isBusy = false;

  String _accountLabel(AccountType account) => switch (account) {
        AccountType.cash => 'Cash',
        AccountType.bank => 'Bank',
        AccountType.card => 'Card',
      };

  IconData _accountIcon(AccountType account) => switch (account) {
        AccountType.cash => Icons.payments_outlined,
        AccountType.bank => Icons.account_balance_outlined,
        AccountType.card => Icons.credit_card_outlined,
      };

  Future<void> _restore() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    await context.read<ExpensesController>().unhideExpense(widget.tx.id);

    if (!mounted) return;
    setState(() => _isBusy = false);
    context.read<NotifyingProvider>().showMessage('"${widget.tx.title}" restored');
  }

  Future<void> _deleteForever() async {
    if (_isBusy) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: Text('"${widget.tx.title}" will be removed for good. This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isBusy = true);
    final controller = context.read<ExpensesController>();
    final title = widget.tx.title;

    await controller.deleteExpenses(widget.tx);

    if (!mounted) return;
    context.read<NotifyingProvider>().showMessage('"$title" deleted permanently');
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final isExpense = tx.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';
    final color = isExpense ? Colors.red : Colors.green;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final symbol = currencyForCode(tx.currencyCode).symbol;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(isExpense ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Collapsed: title stays a single line.
                        Text(
                          tx.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
                        ),
                        const SizedBox(height: 2),
                        // Collapsed: category · date can wrap up to 3 lines
                        // before truncating, instead of clipping at 1.
                        Text(
                          '${tx.category} · ${formatTransactionDate(tx.date)}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$sign$symbol${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: widget.isExpanded
                ? _buildDetailPanel(onSurface, tx)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(Color onSurface, TransactionModel tx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note — same pattern as ActivityScreen's detail panel.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_rounded, size: 16, color: onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tx.note.trim().isEmpty ? 'No note added' : tx.note,
                    style: TextStyle(
                      fontSize: 13,
                      color: tx.note.trim().isEmpty
                          ? onSurface.withValues(alpha: 0.4)
                          : onSurface.withValues(alpha: 0.8),
                      fontStyle: tx.note.trim().isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Account type — cash / bank / card.
            Row(
              children: [
                Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  _accountLabel(tx.account),
                  style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isBusy)
              const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _restore,
                    icon: const Icon(Icons.restore, size: 16, color: Color(0xFF1C6B47)),
                    label: const Text('', style: TextStyle(color: Color(0xFF1C6B47))),
                  ),
                  IconButton(
                    onPressed: _deleteForever,
                    icon: const Icon(Icons.delete_forever_outlined, size: 16, color: Colors.red),
                    
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}















// import 'package:expense_tracking/controllers/date_formatter_controller.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/models/currency_model.dart';
// import 'package:expense_tracking/models/transaction_model.dart';
// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// /// Shows soft-deleted transactions (isHidden == true) with Restore
// /// and Delete Permanently actions. Manual cleanup only — nothing here
// /// auto-purges, so items stay until the user acts on them.
// class DeletedTransactionsScreen extends StatelessWidget {
//   const DeletedTransactionsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final deleted = context.watch<ExpensesController>().hiddenExpenses;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text(
//           'Deleted Transactions',
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: deleted.isEmpty
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.delete_outline, size: 60, color: Colors.grey.shade400),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No deleted transactions',
//                       style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
//                     ),
//                   ],
//                 ),
//               )
//             : ListView.separated(
//                 padding: const EdgeInsets.all(14),
//                 itemCount: deleted.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 8),
//                 itemBuilder: (context, index) => _DeletedTransactionTile(tx: deleted[index]),
//               ),
//       ),
//     );
//   }
// }

// class _DeletedTransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   const _DeletedTransactionTile({required this.tx});

//   @override
//   State<_DeletedTransactionTile> createState() => _DeletedTransactionTileState();
// }

// class _DeletedTransactionTileState extends State<_DeletedTransactionTile> {
//   bool _isBusy = false;

//   Future<void> _restore() async {
//     if (_isBusy) return;
//     setState(() => _isBusy = true);

//     await context.read<ExpensesController>().unhideExpense(widget.tx.id);

//     if (!mounted) return;
//     setState(() => _isBusy = false);
//     context.read<NotifyingProvider>().showMessage('"${widget.tx.title}" restored');
//   }

//   Future<void> _deleteForever() async {
//     if (_isBusy) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Delete permanently?'),
//         content: Text('"${widget.tx.title}" will be removed for good. This can\'t be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;

//     setState(() => _isBusy = true);
//     final controller = context.read<ExpensesController>();
//     final title = widget.tx.title;

//     await controller.deleteExpenses(widget.tx);

//     if (!mounted) return;
//     context.read<NotifyingProvider>().showMessage('"$title" deleted permanently');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tx = widget.tx;
//     final isExpense = tx.type == TransactionType.expense;
//     final sign = isExpense ? '-' : '+';
//     final color = isExpense ? Colors.red : Colors.green;
//     final onSurface = Theme.of(context).colorScheme.onSurface;
//     final symbol = currencyForCode(tx.currencyCode).symbol;

//     return Container(
//       decoration: BoxDecoration(
//         color: context.appColors.cardsBackground,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(isExpense ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 18),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       tx.title,
//                       style: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       '${tx.category} · ${formatTransactionDate(tx.date)}',
//                       style: const TextStyle(fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 '$sign$symbol${tx.amount.toStringAsFixed(2)}',
//                 style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               if (_isBusy)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
//                 )
//               else ...[
//                 TextButton.icon(
//                   onPressed: _restore,
//                   // icon: const Icon(Icons.restore, size: 16, color: Color(0xFF1C6B47)),
//                   label: const Text('Restore', style: TextStyle(color: Color(0xFF1C6B47))),
//                 ),
//                 IconButton(
//                   onPressed: _deleteForever,
//                   icon: const Icon(Icons.delete_forever_outlined, size: 16, color: Colors.red),
                  
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }