import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(20),
      child: Container(
        width: double.infinity,
        color: Colors.greenAccent,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total baclance"),
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 25),
                child: Text("12,480.50"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("Income"), Text("\$4,250.00")],
                  ),
                  SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("Expense"), Text("\$171.09")],
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
