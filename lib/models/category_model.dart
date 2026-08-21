
enum CategoryType { expense, income, reminder }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;
  final bool isDefault;
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