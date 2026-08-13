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

  /// "More" opens a centered dialog showing every category as a
  /// scrollable wrap — for SELECTING one, as opposed to Manage
  /// Categories, which is for ADDING/DELETING. Tapping a chip here both
  /// selects it and closes the dialog.
  ///
  /// A dialog instead of a bottom sheet: bottom sheets size themselves
  /// to their content by default with no height cap, so a long list of
  /// categories could extend past the visible screen with nothing to
  /// scroll it into view. Capping this dialog's height and wrapping the
  /// Wrap in a SingleChildScrollView means it never gets cut off — it
  /// just scrolls internally instead.
  void _openAllCategoriesSheet(BuildContext context, List<CategoryModel> all) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.6,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All categories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      _chip2('+ Add New', false, () {
                        Navigator.of(dialogContext).pop();
                        _openManageCategories(context);
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final category in all)
                            _chip(
                              category.name,
                              category.name == selectedCategory,
                              () {
                                onSelected(category.name);
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "CATEGORY",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface ,
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
            // "More" now visually distinct from a regular category chip
            // — outlined instead of filled, with an icon, so it reads
            // as an action rather than another option in the list.
            if (hasMore) _moreChip(context, allCategories),
           
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

   Widget _chip2(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color.fromARGB(164, 220, 220, 220),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 0.1,
            color: Colors.black,
            style: BorderStyle.solid
          )     
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Deliberately different from _chip's filled style — an outlined
  /// pill with a small icon, so "there are more options hiding here"
  /// reads as its own kind of control rather than blending in with the
  /// actual category choices.
  Widget _moreChip(BuildContext context, List<CategoryModel> all) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openAllCategoriesSheet(context, all),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color.fromARGB(98, 171, 210, 193), width: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.expand_more_rounded, size: 14, color: Color.fromARGB(182, 33, 113, 77)),
            const SizedBox(width: 3),
            Text(
              'More',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
