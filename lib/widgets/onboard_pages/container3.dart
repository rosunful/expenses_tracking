import 'package:expense_tracking/widgets/onboard_widgets/card.dart';
import 'package:expense_tracking/widgets/onboard_widgets/text_headingANDsubheading.dart.dart';
import 'package:flutter/material.dart';

class Container3 extends StatelessWidget {
  const Container3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CardContainer(
          anyWidget: Stack(
            children: [
              Center(
                child: Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromARGB(56, 61, 220, 151),
                      width: 1,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.fromARGB(214, 61, 220, 151),
                          width: 1.5,
                          style: BorderStyle.solid,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(203, 61, 220, 151),
                            shape: BoxShape.circle,
                            
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Column(
          children: [
           

            //THIS IS THE LARGE TYPE TEXT
            //FOR HEADING
            HeadingText("Reach your goals"),

             //THIS IS THE PADDING FOR THE BOX CONTAINER
            const SizedBox(height: 10),

            //FOR SUB HEADING
            SubHeading(
              "Save towards what matters - from an emergency fund to your next trip .",
            ),
          ],
        ),
      ],
    );
  }
}
