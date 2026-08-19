import 'package:expense_tracking/screens/note_screen.dart';
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:expense_tracking/screens/about_us_screen.dart';
import 'package:expense_tracking/screens/bills_subscription_screen.dart';
import 'package:expense_tracking/screens/manage_category_screen.dart';
import 'package:expense_tracking/screens/report_screen.dart';
import 'package:expense_tracking/screens/saving_goal_screen.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/screens/budgets_palnner_screen.dart';
import 'package:expense_tracking/providers/auth_provider.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
import 'package:expense_tracking/providers/budgets_provider.dart';
import 'package:expense_tracking/models/budgets_model.dart';
import 'package:expense_tracking/controllers/budget_period_controller.dart';
import 'package:expense_tracking/screens/login_screen.dart';
import 'package:expense_tracking/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Averages how close each budget is to (or over) its limit into one
/// 0–100 score. A budget within its limit contributes a full 100; one
/// that's over contributes less, scaled by how far over it is. Returns
/// null when there are no budgets at all, since "average of nothing"
/// isn't a meaningful score — the UI shows a prompt instead in that case.
double? _computeHealthScore(
  List<BudgetModel> budgets,
  ExpensesController controller,
) {
  if (budgets.isEmpty) return null;

  double totalScore = 0;
  for (final budget in budgets) {
    final spent = controller.spentForCategorySince(
      budget.category,
      periodStartFor(budget.period),
    );

    double score;
    if (budget.targetAmount <= 0 || spent <= budget.targetAmount) {
      score = 100;
    } else {
      final overRatio = (spent - budget.targetAmount) / budget.targetAmount;
      score = (100 - overRatio * 100).clamp(0, 100);
    }
    totalScore += score;
  }
  return totalScore / budgets.length;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// "Manage Categories" doesn't know which list to open on its own —
  /// Expense, Income, and Reminder categories are all separate. This
  /// small chooser lets the user pick before ManageCategoriesScreen
  /// (which requires a CategoryType) opens.
  Future<void> _openCategoryChooser(BuildContext context) async {
    final type = await showDialog<CategoryType>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Manage which categories?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: const Text('Expense categories'),
              onTap: () =>
                  Navigator.of(dialogContext).pop(CategoryType.expense),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: const Text('Income categories'),
              onTap: () => Navigator.of(dialogContext).pop(CategoryType.income),
            ),
            ListTile(
              leading: const Icon(
                Icons.notifications_none,
                color: Colors.indigo,
              ),
              title: const Text('Reminder categories'),
              onTap: () =>
                  Navigator.of(dialogContext).pop(CategoryType.reminder),
            ),
          ],
        ),
      ),
    );

    if (type != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ManageCategoriesScreen(type: type)),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You\'ll need to sign in again to access your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;

    // pushAndRemoveUntil clears the whole navigation stack — otherwise
    // tapping back after logout could return to a screen that assumed
    // a logged-in user, since nothing here reactively watches
    // isLoggedIn the way AuthWrapper would.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final activeGoals = context.watch<SavingsGoalProvider>().goals.length;
    final budgets = context.watch<BudgetProvider>().budgets;
    final expensesController = context.watch<ExpensesController>();
    final healthScore = _computeHealthScore(budgets, expensesController);

    // Your signup flow only collects email/password, so Firebase never
    // gets a displayName — it'll be null for every existing account.
    // Falling back to the part of the email before '@' gives a
    // reasonable name instead of showing nothing. A real "edit profile
    // name" feature would need its own screen — say the word if you
    // want that built.
    final email = user?.email ?? '';
    final displayName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (email.contains('@') ? email.split('@').first : 'Friend');
    final avatarLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            avatarLetter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Text(displayName),
                      Text(
                        email,
                        style:  TextStyle(
                          fontWeight: FontWeight.w700,
                          color:Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // _StatCard(value: '$streak', label: 'Day Streak'),
                    _StatCard(value: '$activeGoals', label: 'Active Goals'),
                    _StatCard(
                      value: healthScore == null
                          ? '—'
                          : healthScore.round().toString(),
                      label: 'Health Score',
                    ),
                  ],
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.appColors.cardsBackground,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      spacing: 20,
                      children: [

                         _ProfileRow(
                          label: 'Create Notes',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NoteScreen(),
                            ),
                          ),
                        ),
                        

                        _ProfileRow(
                          label: 'Budget Planner',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BudgetPlannerScreen(),
                            ),
                          ),
                        ),

                        _ProfileRow(
                          label: 'Savings Goals',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SavingsGoalsScreen(),
                            ),
                          ),
                        ),

              
                        _ProfileRow(
                          label: 'Reminders',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BillsSubscriptionsScreen(),
                            ),
                          ),
                        ),

                        _ProfileRow(
                          label: 'Manage Categories',
                          onTap: () => _openCategoryChooser(context),
                        ),


                       
                        _ProfileRow(
                          label: 'About Us',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AboutUsScreen(),
                            ),
                          ),
                        ),
                        _ProfileRow(
                          label: 'Report Us',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReportProblemScreen(),
                            ),
                          ),
                        ),               
                      
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(),
                      minimumSize: Size.zero,
                      side: const BorderSide(style: BorderStyle.none),
                    ),
                    onPressed: () => _logout(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 225, 225),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _ProfileRow({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label ',
            style:  TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
















