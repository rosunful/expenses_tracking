import 'package:flutter/material.dart';

class TransactionHistorySection extends StatelessWidget {
  const TransactionHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.green,
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Whole Foods Market"),
                        Text("Food - Today"),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text("-\$64.20"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Whole Foods Market"),
                        Text("Food - Today"),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text("-\$64.20"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Whole Foods Market"),
                        Text("Food - Today"),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text("-\$64.20"),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Whole Foods Market"),
                        Text("Food - Today"),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text("-\$64.20"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
