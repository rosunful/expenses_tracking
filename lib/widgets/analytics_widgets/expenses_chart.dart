import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';

class ExpensesChart extends StatelessWidget {
  const ExpensesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExpensesController>();
    final income = controller.totalIncome;
    final expense = controller.totalExpenses;
    // Live symbol — see the note on aggregation: this sums raw amounts
    // regardless of each transaction's own locked currency, so it's
    // only fully accurate if your history is all one currency.
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

    // Scale both bars relative to whichever is larger, capped at 95px
    // (your original max height) so the chart never overflows.
    const maxBarHeight = 95.0;
    final largest = income > expense ? income : expense;
    // Avoid dividing by zero when there's no data yet.
    final scale = largest == 0 ? 0.0 : maxBarHeight / largest;

    // A tiny minimum height keeps a bar visibly present even for small
    // amounts, instead of it shrinking to an invisible sliver.
    double barHeight(double amount) =>
        amount == 0 ? 0 : (amount * scale).clamp(6.0, maxBarHeight);

    return 
 Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: context.appColors.cardsBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // spacing: 10,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Income vs Expense",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     _bar(
                      context: context,
                    height: barHeight(income),
                    color: Colors.green.shade700,
                    label: "Income",
                    amount: income,
                    symbol: symbol,
                  ),
                  _bar(
                    context: context,
                    height: barHeight(expense),
                    color: Colors.indigo,
                    label: "Expense",
                    amount: expense,
                    symbol: symbol,
                  ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _bar({
    required BuildContext context,
    required double height,
    required Color color,
    required String label,
    required double amount,
    required String symbol,
  }) {
    return Column(
      children: [
        Text(
          '$symbol${amount.toStringAsFixed(0)}',
          style:  TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface,),
        ),
        const SizedBox(height: 4),
        Container(
          width: 44,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 8),
        Text(label,  style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),),
      ],
    );
  }
}






    
    // Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   spacing: 10,
    //   children: [
       
    //     Container(
    //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    //       decoration: BoxDecoration(
    //         color: context.appColors.cardsBackground,
    //         borderRadius: BorderRadius.circular(20),
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           const Text(
    //             "Income vs Expense",
    //             style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
    //           ),
    //           const SizedBox(height: 24),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               _bar(
    //                 height: barHeight(income),
    //                 color: Colors.green.shade700,
    //                 label: "Income",
    //                 amount: income,
    //                 symbol: symbol,
    //               ),
    //               _bar(
    //                 height: barHeight(expense),
    //                 color: Colors.indigo,
    //                 label: "Expense",
    //                 amount: expense,
    //                 symbol: symbol,
    //               ),
    //             ],
    //           ),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  
  
  
//   }

//   Widget _bar({
//     required double height,
//     required Color color,
//     required String label,
//     required double amount,
//     required String symbol,
//   }) {
//     return Column(
//       children: [
//         Text(
//           '$symbol${amount.toStringAsFixed(0)}',
//           style: const TextStyle(fontSize: 12, color: Colors.black54),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           width: 44,
//           height: height,
//           decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
//         ),
//         const SizedBox(height: 8),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }































// #VERSION 1

// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';

// class ExpensesChart extends StatelessWidget {
//   const ExpensesChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<ExpensesController>();
//     final income = controller.totalIncome;
//     final expense = controller.totalExpenses;

//     // Scale both bars relative to whichever is larger, capped at 95px
//     // (your original max height) so the chart never overflows.
//     const maxBarHeight = 95.0;
//     final largest = income > expense ? income : expense;
//     // Avoid dividing by zero when there's no data yet.
//     final scale = largest == 0 ? 0.0 : maxBarHeight / largest;

//     // A tiny minimum height keeps a bar visibly present even for small
//     // amounts, instead of it shrinking to an invisible sliver.
//     double barHeight(double amount) =>
//         amount == 0 ? 0 : (amount * scale).clamp(6.0, maxBarHeight);

//     return 
// 
// Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 3.0),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//         decoration: BoxDecoration(
//           color: context.appColors.cardsBackground,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           // spacing: 10,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Income vs Expense",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     color: Theme.of(context).colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     _bar(
//                       context: context,
//                       height: barHeight(income),
//                       color: Colors.green.shade700,
//                       label: "Income",
//                       amount: income,
//                     ),
//                     _bar(
//                       context: context,
//                       height: barHeight(expense),
//                       color: Colors.indigo,
//                       label: "Expense",
//                       amount: expense,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _bar({
//     required BuildContext context,
//     required double height,
//     required Color color,
//     required String label,
//     required double amount,
//   }) {
//     return Column(
//       children: [
//         Text(
//           '\$${amount.toStringAsFixed(0)}',
//           style: TextStyle(
//             fontSize: 12,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           width: 44,
//           height: height,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Theme.of(context).colorScheme.onSurface,
//           ),
//         ),
//       ],
//     );
//   }
// }
