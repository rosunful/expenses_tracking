import 'package:expense_tracking/controllers/date_formatter_controller.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/providers/currency_provider.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows soft-deleted transactions (isHidden == true) with Restore
/// and Delete Permanently actions. Manual cleanup only — nothing here
/// auto-purges, so items stay until the user acts on them.
class DeletedTransactionsScreen extends StatefulWidget {
  const DeletedTransactionsScreen({super.key});

  @override
  State<DeletedTransactionsScreen> createState() =>
      _DeletedTransactionsScreenState();
}

class _DeletedTransactionsScreenState extends State<DeletedTransactionsScreen> {
  String? _expandedTransactionId;

  void _toggleExpanded(String transactionId) {
    setState(() {
      _expandedTransactionId = _expandedTransactionId == transactionId
          ? null
          : transactionId;
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
                      Icon(
                        Icons.delete_outline,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No deleted transactions',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: deleted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
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
  State<_DeletedTransactionTile> createState() =>
      _DeletedTransactionTileState();
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
        content: Text(
          '"${widget.tx.title}" will be removed for good. This can\'t be undone.',
        ),
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
    // Live — reflects the currently selected app-wide currency, same
    // as ActivityScreen, not locked to what was active when this
    // transaction was originally saved.
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

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
                  Icon(
                    isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Truncated to one line while collapsed; once
                        // expanded, no line cap and no ellipsis — this
                        // IS the full title now, so the detail panel
                        // below no longer needs to repeat it.
                        Text(
                          tx.title,
                          maxLines: widget.isExpanded ? null : 1,
                          overflow: widget.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Same idea for category: single-line + ellipsis
                        // while collapsed, full text once expanded. Date
                        // moves to its own row when expanded so a long
                        // category has room to wrap without being
                        // squeezed against it.
                        if (widget.isExpanded) ...[
                          Text(
                            tx.category,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            formatTransactionDate(tx.date),
                            style: TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.5)),
                          ),
                        ] else
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  tx.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatTransactionDate(tx.date),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$sign$symbol${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
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
            // Note.
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
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _restore,
                    icon: const Icon(Icons.restore, size: 16, color: Color(0xFF1C6B47)),
                    label: const Text('Restore', style: TextStyle(color: Color(0xFF1C6B47))),
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
// class DeletedTransactionsScreen extends StatefulWidget {
//   const DeletedTransactionsScreen({super.key});

//   @override
//   State<DeletedTransactionsScreen> createState() =>
//       _DeletedTransactionsScreenState();
// }

// class _DeletedTransactionsScreenState extends State<DeletedTransactionsScreen> {
//   String? _expandedTransactionId;

//   void _toggleExpanded(String transactionId) {
//     setState(() {
//       _expandedTransactionId = _expandedTransactionId == transactionId
//           ? null
//           : transactionId;
//     });
//   }

//   void _collapse() {
//     if (_expandedTransactionId != null) {
//       setState(() => _expandedTransactionId = null);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final deleted = context.watch<ExpensesController>().hiddenExpenses;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
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
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _collapse,
//         child: SafeArea(
//           child: deleted.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.delete_outline,
//                         size: 60,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No deleted transactions',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.separated(
//                   padding: const EdgeInsets.all(14),
//                   itemCount: deleted.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 8),
//                   itemBuilder: (context, index) => _DeletedTransactionTile(
//                     tx: deleted[index],
//                     isExpanded: _expandedTransactionId == deleted[index].id,
//                     onToggle: () => _toggleExpanded(deleted[index].id),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }

// class _DeletedTransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   final bool isExpanded;
//   final VoidCallback onToggle;

//   const _DeletedTransactionTile({
//     required this.tx,
//     required this.isExpanded,
//     required this.onToggle,
//   });

//   @override
//   State<_DeletedTransactionTile> createState() =>
//       _DeletedTransactionTileState();
// }

// class _DeletedTransactionTileState extends State<_DeletedTransactionTile> {
//   bool _isBusy = false;

//   String _accountLabel(AccountType account) => switch (account) {
//         AccountType.cash => 'Cash',
//         AccountType.bank => 'Bank',
//         AccountType.card => 'Card',
//       };

//   IconData _accountIcon(AccountType account) => switch (account) {
//         AccountType.cash => Icons.payments_outlined,
//         AccountType.bank => Icons.account_balance_outlined,
//         AccountType.card => Icons.credit_card_outlined,
//       };

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
//         content: Text(
//           '"${widget.tx.title}" will be removed for good. This can\'t be undone.',
//         ),
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
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: widget.onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     isExpense ? Icons.arrow_upward : Icons.arrow_downward,
//                     color: color,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Truncated to one line while collapsed; once
//                         // expanded, no line cap and no ellipsis — this
//                         // IS the full title now, so the detail panel
//                         // below no longer needs to repeat it.
//                         Text(
//                           tx.title,
//                           maxLines: widget.isExpanded ? null : 1,
//                           overflow: widget.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                             color: onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         // Same idea for category: single-line + ellipsis
//                         // while collapsed, full text once expanded. Date
//                         // moves to its own row when expanded so a long
//                         // category has room to wrap without being
//                         // squeezed against it.
//                         if (widget.isExpanded) ...[
//                           Text(
//                             tx.category,
//                             style: const TextStyle(fontSize: 13),
//                           ),
//                           Text(
//                             formatTransactionDate(tx.date),
//                             style: TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.4) , fontWeight: FontWeight(500)),
//                           ),
//                         ] else
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   tx.category,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 formatTransactionDate(tx.date),
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                     Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '$sign$symbol ',
//                         style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 10),
//                       ),
//                       Text(
//                         tx.amount.toStringAsFixed(2),
//                         style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                   // Text(
//                   //   '$sign$symbol${tx.amount.toStringAsFixed(2)}',
//                   //   style: TextStyle(
//                   //     color: color,
//                   //     fontWeight: FontWeight.w600,
//                   //     fontSize: 15,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             child: widget.isExpanded
//                 ? _buildDetailPanel(onSurface, tx)
//                 : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailPanel(Color onSurface, TransactionModel tx) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: onSurface.withValues(alpha: 0.04),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Note.
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.notes_rounded, size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     tx.note.trim().isEmpty ? 'No note added' : tx.note,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: tx.note.trim().isEmpty
//                           ? onSurface.withValues(alpha: 0.4)
//                           : onSurface.withValues(alpha: 0.8),
//                       fontStyle: tx.note.trim().isEmpty ? FontStyle.italic : FontStyle.normal,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Account type — cash / bank / card.
            
//             const SizedBox(height: 16),
//             if (_isBusy)
//               const Align(
//                 alignment: Alignment.centerRight,
//                 child: SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               )
//             else
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
//                   const SizedBox(width: 6),
//                   Text(
//                     _accountLabel(tx.account),
//                     style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
//                   ),
//                 const Spacer(),
//                   TextButton.icon(
//                     onPressed: _restore,
//                     icon: const Icon(Icons.restore, size: 16, color: Color(0xFF1C6B47)),
//                     label: const Text('Restore', style: TextStyle(color: Color(0xFF1C6B47))),
//                   ),
//                   IconButton(
//                     onPressed: _deleteForever,
//                     icon: const Icon(Icons.delete_forever_outlined, size: 16, color: Colors.red),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }






////version unkown

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
// class DeletedTransactionsScreen extends StatefulWidget {
//   const DeletedTransactionsScreen({super.key});

//   @override
//   State<DeletedTransactionsScreen> createState() =>
//       _DeletedTransactionsScreenState();
// }

// class _DeletedTransactionsScreenState extends State<DeletedTransactionsScreen> {
//   String? _expandedTransactionId;

//   void _toggleExpanded(String transactionId) {
//     setState(() {
//       _expandedTransactionId = _expandedTransactionId == transactionId
//           ? null
//           : transactionId;
//     });
//   }

//   void _collapse() {
//     if (_expandedTransactionId != null) {
//       setState(() => _expandedTransactionId = null);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final deleted = context.watch<ExpensesController>().hiddenExpenses;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
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
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _collapse,
//         child: SafeArea(
//           child: deleted.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.delete_outline,
//                         size: 60,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No deleted transactions',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.separated(
//                   padding: const EdgeInsets.all(14),
//                   itemCount: deleted.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 8),
//                   itemBuilder: (context, index) => _DeletedTransactionTile(
//                     tx: deleted[index],
//                     isExpanded: _expandedTransactionId == deleted[index].id,
//                     onToggle: () => _toggleExpanded(deleted[index].id),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }

// class _DeletedTransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   final bool isExpanded;
//   final VoidCallback onToggle;

//   const _DeletedTransactionTile({
//     required this.tx,
//     required this.isExpanded,
//     required this.onToggle,
//   });

//   @override
//   State<_DeletedTransactionTile> createState() =>
//       _DeletedTransactionTileState();
// }

// class _DeletedTransactionTileState extends State<_DeletedTransactionTile> {
//   bool _isBusy = false;

//   String _accountLabel(AccountType account) => switch (account) {
//         AccountType.cash => 'Cash',
//         AccountType.bank => 'Bank',
//         AccountType.card => 'Card',
//       };

//   IconData _accountIcon(AccountType account) => switch (account) {
//         AccountType.cash => Icons.payments_outlined,
//         AccountType.bank => Icons.account_balance_outlined,
//         AccountType.card => Icons.credit_card_outlined,
//       };

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
//         content: Text(
//           '"${widget.tx.title}" will be removed for good. This can\'t be undone.',
//         ),
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
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: widget.onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     isExpense ? Icons.arrow_upward : Icons.arrow_downward,
//                     color: color,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Collapsed: title stays a single line here —
//                         // it's shown again in FULL (no truncation) at
//                         // the top of the expanded detail panel below.
//                         Text(
//                           tx.title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                             color: onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         // Collapsed: category truncated to one line —
//                         // this was showing a leftover debug placeholder
//                         // string instead of tx.category. Fixed. The
//                         // untruncated version shows in the detail panel
//                         // once expanded.
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 tx.category,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               formatTransactionDate(tx.date),
//                               style: const TextStyle(fontSize: 13),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '$sign$symbol${tx.amount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       color: color,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             child: widget.isExpanded
//                 ? _buildDetailPanel(onSurface, tx)
//                 : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailPanel(Color onSurface, TransactionModel tx) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: onSurface.withValues(alpha: 0.04),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Full title — untruncated, unlike the collapsed row above,
//             // which is capped at one line with an ellipsis.
//             Text(
//               tx.title,
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 fontSize: 15,
//                 color: onSurface,
//               ),
//             ),
//             const SizedBox(height: 4),
//             // Full category — same idea, wraps freely instead of being
//             // clipped to one line like it is in the collapsed row.
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.category_outlined, size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     tx.category,
//                     style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Note.
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.notes_rounded, size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     tx.note.trim().isEmpty ? 'No note added' : tx.note,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: tx.note.trim().isEmpty
//                           ? onSurface.withValues(alpha: 0.4)
//                           : onSurface.withValues(alpha: 0.8),
//                       fontStyle: tx.note.trim().isEmpty ? FontStyle.italic : FontStyle.normal,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Account type — cash / bank / card.
//             Row(
//               children: [
//                 Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Text(
//                   _accountLabel(tx.account),
//                   style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_isBusy)
//               const Align(
//                 alignment: Alignment.centerRight,
//                 child: SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               )
//             else
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton.icon(
//                     onPressed: _restore,
//                     icon: const Icon(Icons.restore, size: 16, color: Color(0xFF1C6B47)),
//                     label: const Text('Restore', style: TextStyle(color: Color(0xFF1C6B47))),
//                   ),
//                   IconButton(
//                     onPressed: _deleteForever,
//                     icon: const Icon(Icons.delete_forever_outlined, size: 16, color: Colors.red),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


















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
// class DeletedTransactionsScreen extends StatefulWidget {
//   const DeletedTransactionsScreen({super.key});

//   @override
//   State<DeletedTransactionsScreen> createState() =>
//       _DeletedTransactionsScreenState();
// }

// class _DeletedTransactionsScreenState extends State<DeletedTransactionsScreen> {
//   String? _expandedTransactionId;

//   void _toggleExpanded(String transactionId) {
//     setState(() {
//       _expandedTransactionId = _expandedTransactionId == transactionId
//           ? null
//           : transactionId;
//     });
//   }

//   void _collapse() {
//     if (_expandedTransactionId != null) {
//       setState(() => _expandedTransactionId = null);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final deleted = context.watch<ExpensesController>().hiddenExpenses;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
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
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _collapse,
//         child: SafeArea(
//           child: deleted.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.delete_outline,
//                         size: 60,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No deleted transactions',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.separated(
//                   padding: const EdgeInsets.all(14),
//                   itemCount: deleted.length,
//                   separatorBuilder: (_, _) => const SizedBox(height: 8),
//                   itemBuilder: (context, index) => _DeletedTransactionTile(
//                     tx: deleted[index],
//                     isExpanded: _expandedTransactionId == deleted[index].id,
//                     onToggle: () => _toggleExpanded(deleted[index].id),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }

// class _DeletedTransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   final bool isExpanded;
//   final VoidCallback onToggle;

//   const _DeletedTransactionTile({
//     required this.tx,
//     required this.isExpanded,
//     required this.onToggle,
//   });

//   @override
//   State<_DeletedTransactionTile> createState() =>
//       _DeletedTransactionTileState();
// }

// class _DeletedTransactionTileState extends State<_DeletedTransactionTile> {
//   bool _isBusy = false;

//   String _accountLabel(AccountType account) => switch (account) {
//     AccountType.cash => 'Cash',
//     AccountType.bank => 'Bank',
//     AccountType.card => 'Card',
//   };

//   IconData _accountIcon(AccountType account) => switch (account) {
//     AccountType.cash => Icons.payments_outlined,
//     AccountType.bank => Icons.account_balance_outlined,
//     AccountType.card => Icons.credit_card_outlined,
//   };

//   Future<void> _restore() async {
//     if (_isBusy) return;
//     setState(() => _isBusy = true);

//     await context.read<ExpensesController>().unhideExpense(widget.tx.id);

//     if (!mounted) return;
//     setState(() => _isBusy = false);
//     context.read<NotifyingProvider>().showMessage(
//       '"${widget.tx.title}" restored',
//     );
//   }

//   Future<void> _deleteForever() async {
//     if (_isBusy) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Delete permanently?'),
//         content: Text(
//           '"${widget.tx.title}" will be removed for good. This can\'t be undone.',
//         ),
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
//     context.read<NotifyingProvider>().showMessage(
//       '"$title" deleted permanently',
//     );
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
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: widget.onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     isExpense ? Icons.arrow_upward : Icons.arrow_downward,
//                     color: color,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Collapsed: title stays a single line.
//                         Text(
//                           tx.title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                             color: onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         // Collapsed: category · date can wrap up to 3 lines
//                         // before truncating, instead of clipping at 1.
//                         Row(
//                           children: [
//                             // Text(
//                             //   '${tx.category} ',

//                             //   overflow: TextOverflow.ellipsis,
//                             //   style: const TextStyle(fontSize: 13),
//                             // ),
//                            Expanded(
//                               child: Text(
//                                 "kjgjhhjgkhjgjhbjbljhgjhbjblgb h hhihkbk",
                                
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               formatTransactionDate(tx.date),
//                               style: const TextStyle(fontSize: 13),
//                             ),
//                             // Text("kjgjhhjgkhjgjhbjbljhgjhbjblgb h hhihkbk"),

//                             // Text(
//                             //   formatTransactionDate(tx.date),

//                             //   style: const TextStyle(fontSize: 13),
//                             // ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '$sign$symbol${tx.amount.toStringAsFixed(2)}',
//                     style: TextStyle(
//                       color: color,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             child: widget.isExpanded
//                 ? _buildDetailPanel(onSurface, tx)
//                 : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailPanel(Color onSurface, TransactionModel tx) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: onSurface.withValues(alpha: 0.04),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Note — same pattern as ActivityScreen's detail panel.
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(
//                   Icons.notes_rounded,
//                   size: 16,
//                   color: onSurface.withValues(alpha: 0.6),
//                 ),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     tx.note.trim().isEmpty ? 'No note added' : tx.note,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: tx.note.trim().isEmpty
//                           ? onSurface.withValues(alpha: 0.4)
//                           : onSurface.withValues(alpha: 0.8),
//                       fontStyle: tx.note.trim().isEmpty
//                           ? FontStyle.italic
//                           : FontStyle.normal,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Account type — cash / bank / card.
//             Row(
//               children: [
//                 Icon(
//                   _accountIcon(tx.account),
//                   size: 16,
//                   color: onSurface.withValues(alpha: 0.6),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   _accountLabel(tx.account),
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: onSurface.withValues(alpha: 0.8),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (_isBusy)
//               const Align(
//                 alignment: Alignment.centerRight,
//                 child: SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               )
//             else
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton.icon(
//                     onPressed: _restore,
//                     icon: const Icon(
//                       Icons.restore,
//                       size: 16,
//                       color: Color(0xFF1C6B47),
//                     ),
//                     label: const Text(
//                       '',
//                       style: TextStyle(color: Color(0xFF1C6B47)),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: _deleteForever,
//                     icon: const Icon(
//                       Icons.delete_forever_outlined,
//                       size: 16,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
