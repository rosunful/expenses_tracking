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
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 225, 225, 225),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),

          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Icon(Icons.do_disturb_on_outlined)),
                  Text(
                    "Add \n Expense",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
       Container(
          decoration: BoxDecoration(
           color: const Color.fromARGB(255, 225, 225, 225),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),

          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Icon(Icons.add_circle_outline_rounded)),
                  Text(
                    "Add \n Income",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
