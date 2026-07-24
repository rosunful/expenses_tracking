import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//HEADING TEXT
class HeadingText extends StatelessWidget {
  final String headingText;

  const HeadingText(this.headingText, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      headingText,
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color:Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

//SUB-HEADING TEXT
class SubHeading extends StatelessWidget {
  final String subHeading;

  const SubHeading(this.subHeading, {super.key});

  // Text('Plan smarter budgets', style: Theme.of(context).textTheme.headlineMedium)

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Text(
        subHeading,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color:context.textTheme.bodyMedium?.color,
        )
      ),
    );
  }
}
