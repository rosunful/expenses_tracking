import 'package:expense_tracking/widgets/add_expenses_widgets/expense_form.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/expense_income_switch.dart';
import 'package:flutter/material.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreen();
}

class _AddExpensesScreen extends State<AddExpensesScreen> {
  String amount = "0";
  bool isExpense = true;

  String selectedCategory = "Food";
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

  void _saveExpense() {
    debugPrint("Amount : $amount");
    debugPrint("Note : ${titleController.text}");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Expense Saved")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 10,
          children: [
            Row(
              spacing: 10,
              children: [
                Expanded(flex: 1, child: InkWell(child: Icon(Icons.back_hand))),

                Expanded(flex: 9, child: Text("Transaction")),
              ],
            ),

            const ExpenseIncomeSwitch(),

            const SizedBox(height: 30),

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
                  : const Center(
                      child: Text(
                        "Income Screen",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
