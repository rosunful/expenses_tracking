import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isExpense;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.isExpense,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1F7A53),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          isExpense ? "Save Expense" : "Save Income",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
