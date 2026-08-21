import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/expense_form.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/expense_income_switch.dart';
import 'package:expense_tracking/providers/transaction_provider.dart';
import 'package:expense_tracking/widgets/add_income_widgets/income_form.dart';
import 'package:expense_tracking/screens/currency_selection_screen.dart';
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

  TextEditingController noteController = TextEditingController();

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
    if (_isSaving) return;

    final parsedAmount = double.tryParse(amount) ?? 0;
    if (parsedAmount <= 0) {
      context.read<NotifyingProvider>().showMessage("Enter an amount first");
      return;
    }

    setState(() => _isSaving = true);

    final isExpense = context.read<TransactionProvider>().isExpense;
    final category = isExpense ? selectedCategory : selectedIncomeCategory;

    final transaction = TransactionModel(
      id: '',
      title: category,
      amount: parsedAmount,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      category: category,
      account: _accountFromLabel(selectedAccount),
      note: noteController.text.trim(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
   
      currencyCode: context.read<CurrencyProvider>().selected.code,
    );

    try {
      await context.read<ExpensesController>().addExpenses(transaction);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.read<NotifyingProvider>().showMessage("Couldn't save — please try again");
      }
      return;
    }

    if (!mounted) return;

    context.read<NotifyingProvider>().showMessage(isExpense ? "Expense Saved" : "Income Saved");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = context.watch<TransactionProvider>().isExpense;

    final currencyCode = context.watch<CurrencyProvider>().selected.code;

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 28, height: 36),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Add Transaction",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
  
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.appColors.cardsBackground,
                        border: Border.all(
                          color: Colors.black54,
                          width: 0.9,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currencyCode,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.expand_more_rounded, size: 16),
                        ],
                      ),
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
                        noteController: noteController,
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
                        noteController: noteController,
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




