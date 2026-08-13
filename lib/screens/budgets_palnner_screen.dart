import 'package:expense_tracking/screens/budgets_history_screen.dart';
import 'package:expense_tracking/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/models/budgets_model.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/widgets/budget_period/budget_period.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/providers/category_provider.dart';
import 'package:expense_tracking/models/category_model.dart';


// Sentinel value used inside the category dropdown to represent the
// "+ Add new category" option, since dropdown items need a String value
// and no real category will ever equal this.
const String _addNewCategorySentinel = '__add_new_category__';

class BudgetPlannerScreen extends StatelessWidget {
  const BudgetPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>().budgets;
    final expensesController = context.watch<ExpensesController>();

    double totalSpent = 0;
    double totalTarget = 0;
    for (final budget in budgets) {
      totalSpent += expensesController.spentForCategorySince(
        budget.category,
        periodStartFor(budget.period),
      );
      totalTarget += budget.targetAmount;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Budget Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          // Entry point to the hidden/soft-deleted budgets — this IS
          // the "history" you asked for: nothing disappears immediately,
          // it just moves here until permanently deleted.
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Budget history',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BudgetHistoryScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C6B47),
        onPressed: () => _openBudgetDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1C6B47), const Color(0xFF2E8B63)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C6B47).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.savings_rounded, color: Colors.white70, size: 22),
                    const SizedBox(height: 8),
                    const Text(
                      'TOTAL BUDGET',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${totalSpent.toStringAsFixed(0)} / \$${totalTarget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (budgets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "No budgets set yet.\nTap + to add one.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              else
                for (final budget in budgets) ...[
                  _BudgetCard(
                    budget: budget,
                    spent: expensesController.spentForCategorySince(
                      budget.category,
                      periodStartFor(budget.period),
                    ),
                    onTap: () => _openBudgetDialog(context, existing: budget),
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          ),
        ),
      ),
    );
  }

  void _openBudgetDialog(BuildContext context, {BudgetModel? existing}) {
    showDialog(
      context: context,
      builder: (_) => _BudgetFormDialog(existing: existing),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final double spent;
  final VoidCallback onTap;

  const _BudgetCard({required this.budget, required this.spent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOverBudget = spent > budget.targetAmount;
    final progress = budget.targetAmount == 0 ? 0.0 : (spent / budget.targetAmount).clamp(0.0, 1.0);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Icon avatar matching the category — replaces
                      // any emoji shorthand with a proper Material icon.
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: (isOverBudget ? Colors.red : const Color(0xFF1C6B47))
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconForCategory(budget.category),
                          color: isOverBudget ? Colors.red : const Color(0xFF1C6B47),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Full name still shows here, just capped
                            // at one line — this is the actual fix:
                            // long category names truncate with an
                            // ellipsis instead of wrapping and breaking
                            // the card's layout.
                            Text(
                              budget.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              budget.period.label,
                              style: const TextStyle(fontSize: 11, color: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${spent.toStringAsFixed(0)} / \$${budget.targetAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? Colors.red : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: isOverBudget ? Colors.red : const Color(0xFF1C6B47),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetFormDialog extends StatefulWidget {
  final BudgetModel? existing;
  const _BudgetFormDialog({this.existing});

  @override
  State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<_BudgetFormDialog> {
  String? _selectedCategory;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  final TextEditingController _amountController = TextEditingController();

  // New: inline "add a category without leaving this dialog" state.
  bool _isAddingNewCategory = false;
  final TextEditingController _newCategoryController = TextEditingController();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _selectedCategory = widget.existing!.category;
      _selectedPeriod = widget.existing!.period;
      _amountController.text = widget.existing!.targetAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  /// Called when the user picks "+ Add new category" from the dropdown.
  /// Doesn't save anything yet — just reveals the inline text field.
  void _startAddingCategory() {
    setState(() {
      _isAddingNewCategory = true;
      _selectedCategory = null;
    });
  }

  /// Called when the user confirms the new category name. Saves it
  /// through CategoryProvider (same path ManageCategoriesScreen uses),
  /// then selects it immediately so they don't have to reopen the
  /// dropdown to pick what they just typed.
  Future<void> _confirmNewCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    final added = await context.read<CategoryProvider>().addCategory(name, CategoryType.expense);

    if (!mounted) return;

    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$name" already exists')),
      );
      return;
    }

    setState(() {
      _selectedCategory = name;
      _isAddingNewCategory = false;
      _newCategoryController.clear();
    });
  }

  Future<void> _save() async {
    final category = _selectedCategory;
    final amount = double.tryParse(_amountController.text.trim());

    if (category == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a category and enter a valid amount')),
      );
      return;
    }

    await context.read<BudgetProvider>().setBudget(category, amount, _selectedPeriod);
    if (mounted) Navigator.of(context).pop();
  }

  /// Soft delete now — this hides the budget rather than removing it.
  /// It reappears in Budget History, recoverable via "Unhide", until the
  /// user explicitly chooses "Delete Permanently" there.
  Future<void> _hide() async {
    if (widget.existing == null) return;
    await context.read<BudgetProvider>().hideBudget(widget.existing!.category);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories =
        context.watch<CategoryProvider>().categoriesFor(CategoryType.expense);

    final budgetedCategories =
        context.watch<BudgetProvider>().budgets.map((b) => b.category).toSet();
    final availableCategories = _isEditing
        ? expenseCategories
        : expenseCategories.where((c) => !budgetedCategories.contains(c.name)).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(_isEditing ? 'Edit Budget' : 'New Budget'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(iconForCategory(_selectedCategory ?? ''),
                        size: 18, color: const Color(0xFF1C6B47)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedCategory ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              DropdownButtonFormField<String>(
                initialValue: _isAddingNewCategory ? null : _selectedCategory,
                // The actual fix: without isExpanded, the dropdown sizes
                // itself to its intrinsic content width, which is what
                // was clipping longer category names. isExpanded: true
                // makes it fill the available row width instead, so the
                // full name always has room to render.
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final category in availableCategories)
                    DropdownMenuItem(
                      value: category.name,
                      child: Row(
                        children: [
                          Icon(iconForCategory(category.name), size: 18, color: const Color(0xFF1C6B47)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const DropdownMenuItem(
                    value: _addNewCategorySentinel,
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF1C6B47)),
                        SizedBox(width: 10),
                        Text('Add new category', style: TextStyle(color: Color(0xFF1C6B47))),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == _addNewCategorySentinel) {
                    _startAddingCategory();
                  } else {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              if (_isAddingNewCategory) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCategoryController,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'e.g. Pets'),
                        onSubmitted: (_) => _confirmNewCategory(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Color(0xFF1C6B47)),
                      onPressed: _confirmNewCategory,
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Budget amount'),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Resets', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ),
            const SizedBox(height: 6),
            SegmentedButton<BudgetPeriod>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: const Color(0xFF1C6B47),
                selectedForegroundColor: Colors.white,
                foregroundColor: const Color(0xFF1C6B47),
              ),
              segments: const [
                ButtonSegment(value: BudgetPeriod.weekly, label: Text('Weekly')),
                ButtonSegment(value: BudgetPeriod.monthly, label: Text('Monthly')),
                ButtonSegment(value: BudgetPeriod.yearly, label: Text('Yearly')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (selection) =>
                  setState(() => _selectedPeriod = selection.first),
            ),
          ],
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: _hide,
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C6B47)),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}






















// import 'package:expense_tracking/screens/budgets_history_screen.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/models/budgets_model.dart';
// import 'package:expense_tracking/providers/budgets_provider.dart';
// import 'package:expense_tracking/widgets/budget_period/budget_period.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/providers/category_provider.dart';
// import 'package:expense_tracking/models/category_model.dart';

// // Sentinel value used inside the category dropdown to represent the
// // "+ Add new category" option, since dropdown items need a String value
// // and no real category will ever equal this.
// const String _addNewCategorySentinel = '__add_new_category__';

// class BudgetPlannerScreen extends StatelessWidget {
//   const BudgetPlannerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final budgets = context.watch<BudgetProvider>().budgets;
//     final expensesController = context.watch<ExpensesController>();

//     double totalSpent = 0;
//     double totalTarget = 0;
//     for (final budget in budgets) {
//       totalSpent += expensesController.spentForCategorySince(
//         budget.category,
//         periodStartFor(budget.period),
//       );
//       totalTarget += budget.targetAmount;
//     }

//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text('Budget Planner', style: TextStyle(fontWeight: FontWeight.bold)),
//         elevation: 0,
//         actions: [
//           // Entry point to the hidden/soft-deleted budgets — this IS
//           // the "history" you asked for: nothing disappears immediately,
//           // it just moves here until permanently deleted.
//           IconButton(
//             icon: const Icon(Icons.history),
//             tooltip: 'Budget history',
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(builder: (_) => const BudgetHistoryScreen()),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: colorScheme.primary,
//         onPressed: () => _openBudgetDialog(context),
//         child: Icon(Icons.add, color: colorScheme.onPrimary),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//                 decoration: BoxDecoration(
//                   color: context.appColors.cardsBackground,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'TOTAL BUDGET',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black54,
//                         letterSpacing: 0.6,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       '\$${totalSpent.toStringAsFixed(0)} / \$${totalTarget.toStringAsFixed(0)}',
//                       style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (budgets.isEmpty)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 40),
//                   child: Center(
//                     child: Text(
//                       "No budgets set yet.\nTap + to add one.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.black54),
//                     ),
//                   ),
//                 )
//               else
//                 for (final budget in budgets) ...[
//                   _BudgetCard(
//                     budget: budget,
//                     spent: expensesController.spentForCategorySince(
//                       budget.category,
//                       periodStartFor(budget.period),
//                     ),
//                     onTap: () => _openBudgetDialog(context, existing: budget),
//                   ),
//                   const SizedBox(height: 14),
//                 ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _openBudgetDialog(BuildContext context, {BudgetModel? existing}) {
//     showDialog(
//       context: context,
//       builder: (_) => _BudgetFormDialog(existing: existing),
//     );
//   }
// }

// class _BudgetCard extends StatelessWidget {
//   final BudgetModel budget;
//   final double spent;
//   final VoidCallback onTap;

//   const _BudgetCard({required this.budget, required this.spent, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final isOverBudget = spent > budget.targetAmount;
//     final progress = budget.targetAmount == 0 ? 0.0 : (spent / budget.targetAmount).clamp(0.0, 1.0);

//     return InkWell(
//       borderRadius: BorderRadius.circular(14),
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: context.appColors.cardsBackground,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Expanded so a long category name truncates instead of
//                 // pushing the amount text off the right edge.
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         budget.category,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                       ),
//                       Text(
//                         budget.period.label,
//                         style: const TextStyle(fontSize: 11, color: Colors.black45),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '\$${spent.toStringAsFixed(0)} / \$${budget.targetAmount.toStringAsFixed(0)}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: isOverBudget ? colorScheme.error : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 minHeight: 8,
//                 value: progress,
//                 backgroundColor: Colors.grey.shade300,
//                 color: isOverBudget ? colorScheme.error : colorScheme.primary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _BudgetFormDialog extends StatefulWidget {
//   final BudgetModel? existing;
//   const _BudgetFormDialog({this.existing});

//   @override
//   State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
// }

// class _BudgetFormDialogState extends State<_BudgetFormDialog> {
//   String? _selectedCategory;
//   BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
//   final TextEditingController _amountController = TextEditingController();

//   // Inline "add a category without leaving this dialog" state.
//   bool _isAddingNewCategory = false;
//   final TextEditingController _newCategoryController = TextEditingController();

//   bool get _isEditing => widget.existing != null;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.existing != null) {
//       _selectedCategory = widget.existing!.category;
//       _selectedPeriod = widget.existing!.period;
//       _amountController.text = widget.existing!.targetAmount.toStringAsFixed(0);
//     }
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _newCategoryController.dispose();
//     super.dispose();
//   }

//   /// Called when the user picks "+ Add new category" from the dropdown.
//   /// Doesn't save anything yet — just reveals the inline text field.
//   void _startAddingCategory() {
//     setState(() {
//       _isAddingNewCategory = true;
//       _selectedCategory = null;
//     });
//   }

//   /// Called when the user picks a REAL category from the dropdown while
//   /// still in "adding" mode (e.g. they opened the add-category field,
//   /// typed nothing, then just picked an existing category instead).
//   /// This is the path that used to desync the dropdown's internal state
//   /// from ours and crash — now it cleanly exits "adding" mode too.
//   void _selectExistingCategory(String value) {
//     setState(() {
//       _selectedCategory = value;
//       _isAddingNewCategory = false;
//       _newCategoryController.clear();
//     });
//   }

//   /// Called when the user confirms the new category name. Saves it
//   /// through CategoryProvider (same path ManageCategoriesScreen uses),
//   /// then selects it immediately so they don't have to reopen the
//   /// dropdown to pick what they just typed.
//   Future<void> _confirmNewCategory() async {
//     final name = _newCategoryController.text.trim();
//     if (name.isEmpty) return;

//     final added = await context.read<CategoryProvider>().addCategory(name, CategoryType.expense);

//     if (!mounted) return;

//     if (!added) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('"$name" already exists')),
//       );
//       return;
//     }

//     setState(() {
//       _selectedCategory = name;
//       _isAddingNewCategory = false;
//       _newCategoryController.clear();
//     });
//   }

//   Future<void> _save() async {
//     final category = _selectedCategory;
//     final amount = double.tryParse(_amountController.text.trim());

//     if (category == null || amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Pick a category and enter a valid amount')),
//       );
//       return;
//     }

//     await context.read<BudgetProvider>().setBudget(category, amount, _selectedPeriod);
//     if (mounted) Navigator.of(context).pop();
//   }

//   /// Soft delete now — this hides the budget rather than removing it.
//   /// It reappears in Budget History, recoverable via "Unhide", until the
//   /// user explicitly chooses "Delete Permanently" there.
//   Future<void> _hide() async {
//     if (widget.existing == null) return;
//     await context.read<BudgetProvider>().hideBudget(widget.existing!.category);
//     if (mounted) Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     final expenseCategories =
//         context.watch<CategoryProvider>().categoriesFor(CategoryType.expense);

//     final budgetedCategories =
//         context.watch<BudgetProvider>().budgets.map((b) => b.category).toSet();
//     final availableCategories = _isEditing
//         ? expenseCategories
//         : expenseCategories.where((c) => !budgetedCategories.contains(c.name)).toList();

//     return AlertDialog(
//       title: Text(_isEditing ? 'Edit Budget' : 'New Budget'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (_isEditing)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: Text(
//                   _selectedCategory ?? '',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//               )
//             else ...[
//               DropdownButtonFormField<String>(
//                 // Keying this on the state that used to get out of sync
//                 // with the dropdown's own internal selection forces Flutter
//                 // to fully remount the field (re-reading initialValue)
//                 // whenever we change mode, instead of trusting stale
//                 // internal state left over from a previous selection.
//                 // That stale internal state is what was throwing the
//                 // "exactly one item with [DropdownButton]'s value" crash.
//                 key: ValueKey('category-dropdown-$_isAddingNewCategory-$_selectedCategory'),
//                 initialValue: _isAddingNewCategory ? null : _selectedCategory,
//                 isExpanded: true, // lets long names ellipsize instead of overflowing
//                 decoration: const InputDecoration(labelText: 'Category'),
//                 items: [
//                   for (final category in availableCategories)
//                     DropdownMenuItem(
//                       value: category.name,
//                       child: Text(
//                         category.name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   DropdownMenuItem(
//                     value: _addNewCategorySentinel,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.add, size: 18, color: colorScheme.primary),
//                         const SizedBox(width: 6),
//                         Text('Add new category', style: TextStyle(color: colorScheme.primary)),
//                       ],
//                     ),
//                   ),
//                 ],
//                 onChanged: (value) {
//                   if (value == _addNewCategorySentinel) {
//                     _startAddingCategory();
//                   } else if (value != null) {
//                     _selectExistingCategory(value);
//                   }
//                 },
//               ),
//               if (_isAddingNewCategory) ...[
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _newCategoryController,
//                         autofocus: true,
//                         decoration: const InputDecoration(hintText: 'e.g. Pets'),
//                         onSubmitted: (_) => _confirmNewCategory(),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed: _confirmNewCategory,
//                       style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
//                       child: const Text('Add'),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//             const SizedBox(height: 12),
//             TextField(
//               controller: _amountController,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(labelText: 'Budget amount'),
//             ),
//             const SizedBox(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Resets', style: TextStyle(fontSize: 12, color: Colors.black54)),
//             ),
//             const SizedBox(height: 6),
//             SegmentedButton<BudgetPeriod>(
//               segments: const [
//                 ButtonSegment(value: BudgetPeriod.weekly, label: Text('Weekly')),
//                 ButtonSegment(value: BudgetPeriod.monthly, label: Text('Monthly')),
//                 ButtonSegment(value: BudgetPeriod.yearly, label: Text('Yearly')),
//               ],
//               selected: {_selectedPeriod},
//               onSelectionChanged: (selection) =>
//                   setState(() => _selectedPeriod = selection.first),
//               style: SegmentedButton.styleFrom(
//                 selectedBackgroundColor: colorScheme.primary,
//                 selectedForegroundColor: colorScheme.onPrimary,
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         if (_isEditing)
//           TextButton(
//             onPressed: _hide,
//             style: TextButton.styleFrom(foregroundColor: colorScheme.error),
//             child: const Text('Delete'),
//           ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _save,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: colorScheme.primary,
//             foregroundColor: colorScheme.onPrimary,
//           ),
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }