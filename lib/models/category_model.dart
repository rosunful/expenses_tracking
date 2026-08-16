

// /// Categories are scoped by type — "Food" belongs to expenses,
// /// "Salary" belongs to income, "Subscription" belongs to reminders.
// /// Keeping them as separate lists prevents an expense category showing
// /// up as an option while adding income (or a reminder).
// enum CategoryType { expense, income, reminder }

// class CategoryModel {
//   final String id;
//   final String name;
//   final CategoryType type;

//   /// True for the built-in categories ("Food", "Salary", etc.) that
//   /// ship with the app and are never stored in Firestore. False for
//   /// anything the user added themselves through Manage Categories.
//   /// Only non-default categories can be deleted.
//   final bool isDefault;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.type,
//     this.isDefault = false,
//   });

//   Map<String, dynamic> toMap() {
//     return {'name': name, 'type': type.name};
//   }

//   factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
//     return CategoryModel(
//       id: id,
//       name: map['name'] ?? '',
//       type: CategoryType.values.firstWhere(
//         (e) => e.name == map['type'],
//         orElse: () => CategoryType.expense,
//       ),
//       isDefault: false,
//     );
//   }
// }





/// Categories are scoped by type — "Food" belongs to expenses,
/// "Salary" belongs to income, "Subscription" belongs to reminders.
/// Keeping them as separate lists prevents an expense category showing
/// up as an option while adding income (or a reminder).
enum CategoryType { expense, income, reminder }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;

  /// True for the built-in categories ("Food", "Salary", etc.) that
  /// ship with the app and are never stored in Firestore. False for
  /// anything the user added themselves through Manage Categories.
  /// Only non-default categories can be deleted.
  final bool isDefault;

  /// Key into categoryIconLibrary (see category_icons.dart) for the
  /// icon the user picked when creating this category. Null for every
  /// built-in category (they use the name-based fallback instead) and
  /// for any custom category saved before icon picking existed.
  final String? iconKey;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.isDefault = false,
    this.iconKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      if (iconKey != null) 'iconKey': iconKey,
    };
  }

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      type: CategoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => CategoryType.expense,
      ),
      isDefault: false,
      iconKey: map['iconKey'],
    );
  }
}