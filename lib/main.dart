import 'package:expense_tracking/screens/starting_onboard.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/theme/app_theme_notifier.dart';
import 'package:expense_tracking/widgets/nav_bar_widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNav()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
     final themeNotifier = context.watch<ThemeNotifier>(); 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.themeMode, 
      home: const StartingOnboard(),
    );
  }
}