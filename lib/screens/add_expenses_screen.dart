import 'package:expense_tracking/providers/notifying_provider.dart';
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
  String amount = "0";
  String selectedCategory = "Food";
  String selectedIncomeCategory = "Salary";
  String selectedAccount = "Cash";

  TextEditingController titleController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  // The actual fix: blocks a second _saveExpense() call from doing
  // anything while the first one is still in flight. Without this,
  // a fast double-tap runs the whole async function twice — two
  // transactions get saved, and the screen gets popped twice, which
  // crashes since the second pop() has nothing left to pop.
  bool _isSaving = false;

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
    // Guard checked FIRST and synchronously — if a save is already
    // running, every subsequent call (from extra taps) exits here
    // immediately, before touching Firestore or the navigator at all.
    if (_isSaving) return;

    final parsedAmount = double.tryParse(amount) ?? 0;
    if (parsedAmount <= 0) {
      context.read<NotifyingProvider>().showMessage(
        "Enter an amount first",
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    final isExpense = context.read<TransactionProvider>().isExpense;
    final category = isExpense ? selectedCategory : selectedIncomeCategory;

    final transaction = TransactionModel(
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

    try {
      await context.read<ExpensesController>().addExpenses(transaction);
    } catch (e) {
      // Something actually failed (e.g. no network) — reset the guard
      // so the user can retry, instead of the button staying stuck
      // disabled forever.
      if (mounted) {
        setState(() => _isSaving = false);
        context.read<NotifyingProvider>().showMessage(
          "Couldn't save. Please try again.",
          isError: true,
        );
      }
      return;
    }

    if (!mounted) return;

    context.read<NotifyingProvider>().showMessage(
      isExpense ? "Expense Saved" : "Income Saved",
    );
    // No need to reset _isSaving here — pop() removes this screen
    // entirely, so there's no button left to re-enable.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = context.watch<TransactionProvider>().isExpense;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
                  Text(
                    "Add Transaction",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                        onSave: _isSaving ? () {} : _saveExpense,
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
                        onSave: _isSaving ? () {} : _saveExpense,
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












