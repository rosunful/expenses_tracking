import 'package:flutter/material.dart';

class FundingGoalSection extends StatelessWidget {
  const FundingGoalSection({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Emergency Fund Goal"),
                    Text("\$2,100 of \$5,000 saved"),
                  ],
                ),
              ],
            ),
          ),
        ),

        //THIS IS THE AREA OF THE RECENT TRANSACTION + SEE ALL BUTTON
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Recent Transactions"), Text("Sell all")],
          ),
        ),
      ],
    );
  }
}
