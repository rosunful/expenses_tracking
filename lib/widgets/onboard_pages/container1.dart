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
          anyWidget:
              //THIS PADDING IS FOR THE TO MAKE THE BAR TO BE IN GOOD POSITION
              Padding(
                padding: const EdgeInsets.all(40.0),

                //THIS IS FOR THE STRAIGHT BAR LINE
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLine,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 62,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLongerLine,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLine,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLongerLine,
                      ),
                    ),
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
}
