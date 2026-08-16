import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/providers/auth_provider.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/providers/category_provider.dart';
import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/providers/reminder_provider.dart';
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:expense_tracking/providers/transaction_provider.dart';
import 'package:expense_tracking/screens/starting_onboard.dart';
import 'package:expense_tracking/theme/app_navigation.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/theme/app_theme_notifier.dart';
import 'package:expense_tracking/widgets/nav_bar_widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNav()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => ExpensesController()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => SavingsGoalProvider()),
        ChangeNotifierProvider(create: (_) => NotifyingProvider()),
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
      themeAnimationDuration: Duration.zero,
      navigatorKey: appNavigatorKey, 
      home: const StartingOnboard(),
    );
  }
}
