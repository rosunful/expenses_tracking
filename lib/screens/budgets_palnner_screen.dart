import 'package:expense_tracking/controllers/budget_period_controller.dart';
import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/screens/budgets_history_screen.dart';
import 'package:expense_tracking/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/models/budgets_model.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/providers/category_provider.dart';
import 'package:expense_tracking/models/category_model.dart';


const String _addNewCategorySentinel = '__add_new_category__';

IconData _resolveBudgetIcon(BuildContext context, String categoryName) {
  final categories = context.watch<CategoryProvider>().categoriesFor(CategoryType.expense);
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
   
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

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
      backgroundColor: const Color(0xFFF7F8F7),
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Budget Planner', style: TextStyle(fontWeight: FontWeight.bold)),
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
        onPressed: () => showDialog(context: context, builder: (_) => const _NewBudgetDialog()),
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
                    const Icon(Icons.savings_rounded, color: Colors.white70, size: 22),
                    const SizedBox(height: 8),
                    const Text(
                      'TOTAL BUDGET',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: Colors.white70, letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$symbol${totalSpent.toStringAsFixed(0)} / $symbol${totalTarget.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
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
                    isExpanded: _expandedCategory == budget.category,
                    onToggle: () => setState(() {
                      _expandedCategory =
                          _expandedCategory == budget.category ? null : budget.category;
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
    _amountController = TextEditingController(text: widget.budget.targetAmount.toStringAsFixed(0));
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

   
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      
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
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
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
                          color: (isOverBudget ? Colors.red : const Color(0xFF1C6B47)).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: isOverBudget ? Colors.red : const Color(0xFF1C6B47), size: 19),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              widget.budget.period.label,
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
                  '$symbol${widget.spent.toStringAsFixed(0)} / $symbol${widget.budget.targetAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? Colors.red : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  widget.isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: Colors.black38,
                ),
              ],
            ),
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
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: widget.isExpanded ? _buildExpandedEditor() : const SizedBox(width: double.infinity),
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
          color: const Color(0xFFF7F8F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              enabled: !_isSaving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Budget amount',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Resets', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 6),
            SegmentedButton<BudgetPeriod>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: const Color(0xFF1C6B47),
                selectedForegroundColor: Colors.white,
                foregroundColor: const Color(0xFF1C6B47),
                backgroundColor: Colors.white,
              ),
              segments: const [
                ButtonSegment(value: BudgetPeriod.weekly, label: Text('Weekly')),
                ButtonSegment(value: BudgetPeriod.monthly, label: Text('Monthly')),
                ButtonSegment(value: BudgetPeriod.yearly, label: Text('Yearly')),
              ],
              selected: {_period},
              onSelectionChanged: _isSaving ? null : (selection) => setState(() => _period = selection.first),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(onPressed: _isSaving ? null : _reset, child: const Text('Reset')),
                const Spacer(),
                TextButton(
                  onPressed: _isSaving ? null : _delete,
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: _isSaving ? null : widget.onToggle,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C6B47)),
                  child: _isSaving
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
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
      context.read<NotifyingProvider>().showMessage('Pick a category and enter a valid amount.');
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
    final expenseCategories = context.watch<CategoryProvider>().categoriesFor(CategoryType.expense);
    final budgetedCategories = context.watch<BudgetProvider>().budgets.map((b) => b.category).toSet();
    final availableCategories =
        expenseCategories.where((c) => !budgetedCategories.contains(c.name)).toList();

    final dropdownCategories = [...availableCategories];
    if (!_isAddingNewCategory &&
        _selectedCategory != null &&
        !dropdownCategories.any((c) => c.name == _selectedCategory)) {
      dropdownCategories.insert(
        0,
        CategoryModel(id: _selectedCategory!, name: _selectedCategory!, type: CategoryType.expense),
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
            DropdownButtonFormField<String>(
              
              key: ValueKey('$_selectedCategory-$_isAddingNewCategory'),
              initialValue: _isAddingNewCategory ? null : _selectedCategory,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Category',
                filled: true,
                fillColor: const Color(0xFFF7F8F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
                ),
              ),
              items: [
                for (final category in dropdownCategories)
                  DropdownMenuItem(
                    value: category.name,
                    child: Row(
                      children: [
                        Icon(resolveCategoryIcon(category), size: 18, color: const Color(0xFF1C6B47)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(category.name, overflow: TextOverflow.ellipsis)),
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
                  setState(() {
                    _selectedCategory = value;
                    _isAddingNewCategory = false;
                  });
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
                      enabled: !_isConfirmingCategory,
                      decoration: InputDecoration(
                        hintText: 'e.g. Pets',
                        filled: true,
                        fillColor: const Color(0xFFF7F8F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
                        ),
                      ),
                      onSubmitted: (_) => _confirmNewCategory(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  
                  _isConfirmingCategory
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C6B47)),
                        )
                      : TextButton(onPressed: _confirmNewCategory, child: const Text("Ok")),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              enabled: !_isSaving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              onSelectionChanged:
                  _isSaving ? null : (selection) => setState(() => _selectedPeriod = selection.first),
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
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C6B47)),
          child: _isSaving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}








