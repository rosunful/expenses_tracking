import 'package:expense_tracking/screens/bills_subscription_screen.dart';
import 'package:expense_tracking/screens/nav_activity_screen.dart';
import 'package:expense_tracking/screens/saving_goal_screen.dart';
import 'package:expense_tracking/widgets/home_widgets/adding_expense_section.dart';
import 'package:expense_tracking/widgets/home_widgets/bill_reminder_section.dart';
import 'package:expense_tracking/widgets/home_widgets/budget_progressbar_section.dart';
import 'package:expense_tracking/widgets/home_widgets/emergency_funding_goal_section.dart';
import 'package:expense_tracking/widgets/home_widgets/header_section.dart';
import 'package:expense_tracking/widgets/home_widgets/hero_section.dart';
import 'package:expense_tracking/widgets/home_widgets/transaction_history_section.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                // Good morning/afternoon/evening + name, theme toggle
                HeaderSection(),

                // Total balance / income / expense
                const HeroSection(),

                // Add Expense / Add Income / Transfer / Scan
                const AddingExpenseSection(),

                // Whichever budget is closest to (or over) its limit
                const BudgetProgressbarSection(),

                // Emergency fund / savings goal card — tap opens the
                // full Savings Goals screen.
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavingsGoalsScreen(),
                    ),
                  ),
                  child: const FundingGoalSection(),
                ),
                const SizedBox(height: 4,),

                // Latest transactions, newest first.
                TransactionHistorySection(
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivityScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: 4,),

                // New: upcoming bills/subscriptions with a badge count.
                BillsReminderSection(
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BillsSubscriptionsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
