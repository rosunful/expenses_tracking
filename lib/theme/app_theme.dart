import 'package:flutter/material.dart';

class AppTheme {
  // ---- Shared brand colors ----
  static const Color _accentGreen = Color(0xFF28A873);
  static const Color _incomeGreen = Color(0xFF28A873);
  static const Color _expenseRed = Color(0xFFE5484D);

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7FAF8), //using
    fontFamily: 'Inter', // swap for whatever font you're using
    colorScheme: const ColorScheme.light(
      primary: _accentGreen,
      secondary: _accentGreen,
      surface: Colors.white,
      //THIS HAS BEEN THE COLOR OF THE TEXT LIKE USERNAME
      onSurface: Color(0xFF1A1A1A),
    ),
    cardColor: Colors.white,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
      bodyMedium: TextStyle(color: Color(0xFF8A8E94)),
      titleLarge: TextStyle(
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: _accentGreen,
      unselectedItemColor: Color(0xFF75857C),
    ),
    extensions: const [
      AppColors(
        balanceCardBackground: Color(0xFF1C6B47),
        balanceCardText: Colors.white,
        balanceCardSubtext: Color(0xCCFFFFFF),
        incomeText: _incomeGreen,
        expenseText: _expenseRed,
        progressTrack: Color(0xFFE4E6E9),
        toggleBackground: Color(0xFFEDEEF0),
        card: Colors.white,
        verticalLine: Color(0xFFB8E6D1),
        verticalLongerLine: _accentGreen,
        navBarBackground: Colors.white,
        activeIcon: _accentGreen,
        inactiveIcon: Color(0xFFB0B4B9),
        fabColor: _accentGreen,
        skipText: Color.fromARGB(255, 62, 69, 66),
        cardsBackground: Color(0xFFEEF3F0),
        smallCardBg: Color(0xFFEEF3F0),
        smallCardIconBackground: Color(0xFFDCECDF),
        emergencyFundCircleRound: Color(0xFFD9E3DD),
        progressBar: Color(0xFF1C6B47),
        searchBarColor: Color(0xFFEEF3F0),
        logoutButtonColor: Color(0xFFFCE4DE),
        logoutButtonTextColor: Color(0xFFC8412A),
        blueColor: Color(0xFF3457C9),

        paragraphColor:Color.fromARGB(255, 171, 175, 173),
      ),
    ],
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1A15), //using
    colorScheme: const ColorScheme.dark(
      primary: _accentGreen,
      secondary: _accentGreen,
      surface: Color(0xFF1A1C1E),
      onSurface: Color(0xFFF5F5F5),
    ),
    cardColor: const Color(0xFF1A1C1E),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1C1E),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF5F5F5)),
      bodyMedium: TextStyle(color: Color(0xFF8E9297)),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF111F18),
      selectedItemColor: _accentGreen,
      unselectedItemColor: Color(0xFF5C6066),
    ),
    extensions: const [
      AppColors(
        balanceCardBackground: Color(0xFF3DDC97),
        balanceCardText: Color(0xFF0E0F10),
        balanceCardSubtext: Color(0xFF13473A),
        incomeText: Color(0xFF3EE6A8),
        expenseText: Color(0xFFFF6B6B),
        progressTrack: Color(0xFF2A2D30),
        toggleBackground: Color(0xFF1A1C1E),
        card: Color(0xFF1A1C1E),
        verticalLine: Color(0xFF2D5C4A),
        verticalLongerLine: Color(0xFF3EE6A8),
        navBarBackground: Color(0xFF11241C),
        activeIcon: Color(0xFF34D399),
        inactiveIcon: Color(0xFF5C6066),
        fabColor: Color(0xFF34D399),
        skipText: Color.fromARGB(255, 171, 175, 173),
        cardsBackground: Color(0xFF17291F),
        smallCardBg: Color(0xFF17291F),
        smallCardIconBackground: Color(0xFF1E3D2C),
        emergencyFundCircleRound: Color(0xFF234030),
        progressBar: Color(0xFF1C6B47),
        searchBarColor: Color(0xFF17291F),
        logoutButtonColor: Color(0xFF4A2420),
        logoutButtonTextColor: Color(0xFFEF6A52),
        blueColor: Color(0xFF3457C9),

        paragraphColor:Color.fromARGB(255, 171, 175, 173),
      ),
    ],
  );
}

/////////////APP COLOR PART////////////////

class AppColors extends ThemeExtension<AppColors> {
  final Color balanceCardBackground;
  final Color balanceCardText;
  final Color balanceCardSubtext;
  final Color incomeText;
  final Color expenseText;
  final Color progressTrack;
  final Color toggleBackground;

