import 'package:flutter/material.dart';

class ExpensesChart extends StatelessWidget {
  const ExpensesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          "Analytics",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
          color: Colors.black),
        ),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 216, 216, 216),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Income vs Expense",
                style: TextStyle(fontWeight: FontWeight.w600,
                color: Colors.black),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _bar(
                    height: 95,
                    color: Colors.green.shade700,
                    label: "Income",
                  ),

                  _bar(height: 12, color: Colors.indigo, label: "Expense"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bar({
    required double height,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        const SizedBox(height: 8),

        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
