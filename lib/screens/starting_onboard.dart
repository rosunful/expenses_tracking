import 'package:expense_tracking/screens/landing_page.dart';
import 'package:expense_tracking/screens/login_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/onboard_pages_widgets/container1.dart';
import 'package:expense_tracking/widgets/onboard_pages_widgets/container2.dart';
import 'package:expense_tracking/widgets/onboard_pages_widgets/container3.dart';
import 'package:expense_tracking/widgets/onboard_pages_widgets/container4.dart';
import 'package:expense_tracking/widgets/onboard_pages_widgets/container5.dart';
import 'package:expense_tracking/widgets/onboard_widgets/next_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:expense_tracking/theme/utils.dart';
import 'package:expense_tracking/providers/auth_provider.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.read<AuthProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(20, 10, 20, 60),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        _control.jumpToPage(4);
                      },
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).extension<AppColors>()!.skipText,
                        ),
                      ),
                    ),
                  ],
                ),

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

                Padding(
                  padding: const EdgeInsetsGeometry.fromLTRB(0, 0, 0, 24),
                  child: SmoothPageIndicator(
                    controller: _control,
                    count: 5,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6, // gap between dots
                      radius: 16,
                      activeDotColor: const Color(0xFF3DDC97),
                      dotColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

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
                            backgroundColor: Theme.of(
                              context,
                            ).extension<AppColors>()!.balanceCardBackground,
                            foregroundColor: context.appColors.balanceCardText,
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
                              color: Theme.of(context).colorScheme.surface,
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
                                builder: (context) {
                                  if (authProvider.isLoggedIn) {
                                    return const LandingPage();
                                  }

                                  return const LoginScreen();
                                },
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
