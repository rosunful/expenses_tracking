import 'package:expense_tracking/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ExpenseIncomeSwitch extends StatelessWidget {
  const ExpenseIncomeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffE9EEEA),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: provider.isExpense
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 40) / 2,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: provider.selectExpense,
                  child: Center(
                    child: Text(
                      "Expense",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: provider.isExpense
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: provider.selectIncome,
                  child: Center(
                    child: Text(
                      "Income",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: provider.isExpense
                            ? Colors.black54
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}