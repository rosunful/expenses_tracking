import 'package:expense_tracking/models/category_model.dart';
import 'package:flutter/material.dart';
import 'category_chip_picker.dart';


class IncomeCategorySection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const IncomeCategorySection({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryChipPicker(
      type: CategoryType.income,
      selectedCategory: selectedCategory,
      onSelected: onSelected,
    );
  }
}