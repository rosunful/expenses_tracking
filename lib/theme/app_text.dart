import 'package:flutter/material.dart';

class AppTextTheme {
  static const TextTheme textTheme = TextTheme(
    //THIS IS FOR THE BIG HEADING TEXT
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),

    //THIS IS FOR THE SUB HEADING TEXT
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),

    //THIS IS FOR THE SMALL HEADING TEXT
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),

    //THIS IS FOR THE BODY TEXT SIZE
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),

    //THIS IS FOR THE MEDIUM TYPE TEXT
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),

    //THIS IS FOR THE SMALL TYPE SIZE TEXT
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
  );
}