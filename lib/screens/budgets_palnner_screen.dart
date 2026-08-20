import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/screens/budgets_history_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/models/budgets_model.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/controllers/budget_period_controller.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/providers/category_provider.dart';
import 'package:expense_tracking/models/category_model.dart';

const String _addNewCategorySentinel = '__add_new_category__';

IconData _resolveBudgetIcon(BuildContext context, String categoryName) {
  final categories = context.watch<CategoryProvider>().categoriesFor(
    CategoryType.expense,
  );
  for (final category in categories) {
    if (category.name == categoryName) return resolveCategoryIcon(category);
  }
  return iconForCategory(categoryName);
}

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  String? _expandedCategory;

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
        title: const Text(
          'Budget Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
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
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _NewBudgetDialog(),
        ),
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
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1C6B47), Color(0xFF2E8B63)],
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
                    const Icon(
                      Icons.savings_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "No budgets set yet.\nTap + to add one.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                    isExpanded: _expandedCategory == budget.category,
                    onToggle: () => setState(() {
                      _expandedCategory = _expandedCategory == budget.category
                          ? null
                          : budget.category;
                    }),
                  ),
                  const SizedBox(height: 14),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatefulWidget {
  final BudgetModel budget;
  final double spent;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<_BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<_BudgetCard> {
  late TextEditingController _amountController;
  late BudgetPeriod _period;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget.targetAmount.toStringAsFixed(0),
    );
    _period = widget.budget.period;
  }

  @override
  void didUpdateWidget(covariant _BudgetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) {
      _amountController.text = widget.budget.targetAmount.toStringAsFixed(0);
      _period = widget.budget.period;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _amountController.text = widget.budget.targetAmount.toStringAsFixed(0);
      _period = widget.budget.period;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      context.read<NotifyingProvider>().showMessage("Enter a valid amount.");
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Timeout: without this, a stalled connection leaves this await
      // pending forever with no feedback — which is exactly what
      // "the app is stuck" looks like from the outside, even when
      // nothing has technically crashed.
      await context
          .read<BudgetProvider>()
          .setBudget(widget.budget.category, amount, _period)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.read<NotifyingProvider>().showMessage(
          "Couldn't save — check your connection and try again.",
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isSaving = false);
      widget.onToggle();
    }
  }

  Future<void> _delete() async {
    await context.read<BudgetProvider>().hideBudget(widget.budget.category);
  }

  @override
  Widget build(BuildContext context) {
    final isOverBudget = widget.spent > widget.budget.targetAmount;
    final progress = widget.budget.targetAmount == 0
        ? 0.0
        : (widget.spent / widget.budget.targetAmount).clamp(0.0, 1.0);
    final icon = _resolveBudgetIcon(context, widget.budget.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
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
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: widget.onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color:
                              (isOverBudget
                                      ? Colors.red
                                      : const Color(0xFF1C6B47))
                                  .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: isOverBudget
                              ? Colors.red
                              : const Color(0xFF1C6B47),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.budget.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              widget.budget.period.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.appColors.paragraphColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${widget.spent.toStringAsFixed(0)} / \$${widget.budget.targetAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOverBudget
                        ? Colors.red
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                // const SizedBox(width: 4),
                // Icon(
                //   widget.isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                //   color: Colors.black38,
                // ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.white60,
              color: isOverBudget ? Colors.red : const Color(0xFF1C6B47),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: widget.isExpanded
                ? _buildExpandedEditor()
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedEditor() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.appColors.expandedcardtheme,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              enabled: !_isSaving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                //   labelText: 'Budget amount',
                //   isDense: true,
                //   filled: true,
                //   fillColor: Colors.white,

                // Normal
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),

                //   // When focused
                //   focusedBorder: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(10),
                //     borderSide: BorderSide(
                //       color: Colors.black.withValues(alpha: 0.35),
                //       width: 1.2,
                //     ),
                //   ),

                //   // When disabled
                //   disabledBorder: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(10),
                //     borderSide: BorderSide(
                //       color: Colors.black.withValues(alpha: 0.35),
                //       width: 1.2,
                //     ),
                //   ),
              ),
            ),
            // TextField(
            //   controller: _amountController,
            //   enabled: !_isSaving,
            //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
            //   decoration: InputDecoration(
            //     labelText: 'Budget amount',
            //     isDense: true,
            //     filled: true,
            //     fillColor: Colors.white,
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(10),
            //        borderSide: const BorderSide(
            //         width: 0.1,

            //         color: Color(0xFFDCE5DF)),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 12),
            const Text(
              'Resets',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            const SizedBox(height: 6),

            Center(
              child: SegmentedButton<BudgetPeriod>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF1C6B47),
                  selectedForegroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1C6B47),
                  backgroundColor: Colors.white,
              
                  // Only change the border
                  side: const BorderSide(color: Color(0xFFDCE5DF), width: 1),
                ),
                segments: const [
                  ButtonSegment(
                    value: BudgetPeriod.weekly,
                    label: Text('Weekly'),
                  ),
                  ButtonSegment(
                    value: BudgetPeriod.monthly,
                    label: Text('Monthly'),
                  ),
                  ButtonSegment(
                    value: BudgetPeriod.yearly,
                    label: Text('Yearly'),
                  ),
                ],
                selected: {_period},
                onSelectionChanged: _isSaving
                    ? null
                    : (selection) {
                        setState(() => _period = selection.first);
                      },
              ),
            ),
            const SizedBox(height: 14),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // TextButton(onPressed: _isSaving ? null : _reset, child: const Text('Pre Reset')),
                // const Spacer(),
                TextButton(
                  onPressed: _isSaving ? null : _delete,
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red,),
                  )
                ),
                TextButton(
                  onPressed: _isSaving ? null : widget.onToggle,
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                TextButton(onPressed: 
                _isSaving ? null : _save,
                
                
                 child: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      :  Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface),
                        ),)
             
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NewBudgetDialog extends StatefulWidget {
  const _NewBudgetDialog();

  @override
  State<_NewBudgetDialog> createState() => _NewBudgetDialogState();
}

