import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get width => screenSize.width;
  double get height => screenSize.height;

  // bonus: percentage helpers, since you'll use these a lot
  double widthPercent(double percent) => width * percent;
  double heightPercent(double percent) => height * percent;
}