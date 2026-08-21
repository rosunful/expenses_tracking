import 'package:expense_tracking/controllers/date_formatter_controller.dart';

import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/screens/delete_transaction_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/models/transaction_model.dart';

enum _ActivityFilter { all, expenses, income }

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  TextEditingController searchTxt = TextEditingController();
  _ActivityFilter _filter = _ActivityFilter.all;
  String? _expandedTransactionId;

  @override
  void dispose() {
    searchTxt.dispose();
    super.dispose();
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
    final query = searchTxt.text.trim().toLowerCase();

    return transactions.where((tx) {
      final matchesFilter = switch (_filter) {
        _ActivityFilter.all => true,
        _ActivityFilter.expenses => tx.type == TransactionType.expense,
        _ActivityFilter.income => tx.type == TransactionType.income,
      };

      final matchesSearch = query.isEmpty ||
          tx.title.toLowerCase().contains(query) ||
          tx.category.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

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
    final allTransactions = context.watch<ExpensesController>().expensesNoPrivate;
    final visibleTransactions = _applyFilters(allTransactions);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _collapse,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transaction",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 26,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.history,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        tooltip: 'Deleted transactions',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DeletedTransactionsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: searchTxt,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search merchant or category",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      _filterChip("All", _ActivityFilter.all),
                      _filterChip("Expenses", _ActivityFilter.expenses),
                      _filterChip("Income", _ActivityFilter.income),
                    ],
                  ),
                  if (visibleTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          "No transactions found",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: context.appColors.cardsBackground,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visibleTransactions.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 0.6,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                          ),
                          itemBuilder: (context, index) => _TransactionTile(
                            tx: visibleTransactions[index],
                            isExpanded: _expandedTransactionId == visibleTransactions[index].id,
                            onToggle: () => _toggleExpanded(visibleTransactions[index].id),
                            onCollapse: _collapse,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, _ActivityFilter value) {
    final isActive = _filter == value;
    return OutlinedButton(
      onPressed: () => setState(() => _filter = value),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isActive ? const Color(0xFF1C6B47) : context.appColors.cardsBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: isActive ? const Color(0xFF1C6B47) : const Color.fromARGB(255, 225, 225, 225),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _TransactionTile extends StatefulWidget {
  final TransactionModel tx;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onCollapse;

  const _TransactionTile({
    required this.tx,
    required this.isExpanded,
    required this.onToggle,
    required this.onCollapse,
  });

  @override
  State<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<_TransactionTile> {
  bool _isDeleting = false;

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

  Future<void> _delete() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    final controller = context.read<ExpensesController>();
    final messenger = ScaffoldMessenger.of(context);
    final txId = widget.tx.id;
    final txTitle = widget.tx.title;

    await controller.hideExpense(widget.tx);

    if (!mounted) return;
    setState(() => _isDeleting = false);
    widget.onCollapse();

    messenger.showSnackBar(
      SnackBar(
        content: Text('"$txTitle" removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => controller.unhideExpense(txId),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final isExpense = tx.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';
    final color = isExpense ? Colors.red : Colors.green;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Live — reads whatever currency is CURRENTLY selected app-wide,
    // not locked to whatever was active when this transaction was
    // originally saved. Every transaction rebuilds and relabels itself
    // the instant the currency setting changes, since watch() subscribes
    // this widget to CurrencyProvider directly.
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                          color: color,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                maxLines: widget.isExpanded ? null : 1,
                                overflow: widget.isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
                              ),
                              if (widget.isExpanded) ...[
                                Text(
                                  tx.category,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  formatTransactionDate(tx.date),
                                  style: TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.5)),
                                ),
                              ] else
                                Text(
                                  '${tx.category} · ${formatTransactionDate(tx.date)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$sign$symbol ',
                        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 10),
                      ),
                      Text(
                        tx.amount.toStringAsFixed(2),
                        style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: widget.isExpanded ? _buildDetailPanel(onSurface, symbol) : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel(Color onSurface, String symbol) {
    final tx = widget.tx;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
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
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  _accountLabel(tx.account),
                  style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isDeleting ? null : _delete,
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                      : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: Text(_isDeleting ? 'Removing…' : 'Delete', style: const TextStyle(color: Colors.red)),
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
// import 'package:expense_tracking/models/currency_model.dart';
// import 'package:expense_tracking/screens/delete_transaction_screen.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/models/transaction_model.dart';

// enum _ActivityFilter { all, expenses, income }

// class ActivityScreen extends StatefulWidget {
//   const ActivityScreen({super.key});
//   @override
//   State<ActivityScreen> createState() => _ActivityScreenState();
// }

// class _ActivityScreenState extends State<ActivityScreen> {
//   TextEditingController searchTxt = TextEditingController();
//   _ActivityFilter _filter = _ActivityFilter.all;
//   String? _expandedTransactionId;

//   @override
//   void dispose() {
//     searchTxt.dispose();
//     super.dispose();
//   }

//   List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
//     final query = searchTxt.text.trim().toLowerCase();

//     return transactions.where((tx) {
//       final matchesFilter = switch (_filter) {
//         _ActivityFilter.all => true,
//         _ActivityFilter.expenses => tx.type == TransactionType.expense,
//         _ActivityFilter.income => tx.type == TransactionType.income,
//       };

//       final matchesSearch = query.isEmpty ||
//           tx.title.toLowerCase().contains(query) ||
//           tx.category.toLowerCase().contains(query);

//       return matchesFilter && matchesSearch;
//     }).toList();
//   }

//   void _toggleExpanded(String transactionId) {
//     setState(() {
//       _expandedTransactionId = _expandedTransactionId == transactionId ? null : transactionId;
//     });
//   }

//   void _collapse() {
//     if (_expandedTransactionId != null) {
//       setState(() => _expandedTransactionId = null);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allTransactions = context.watch<ExpensesController>().expensesNoPrivate;
//     final visibleTransactions = _applyFilters(allTransactions);

//     return Scaffold(
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _collapse,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: Column(
//                 spacing: 10,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Transaction",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).colorScheme.onSurface,
//                           fontSize: 26,
//                         ),
//                       ),
//                       // Opens the trash — soft-deleted transactions waiting
//                       // for Undo or Permanent Delete.
//                       IconButton(
//                         icon: Icon(
//                           Icons.history,
//                           color: Theme.of(context).colorScheme.onSurface,
//                         ),
//                         tooltip: 'Deleted transactions',
//                         onPressed: () {
//                           Navigator.of(context).push(
//                             MaterialPageRoute(builder: (_) => const DeletedTransactionsScreen()),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                   TextField(
//                     controller: searchTxt,
//                     onChanged: (_) => setState(() {}),
//                     decoration: InputDecoration(
//                       hintText: "Search merchant or category",
//                       hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 0.5),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     spacing: 4,
//                     children: [
//                       _filterChip("All", _ActivityFilter.all),
//                       _filterChip("Expenses", _ActivityFilter.expenses),
//                       _filterChip("Income", _ActivityFilter.income),
//                     ],
//                   ),
//                   if (visibleTransactions.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 24),
//                       child: Center(
//                         child: Text(
//                           "No transactions found",
//                           style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                         ),
//                       ),
//                     )
//                   else
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: context.appColors.cardsBackground,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: visibleTransactions.length,
//                           separatorBuilder: (context, index) => Divider(
//                             height: 1,
//                             thickness: 0.6,
//                             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
//                           ),
//                           itemBuilder: (context, index) => _TransactionTile(
//                             tx: visibleTransactions[index],
//                             isExpanded: _expandedTransactionId == visibleTransactions[index].id,
//                             onToggle: () => _toggleExpanded(visibleTransactions[index].id),
//                             onCollapse: _collapse,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _filterChip(String label, _ActivityFilter value) {
//     final isActive = _filter == value;
//     return OutlinedButton(
//       onPressed: () => setState(() => _filter = value),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: Colors.white,
//         backgroundColor: isActive ? const Color(0xFF1C6B47) : context.appColors.cardsBackground,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         side: BorderSide(
//           color: isActive ? const Color(0xFF1C6B47) : const Color.fromARGB(255, 225, 225, 225),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//           color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
//         ),
//       ),
//     );
//   }
// }

// class _TransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final VoidCallback onCollapse;

//   const _TransactionTile({
//     required this.tx,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.onCollapse,
//   });

//   @override
//   State<_TransactionTile> createState() => _TransactionTileState();
// }

// class _TransactionTileState extends State<_TransactionTile> {
//   bool _isDeleting = false;

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

//   Future<void> _delete() async {
//     if (_isDeleting) return;
//     setState(() => _isDeleting = true);

//     final controller = context.read<ExpensesController>();
//     final messenger = ScaffoldMessenger.of(context);
//     final txId = widget.tx.id;
//     final txTitle = widget.tx.title;

//     await controller.hideExpense(widget.tx);

//     if (!mounted) return;
//     setState(() => _isDeleting = false);
//     widget.onCollapse();

//     // Real SnackBar (not NotifyingProvider) so we get a working
//     // Undo action button — one tap calls unhideExpense and the
//     // transaction reappears in Activity immediately.
//     messenger.showSnackBar(
//       SnackBar(
//         content: Text('"$txTitle" removed'),
//         action: SnackBarAction(
//           label: 'UNDO',
//           onPressed: () => controller.unhideExpense(txId),
//         ),
//         duration: const Duration(seconds: 4),
//       ),
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

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(8),
//             onTap: widget.onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(
//                           isExpense ? Icons.arrow_upward : Icons.arrow_downward,
//                           color: color,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 tx.title,
//                                 style: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 '${tx.category} · ${formatTransactionDate(tx.date)}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 2),
//                   Row(
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
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             child: widget.isExpanded ? _buildDetailPanel(onSurface, symbol) : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailPanel(Color onSurface, String symbol) {
//     final tx = widget.tx;
//     return Padding(
//       padding: const EdgeInsets.only(top: 6, bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: onSurface.withValues(alpha: 0.04),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
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
//             const SizedBox(height: 22),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Text(
//                   _accountLabel(tx.account),
//                   style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
//                 ),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: _isDeleting ? null : _delete,
//                   icon: _isDeleting
//                       ? const SizedBox(
//                           width: 14, height: 14,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
//                         )
//                       : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
//                   label: Text(_isDeleting ? 'Removing…' : 'Delete', style: const TextStyle(color: Colors.red)),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






























// import 'package:expense_tracking/controllers/date_formatter_controller.dart';
// import 'package:expense_tracking/models/currency_model.dart';
// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/models/transaction_model.dart';

// enum _ActivityFilter { all, expenses, income }

// class ActivityScreen extends StatefulWidget {
//   const ActivityScreen({super.key});
//   @override
//   State<ActivityScreen> createState() => _ActivityScreenState();
// }

// class _ActivityScreenState extends State<ActivityScreen> {
//   TextEditingController searchTxt = TextEditingController();
//   _ActivityFilter _filter = _ActivityFilter.all;
//   String? _expandedTransactionId;

//   @override
//   void dispose() {
//     searchTxt.dispose();
//     super.dispose();
//   }

//   List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
//     final query = searchTxt.text.trim().toLowerCase();

//     return transactions.where((tx) {
//       final matchesFilter = switch (_filter) {
//         _ActivityFilter.all => true,
//         _ActivityFilter.expenses => tx.type == TransactionType.expense,
//         _ActivityFilter.income => tx.type == TransactionType.income,
//       };

//       final matchesSearch = query.isEmpty ||
//           tx.title.toLowerCase().contains(query) ||
//           tx.category.toLowerCase().contains(query);

//       return matchesFilter && matchesSearch;
//     }).toList();
//   }

//   void _toggleExpanded(String transactionId) {
//     setState(() {
//       _expandedTransactionId = _expandedTransactionId == transactionId ? null : transactionId;
//     });
//   }

//   void _collapse() {
//     if (_expandedTransactionId != null) {
//       setState(() => _expandedTransactionId = null);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allTransactions = context.watch<ExpensesController>().expensesNoPrivate;
//     final visibleTransactions = _applyFilters(allTransactions);

//     return Scaffold(
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _collapse,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: Column(
//                 spacing: 10,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Transaction",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onSurface,
//                       fontSize: 26,
//                     ),
//                   ),
//                   TextField(
//                     controller: searchTxt,
//                     onChanged: (_) => setState(() {}),
//                     decoration: InputDecoration(
//                       hintText: "Search merchant or category",
//                       hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 0.5),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     spacing: 4,
//                     children: [
//                       _filterChip("All", _ActivityFilter.all),
//                       _filterChip("Expenses", _ActivityFilter.expenses),
//                       _filterChip("Income", _ActivityFilter.income),
//                     ],
//                   ),
//                   if (visibleTransactions.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 24),
//                       child: Center(
//                         child: Text(
//                           "No transactions found",
//                           style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                         ),
//                       ),
//                     )
//                   else
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: context.appColors.cardsBackground,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: visibleTransactions.length,
//                           separatorBuilder: (context, index) => Divider(
//                             height: 1,
//                             thickness: 0.6,
//                             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
//                           ),
//                           itemBuilder: (context, index) => _TransactionTile(
//                             tx: visibleTransactions[index],
//                             isExpanded: _expandedTransactionId == visibleTransactions[index].id,
//                             onToggle: () => _toggleExpanded(visibleTransactions[index].id),
//                             onCollapse: _collapse,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _filterChip(String label, _ActivityFilter value) {
//     final isActive = _filter == value;
//     return OutlinedButton(
//       onPressed: () => setState(() => _filter = value),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: Colors.white,
//         backgroundColor: isActive ? const Color(0xFF1C6B47) : context.appColors.cardsBackground,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         side: BorderSide(
//           color: isActive ? const Color(0xFF1C6B47) : const Color.fromARGB(255, 225, 225, 225),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//           color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
//         ),
//       ),
//     );
//   }
// }

// class _TransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final VoidCallback onCollapse;

//   const _TransactionTile({
//     required this.tx,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.onCollapse,
//   });

//   @override
//   State<_TransactionTile> createState() => _TransactionTileState();
// }

// class _TransactionTileState extends State<_TransactionTile> {
//   bool _isDeleting = false;

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

//   Future<void> _delete() async {
//     if (_isDeleting) return;
//     setState(() => _isDeleting = true);

//     await context.read<ExpensesController>().hideExpense(widget.tx);

//     if (!mounted) return;
//     setState(() => _isDeleting = false);
//     widget.onCollapse();

//     context.read<NotifyingProvider>().showMessage('"${widget.tx.title}" removed');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tx = widget.tx;
//     final isExpense = tx.type == TransactionType.expense;
//     final sign = isExpense ? '-' : '+';
//     final color = isExpense ? Colors.red : Colors.green;
//     final onSurface = Theme.of(context).colorScheme.onSurface;

//     // The fix: each transaction shows the currency it was actually
//     // saved with (currencyForCode looks it up from tx.currencyCode),
//     // NOT the app's current live currency setting. This is what keeps
//     // old transactions locked to their original currency — changing
//     // the setting in the picker only affects transactions saved AFTER
//     // that change, via AddExpensesScreen's currencyCode capture.
//     final symbol = currencyForCode(tx.currencyCode).symbol;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(8),
//             onTap: widget.onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(
//                           isExpense ? Icons.arrow_upward : Icons.arrow_downward,
//                           color: color,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 tx.title,
//                                 style: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 '${tx.category} · ${formatTransactionDate(tx.date)}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 2),
//                   // Restored — sign AND currency symbol, both were
//                   // missing before (amount was showing as a bare
//                   // number with no +/-, no currency indicator at all).
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('$sign$symbol ', 
//                       style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 10),),
//                       Text(tx.amount.toStringAsFixed(2),
//                       style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 16),
//                   ),

//                     ],

//                   ),
//                   // Text(
//                   //   '$sign$symbol${tx.amount.toStringAsFixed(2)}',
//                   //   style: TextStyle(color: color, fontWeight: FontWeight.w500),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             child: widget.isExpanded ? _buildDetailPanel(onSurface, symbol) : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailPanel(Color onSurface, String symbol) {
//     final tx = widget.tx;
//     return Padding(
//       padding: const EdgeInsets.only(top: 6, bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: onSurface.withValues(alpha: 0.04),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
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
//             const SizedBox(height: 22),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Text(
//                   _accountLabel(tx.account),
//                   style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
//                 ),
//                 const Spacer(),               
               
//                 TextButton.icon(
//                   onPressed: _isDeleting ? null : _delete,
//                   icon: _isDeleting
//                       ? const SizedBox(
//                           width: 14, height: 14,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
//                         )
//                       : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
//                   label: Text(_isDeleting ? 'Removing…' : 'Delete', style: const TextStyle(color: Colors.red)),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }












// version 2

// import 'package:expense_tracking/controllers/date_formatter_controller.dart';
// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/repositories/currency_repository.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/models/transaction_model.dart';

// enum _ActivityFilter { all, expenses, income }

// class ActivityScreen extends StatefulWidget {
//   const ActivityScreen({super.key});
//   @override
//   State<ActivityScreen> createState() => _ActivityScreenState();
// }

// class _ActivityScreenState extends State<ActivityScreen> {
//   TextEditingController searchTxt = TextEditingController();
//   _ActivityFilter _filter = _ActivityFilter.all;
//   String? _expandedTransactionId;

//   @override
//   void dispose() {
//     searchTxt.dispose();
//     super.dispose();
//   }

//   List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
//     final query = searchTxt.text.trim().toLowerCase();

//     return transactions.where((tx) {
//       final matchesFilter = switch (_filter) {
//         _ActivityFilter.all => true,
//         _ActivityFilter.expenses => tx.type == TransactionType.expense,
//         _ActivityFilter.income => tx.type == TransactionType.income,
//       };

//       final matchesSearch = query.isEmpty ||
//           tx.title.toLowerCase().contains(query) ||
//           tx.category.toLowerCase().contains(query);

//       return matchesFilter && matchesSearch;
//     }).toList();
//   }

//   void _toggleExpanded(String transactionId) {
//     setState(() {
//       _expandedTransactionId = _expandedTransactionId == transactionId ? null : transactionId;
//     });
//   }

//   void _collapse() {
//     if (_expandedTransactionId != null) {
//       setState(() => _expandedTransactionId = null);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allTransactions = context.watch<ExpensesController>().expensesNoPrivate;
//     final visibleTransactions = _applyFilters(allTransactions);

//     return Scaffold(
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _collapse,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: Column(
//                 spacing: 10,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Transaction",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onSurface,
//                       fontSize: 26,
//                     ),
//                   ),
//                   TextField(
//                     controller: searchTxt,
//                     onChanged: (_) => setState(() {}),
//                     decoration: InputDecoration(
//                       hintText: "Search merchant or category",
//                       hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 0.5),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     spacing: 4,
//                     children: [
//                       _filterChip("All", _ActivityFilter.all),
//                       _filterChip("Expenses", _ActivityFilter.expenses),
//                       _filterChip("Income", _ActivityFilter.income),
//                     ],
//                   ),
//                   if (visibleTransactions.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 24),
//                       child: Center(
//                         child: Text(
//                           "No transactions found",
//                           style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                         ),
//                       ),
//                     )
//                   else
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: context.appColors.cardsBackground,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: visibleTransactions.length,
//                           separatorBuilder: (context, index) => Divider(
//                             height: 1,
//                             thickness: 0.6,
//                             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
//                           ),
//                           itemBuilder: (context, index) => _TransactionTile(
//                             tx: visibleTransactions[index],
//                             isExpanded: _expandedTransactionId == visibleTransactions[index].id,
//                             onToggle: () => _toggleExpanded(visibleTransactions[index].id),
//                             onCollapse: _collapse,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _filterChip(String label, _ActivityFilter value) {
//     final isActive = _filter == value;
//     return OutlinedButton(
//       onPressed: () => setState(() => _filter = value),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: Colors.white,
//         backgroundColor: isActive ? const Color(0xFF1C6B47) : context.appColors.cardsBackground,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         side: BorderSide(
//           color: isActive ? const Color(0xFF1C6B47) : const Color.fromARGB(255, 225, 225, 225),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//           color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
//         ),
//       ),
//     );
//   }
// }

// class _TransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final VoidCallback onCollapse;

//   const _TransactionTile({
//     required this.tx,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.onCollapse,
//   });

//   @override
//   State<_TransactionTile> createState() => _TransactionTileState();
// }

// class _TransactionTileState extends State<_TransactionTile> {
//   bool _isDeleting = false;

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

//   Future<void> _delete() async {
//     if (_isDeleting) return;
//     setState(() => _isDeleting = true);

//     await context.read<ExpensesController>().hideExpense(widget.tx);

//     if (!mounted) return;
//     setState(() => _isDeleting = false);
//     widget.onCollapse();

//     context.read<NotifyingProvider>().showMessage('"${widget.tx.title}" removed');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tx = widget.tx;
//     final isExpense = tx.type == TransactionType.expense;
//     final sign = isExpense ? '-' : '+';
//     final color = isExpense ? Colors.red : Colors.green;
//     final onSurface = Theme.of(context).colorScheme.onSurface;

//     // watch() so every row updates live the instant the currency
//     // preference changes, without needing to leave/re-enter this screen.
//     // This only changes the SYMBOL shown — the underlying stored amount
//     // is untouched, since real conversion is a separate future step.
//     final symbol = context.watch<CurrencyProvider>().selected.symbol;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(8),
//             onTap: widget.onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(
//                           isExpense ? Icons.arrow_upward : Icons.arrow_downward,
//                           color: color,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 tx.title,
//                                 style: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 '${tx.category} · ${formatTransactionDate(tx.date)}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 2),
//                   // Restored — sign AND currency symbol, both were
//                   // missing before (amount was showing as a bare
//                   // number with no +/-, no currency indicator at all).
//                   Row(children: [
//                     Text('$sign$symbol',
//                     style: TextStyle(color: color, fontWeight: FontWeight.w500 , fontSize: 12),),
//                     Text(tx.amount.toStringAsFixed(2),
//                     style: TextStyle(color: color, fontWeight: FontWeight.w500 , fontSize: 16),)
//                   ],),
//                   // Text(
//                   //   '$sign$symbol${tx.amount.toStringAsFixed(2)}',
//                   //   style: TextStyle(color: color, fontWeight: FontWeight.w500),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             child: widget.isExpanded ? _buildDetailPanel(onSurface, symbol) : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailPanel(Color onSurface, String symbol) {
//     final tx = widget.tx;
//     return Padding(
//       padding: const EdgeInsets.only(top: 6, bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: onSurface.withValues(alpha: 0.04),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),
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
//             const SizedBox(height: 22),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Text(
//                   _accountLabel(tx.account),
//                   style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
//                 ),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: _isDeleting ? null : _delete,
//                   icon: _isDeleting
//                       ? const SizedBox(
//                           width: 14, height: 14,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
//                         )
//                       : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
//                   label: Text(_isDeleting ? 'Removing…' : 'Delete', style: const TextStyle(color: Colors.red)),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




































//version 1111


// import 'package:expense_tracking/controllers/date_formatter_controller.dart';
// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/models/transaction_model.dart';

// enum _ActivityFilter { all, expenses, income }

// class ActivityScreen extends StatefulWidget {
//   const ActivityScreen({super.key});
//   @override
//   State<ActivityScreen> createState() => _ActivityScreenState();
// }

// class _ActivityScreenState extends State<ActivityScreen> {
//   TextEditingController searchTxt = TextEditingController();
//   _ActivityFilter _filter = _ActivityFilter.all;

//   // Single source of truth for "which transaction is expanded" — same
//   // pattern as Budget Planner's accordion. Only one id can ever be
//   // stored here, which is what makes "only one row open at a time"
//   // automatic rather than something each row has to coordinate.
//   String? _expandedTransactionId;

//   @override
//   void dispose() {
//     searchTxt.dispose();
//     super.dispose();
//   }

//   List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
//     final query = searchTxt.text.trim().toLowerCase();

//     return transactions.where((tx) {
//       final matchesFilter = switch (_filter) {
//         _ActivityFilter.all => true,
//         _ActivityFilter.expenses => tx.type == TransactionType.expense,
//         _ActivityFilter.income => tx.type == TransactionType.income,
//       };

//       final matchesSearch = query.isEmpty ||
//           tx.title.toLowerCase().contains(query) ||
//           tx.category.toLowerCase().contains(query);

//       return matchesFilter && matchesSearch;
//     }).toList();
//   }

//   void _toggleExpanded(String transactionId) {
//     setState(() {
//       _expandedTransactionId = _expandedTransactionId == transactionId ? null : transactionId;
//     });
//   }

//   void _collapse() {
//     if (_expandedTransactionId != null) {
//       setState(() => _expandedTransactionId = null);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allTransactions = context.watch<ExpensesController>().expensesNoPrivate;
//     final visibleTransactions = _applyFilters(allTransactions);

//     return Scaffold(
//       // Tapping anywhere that ISN'T a row's own InkWell collapses
//       // whichever row is currently expanded — this is the "tap outside
//       // the list to collapse" behavior. Inner InkWell taps (on a row
//       // itself) win the gesture arena over this outer GestureDetector,
//       // so they don't also trigger a collapse-then-reopen in the same tap.
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _collapse,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: Column(
//                 spacing: 10,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Transaction",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onSurface,
//                       fontSize: 26,
//                     ),
//                   ),
//                   TextField(
//                     controller: searchTxt,
//                     onChanged: (_) => setState(() {}),
//                     decoration: InputDecoration(
//                       hintText: "Search merchant or category",
//                       hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 0.5),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(Radius.circular(8)),
//                         borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1),
//                       ),
//                     ),
//                   ),
//                   Row(
//                     spacing: 4,
//                     children: [
//                       _filterChip("All", _ActivityFilter.all),
//                       _filterChip("Expenses", _ActivityFilter.expenses),
//                       _filterChip("Income", _ActivityFilter.income),
//                     ],
//                   ),
//                   if (visibleTransactions.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 24),
//                       child: Center(
//                         child: Text(
//                           "No transactions found",
//                           style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                         ),
//                       ),
//                     )
//                   else
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         color: context.appColors.cardsBackground,
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: visibleTransactions.length,
//                           // The requested line between items — a thin
//                           // Divider inserted between each row via
//                           // ListView.separated instead of a plain
//                           // ListView.builder.
//                           separatorBuilder: (context, index) => Divider(
//                             height: 1,
//                             thickness: 0.6,
//                             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
//                           ),
//                           itemBuilder: (context, index) => _TransactionTile(
//                             tx: visibleTransactions[index],
//                             isExpanded: _expandedTransactionId == visibleTransactions[index].id,
//                             onToggle: () => _toggleExpanded(visibleTransactions[index].id),
//                             onCollapse: _collapse,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _filterChip(String label, _ActivityFilter value) {
//     final isActive = _filter == value;
//     return OutlinedButton(
//       onPressed: () => setState(() => _filter = value),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: Colors.white,
//         backgroundColor: isActive ? const Color(0xFF1C6B47) : context.appColors.cardsBackground,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         minimumSize: Size.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         side: BorderSide(
//           color: isActive ? const Color(0xFF1C6B47) : const Color.fromARGB(255, 225, 225, 225),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//           color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
//         ),
//       ),
//     );
//   }
// }

// /// Own StatefulWidget mainly so the delete action can show its own
// /// brief loading state without touching the whole screen's layout.
// class _TransactionTile extends StatefulWidget {
//   final TransactionModel tx;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final VoidCallback onCollapse;

//   const _TransactionTile({
//     required this.tx,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.onCollapse,
//   });

//   @override
//   State<_TransactionTile> createState() => _TransactionTileState();
// }

// class _TransactionTileState extends State<_TransactionTile> {
//   bool _isDeleting = false;

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

//   Future<void> _delete() async {
//     if (_isDeleting) return;
//     setState(() => _isDeleting = true);

//     // Soft delete — moves this transaction out of every list/total
//     // immediately. A future History screen will offer Undo (unhide)
//     // or Permanent Delete, same pattern as Budget/Goal/Reminder history.
//     await context.read<ExpensesController>().hideExpense(widget.tx);

//     if (!mounted) return;
//     setState(() => _isDeleting = false);
//     widget.onCollapse();

//     context.read<NotifyingProvider>().showMessage('"${widget.tx.title}" removed');

//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   SnackBar(content: Text('"${widget.tx.title}" removed')),
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tx = widget.tx;
//     final isExpense = tx.type == TransactionType.expense;
//     final sign = isExpense ? '-' : '+';
//     final color = isExpense ? Colors.red : Colors.green;
//     final onSurface = Theme.of(context).colorScheme.onSurface;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(8),
//             onTap: widget.onToggle,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Icon(
//                           isExpense ? Icons.arrow_upward : Icons.arrow_downward,
//                           color: color,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 tx.title,
//                                 style: TextStyle(fontWeight: FontWeight.w500, color: onSurface),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 '${tx.category} · ${formatTransactionDate(tx.date)}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                 
//                   const SizedBox(width: 2,),
//                   Text(
//                      tx.amount.toStringAsFixed(2),
//                     // '$sign\$${tx.amount.toStringAsFixed(2)}',
//                     style: TextStyle(color: color, fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(width: 4),
//                   //  Icon(
//                   //   Icons. monetization_on,
//                   //   size: 14,
//                   //   color: Colors.greenAccent,
//                   // ),
//                   // Icon(
//                   //   widget.isExpanded ?Icons.payments_outlined: Icons.payments_outlined,
//                   //   size: 18,
//                   //   color: onSurface.withValues(alpha: 0.4),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//           AnimatedSize(
//             duration: const Duration(milliseconds: 180),
//             child: widget.isExpanded ? _buildDetailPanel(onSurface) : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailPanel(Color onSurface) {
//     final tx = widget.tx;
//     return Padding(
//       padding: const EdgeInsets.only(top: 6, bottom: 10),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: onSurface.withValues(alpha: 0.04),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
         
//             const SizedBox(height: 8),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.notes_rounded, size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 // Icon(Icons.receipt_long_outlined, size: 16, color: onSurface.withValues(alpha: 0.6)),
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
//             const SizedBox(height: 22),
//                Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(_accountIcon(tx.account), size: 16, color: onSurface.withValues(alpha: 0.6)),
//                 const SizedBox(width: 6),
//                 Text(
//                   _accountLabel(tx.account),
//                   style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.8)),
//                 ),
//                   const Spacer(),
//                 TextButton.icon(
                  
//                   onPressed: _isDeleting ? null : _delete,
//                   icon: _isDeleting
//                       ? const SizedBox(
//                           width: 14, height: 14,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
//                         )
//                       : const Icon(Icons.delete_outline, size: 18, color: Colors.red),
//                   label: Text(_isDeleting ? 'Removing…' : 'Delete', style: const TextStyle(color: Colors.red)),
//                 ),


//               ],
//             ),
            
//           ],
//         ),
//       ),
//     );
//   }
// }