class _NewBudgetDialogState extends State<_NewBudgetDialog> {
  String? _selectedCategory;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  final TextEditingController _amountController = TextEditingController();

  bool _isAddingNewCategory = false;
  bool _isConfirmingCategory = false; // spinner + guard on the "Ok" button
  bool _isSaving = false; // spinner + guard on the "Save" button
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  void _startAddingCategory() {
    setState(() {
      _isAddingNewCategory = true;
      _selectedCategory = null;
    });
  }

  Future<void> _confirmNewCategory() async {
    if (_isConfirmingCategory) return; // blocks a double-tap mid-flight
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isConfirmingCategory = true);

    bool added;
    try {
      // Timeout: the actual "stuck" fix. Without this, a stalled
      // connection leaves this await pending forever with the button
      // showing no feedback at all — indistinguishable from a real
      // freeze, even though nothing has actually crashed.
      added = await context
          .read<CategoryProvider>()
          .addCategory(name, CategoryType.expense)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirmingCategory = false);
        context.read<NotifyingProvider>().showMessage(
          "Couldn't add category — check your connection and try again.",
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isConfirmingCategory = false);

    if (!added) {
      context.read<NotifyingProvider>().showMessage('"$name" already exists');
      return; // stop here — don't select a name that wasn't actually added
    }

