import 'package:expense_tracking/models/category_model.dart';
import 'package:expense_tracking/providers/category_provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/providers/reminder_provider.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



  Future<String?> _pickCategoryIcon(BuildContext context, {String? currentKey}) {
  return showDialog<String>(
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
                const Text('Choose an icon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categoryIconLibrary.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final entry = categoryIconLibrary.entries.elementAt(index);
                        final isSelected = entry.key == currentKey;
                        return InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () => Navigator.of(dialogContext).pop(entry.key),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1C6B47)
                                  : const Color(0xFF1C6B47).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              entry.value,
                              size: 20,
                              color: isSelected ? Colors.white : const Color(0xFF1C6B47),
                            ),
                          ),
                        );
                      },
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




class ManageCategoriesScreen extends StatefulWidget {
  final CategoryType type;
  const ManageCategoriesScreen({super.key, required this.type});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _newCategoryController = TextEditingController();
  final FocusNode _newCategoryFocusNode = FocusNode();
  bool _isAdding = false;


  //FOR ADDING CATEGORY
    String _selectedIconKey = 'category';

  @override
  void dispose() {
    _newCategoryController.dispose();
    _newCategoryFocusNode.dispose();
    super.dispose();
  }

  /// A MaterialBanner instead of a SnackBar — this is what actually
  /// makes the message appear at the TOP of the screen (right below the
  /// AppBar) rather than the bottom. Auto-dismisses after 2 seconds, but
  /// also offers a manual "OK" in case someone wants it gone sooner.

  void _throwMessageFromTop(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 14,
          left: 16,
          right: 16,
          child: Material(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                color: context.appColors.balanceCardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError
                        ? Colors.red
                        : context.appColors.balanceCardText,
                        
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isError
                            ? Colors.red
                            : context.appColors.balanceCardText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  ///ADDING CATEGORY IN THE SCREEN 
  ///
  Future<void> _pickIconForNewCategory() async {
    final key = await _pickCategoryIcon(context, currentKey: _selectedIconKey);
    if (key != null) setState(() => _selectedIconKey = key);
  }


  Future<void> _addCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isAdding = true);

    final added = await context.read<CategoryProvider>().addCategory(
      name,
      widget.type,
      iconKey: _selectedIconKey,
    );

    if (!mounted) return;
    setState(() => _isAdding = false);

    if (!added) {
      _throwMessageFromTop('"$name" already exists', isError: true);
      return;
    }

    _throwMessageFromTop('"$name" added');
    _newCategoryController.clear();
    // Straight back to the field so the next category can be typed
    // immediately, without tapping back into it — useful when adding
    // several in a row.
    setState(() => _selectedIconKey = 'category'); // reset for the next one
    _newCategoryFocusNode.requestFocus();
  }


    Future<void> _changeIcon(CategoryModel category) async {
    final key = await _pickCategoryIcon(context, currentKey: category.iconKey);
    if (key == null || !mounted) return;
    await context.read<CategoryProvider>().updateCategoryIcon(category.id, key);
    if (mounted) _throwMessageFromTop('Icon updated');
  }

  /// How many existing records already use this category — this is
  /// what turns the delete warning from generic into actually useful.
  /// Expense/income categories are checked against real transactions;
  /// reminder categories against both active and archived reminders.
  int _usageCount(CategoryModel category) {
    switch (widget.type) {
      case CategoryType.expense:
        return context
            .read<ExpensesController>()
            .expensesNoPrivate
            .where(
              (e) =>
                  e.type == TransactionType.expense &&
                  e.category == category.name,
            )
            .length;
      case CategoryType.income:
        return context
            .read<ExpensesController>()
            .expensesNoPrivate
            .where(
              (e) =>
                  e.type == TransactionType.income &&
                  e.category == category.name,
            )
            .length;
      case CategoryType.reminder:
        final reminders = context.read<ReminderProvider>();
        return [
          ...reminders.reminders,
          ...reminders.hiddenReminders,
        ].where((r) => r.category == category.name).length;
    }
  }

