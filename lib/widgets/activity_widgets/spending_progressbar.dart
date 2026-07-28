import 'package:flutter/material.dart';


class SpendingCategoryCard extends StatelessWidget {
  const SpendingCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 216, 216, 216),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Spending by category",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black
              ),
            ),
          ),

          const SizedBox(height: 18),

          _item("Shopping", 0.95, "\$72.40"),

          const SizedBox(height: 14),

          _item("Food", 0.65, "\$64.20"),

          const SizedBox(height: 14),

          _item("Transport", 0.35, "\$18.50"),

          const SizedBox(height: 14),

          _item("Entertainment", 0.15, "\$15.99"),
        ],
      ),
    );
  }

  Widget _item(
      String title,
      double value,
      String amount,
      ) {
    return Column(
      children: [

        Row(
          children: [

            Text(title, style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600
            ),),

            const Spacer(),

            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black
              ),
            )
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}


