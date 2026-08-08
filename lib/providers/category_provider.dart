import 'dart:async';
import 'package:expense_tracking/models/category_model.dart';
import 'package:expense_tracking/repositories/category_repository.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();

  // Built-in categories — same names your original hardcoded chip lists
  // used. These never change and never touch Firestore.
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

  /// The combined list a chip picker should render: defaults first,
  /// then whatever the user has added, for a given type.
  ///
  /// Deduplicated by name (case-insensitive) — this is the actual fix.
  /// Without it, a custom category that happens to share a name with a
  /// default (e.g. someone re-adding "Transport") would appear TWICE in
  /// this list, and any DropdownButton built from it crashes, because
  /// Flutter requires exactly one item to match the selected value.
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
      if (seenNames.contains(key)) return false; // duplicate — skip it
      seenNames.add(key);
      return true;
    }).toList();

    return [...defaults, ...custom];
  }

  /// Returns true if added, false if a category with this name (any
  /// case) already exists for this type — lets the UI show a message
  /// instead of silently creating a duplicate that would trigger the
  /// same crash categoriesFor() now guards against.
  Future<bool> addCategory(String name, CategoryType type) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    final alreadyExists = categoriesFor(type)
        .any((c) => c.name.toLowerCase() == trimmed.toLowerCase());
    if (alreadyExists) return false;

    await _repository.addCategory(trimmed, type);
    return true;
  }

  Future<void> deleteCategory(String categoryId) async {
    await _repository.deleteCategory(categoryId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}