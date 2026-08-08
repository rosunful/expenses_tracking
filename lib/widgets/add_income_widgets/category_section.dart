import 'package:expense_tracking/models/category_model.dart';
import 'package:flutter/material.dart';
import 'category_chip_picker.dart';

/// Kept as its own small widget so ExpenseForm's existing
/// CategorySection(...) call site doesn't need to change at all —
/// all the real logic now lives in CategoryChipPicker.
class CategorySection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySection({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryChipPicker(
      type: CategoryType.expense,
      selectedCategory: selectedCategory,
      onSelected: onSelected,
    );
  }
}