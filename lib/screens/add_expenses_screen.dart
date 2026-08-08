import 'package:expense_tracking/widgets/add_expenses_widgets/expense_form.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/expense_income_switch.dart';
import 'package:expense_tracking/providers/transaction_provider.dart';
import 'package:expense_tracking/widgets/add_income_widgets/income_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreen();
}

class _AddExpensesScreen extends State<AddExpensesScreen> {
  // isExpense used to be a disconnected local field that never matched
  // what ExpenseIncomeSwitch actually showed. It's gone now — the single
  // source of truth is TransactionProvider.isExpense, read below.
  String amount = "0";

  // Two separate category selections, because expense categories
  // ("Food", "Transport"...) and income categories ("Salary", "Gift"...)
  // are completely different lists — keeping one shared variable would
  // let a leftover "Food" selection sneak into a saved income entry.
  String selectedCategory = "Food";
  String selectedIncomeCategory = "Salary";
  String selectedAccount = "Cash";

  TextEditingController titleController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  void _handleKeyPress(String key) {
    setState(() {
      if (key == "⌫") {
        if (amount.length > 1) {
          amount = amount.substring(0, amount.length - 1);
        } else {
          amount = "0";
        }
      } else if (key == ".") {
        if (!amount.contains(".")) {
          amount += ".";
        }
      } else {
        if (amount == "0") {
          amount = key;
        } else {
          amount += key;
        }
      }
    });
  }

  /// Maps the plain-text account label your UI uses ("Cash"/"Bank"/"Card")
  /// to the AccountType enum the model expects. Keeping this mapping in
  /// one place means your UI can stay simple strings while your data
  /// model stays type-safe.
  AccountType _accountFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'bank':
        return AccountType.bank;
      case 'card':
        return AccountType.card;
      default:
        return AccountType.cash;
    }
  }

  Future<void> _saveExpense() async {
    final parsedAmount = double.tryParse(amount) ?? 0;

    // Guard against saving a $0 transaction, e.g. if the user taps
    // Save Expense before entering anything on the number pad.
    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter an amount first")));
      return;
    }

    // read(), not watch() — we're inside a callback, not build(), so we
    // just need the current value once, not to rebuild on every toggle.
    final isExpense = context.read<TransactionProvider>().isExpense;

    // Pick the category from whichever list actually matches the
    // transaction type — this is the bug fix: previously this always
    // read selectedCategory, so an income entry could get saved with
    // a leftover expense category like "Food".
    final category = isExpense ? selectedCategory : selectedIncomeCategory;

    final transaction = TransactionModel(
      // Firestore generates the real id when addTransaction() runs —
      // this value is never actually sent, TransactionRepository ignores it.
      id: '',
      title: titleController.text.trim().isNotEmpty
          ? titleController.text.trim()
          : category,
      amount: parsedAmount,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      category: category,
      account: _accountFromLabel(selectedAccount),
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await context.read<ExpensesController>().addExpenses(transaction);

    // context used after an await — always re-check mounted first.
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isExpense ? "Expense Saved" : "Income Saved")),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // watch() here so this screen rebuilds and swaps the form the instant
    // the user taps the Expense/Income switch — same provider instance
    // ExpenseIncomeSwitch itself reads.
    final isExpense = context.watch<TransactionProvider>().isExpense;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 36,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Add Transaction",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const ExpenseIncomeSwitch(),
              const SizedBox(height: 8),
              Expanded(
                child: isExpense
                    ? ExpenseForm(
                        amount: amount,
                        onKeyPressed: _handleKeyPress,
                        noteController: titleController,
                        onSave: _saveExpense,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        selectedAccount: selectedAccount,
                        onAccountSelected: (account) {
                          setState(() {
                            selectedAccount = account;
                          });
                        },
                      )
                    : IncomeForm(
                        amount: amount,
                        onKeyPressed: _handleKeyPress,
                        noteController: titleController,
                        onSave: _saveExpense,
                        selectedCategory: selectedIncomeCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            selectedIncomeCategory = category;
                          });
                        },
                        selectedAccount: selectedAccount,
                        onAccountSelected: (account) {
                          setState(() {
                            selectedAccount = account;
                          });
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
