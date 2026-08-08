import 'package:expense_tracking/models/category_model.dart';
import 'package:expense_tracking/providers/category_provider.dart';
import 'package:expense_tracking/screens/manage_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shared by CategorySection (expense) and IncomeCategorySection (income) —
/// both needed identical chip/limit/"more"/"+ New" behavior, just for a
/// different CategoryType. Rather than duplicate this logic twice, both
/// thin wrapper widgets delegate to this one.
class CategoryChipPicker extends StatelessWidget {
  final CategoryType type;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  /// How many chips to show before collapsing the rest behind "More".
  /// There's no reliable way to measure "exactly two rows" without
  /// knowing chip widths ahead of time, so this is a tuned approximation —
  /// adjust up/down if it looks off on your actual device/screen size.
  static const int _maxVisibleChips = 7;

  const CategoryChipPicker({
    super.key,
    required this.type,
    required this.selectedCategory,
    required this.onSelected,
  });

  void _openManageCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ManageCategoriesScreen(type: type)),
    );
  }

  /// "More" opens a bottom sheet showing every category as a scrollable
  /// wrap — for SELECTING one, as opposed to Manage Categories, which is
  /// for ADDING/DELETING. Tapping a chip here both selects it and closes
  /// the sheet.
  void _openAllCategoriesSheet(BuildContext context, List<CategoryModel> all) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in all)
                _chip(category.name, category.name == selectedCategory, () {
                  onSelected(category.name);
                  Navigator.of(sheetContext).pop();
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = context.watch<CategoryProvider>().categoriesFor(type);
    final hasMore = allCategories.length > _maxVisibleChips;
    final visibleCategories = hasMore
        ? allCategories.take(_maxVisibleChips).toList()
        : allCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "CATEGORY",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.7,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in visibleCategories)
              _chip(
                category.name,
                category.name == selectedCategory,
                () => onSelected(category.name),
              ),
            if (hasMore)
              _chip(
                'More',
                false,
                () => _openAllCategoriesSheet(context, allCategories),
              ),
            _chip('+ New', false, () => _openManageCategories(context)),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C6B47) : const Color(0xffE9EEEA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
