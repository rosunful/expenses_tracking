import 'package:expense_tracking/widgets/add_expenses_widgets/account_section.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/amount_display.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/note_field.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/number_pad.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/save_button.dart';
import 'package:expense_tracking/widgets/add_income_widgets/income_category_section.dart';
import 'package:flutter/material.dart';

/// Same shape as ExpenseForm — amount, category, account, note, number pad,
/// save button — just using IncomeCategorySection instead of the expense
/// category chips, and labeled for income.
class IncomeForm extends StatelessWidget {
  final String amount;
  final Function(String) onKeyPressed;
  final TextEditingController noteController;
  final VoidCallback onSave;

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  final String selectedAccount;
  final ValueChanged<String> onAccountSelected;

  const IncomeForm({
    super.key,
    required this.amount,
    required this.onKeyPressed,
    required this.noteController,
    required this.onSave,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedAccount,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: AmountDisplay(amount: amount)),
            const SizedBox(height: 22),
            IncomeCategorySection(
              selectedCategory: selectedCategory,
              onSelected: onCategorySelected,
            ),
            const SizedBox(height: 18),
            AccountSection(
              selectedAccount: selectedAccount,
              onSelected: onAccountSelected,
            ),
            const SizedBox(height: 18),
            NoteField(controller: noteController),
            const SizedBox(height: 18),
            NumberPad(onKeyPressed: onKeyPressed),
            const SizedBox(height: 18),
            SaveButton(isExpense: false, onPressed: onSave),
          ],
        ),
      ),
    );
  }
}
