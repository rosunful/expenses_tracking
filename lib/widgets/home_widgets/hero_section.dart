import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/home_widgets/currency_foramatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpensesController>();
    final income = expenses.totalIncome;
    final expense = expenses.totalExpenses;
    final balance = income - expense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: context.appColors.balanceCardBackground,
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL BALANCE",
                style: TextStyle(color: context.appColors.balanceCardSubtext),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  formatCurrency(balance),
                  style: TextStyle(
                    color: context.appColors.balanceCardText,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Income",
                        style: TextStyle(color: context.appColors.balanceCardSubtext),
                      ),
                      Text(
                        formatCurrency(income),
                        style: TextStyle(color: context.appColors.balanceCardText, fontWeight: FontWeight(500),),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expense",
                        style: TextStyle(color: context.appColors.balanceCardSubtext),
                      ),
                      Text(
                        formatCurrency(expense),
                        style: TextStyle(color: context.appColors.balanceCardText , fontWeight: FontWeight(500)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}