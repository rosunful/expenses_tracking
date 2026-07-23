import 'package:expense_tracking/widgets/onboard_widgets/card.dart';
import 'package:expense_tracking/widgets/onboard_widgets/text_headingANDsubheading.dart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Container2 extends StatelessWidget {
  const Container2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CardContainer(
          anyWidget: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: 0.68,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFF1B2E23),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF34D399),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "68%",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "used",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        

        HeadingText("Plan smarter budgets"),

        const SizedBox(height: 10),
        
        SubHeading(
          "Set monthly limits per category and watch progress in real time.",
        ),
      ],
    );
  }
}
