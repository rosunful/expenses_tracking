import 'package:expense_tracking/widgets/onboard_widgets/card.dart';
import 'package:expense_tracking/widgets/onboard_widgets/text_headingANDsubheading.dart.dart';
import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

class Container5 extends StatelessWidget {
  const Container5({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CardContainer(
          anyWidget: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Stack(
                children: [
                  HexagonWidget.flat(
                    width: 70,
                    color: const Color(0xFF47E0A1),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black87,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        HeadingText("Bank-level security"),
        
         //THIS IS THE PADDING FOR THE BOX CONTAINER
        const SizedBox(height: 10),
        
        //SUB HEADING
        SubHeading(
          "Face ID, PIN lock and encrypted backups keep your data yours alone.",
        ),

      ],
    );
  }
}

