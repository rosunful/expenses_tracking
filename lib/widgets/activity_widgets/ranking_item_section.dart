import 'package:flutter/material.dart';

class TopCategoryCard extends StatelessWidget {
  const TopCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 216, 216, 216),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(width: 12),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Top category: Shopping",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Based on this month's activity",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

