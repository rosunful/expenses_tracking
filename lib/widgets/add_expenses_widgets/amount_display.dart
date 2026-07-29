import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final String amount;

  const AmountDisplay({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "AMOUNT",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "\$$amount",
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}