  /// Expense categories can also have a live Budget Planner entry tied
  /// to them (BudgetModel.category is a plain string, not a live
  /// reference) — worth calling out specifically since a budget silently
  /// surviving under a deleted category's name could be confusing later.
  bool _hasActiveBudget(CategoryModel category) {
    if (widget.type != CategoryType.expense) return false;
    return context.read<BudgetProvider>().budgets.any(
      (b) => b.category == category.name,
    );
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final usageCount = _usageCount(category);
    final hasBudget = _hasActiveBudget(category);

    final buffer = StringBuffer(
      '"${category.name}" will be removed from your category list.',
    );
    if (usageCount > 0) {
      buffer.write(
        ' $usageCount existing ${usageCount == 1 ? "entry" : "entries"} already '
        'use this category and will keep showing "${category.name}" — you just '
        "won't be able to pick it for new ones.",
      );
    }
    if (hasBudget) {
      buffer.write(
        ' Note: you also have a budget set for this category — deleting the '
        "category here won't remove that budget.",
      );
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete category?'),
        content: Text(buffer.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete Permanently',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<CategoryProvider>().deleteCategory(category.id);
      if (mounted) _throwMessageFromTop('"${category.name}" deleted');
    }
  }

  Future<void> _renameCategory(CategoryModel category) async {
    final controller = TextEditingController(text: category.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: controller, autofocus: true),
            const SizedBox(height: 10),
            const Text(
              'Existing entries using the old name will be updated to the new name too.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C6B47),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == category.name) return;
    if (!mounted) return;

    final renamed = await context.read<CategoryProvider>().renameCategory(
      category.id,
      category.name,
      newName,
      widget.type,
    );

    if (!mounted) return;
    if (!renamed) {
      _throwMessageFromTop('"$newName" already exists', isError: true);
    } else {
      _throwMessageFromTop('Renamed to "$newName"');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categoriesFor(
      widget.type,
    );
    final defaults = categories.where((c) => c.isDefault).toList();
    final custom = categories.where((c) => !c.isDefault).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      // MaterialBanner renders here automatically, docked at the top of
      // the Scaffold body just under the AppBar — no extra wiring needed.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'BUILT-IN',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Grid for built-ins — they're fixed, unchangeable,
                    // and there's usually only a handful, so a compact
                    // grid reads as "reference info" rather than a list
                    // of things you can act on (which the custom ones
                    // below actually are).
                    GridView.builder(                      
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: defaults.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 8,
                            childAspectRatio: .90,

                          ),
                      itemBuilder: (context, index) =>
                          _DefaultCategoryTile(category: defaults[index]),
                    ),
                    // const SizedBox(height: 0),
                    Text(
                      'YOUR CATEGORIES (${custom.length})',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (custom.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            "You haven't added any custom categories yet.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final category in custom) ...[
                        _CustomCategoryRow(
                          category: category,
                          onRename: () => _renameCategory(category),
                          onDelete: () => _confirmDelete(category),
                          onChangeIcon: () => _changeIcon(category),
                        ),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "ADD CATEGORY",
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _isAdding ? null : _pickIconForNewCategory,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C6B47).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(iconFromKey(_selectedIconKey), size: 20, color: const Color(0xFF1C6B47)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: _newCategoryController,
                      focusNode: _newCategoryFocusNode,
                      enabled: !_isAdding,
                      decoration: InputDecoration(
                        hintText: 'Pets / Travel ',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFDCE5DF),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFDCE5DF),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _addCategory(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isAdding ? null : _addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C6B47),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(66, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Add',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact tile for a built-in category — icon on top, name below,
/// centered. No edit/delete affordance since these can't be modified.
class _DefaultCategoryTile extends StatelessWidget {
  final CategoryModel category;
  const _DefaultCategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF1C6B47).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
           child: Icon(resolveCategoryIcon(category), size: 20, color:  context.appColors.balanceCardBackground.withValues(alpha: 0.5)),
  
          // child: Icon(
          //   iconForCategory(category.name),
          //   size: 20,
          //   color: context.appColors.balanceCardBackground,
          // ),
        ),
        const SizedBox(height: 6),
        Text(
          category.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Row card for a custom (user-added) category — this is the one that
/// still needs Edit/Delete, since only custom categories allow either.
class _CustomCategoryRow extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onChangeIcon;

  const _CustomCategoryRow({
    required this.category,
    required this.onRename,
    required this.onDelete,
     required this.onChangeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.appColors.balanceCardText,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1C6B47).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
             resolveCategoryIcon(category),
            // iconForCategory(category.name),
            size: 18,
            color: context.appColors.balanceCardBackground,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.greenAccent,
              ),
              onPressed: onRename,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
