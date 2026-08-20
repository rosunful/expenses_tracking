import 'package:expense_tracking/screens/nav_activity_screen.dart';
import 'package:expense_tracking/screens/add_expenses_screen.dart';
import 'package:expense_tracking/screens/nav_analytics_screen.dart';
import 'package:expense_tracking/screens/nav_home_screen.dart';
import 'package:expense_tracking/screens/nav_profile_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking/widgets/nav_bar_widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPage();
}

class _LandingPage extends State<LandingPage> {
  static final _pages = [
    const HomeScreen(),
    const ActivityScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BottomNav>();
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          // preserves each tab's state
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
          border: Border.all(
            width: 2,
            color: context.appColors.navBarBackground,
            style: BorderStyle.solid,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.add,
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddExpensesScreen(),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
