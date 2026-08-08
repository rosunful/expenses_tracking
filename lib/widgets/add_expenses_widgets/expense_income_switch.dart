import 'package:expense_tracking/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseIncomeSwitch extends StatelessWidget {
  const ExpenseIncomeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xffE9EEEA),
        borderRadius: BorderRadius.circular(10),
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
              width: (MediaQuery.of(context).size.width - 46) / 2,
              decoration: BoxDecoration(
                color: const Color(0xFF1C6B47),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: provider.selectExpense,
                  child: Center(
                    child: Text(
                      "Expense",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
                  borderRadius: BorderRadius.circular(8),
                  onTap: provider.selectIncome,
                  child: Center(
                    child: Text(
                      "Income",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
