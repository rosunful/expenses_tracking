import 'package:expense_tracking/screens/activity_screen.dart';
import 'package:expense_tracking/screens/analytics_screen.dart';
import 'package:expense_tracking/screens/home_screen.dart';
import 'package:expense_tracking/screens/profile_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/theme/app_theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking/widgets/nav_bar_widgets/custom_bottomNavBar.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
  static const _pages = [
    HomeScreen(),
    ActivityScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BottomNav>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            height: 40,
            width: double.infinity,
            child: Switch(
              value: context.watch<ThemeNotifier>().themeMode == ThemeMode.dark,
              onChanged: (_) => context.read<ThemeNotifier>().toggleTheme(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          // preserves each tab's state — you already use this pattern
          index: vm.selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appColors.fabColor,
        ),
        child: IconButton(
          icon: Icon(Icons.add, color: Colors.black, size: 28),
          onPressed: () {
            // open add expense/income bottom sheet
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
