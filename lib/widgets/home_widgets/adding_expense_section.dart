import 'package:expense_tracking/screens/add_expenses_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
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
        InkWell(
          onTap: () {

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AddExpensesScreen(),));
          },
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.cardsBackground,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),

            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.appColors.cardsBackground,
                        ),
                        child: Icon(Icons.do_disturb_on_outlined),
                      ),
                    ),
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
        ),

        SizedBox(width: 8),
        InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.cardsBackground,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),

            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.appColors.cardsBackground,
                        ),
                        child: Icon(Icons.add),
                      ),
                    ),
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
        ),
      ],
    );
  }
}
