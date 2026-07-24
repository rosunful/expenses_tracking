import 'package:flutter/material.dart';

class AddingExpenseSection extends StatefulWidget {
  const AddingExpenseSection({super.key});

  @override
  State<AddingExpenseSection> createState() => _AddingExpenseSection();
}

class _AddingExpenseSection extends State<AddingExpenseSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: Colors.blueGrey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Center(child: Icon(Icons.do_not_disturb_on_sharp)),
                Text("Add Expenses"),
              ],
            ),
          ),
        ),
        SizedBox(width: 8),
        Container(
          color: Colors.blueGrey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Center(child: Icon(Icons.add)),
                Text("Add Income"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