    setState(() {
      _selectedCategory = name;
      _isAddingNewCategory = false;
      _newCategoryController.clear();
    });
  }

  Future<void> _save() async {
    if (_isSaving) return; // blocks a double-tap mid-flight

    final category = _selectedCategory;
    final amount = double.tryParse(_amountController.text.trim());

    if (category == null || amount == null || amount <= 0) {
      context.read<NotifyingProvider>().showMessage(
        'Pick a category and enter a valid amount.',
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context
          .read<BudgetProvider>()
          .setBudget(category, amount, _selectedPeriod)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.read<NotifyingProvider>().showMessage(
          "Couldn't save — check your connection and try again.",
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = context.watch<CategoryProvider>().categoriesFor(
      CategoryType.expense,
    );
    final budgetedCategories = context
        .watch<BudgetProvider>()
        .budgets
        .map((b) => b.category)
        .toSet();
    final availableCategories = expenseCategories
        .where((c) => !budgetedCategories.contains(c.name))
        .toList();

    final dropdownCategories = [...availableCategories];
    if (!_isAddingNewCategory &&
        _selectedCategory != null &&
        !dropdownCategories.any((c) => c.name == _selectedCategory)) {
      dropdownCategories.insert(
        0,
        CategoryModel(
          id: _selectedCategory!,
          name: _selectedCategory!,
          type: CategoryType.expense,
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('New Budget'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plain DropdownButton (inside an InputDecorator) instead of
            // DropdownButtonFormField: the FormField variant computes the
            // child's baseline during performLayout and trips a framework
            // assertion (!debugNeedsLayout) whenever this dialog gets
            // re-laid-out — e.g. right after tapping Save swaps the button
            // for a spinner — which freezes the app even though the
            // Firestore write succeeds. A plain DropdownButton takes its
            // selection straight from `value`, so there is no internal
            // state to desync and no baseline assert.
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Category',
                filled: true,
                fillColor: const Color(0xFFF7F8F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _isAddingNewCategory ? null : _selectedCategory,
                  isExpanded: true,
                  isDense: true,
                  hint: const Text('Select a category'),
                  items: [
                    for (final category in dropdownCategories)
                      DropdownMenuItem(
                        value: category.name,
                        child: Row(
                          children: [
                            Icon(
                              resolveCategoryIcon(category),
                              size: 18,
                              color: const Color(0xFF1C6B47),
                            ),
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
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 18,
                            color: Color(0xFF1C6B47),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Add new category',
                            style: TextStyle(color: Color(0xFF1C6B47)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == _addNewCategorySentinel) {
                      _startAddingCategory();
                    } else {
                      setState(() {
                        _selectedCategory = value;
                        _isAddingNewCategory = false;
                      });
                    }
                  },
                ),
              ),
            ),
            if (_isAddingNewCategory) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newCategoryController,
                      autofocus: true,
                      enabled: !_isConfirmingCategory,
                      decoration: InputDecoration(
                        hintText: 'e.g. Pets',
                        filled: true,
                        fillColor: const Color(0xFFF7F8F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFDCE5DF),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _confirmNewCategory(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // The actual "make it visible instead of stuck" fix:
                  // this button now shows a spinner while _confirmNewCategory
                  // is genuinely in flight, so a slow save LOOKS like it's
                  // working instead of looking frozen.
                  _isConfirmingCategory
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1C6B47),
                          ),
                        )
                      : TextButton(
                          onPressed: _confirmNewCategory,
                          child: const Text("Ok"),
                        ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              enabled: !_isSaving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Budget amount',
                filled: true,
                fillColor: const Color(0xFFF7F8F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Resets',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)
              ),
            ),
            const SizedBox(height: 6),
            SegmentedButton<BudgetPeriod>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: const Color(0xFF1C6B47),
                selectedForegroundColor: Colors.white,
                foregroundColor: const Color(0xFF1C6B47),
              ),
              segments: const [
                ButtonSegment(
                  value: BudgetPeriod.weekly,
                  label: Text('Weekly'),
                ),
                ButtonSegment(
                  value: BudgetPeriod.monthly,
                  label: Text('Monthly'),
                ),
                ButtonSegment(
                  value: BudgetPeriod.yearly,
                  label: Text('Yearly'),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: _isSaving
                  ? null
                  : (selection) =>
                        setState(() => _selectedPeriod = selection.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C6B47),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}




















// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/screens/budgets_history_screen.dart';
// import 'package:expense_tracking/widgets/category_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/models/budgets_model.dart';
// import 'package:expense_tracking/providers/budgets_provider.dart';
// import 'package:expense_tracking/widgets/budget_period/budget_period.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/providers/category_provider.dart';
// import 'package:expense_tracking/models/category_model.dart';

// const String _addNewCategorySentinel = '__add_new_category__';

// /// Finds the full CategoryModel behind a plain category-name string
// /// (which is all a BudgetModel stores) so its custom iconKey — if the
// /// user picked one in Manage Categories — can actually be used. Falls
// /// back to the old name-based guess if no match is found, e.g. if the
// /// category was deleted after this budget was created.
// IconData _resolveBudgetIcon(BuildContext context, String categoryName) {
//   final categories = context.watch<CategoryProvider>().categoriesFor(
//     CategoryType.expense,
//   );
//   for (final category in categories) {
//     if (category.name == categoryName) return resolveCategoryIcon(category);
//   }
//   return iconForCategory(categoryName);
// }

// class BudgetPlannerScreen extends StatelessWidget {
//   const BudgetPlannerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final budgets = context.watch<BudgetProvider>().budgets;
//     final expensesController = context.watch<ExpensesController>();
//     // final budgets = context.watch<BudgetProvider>().budgets;

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
//       backgroundColor: const Color(0xFFF7F8F7),
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text(
//           'Budget Planner',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//         actions: [
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
//         backgroundColor: const Color(0xFF1C6B47),
//         onPressed: () => showDialog(
//           context: context,
//           builder: (_) => const _NewBudgetDialog(),
//         ),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 22,
//                   horizontal: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Color(0xFF1C6B47), Color(0xFF2E8B63)],
//                   ),
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF1C6B47).withValues(alpha: 0.25),
//                       blurRadius: 16,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.savings_rounded,
//                       color: Colors.white70,
//                       size: 22,
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'TOTAL BUDGET',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white70,
//                         letterSpacing: 0.6,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       '\$${totalSpent.toStringAsFixed(0)} / \$${totalTarget.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
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
//                   ),
//                   const SizedBox(height: 14),
//                 ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Now a StatefulWidget — tapping the header EXPANDS this card in
// /// place (amount field, period selector, Reset/Cancel/Delete/Save)
// /// instead of opening a separate dialog. This is both the UX change
// /// you asked for AND what eliminates the edit-time crash: the old
// /// dialog-based editor reused the same category dropdown as creation,
// /// which is where the crash lived. Editing never needs a category
// /// dropdown at all — category can't change after a budget exists,
// /// since it IS the document's id — so removing that code path removes
// /// the crash risk along with it.
// class _BudgetCard extends StatefulWidget {
//   final BudgetModel budget;
//   final double spent;
//   const _BudgetCard({required this.budget, required this.spent});

//   @override
//   State<_BudgetCard> createState() => _BudgetCardState();
// }

// class _BudgetCardState extends State<_BudgetCard> {
//   bool _isExpanded = false;
//   late TextEditingController _amountController;
//   late BudgetPeriod _period;

//   @override
//   void initState() {
//     super.initState();
//     _amountController = TextEditingController(
//       text: widget.budget.targetAmount.toStringAsFixed(0),
//     );
//     _period = widget.budget.period;
//   }

//   @override
//   void didUpdateWidget(covariant _BudgetCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // If the underlying budget changes externally (another device,
//     // etc.) while this card is collapsed, keep the edit fields synced
//     // so reopening it shows current data, not stale values from when
//     // this widget was first built.
//     if (!_isExpanded) {
//       _amountController.text = widget.budget.targetAmount.toStringAsFixed(0);
//       _period = widget.budget.period;
//     }
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }

//   void _reset() {
//     setState(() {
//       _amountController.text = widget.budget.targetAmount.toStringAsFixed(0);
//       _period = widget.budget.period;
//     });
//   }

//   Future<void> _save() async {
//     final amount = double.tryParse(_amountController.text.trim());
//     if (amount == null || amount <= 0) {
//       context.read<NotifyingProvider>().showMessage("Enter a valid amount .");
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(content: Text('Enter a valid amount')),
//       // );
//       return;
//     }
//     await context.read<BudgetProvider>().setBudget(
//       widget.budget.category,
//       amount,
//       _period,
//     );
//     if (mounted) setState(() => _isExpanded = false);
//   }

//   Future<void> _delete() async {
//     // Soft delete — moves to Budget History, recoverable via Unhide.
//     await context.read<BudgetProvider>().hideBudget(widget.budget.category);
//     // No setState needed — BudgetProvider.budgets excludes hidden
//     // budgets, so this card disappears from the list on its own once
//     // the stream updates.
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isOverBudget = widget.spent > widget.budget.targetAmount;
//     final progress = widget.budget.targetAmount == 0
//         ? 0.0
//         : (widget.spent / widget.budget.targetAmount).clamp(0.0, 1.0);
//     final icon = _resolveBudgetIcon(context, widget.budget.category);

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(10),
//             onTap: () => setState(() => _isExpanded = !_isExpanded),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 38,
//                         height: 38,
//                         decoration: BoxDecoration(
//                           color:
//                               (isOverBudget
//                                       ? Colors.red
//                                       : const Color(0xFF1C6B47))
//                                   .withValues(alpha: 0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           icon,
//                           color: isOverBudget
//                               ? Colors.red
//                               : const Color(0xFF1C6B47),
//                           size: 19,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.budget.category,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             Text(
//                               widget.budget.period.label,
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.black45,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '\$${widget.spent.toStringAsFixed(0)} / \$${widget.budget.targetAmount.toStringAsFixed(0)}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: isOverBudget ? Colors.red : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Icon(
//                   _isExpanded
//                       ? Icons.expand_less_rounded
//                       : Icons.expand_more_rounded,
//                   color: Colors.black38,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: LinearProgressIndicator(
//               minHeight: 8,
//               value: progress,
//               backgroundColor: Colors.grey.shade200,
//               color: isOverBudget ? Colors.red : const Color(0xFF1C6B47),
//             ),
//           ),
//           // AnimatedSize gives the expand/collapse a smooth transition
//           // instead of the layout just snapping open/shut.
//           AnimatedSize(
//             duration: const Duration(milliseconds: 200),
//             child: _isExpanded
//                 ? _buildExpandedEditor()
//                 : const SizedBox(width: double.infinity),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpandedEditor() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF7F8F7),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(
//               controller: _amountController,
//               keyboardType: const TextInputType.numberWithOptions(
//                 decimal: true,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'Budget amount',
//                 isDense: true,
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'Resets',
//               style: TextStyle(fontSize: 12, color: Colors.black54),
//             ),
//             const SizedBox(height: 6),
//             SegmentedButton<BudgetPeriod>(
//               style: SegmentedButton.styleFrom(
//                 selectedBackgroundColor: const Color(0xFF1C6B47),
//                 selectedForegroundColor: Colors.white,
//                 foregroundColor: const Color(0xFF1C6B47),
//                 backgroundColor: Colors.white,
//               ),
//               segments: const [
//                 ButtonSegment(
//                   value: BudgetPeriod.weekly,
//                   label: Text('Weekly'),
//                 ),
//                 ButtonSegment(
//                   value: BudgetPeriod.monthly,
//                   label: Text('Monthly'),
//                 ),
//                 ButtonSegment(
//                   value: BudgetPeriod.yearly,
//                   label: Text('Yearly'),
//                 ),
//               ],
//               selected: {_period},
//               onSelectionChanged: (selection) =>
//                   setState(() => _period = selection.first),
//             ),
//             const SizedBox(height: 14),
//             Row(
//               children: [
//                 TextButton(onPressed: _reset, child: const Text('Reset')),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: _delete,
//                   child: const Text(
//                     'Delete',
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () => setState(() => _isExpanded = false),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _save,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1C6B47),
//                   ),
//                   child: const Text(
//                     'Save',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Creation only now — category selection genuinely only matters here,
// /// since it's the one moment a category actually gets locked in.
// class _NewBudgetDialog extends StatefulWidget {
//   const _NewBudgetDialog();

//   @override
//   State<_NewBudgetDialog> createState() => _NewBudgetDialogState();
// }

// class _NewBudgetDialogState extends State<_NewBudgetDialog> {
//   String? _selectedCategory;
//   BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
//   final TextEditingController _amountController = TextEditingController();

//   bool _isAddingNewCategory = false;
//   final TextEditingController _newCategoryController = TextEditingController();

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _newCategoryController.dispose();
//     super.dispose();
//   }

//   void _startAddingCategory() {
//     setState(() {
//       _isAddingNewCategory = true;
//       _selectedCategory = null;
//     });
//   }

//   Future<void> _confirmNewCategory() async {
//     final name = _newCategoryController.text.trim();
//     if (name.isEmpty) return;

//     final added = await context.read<CategoryProvider>().addCategory(
//       name,
//       CategoryType.expense,
//     );
//     if (!mounted) return;

//     if (!added) {
//       context.read<NotifyingProvider>().showMessage('"$name" already exists');
//       return; // restored — stop here, don't select a name that wasn't actually added
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
//       context.read<NotifyingProvider>().showMessage(
//         'Pick a category and enter a valid amount .',
//       );

//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(content: Text('Pick a category and enter a valid amount')),
//       // );
//       return;
//     }

//     await context.read<BudgetProvider>().setBudget(
//       category,
//       amount,
//       _selectedPeriod,
//     );
//     if (mounted) Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final expenseCategories = context.watch<CategoryProvider>().categoriesFor(
//       CategoryType.expense,
//     );
//     final budgetedCategories = context
//         .watch<BudgetProvider>()
//         .budgets
//         .map((b) => b.category)
//         .toSet();
//     final availableCategories = expenseCategories
//         .where((c) => !budgetedCategories.contains(c.name))
//         .toList();

//     // THE actual crash fix: guarantee the dropdown's items always
//     // contain an entry matching _selectedCategory, even in the brief
//     // window right after adding a new one, before CategoryProvider's
//     // Firestore stream has caught up. Without this, DropdownButtonFormField
//     // crashes the instant its selected value has zero matching items.
//     final dropdownCategories = [...availableCategories];
//     if (!_isAddingNewCategory &&
//         _selectedCategory != null &&
//         !dropdownCategories.any((c) => c.name == _selectedCategory)) {
//       dropdownCategories.insert(
//         0,
//         CategoryModel(
//           id: _selectedCategory!,
//           name: _selectedCategory!,
//           type: CategoryType.expense,
//         ),
//       );
//     }

//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       title: const Text('New Budget'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             DropdownButtonFormField<String>(
//               key: ValueKey('$_selectedCategory-$_isAddingNewCategory'),
//               initialValue: _isAddingNewCategory ? null : _selectedCategory,
//               isExpanded: true,
//               decoration: InputDecoration(
//                 labelText: 'Category',
//                 filled: true,
//                 fillColor: const Color(0xFFF7F8F7),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
//                 ),
//               ),
//               items: [
//                 for (final category in dropdownCategories)
//                   DropdownMenuItem(
//                     value: category.name,
//                     child: Row(
//                       children: [
//                         Icon(
//                           resolveCategoryIcon(category),
//                           size: 18,
//                           color: const Color(0xFF1C6B47),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             category.name,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 const DropdownMenuItem(
//                   value: _addNewCategorySentinel,
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.add_circle_outline_rounded,
//                         size: 18,
//                         color: Color(0xFF1C6B47),
//                       ),
//                       SizedBox(width: 10),
//                       Text(
//                         'Add new category',
//                         style: TextStyle(color: Color(0xFF1C6B47)),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//               // The other half of the fix: picking a REAL category now
//               // always resets _isAddingNewCategory back to false. Before,
//               // this only happened via _startAddingCategory() — selecting
//               // an existing category afterward left the inline "add new"
//               // text field stuck visible with stale, conflicting state.
//               onChanged: (value) {
//                 if (value == _addNewCategorySentinel) {
//                   _startAddingCategory();
//                 } else {
//                   setState(() {
//                     _selectedCategory = value;
//                     _isAddingNewCategory = false;
//                   });
//                 }
//               },
//             ),
//             if (_isAddingNewCategory) ...[
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _newCategoryController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: '',
//                         filled: true,
//                         fillColor: const Color(0xFFF7F8F7),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFDCE5DF),
//                           ),
//                         ),
//                       ),
//                       onSubmitted: (_) => _confirmNewCategory(),
//                     ),
//                   ),
//                   // IconButton(
//                   //   icon: const Icon(Icons.done, color: Color(0xFF1C6B47)),
//                   //   onPressed: _confirmNewCategory,
//                   // ),
//                   TextButton(onPressed: _confirmNewCategory, child: Text("Ok")),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 12),
//             TextField(
//               controller: _amountController,
//               keyboardType: const TextInputType.numberWithOptions(
//                 decimal: true,
//               ),
//               decoration: InputDecoration(
//                 labelText: 'Budget amount',
//                 filled: true,
//                 fillColor: const Color(0xFFF7F8F7),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Resets',
//                 style: TextStyle(fontSize: 12, color: Colors.black54),
//               ),
//             ),
//             const SizedBox(height: 6),
//             SegmentedButton<BudgetPeriod>(
//               style: SegmentedButton.styleFrom(
//                 selectedBackgroundColor: const Color(0xFF1C6B47),
//                 selectedForegroundColor: Colors.white,
//                 foregroundColor: const Color(0xFF1C6B47),
//               ),
//               segments: const [
//                 ButtonSegment(
//                   value: BudgetPeriod.weekly,
//                   label: Text('Weekly'),
//                 ),
//                 ButtonSegment(
//                   value: BudgetPeriod.monthly,
//                   label: Text('Monthly'),
//                 ),
//                 ButtonSegment(
//                   value: BudgetPeriod.yearly,
//                   label: Text('Yearly'),
//                 ),
//               ],
//               selected: {_selectedPeriod},
//               onSelectionChanged: (selection) =>
//                   setState(() => _selectedPeriod = selection.first),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _save,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF1C6B47),
//           ),
//           child: const Text('Save', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }





















// // import 'package:expense_tracking/screens/budgets_history_screen.dart';
// // import 'package:expense_tracking/widgets/category_icon.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:expense_tracking/models/budgets_model.dart';
// // import 'package:expense_tracking/providers/budgets_provider.dart';
// // import 'package:expense_tracking/widgets/budget_period/budget_period.dart';
// // import 'package:expense_tracking/controllers/expenses_controller.dart';
// // import 'package:expense_tracking/providers/category_provider.dart';
// // import 'package:expense_tracking/models/category_model.dart';


// // // Sentinel value used inside the category dropdown to represent the
// // // "+ Add new category" option, since dropdown items need a String value
// // // and no real category will ever equal this.
// // const String _addNewCategorySentinel = '__add_new_category__';

// // class BudgetPlannerScreen extends StatelessWidget {
// //   const BudgetPlannerScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final budgets = context.watch<BudgetProvider>().budgets;
// //     final expensesController = context.watch<ExpensesController>();

// //     double totalSpent = 0;
// //     double totalTarget = 0;
// //     for (final budget in budgets) {
// //       totalSpent += expensesController.spentForCategorySince(
// //         budget.category,
// //         periodStartFor(budget.period),
// //       );
// //       totalTarget += budget.targetAmount;
// //     }

// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: const BackButton(),
// //         title: const Text('Budget Planner', style: TextStyle(fontWeight: FontWeight.bold)),
// //         elevation: 0,
// //         actions: [
// //           // Entry point to the hidden/soft-deleted budgets — this IS
// //           // the "history" you asked for: nothing disappears immediately,
// //           // it just moves here until permanently deleted.
// //           IconButton(
// //             icon: const Icon(Icons.history),
// //             tooltip: 'Budget history',
// //             onPressed: () => Navigator.of(context).push(
// //               MaterialPageRoute(builder: (_) => const BudgetHistoryScreen()),
// //             ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         backgroundColor: const Color(0xFF1C6B47),
// //         onPressed: () => _openBudgetDialog(context),
// //         child: const Icon(Icons.add, color: Colors.white),
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Container(
// //                 width: double.infinity,
// //                 padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                     colors: [const Color(0xFF1C6B47), const Color(0xFF2E8B63)],
// //                   ),
// //                   borderRadius: BorderRadius.circular(18),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: const Color(0xFF1C6B47).withValues(alpha: 0.25),
// //                       blurRadius: 16,
// //                       offset: const Offset(0, 6),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Column(
// //                   children: [
// //                     const Icon(Icons.savings_rounded, color: Colors.white70, size: 22),
// //                     const SizedBox(height: 8),
// //                     const Text(
// //                       'TOTAL BUDGET',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.white70,
// //                         letterSpacing: 0.6,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 6),
// //                     Text(
// //                       '\$${totalSpent.toStringAsFixed(0)} / \$${totalTarget.toStringAsFixed(0)}',
// //                       style: const TextStyle(
// //                         fontSize: 28,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //               if (budgets.isEmpty)
// //                 const Padding(
// //                   padding: EdgeInsets.symmetric(vertical: 40),
// //                   child: Center(
// //                     child: Text(
// //                       "No budgets set yet.\nTap + to add one.",
// //                       textAlign: TextAlign.center,
// //                       style: TextStyle(color: Colors.black54),
// //                     ),
// //                   ),
// //                 )
// //               else
// //                 for (final budget in budgets) ...[
// //                   _BudgetCard(
// //                     budget: budget,
// //                     spent: expensesController.spentForCategorySince(
// //                       budget.category,
// //                       periodStartFor(budget.period),
// //                     ),
// //                     onTap: () => _openBudgetDialog(context, existing: budget),
// //                   ),
// //                   const SizedBox(height: 14),
// //                 ],
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void _openBudgetDialog(BuildContext context, {BudgetModel? existing}) {
// //     showDialog(
// //       context: context,
// //       builder: (_) => _BudgetFormDialog(existing: existing),
// //     );
// //   }
// // }

// // class _BudgetCard extends StatelessWidget {
// //   final BudgetModel budget;
// //   final double spent;
// //   final VoidCallback onTap;

// //   const _BudgetCard({required this.budget, required this.spent, required this.onTap});

// //   @override
// //   Widget build(BuildContext context) {
// //     final isOverBudget = spent > budget.targetAmount;
// //     final progress = budget.targetAmount == 0 ? 0.0 : (spent / budget.targetAmount).clamp(0.0, 1.0);

// //     return InkWell(
// //       borderRadius: BorderRadius.circular(14),
// //       onTap: onTap,
// //       child: Container(
// //         width: double.infinity,
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(14),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withValues(alpha: 0.04),
// //               blurRadius: 10,
// //               offset: const Offset(0, 3),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Expanded(
// //                   child: Row(
// //                     children: [
// //                       // Icon avatar matching the category — replaces
// //                       // any emoji shorthand with a proper Material icon.
// //                       Container(
// //                         width: 38,
// //                         height: 38,
// //                         decoration: BoxDecoration(
// //                           color: (isOverBudget ? Colors.red : const Color(0xFF1C6B47))
// //                               .withValues(alpha: 0.1),
// //                           shape: BoxShape.circle,
// //                         ),
// //                         child: Icon(
// //                           iconForCategory(budget.category),
// //                           color: isOverBudget ? Colors.red : const Color(0xFF1C6B47),
// //                           size: 19,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             // Full name still shows here, just capped
// //                             // at one line — this is the actual fix:
// //                             // long category names truncate with an
// //                             // ellipsis instead of wrapping and breaking
// //                             // the card's layout.
// //                             Text(
// //                               budget.category,
// //                               maxLines: 1,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
// //                             ),
// //                             Text(
// //                               budget.period.label,
// //                               style: const TextStyle(fontSize: 11, color: Colors.black45),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   '\$${spent.toStringAsFixed(0)} / \$${budget.targetAmount.toStringAsFixed(0)}',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.w600,
// //                     color: isOverBudget ? Colors.red : Colors.black87,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(10),
// //               child: LinearProgressIndicator(
// //                 minHeight: 8,
// //                 value: progress,
// //                 backgroundColor: Colors.grey.shade200,
// //                 color: isOverBudget ? Colors.red : const Color(0xFF1C6B47),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _BudgetFormDialog extends StatefulWidget {
// //   final BudgetModel? existing;
// //   const _BudgetFormDialog({this.existing});

// //   @override
// //   State<_BudgetFormDialog> createState() => _BudgetFormDialogState();
// // }

// // class _BudgetFormDialogState extends State<_BudgetFormDialog> {
// //   String? _selectedCategory;
// //   BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
// //   final TextEditingController _amountController = TextEditingController();

// //   // New: inline "add a category without leaving this dialog" state.
// //   bool _isAddingNewCategory = false;
// //   final TextEditingController _newCategoryController = TextEditingController();

// //   bool get _isEditing => widget.existing != null;

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (widget.existing != null) {
// //       _selectedCategory = widget.existing!.category;
// //       _selectedPeriod = widget.existing!.period;
// //       _amountController.text = widget.existing!.targetAmount.toStringAsFixed(0);
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _amountController.dispose();
// //     _newCategoryController.dispose();
// //     super.dispose();
// //   }

// //   /// Called when the user picks "+ Add new category" from the dropdown.
// //   /// Doesn't save anything yet — just reveals the inline text field.
// //   void _startAddingCategory() {
// //     setState(() {
// //       _isAddingNewCategory = true;
// //       _selectedCategory = null;
// //     });
// //   }

// //   /// Called when the user confirms the new category name. Saves it
// //   /// through CategoryProvider (same path ManageCategoriesScreen uses),
// //   /// then selects it immediately so they don't have to reopen the
// //   /// dropdown to pick what they just typed.
// //   Future<void> _confirmNewCategory() async {
// //     final name = _newCategoryController.text.trim();
// //     if (name.isEmpty) return;

// //     final added = await context.read<CategoryProvider>().addCategory(name, CategoryType.expense);

// //     if (!mounted) return;

// //     if (!added) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('"$name" already exists')),
// //       );
// //       return;
// //     }

// //     setState(() {
// //       _selectedCategory = name;
// //       _isAddingNewCategory = false;
// //       _newCategoryController.clear();
// //     });
// //   }

// //   Future<void> _save() async {
// //     final category = _selectedCategory;
// //     final amount = double.tryParse(_amountController.text.trim());

// //     if (category == null || amount == null || amount <= 0) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Pick a category and enter a valid amount')),
// //       );
// //       return;
// //     }

// //     await context.read<BudgetProvider>().setBudget(category, amount, _selectedPeriod);
// //     if (mounted) Navigator.of(context).pop();
// //   }

// //   /// Soft delete now — this hides the budget rather than removing it.
// //   /// It reappears in Budget History, recoverable via "Unhide", until the
// //   /// user explicitly chooses "Delete Permanently" there.
// //   Future<void> _hide() async {
// //     if (widget.existing == null) return;
// //     await context.read<BudgetProvider>().hideBudget(widget.existing!.category);
// //     if (mounted) Navigator.of(context).pop();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final expenseCategories =
// //         context.watch<CategoryProvider>().categoriesFor(CategoryType.expense);

// //     final budgetedCategories =
// //         context.watch<BudgetProvider>().budgets.map((b) => b.category).toSet();
// //     final availableCategories = _isEditing
// //         ? expenseCategories
// //         : expenseCategories.where((c) => !budgetedCategories.contains(c.name)).toList();

// //     return AlertDialog(
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
// //       title: Text(_isEditing ? 'Edit Budget' : 'New Budget'),
// //       content: SingleChildScrollView(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             if (_isEditing)
// //               Padding(
// //                 padding: const EdgeInsets.only(bottom: 8),
// //                 child: Row(
// //                   children: [
// //                     Icon(iconForCategory(_selectedCategory ?? ''),
// //                         size: 18, color: const Color(0xFF1C6B47)),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: Text(
// //                         _selectedCategory ?? '',
// //                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               )
// //             else ...[
// //               DropdownButtonFormField<String>(
// //                 initialValue: _isAddingNewCategory ? null : _selectedCategory,
// //                 // The actual fix: without isExpanded, the dropdown sizes
// //                 // itself to its intrinsic content width, which is what
// //                 // was clipping longer category names. isExpanded: true
// //                 // makes it fill the available row width instead, so the
// //                 // full name always has room to render.
// //                 isExpanded: true,
// //                 decoration: const InputDecoration(labelText: 'Category'),
// //                 items: [
// //                   for (final category in availableCategories)
// //                     DropdownMenuItem(
// //                       value: category.name,
// //                       child: Row(
// //                         children: [
// //                           Icon(iconForCategory(category.name), size: 18, color: const Color(0xFF1C6B47)),
// //                           const SizedBox(width: 10),
// //                           Expanded(
// //                             child: Text(
// //                               category.name,
// //                               overflow: TextOverflow.ellipsis,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   const DropdownMenuItem(
// //                     value: _addNewCategorySentinel,
// //                     child: Row(
// //                       children: [
// //                         Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF1C6B47)),
// //                         SizedBox(width: 10),
// //                         Text('Add new category', style: TextStyle(color: Color(0xFF1C6B47))),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //                 onChanged: (value) {
// //                   if (value == _addNewCategorySentinel) {
// //                     _startAddingCategory();
// //                   } else {
// //                     setState(() => _selectedCategory = value);
// //                   }
// //                 },
// //               ),
// //               if (_isAddingNewCategory) ...[
// //                 const SizedBox(height: 10),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: _newCategoryController,
// //                         autofocus: true,
// //                         decoration: const InputDecoration(hintText: 'e.g. Pets'),
// //                         onSubmitted: (_) => _confirmNewCategory(),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.check_circle, color: Color(0xFF1C6B47)),
// //                       onPressed: _confirmNewCategory,
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ],
// //             const SizedBox(height: 12),
// //             TextField(
// //               controller: _amountController,
// //               keyboardType: const TextInputType.numberWithOptions(decimal: true),
// //               decoration: const InputDecoration(labelText: 'Budget amount'),
// //             ),
// //             const SizedBox(height: 16),
// //             const Align(
// //               alignment: Alignment.centerLeft,
// //               child: Text('Resets', style: TextStyle(fontSize: 12, color: Colors.black54)),
// //             ),
// //             const SizedBox(height: 6),
// //             SegmentedButton<BudgetPeriod>(
// //               style: SegmentedButton.styleFrom(
// //                 selectedBackgroundColor: const Color(0xFF1C6B47),
// //                 selectedForegroundColor: Colors.white,
// //                 foregroundColor: const Color(0xFF1C6B47),
// //               ),
// //               segments: const [
// //                 ButtonSegment(value: BudgetPeriod.weekly, label: Text('Weekly')),
// //                 ButtonSegment(value: BudgetPeriod.monthly, label: Text('Monthly')),
// //                 ButtonSegment(value: BudgetPeriod.yearly, label: Text('Yearly')),
// //               ],
// //               selected: {_selectedPeriod},
// //               onSelectionChanged: (selection) =>
// //                   setState(() => _selectedPeriod = selection.first),
// //             ),
// //           ],
// //         ),
// //       ),
// //       actions: [
// //         if (_isEditing)
// //           TextButton(
// //             onPressed: _hide,
// //             child: const Text('Delete', style: TextStyle(color: Colors.red)),
// //           ),
// //         TextButton(
// //           onPressed: () => Navigator.of(context).pop(),
// //           child: const Text('Cancel'),
// //         ),
// //         ElevatedButton(
// //           onPressed: _save,
// //           style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C6B47)),
// //           child: const Text('Save', style: TextStyle(color: Colors.white)),
// //         ),
// //       ],
// //     );
// //   }
// // }











