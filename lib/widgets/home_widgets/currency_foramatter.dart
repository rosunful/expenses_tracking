String formatCurrency(
  double amount, {
  bool showSign = false,
  String symbol = '\$',
}) {
  final isNegative = amount < 0;

  final absAmount = amount.abs();

  final fixed = absAmount.toStringAsFixed(2);

  final parts = fixed.split('.');

  final wholePart = parts[0];

  final decimalPart = parts[1];

  final buffer = StringBuffer();

  for (int i = 0; i < wholePart.length; i++) {
    if (i != 0 && (wholePart.length - i) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(wholePart[i]);
  }

  final sign = isNegative ? '-' : (showSign ? '+' : '');

  return '$sign$symbol$buffer.$decimalPart';
}







// String formatCurrency(double amount, {bool showSign = false}) {
//   final isNegative = amount < 0;
//   final absAmount = amount.abs();
//   final fixed = absAmount.toStringAsFixed(2);
//   final parts = fixed.split('.');
//   final wholePart = parts[0];
//   final decimalPart = parts[1];

//   final buffer = StringBuffer();
//   for (int i = 0; i < wholePart.length; i++) {
//     if (i != 0 && (wholePart.length - i) % 3 == 0) buffer.write(',');
//     buffer.write(wholePart[i]);
//   }

//   final sign = isNegative ? '-' : (showSign ? '+' : '');
//   return '$sign\$$buffer.$decimalPart';
// }