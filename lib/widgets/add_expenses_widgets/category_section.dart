import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySection({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories = const [
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Entertainment",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CATEGORY",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.map((category) {
            final isSelected = category == selectedCategory;

            return GestureDetector(
              onTap: () => onSelected(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.cyanAccent : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
