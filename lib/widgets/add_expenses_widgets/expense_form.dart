import 'package:expense_tracking/widgets/add_expenses_widgets/number_pad.dart';
import 'package:flutter/material.dart';
import 'account_section.dart';
import 'amount_display.dart';
import 'category_section.dart';
import 'note_field.dart';
import 'save_button.dart';

class ExpenseForm extends StatelessWidget {
  final String amount;
  final Function(String) onKeyPressed;
  final TextEditingController noteController;
  final VoidCallback onSave;

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  final String selectedAccount;
  final ValueChanged<String> onAccountSelected;

  const ExpenseForm({
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
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: AmountDisplay(amount: amount)),

          const SizedBox(height: 22),

          CategorySection(
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

          SaveButton(isExpense: true, onPressed: onSave),
        ],
      ),
    );
  }
}
