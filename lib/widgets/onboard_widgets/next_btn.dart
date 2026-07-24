import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NextButton extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;

  const NextButton({
    super.key,
    required this.currentPage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onNext,
        child: Text(currentPage == 4 ? "Get Started" : "Next", 
        style: GoogleFonts.inter(color:Theme.of(context).colorScheme.onSurface, 
        fontWeight: FontWeight.w700),),
      ),
    );
  }
}
