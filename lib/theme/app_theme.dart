import 'package:flutter/material.dart';

class AppTheme {
  // ---- Shared brand colors ----
  static const Color _accentGreen = Color(0xFF28A873);
  static const Color _incomeGreen = Color(0xFF28A873);
  static const Color _expenseRed = Color(0xFFE5484D);

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F6F8),
    fontFamily: 'Inter', // swap for whatever font you're using
    colorScheme: const ColorScheme.light(
      primary: _accentGreen,
      secondary: _accentGreen,
      surface: Colors.white,
      onSurface: Color(0xFF1A1A1A),
      background: Color(0xFFF5F6F8),
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
      titleLarge: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _accentGreen,
      unselectedItemColor: Color(0xFFB0B4B9),
    ),
    extensions: const [
      AppColors(
      balanceCardBackground: Color(0xFF1B5E4A),
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
      ),
    ],
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E0F10),
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: _accentGreen,
      secondary: _accentGreen,
      surface: Color(0xFF1A1C1E),
      onSurface: Color(0xFFF5F5F5),
      background: Color(0xFF0E0F10),
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
      backgroundColor: Color(0xFF1A1C1E),
      selectedItemColor: _accentGreen,
      unselectedItemColor: Color(0xFF5C6066),
    ),
    extensions: const [
      AppColors(
      balanceCardBackground: Color(0xFF1FE0A3),
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
      ),
    ],
  );
}


/////////////APP COLOR PART////////////////


// class AppColors extends ThemeExtension<AppColors> {
//   final Color balanceCardBackground;
//   final Color balanceCardText;
//   final Color balanceCardSubtext;
//   final Color incomeText;
//   final Color expenseText;
//   final Color progressTrack;
//   final Color toggleBackground;

//   const AppColors({
//     required this.balanceCardBackground,
//     required this.balanceCardText,
//     required this.balanceCardSubtext,
//     required this.incomeText,
//     required this.expenseText,
//     required this.progressTrack,
//     required this.toggleBackground,
//   });

//   @override
//   AppColors copyWith({
//     Color? balanceCardBackground,
//     Color? balanceCardText,
//     Color? balanceCardSubtext,
//     Color? incomeText,
//     Color? expenseText,
//     Color? progressTrack,
//     Color? toggleBackground,
//   }) {
//     return AppColors(
//       balanceCardBackground: balanceCardBackground ?? this.balanceCardBackground,
//       balanceCardText: balanceCardText ?? this.balanceCardText,
//       balanceCardSubtext: balanceCardSubtext ?? this.balanceCardSubtext,
//       incomeText: incomeText ?? this.incomeText,
//       expenseText: expenseText ?? this.expenseText,
//       progressTrack: progressTrack ?? this.progressTrack,
//       toggleBackground: toggleBackground ?? this.toggleBackground,
//     );
//   }

//   @override
//   AppColors lerp(ThemeExtension<AppColors>? other, double t) {
//     if (other is! AppColors) return this;
//     return AppColors(
//       balanceCardBackground: Color.lerp(balanceCardBackground, other.balanceCardBackground, t)!,
//       balanceCardText: Color.lerp(balanceCardText, other.balanceCardText, t)!,
//       balanceCardSubtext: Color.lerp(balanceCardSubtext, other.balanceCardSubtext, t)!,
//       incomeText: Color.lerp(incomeText, other.incomeText, t)!,
//       expenseText: Color.lerp(expenseText, other.expenseText, t)!,
//       progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
//       toggleBackground: Color.lerp(toggleBackground, other.toggleBackground, t)!,
//     );
//   }
// }


class AppColors extends ThemeExtension<AppColors> {
  final Color balanceCardBackground;
  final Color balanceCardText;
  final Color balanceCardSubtext;
  final Color incomeText;
  final Color expenseText;
  final Color progressTrack;
  final Color toggleBackground;

  // 👇 new fields
  final Color card;
  final Color verticalLine;
  final Color verticalLongerLine;
  final Color navBarBackground;
  final Color activeIcon;
  final Color inactiveIcon;
  final Color fabColor;

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
  }) {
    return AppColors(
      balanceCardBackground: balanceCardBackground ?? this.balanceCardBackground,
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
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      balanceCardBackground: Color.lerp(balanceCardBackground, other.balanceCardBackground, t)!,
      balanceCardText: Color.lerp(balanceCardText, other.balanceCardText, t)!,
      balanceCardSubtext: Color.lerp(balanceCardSubtext, other.balanceCardSubtext, t)!,
      incomeText: Color.lerp(incomeText, other.incomeText, t)!,
      expenseText: Color.lerp(expenseText, other.expenseText, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      toggleBackground: Color.lerp(toggleBackground, other.toggleBackground, t)!,
      card: Color.lerp(card, other.card, t)!,
      verticalLine: Color.lerp(verticalLine, other.verticalLine, t)!,
      verticalLongerLine: Color.lerp(verticalLongerLine, other.verticalLongerLine, t)!,
      navBarBackground: Color.lerp(navBarBackground, other.navBarBackground, t)!,
      activeIcon: Color.lerp(activeIcon, other.activeIcon, t)!,
      inactiveIcon: Color.lerp(inactiveIcon, other.inactiveIcon, t)!,
      fabColor: Color.lerp(fabColor, other.fabColor, t)!,
    );
  }
}

// Handy shortcut extension
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}