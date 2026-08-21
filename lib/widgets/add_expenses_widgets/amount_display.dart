import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AmountDisplay extends StatelessWidget {
  final String amount;

  const AmountDisplay({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final String checkAmount = "0";
    final symbol = context.watch<CurrencyProvider>().selected.symbol;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$symbol$amount",
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: checkAmount == amount ? Colors.grey[400] : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}





























// import 'package:flutter/material.dart';

// class AmountDisplay extends StatelessWidget {
//   final String amount;

//   const AmountDisplay({super.key, required this.amount});

//   @override
//   Widget build(BuildContext context) {

//     final String checkAmount = "0";
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "\$$amount",
//             style: TextStyle(fontSize: 64, fontWeight: FontWeight.w700,
//             color:checkAmount == amount ? Colors.grey[400] : Theme.of(context).colorScheme.onSurface,
            
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
