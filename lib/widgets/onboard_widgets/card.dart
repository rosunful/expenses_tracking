import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CardContainer extends StatelessWidget {
  Widget anyWidget;
  CardContainer({super.key, required this.anyWidget});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //THIS IS THE PADDING FOR THE BOX CONTAINER
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: context.appColors.card,
              borderRadius: BorderRadius.all(Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurStyle: BlurStyle.normal,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),

            //THIS PADDING IS FOR THE TO MAKE THE BAR TO BE IN GOOD POSITION
            child: anyWidget,
          ),
        ),

        SizedBox(height: 8),
      ],
    );
  }
}
