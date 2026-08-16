import 'package:expense_tracking/controllers/date_formatter_controller.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/models/transaction_model.dart';

/// Which chip is currently selected — replaces the three onPressed: () {}
/// placeholders that didn't do anything before.
enum _ActivityFilter { all, expenses, income }

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  TextEditingController searchTxt = TextEditingController();
  _ActivityFilter _filter = _ActivityFilter.all;

  @override
  void dispose() {
    searchTxt.dispose();
    super.dispose();
  }

  /// Applies both the search box and the chip filter together.
  /// Runs on every build, which is fine for a personal expense list —
  /// this isn't the kind of list that grows into the thousands.
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

  @override
  Widget build(BuildContext context) {
    // watch() so this screen rebuilds live whenever Firestore pushes
    // a new/changed transaction through ExpensesController.
    final allTransactions = context.watch<ExpensesController>().expensesNoPrivate;
    final visibleTransactions = _applyFilters(allTransactions);

    return Scaffold(      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Transaction",
                  style: TextStyle(fontWeight: FontWeight.bold, color:Theme.of(context).colorScheme.onSurface , fontSize: 26),
                ),
                TextField(
                  controller: searchTxt,
                  // setState on every keystroke so _applyFilters re-runs live.
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search merchant or category",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color:Theme.of(context).colorScheme.onSurface, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color:Theme.of(context).colorScheme.onSurface, width: 1),
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
                        style: TextStyle(color:Theme.of(context).colorScheme.onSurface),
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
                      padding: const EdgeInsets.all(10.0),
                      // Eagerly building every transaction row inside a Column creates a
                    // widget for every entry on every rebuild, which is what
                    // makes this list chug as the history grows. ListView.
                    // builder only builds the handful of rows actually on
                    // screen.
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleTransactions.length,
                      itemBuilder: (context, index) =>
                          _transactionTile(visibleTransactions[index]),
                    ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One chip. Active state uses the same green/white style your
  /// original hardcoded "All" chip had; inactive chips get the
  /// grey/black style your "Expenses"/"Income" chips had.
  Widget _filterChip(String label, _ActivityFilter value) {
    final isActive = _filter == value;
    return OutlinedButton(
      onPressed: () => setState(() => _filter = value),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isActive
            ? const Color(0xFF1C6B47)
            : context.appColors.cardsBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: isActive
              ? const Color(0xFF1C6B47)
              : const Color.fromARGB(255, 225, 225, 225),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurface
        ),
      ),
    );
  }

  /// One row for one real transaction, replacing the 4 copy-pasted
  /// hardcoded "Whole Foods Market" rows.
  Widget _transactionTile(TransactionModel tx) {
    final isExpense = tx.type == TransactionType.expense;
    final sign = isExpense ? '-' : '+';
    final color = isExpense ? Colors.red : Colors.green;

    return Padding(
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
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${tx.category} · ${formatTransactionDate(tx.date)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign\$${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

