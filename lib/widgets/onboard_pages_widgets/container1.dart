import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/onboard_widgets/card.dart';
import 'package:expense_tracking/widgets/onboard_widgets/text_headingANDsubheading.dart.dart';
import 'package:flutter/material.dart';

class Container1 extends StatelessWidget {
  const Container1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CardContainer(
          anyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bar(32, context.appColors.verticalLine),
                _bar(62, context.appColors.verticalLongerLine),
                _bar(42, context.appColors.verticalLine),
                _bar(82, context.appColors.verticalLongerLine),
              ],
            ),
          ),
        ),

        HeadingText("Track every expense"),
        
         //THIS IS THE PADDING FOR THE BOX CONTAINER
        const SizedBox(height: 10),
        
        //THIS IS THE SUB TEXT
        SubHeading(
          "Log spending in seconds with smart categories and receipt capture. ",
        ),
      ],
    );
  }

  Widget _bar(double height, Color color) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color,
      ),
    );
  }
}
