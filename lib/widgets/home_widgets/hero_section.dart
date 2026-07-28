import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 2, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          color: context.appColors.balanceCardBackground,
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total balance",
                style: TextStyle(color: context.appColors.balanceCardSubtext),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 20),
                child: Text(
                  "\$12,480.50",
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
                        style: TextStyle(
                          color: context.appColors.balanceCardSubtext,
                        ),
                      ),
                      Text(
                        "\$4,250.00",
                        style: TextStyle(
                          color: context.appColors.balanceCardText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expense",
                        style: TextStyle(
                          color: context.appColors.balanceCardSubtext,
                        ),
                      ),
                      Text(
                        "\$171.09",
                        style: TextStyle(
                          color: context.appColors.balanceCardText,
                        ),
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
