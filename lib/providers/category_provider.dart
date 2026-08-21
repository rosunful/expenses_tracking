import 'dart:async';
import 'package:expense_tracking/models/category_model.dart';
import 'package:expense_tracking/repositories/category_repository.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

 
  static const List<String> _defaultExpenseNames = [
    'Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Other',
  ];
  static const List<String> _defaultIncomeNames = [
    'Salary', 'Freelance', 'Business', 'Gift', 'Family', 'Borrowed',
    'Investment', 'Other',
  ];
  static const List<String> _defaultReminderNames = [
    'Subscription', 'Utility', 'Rent', 'Loan', 'Insurance', 'Other',
  ];

  List<CategoryModel> _customCategories = [];
  StreamSubscription<List<CategoryModel>>? _subscription;

  CategoryProvider() {
    _subscription = _repository.streamCategories().listen((categories) {
      _customCategories = categories;
      notifyListeners();
    });
  }

  List<CategoryModel> categoriesFor(CategoryType type) {
    final defaultNames = switch (type) {
      CategoryType.expense => _defaultExpenseNames,
      CategoryType.income => _defaultIncomeNames,
      CategoryType.reminder => _defaultReminderNames,
    };

    final defaults = defaultNames
        .map((name) => CategoryModel(id: name, name: name, type: type, isDefault: true))
        .toList();

    final seenNames = defaults.map((c) => c.name.toLowerCase()).toSet();

    final custom = _customCategories.where((c) {
      if (c.type != type) return false;
      final key = c.name.toLowerCase();
      if (seenNames.contains(key)) return false; 
      seenNames.add(key);
      return true;
    }).toList();

    return [...defaults, ...custom];
  }

  /// Returns true if added, false if a category with this name (any
  /// case) already exists for this type — lets the UI show a message
  /// instead of silently creating a duplicate that would trigger the
  /// same crash categoriesFor() 
  Future<bool> addCategory(String name, CategoryType type, {String? iconKey}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    final alreadyExists = categoriesFor(type)
        .any((c) => c.name.toLowerCase() == trimmed.toLowerCase());
    if (alreadyExists) return false;

    await _repository.addCategory(trimmed, type, iconKey: iconKey);
    return true;
  }

  Future<void> updateCategoryIcon(String categoryId, String iconKey) async {
    await _repository.updateCategoryIcon(categoryId, iconKey);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
  }

  /// Same duplicate-guard idea as addCategory — you shouldn't be able
  /// to rename "Pets" to "Food" and end up with the same crash-causing
  /// duplicate categoriesFor() protects against. Excludes the category
  /// being renamed itself from that check, obviously, or renaming a
  /// category to its OWN current name would incorrectly count as a
  /// duplicate.
  ///
  /// Takes [oldName] explicitly (rather than looking it up) because the
  /// caller already has it on hand from the CategoryModel being edited,
  /// and it's needed to find every existing transaction/reminder/budget
  /// that used the old name so they can be rewritten to the new one.
  Future<bool> renameCategory(
    String categoryId,
    String oldName,
    String newName,
    CategoryType type,
  ) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;

    final alreadyExists = categoriesFor(type).any(
      (c) => c.id != categoryId && c.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (alreadyExists) return false;

    await _repository.updateCategoryName(categoryId, trimmed);
    await _repository.cascadeRenameCategory(oldName, trimmed, type);
    return true;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}










