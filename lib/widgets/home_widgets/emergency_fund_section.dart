import 'package:flutter/material.dart';

class EmergencyFundSection extends StatelessWidget {
  const EmergencyFundSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        color: Colors.blueGrey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Budget - Food & Dining"),
                  Text("\$340 / \$500"),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 6,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
