import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const NumberPad({
    super.key,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      "1", "2", "3",
      "4", "5", "6",
      "7", "8", "9",
      ".", "0", "⌫",
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => onKeyPressed(keys[index]),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                keys[index],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}