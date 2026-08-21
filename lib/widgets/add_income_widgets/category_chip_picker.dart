import 'package:expense_tracking/models/category_model.dart';
import 'package:expense_tracking/providers/category_provider.dart';
import 'package:expense_tracking/screens/manage_category_screen.dart';
import 'package:expense_tracking/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CategoryChipPicker extends StatelessWidget {
  final CategoryType type;
  final String selectedCategory;
  final ValueChanged<String> onSelected;
  static const int _maxVisibleCustomChips = 0;
  static const double _maxChipWidth = 150;

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

  void _openAllCategoriesSheet(BuildContext context, List<CategoryModel> all) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(dialogContext).size.height * 0.6),
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
                      _actionChip('+ Add New', () {
                        Navigator.of(dialogContext).pop();
                        _openManageCategories(context);
                      }),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: all.isEmpty
                          // Nothing to browse yet — say so plainly instead
                          // of showing an empty Wrap, since "More" is now
                          // reachable even before any categories exist.
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'No categories yet — tap "+ Add New" to create one.',
                                style: TextStyle(fontSize: 12, color: Colors.black45),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final category in all)
                                  _categoryChip(category, category.name == selectedCategory, () {
                                    onSelected(category.name);
                                    Navigator.of(dialogContext).pop();
                                  }),
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
    final defaults = allCategories.where((c) => c.isDefault).toList();
    final customs = allCategories.where((c) => !c.isDefault).toList();

    final hasMoreCustoms = customs.length > _maxVisibleCustomChips;

    List<CategoryModel> visibleCustoms;
    if (!hasMoreCustoms) {
      visibleCustoms = customs;
    } else {
      // If the selected category is a custom one that would otherwise
      // be hidden, pin it into the visible slice — appended right
      // after the built-ins, not shuffled ahead of them.
      final selectedCustomMatch = customs.where((c) => c.name == selectedCategory);
      if (selectedCustomMatch.isNotEmpty) {
        final selected = selectedCustomMatch.first;
        final others = customs
            .where((c) => c.name != selected.name)
            .take(_maxVisibleCustomChips)
            .toList();
        visibleCustoms = [selected, ...others];
      } else {
        visibleCustoms = customs.take(_maxVisibleCustomChips).toList();
      }
    }

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
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.7,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Built-ins first, always all of them, always this order.
            for (final category in defaults)
              _categoryChip(category, category.name == selectedCategory, () => onSelected(category.name)),
            // Then a capped set of custom categories, right after.
            for (final category in visibleCustoms)
              _categoryChip(category, category.name == selectedCategory, () => onSelected(category.name)),
          
            _moreChip(context, allCategories),
          ],
        ),
      ],
    );
  }


  Widget _categoryChip(CategoryModel category, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxChipWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C6B47) : const Color(0xffE9EEEA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                resolveCategoryIcon(category),
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF1C6B47),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionChip(String label, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xffE9EEEA),
          border: Border.all(color: const Color.fromARGB(98, 171, 210, 193), width: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black),
        ),
      ),
    );
  }

  Widget _moreChip(BuildContext context, List<CategoryModel> all) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openAllCategoriesSheet(context, all),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xffE9EEEA),
          border: Border.all(color: const Color.fromARGB(98, 171, 210, 193), width: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.expand_more_rounded, size: 14, color: Color.fromARGB(182, 33, 113, 77)),
            SizedBox(width: 3),
            Text('More', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}




