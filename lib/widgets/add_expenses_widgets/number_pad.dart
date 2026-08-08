import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(String) onKeyPressed;

  const NumberPad({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    final keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "⌫"];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onKeyPressed(keys[index]),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F2),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                keys[index] == '⌫' ? '⌫' : keys[index],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF26332C),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
