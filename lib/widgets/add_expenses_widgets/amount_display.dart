import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final String amount;

  const AmountDisplay({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "\$$amount",
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
