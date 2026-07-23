import 'dart:math' as math;
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/onboard_widgets/card.dart';
import 'package:expense_tracking/widgets/onboard_widgets/text_headingANDsubheading.dart.dart';
import 'package:flutter/material.dart';

class Container4 extends StatelessWidget {
  const Container4({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CardContainer(
          anyWidget: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Stack(
              alignment: AlignmentGeometry.bottomCenter,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: Offset(0, 28),
                    child: Transform.rotate(
                      angle:
                          -math.pi / 24, // Rotates 45 degrees counter-clockwise
                      child: Container(
                        width: double.infinity,
                        height: 1.5,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLine,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLine,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLongerLine,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLongerLine,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 12,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: context.appColors.verticalLine,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Column(
          children: [
            //HEADING
            HeadingText("See the full picture"),

            //THIS IS THE PADDING FOR THE BOX CONTAINER
            const SizedBox(height: 10),

            //SUB HEADING
            SubHeading("Rich analytics reveal exactly where your money goes."),
          ],
        ),
      ],
    );
  }
}
