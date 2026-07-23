import 'package:expense_tracking/screens/landing_page.dart';
import 'package:expense_tracking/widgets/onboard_pages/container1.dart';
import 'package:expense_tracking/widgets/onboard_pages/container2.dart';
import 'package:expense_tracking/widgets/onboard_pages/container3.dart';
import 'package:expense_tracking/widgets/onboard_pages/container4.dart';
import 'package:expense_tracking/widgets/onboard_pages/container5.dart';
import 'package:expense_tracking/widgets/onboard_widgets/next_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:expense_tracking/theme/utils.dart';

class StartingOnboard extends StatefulWidget {
  const StartingOnboard({super.key});
  @override
  State<StartingOnboard> createState() => _StartingOnboard();
}

class _StartingOnboard extends State<StartingOnboard> {
  final PageController _control = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,

        systemNavigationBarColor: Color(0xFF0E1A14),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(20, 10, 20, 30),

            //THIS IS FOR THE WHOLE SCREEN CONTENT INSIDE
            //THE ONBOARDING SCREEN LIKE
            //SKIP + MIDDLE CONTENT + NEXT BUTTON AREA
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //THIS IS OF THE SKIP - AND WE WILL CREATE THE SEPERATE CLASS AND PUT IN HERE
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        _control.jumpToPage(4);
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),

                //THIS IS THE MIDDLE PART WHERE WE SHOW THE ICONS AND TITLE AND SUB TITLE
                //FOR THEM ALSO WE WILL CREATE THE CLASS AND CALL IN HERE
                Expanded(
                  child: PageView(
                    controller: _control,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      Container1(),
                      Container2(),
                      Container3(),
                      Container4(),
                      Container5(),
                    ],
                  ),
                ),

                //THIS IS FOR THE ANIMATION PAGE INDICATOR AND WE WILL CREATE THE CLASS AND
                //CALL THEM HERE TOO
                Padding(
                  padding: const EdgeInsetsGeometry.fromLTRB(0, 0, 0, 18),
                  child: SmoothPageIndicator(
                    controller: _control,
                    count: 5,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor:
                          3, // increase for a longer pill (try 3–4)
                      spacing: 6, // gap between dots
                      radius:
                          16, // corner rounding — high value = fully pill-shaped
                      activeDotColor: const Color(0xFF3DDC97),
                      dotColor: Colors.white24,
                    ),
                  ),
                ),

                //THIS IS THE BUTTON AREA HERE WILL WILL CREATE THE CLASS AND
                //CALL THEM HERE TO MAKE THE CODE READABLE
                if (_currentPage == 0)
                  Row(
                    children: [
                      NextButton(
                        currentPage: _currentPage,
                        onNext: () {
                          if (_currentPage == 4) {
                            debugPrint("Finished");
                          } else {
                            _control.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF17291F),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _control.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "Back",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color.fromARGB(199, 255, 255, 255),
                            ),
                          ),
                        ),
                        SizedBox(width: context.widthPercent(0.03)),
                      ],
                      NextButton(
                        currentPage: _currentPage,
                        onNext: () {
                          if (_currentPage == 4) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LandingPage(),
                              ),
                            );
                          } else {
                            _control.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
