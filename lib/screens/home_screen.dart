import 'package:expense_tracking/theme/app_theme_notifier.dart';
import 'package:expense_tracking/widgets/home_widgets/adding_expense_section.dart';
import 'package:expense_tracking/widgets/home_widgets/emergency_fund_section.dart';
import 'package:expense_tracking/widgets/home_widgets/funding_goal_section.dart';
import 'package:expense_tracking/widgets/home_widgets/header_section.dart';
import 'package:expense_tracking/widgets/home_widgets/hero_section.dart';
import 'package:expense_tracking/widgets/home_widgets/transaction_history_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [

                //THIS IS THE PART OF THE GOOD MORNING ROW AND THE THEME CHANGED ROW
                HeaderSection(value: isDark),

                //THIS IS THE AREA OF THE ADD EXPENSES , ADD INCOME , TRANSFER + SCAN
                HeroSection(),

                //THIS IS THE AREA OF THE BUDGET-FOOD & DINING
                AddingExpenseSection(),

                //THIS IS THE AREA OF THE EMERGENCY FUND GOAL
                EmergencyFundSection(),

                //THIS IS THE FUNDING GOAL + SEE ALL TRANCTION HISTORY BUTTON
                FundingGoalSection(),

                //THIS IS THE PART OF THE MONEY SPEND HISTORY LISTS
                TransactionHistorySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