  final Color card;
  final Color verticalLine;
  final Color verticalLongerLine;
  final Color navBarBackground;
  final Color activeIcon;
  final Color inactiveIcon;
  final Color fabColor;

  //THIS IS COLOR ADDED FOR TEXT
  //FOR THE SKIP TEXT
  final Color skipText;

  //THIS COLOR IS FOR THE CARD BACKGROUND
  final Color cardsBackground;

  //THIS COLOR IS FOR THE SMALL CARD BACKGROUND
  final Color smallCardBg;

  //THIS COLOR IS FOR THE ICON BACKGROUND
  final Color smallCardIconBackground;

  //THIS IS FOR THR EMERGENCY FUND CIRCLE ROUND
  final Color emergencyFundCircleRound;

  //THIS COLOR IS FOR THE PROGRESS BAR
  final Color progressBar;

  //THIS COLOR IS FOR SEARCH BAR
  final Color searchBarColor;

  //THIS COLOR IS FOR LOGOUT BUTTON
  final Color logoutButtonColor;

  //THIS COLOR IS FOR THE LOGOUT BUTTON TEXT
  final Color logoutButtonTextColor;

  //THIS COLOR IS FOR THE ALL BLUE COLOR THAT HAS BEEN IN THE APP
  final Color blueColor;

  //THIS COLOR IS FOR THE SUB HEADING KO NI HEADING LIKE GREY TYPE TEXT KO LAGI
  final Color paragraphColor;

  const AppColors({
    required this.balanceCardBackground,
    required this.balanceCardText,
    required this.balanceCardSubtext,
    required this.incomeText,
    required this.expenseText,
    required this.progressTrack,
    required this.toggleBackground,
    required this.card,
    required this.verticalLine,
    required this.verticalLongerLine,
    required this.navBarBackground,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.fabColor,
    required this.skipText,
    required this.cardsBackground,
    required this.smallCardBg,
    required this.smallCardIconBackground,
    required this.emergencyFundCircleRound,
    required this.progressBar,
    required this.searchBarColor,
    required this.logoutButtonColor,
    required this.logoutButtonTextColor,
    required this.blueColor,
    required this.paragraphColor,
  });

  @override
  AppColors copyWith({
    Color? balanceCardBackground,
    Color? balanceCardText,
    Color? balanceCardSubtext,
    Color? incomeText,
    Color? expenseText,
    Color? progressTrack,
    Color? toggleBackground,
    Color? card,
    Color? verticalLine,
    Color? verticalLongerLine,
    Color? navBarBackground,
    Color? activeIcon,
    Color? inactiveIcon,
    Color? fabColor,
    Color? skipText,
    Color? cardsBackground,
    Color? smallCardBg,
    Color? smallCardIconBackground,
    Color? emergencyFundCircleRound,
    Color? progressBar,
    Color? searchBarColor,
    Color? logoutButtonColor,
    Color? logoutButtonTextColor,
    Color? blueColor,
    Color? paragraphColor,
  }) {
    return AppColors(
      balanceCardBackground:
          balanceCardBackground ?? this.balanceCardBackground,
      balanceCardText: balanceCardText ?? this.balanceCardText,
      balanceCardSubtext: balanceCardSubtext ?? this.balanceCardSubtext,
      incomeText: incomeText ?? this.incomeText,
      expenseText: expenseText ?? this.expenseText,
      progressTrack: progressTrack ?? this.progressTrack,
      toggleBackground: toggleBackground ?? this.toggleBackground,
      card: card ?? this.card,
      verticalLine: verticalLine ?? this.verticalLine,
      verticalLongerLine: verticalLongerLine ?? this.verticalLongerLine,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      activeIcon: activeIcon ?? this.activeIcon,
      inactiveIcon: inactiveIcon ?? this.inactiveIcon,
      fabColor: fabColor ?? this.fabColor,
      skipText: skipText ?? this.skipText,
      cardsBackground: cardsBackground ?? this.cardsBackground,
      smallCardBg: smallCardBg ?? this.smallCardBg,
      smallCardIconBackground:
          smallCardIconBackground ?? this.smallCardIconBackground,
      emergencyFundCircleRound:
          emergencyFundCircleRound ?? this.emergencyFundCircleRound,
      progressBar: progressBar ?? this.progressBar,
      searchBarColor: searchBarColor ?? this.searchBarColor,
      logoutButtonColor: logoutButtonColor ?? this.logoutButtonColor,
      logoutButtonTextColor:
          logoutButtonTextColor ?? this.logoutButtonTextColor,
      blueColor: blueColor ?? this.blueColor,
      paragraphColor: paragraphColor ?? this.paragraphColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    return this;
  }


}

// Handy shortcut extension
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

//Handy shortcut extension for themedata (textTheme+colorScheme+card)
extension ThemeX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
