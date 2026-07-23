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
          backgroundColor: const Color(0xFF34D399),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onNext,
        child: Text(currentPage == 4 ? "Get Started" : "Next", 
        style: GoogleFonts.inter(color: Colors.black , 
        fontWeight: FontWeight.w700),),
      ),
    );
  }
}
