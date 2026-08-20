// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class HeroSection extends StatefulWidget {
//   const HeroSection({super.key});

//   @override
//   State<HeroSection> createState() => _HeroSectionState();
// }

// class _HeroSectionState extends State<HeroSection> {
//   bool _showFullValue = false;

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<ExpensesController>();
//     final income = controller.totalIncome;
//     final expense = controller.totalExpenses;
//     final balance = income - expense;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: const BorderRadius.all(Radius.circular(24)),
//           color: context.appColors.balanceCardBackground,
//         ),
//         width: double.infinity,
//         child: Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "TOTAL BALANCE",
//                     style: TextStyle(
//                       color: context.appColors.balanceCardSubtext,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _showFullValue = !_showFullValue;
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: context.appColors.balanceCardSubtext
//                             .withValues(alpha: 0.2),
//                       ),
//                       child: Text(
//                         _showFullValue ? "ABBR" : "FULL",
//                         style: TextStyle(
//                           color: context.appColors.balanceCardSubtext,
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _showFullValue = !_showFullValue;
//                   });
//                 },
//                 child: SizedBox(
//                   height: 30,
//                   width: double.infinity,
//                   child: FittedBox(
//                     fit: BoxFit.scaleDown,
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       _showFullValue
//                           ? _formatFullCurrency(balance)
//                           : _formatAbbreviatedCurrency(balance),
//                       style: TextStyle(
//                         color: context.appColors.balanceCardText,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   _buildBalanceItem(
//                     context,
//                     label: "Income",
//                     value: income,
//                   ),
//                   const SizedBox(width: 24),
//                   _buildBalanceItem(
//                     context,
//                     label: "Expense",
//                     value: expense,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBalanceItem(
//     BuildContext context, {
//     required String label,
//     required double value,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: context.appColors.balanceCardSubtext,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               _showFullValue = !_showFullValue;
//             });
//           },
//           child: Text(
//             _showFullValue
//                 ? _formatFullCurrency(value)
//                 : _formatAbbreviatedCurrency(value),
//             style: TextStyle(
//               color: context.appColors.balanceCardText,
//               fontWeight: FontWeight.w500,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatFullCurrency(double amount) {
//     return '\$${amount.toStringAsFixed(2)}';
//   }

//   String _formatAbbreviatedCurrency(double amount) {
//     if (amount.abs() >= 1e12) {
//       return '\$${(amount / 1e12).toStringAsFixed(1)}T';
//     } else if (amount.abs() >= 1e9) {
//       return '\$${(amount / 1e9).toStringAsFixed(1)}B';
//     } else if (amount.abs() >= 1e6) {
//       return '\$${(amount / 1e6).toStringAsFixed(1)}M';
//     } else if (amount.abs() >= 1e3) {
//       return '\$${(amount / 1e3).toStringAsFixed(1)}K';
//     } else {
//       return '\$${amount.toStringAsFixed(2)}';
//     }
//   }
// }




import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/home_widgets/currency_foramatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpensesController>();
    final income = expenses.totalIncome;
    final expense = expenses.totalExpenses;
    final balance = income - expense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: context.appColors.balanceCardBackground,
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TOTAL BALANCE",
                style: TextStyle(color: context.appColors.balanceCardSubtext),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  // Give it a max height so it doesn't grow vertically
                  height: 30,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // Shrinks text to fit width
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatCurrency(balance),
                      style: TextStyle(
                        color: context.appColors.balanceCardText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                         overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatCurrency(income),
                        style: TextStyle(
                          color: context.appColors.balanceCardText,
                          fontWeight: FontWeight(500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
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
                        formatCurrency(expense),
                        style: TextStyle(
                          color: context.appColors.balanceCardText,
                          fontWeight: FontWeight(500),
                          
                        ),
                        overflow: TextOverflow.ellipsis,                        
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
