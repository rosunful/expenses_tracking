import 'package:expense_tracking/widgets/activity_widgets/expenses_chart.dart';
import 'package:expense_tracking/widgets/activity_widgets/ranking_item_section.dart';
import 'package:expense_tracking/widgets/activity_widgets/spending_progressbar.dart';
import 'package:flutter/material.dart';
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [



              ExpensesChart(),

              

              SpendingCategoryCard(),

              

              TopCategoryCard(),
            ],
          ),
        ),
      ),
    );
  }
}






