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

  Future<void> _openCategoryChooser(BuildContext context) async {
    final type = await showDialog<CategoryType>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Manage Categories'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryOption(
              icon: Icons.arrow_upward,
              color: Colors.red,
              label: 'Expense Categories',
              onTap: () =>
                  Navigator.of(dialogContext).pop(CategoryType.expense),
            ),
            _CategoryOption(
              icon: Icons.arrow_downward,
              color: Colors.green,
              label: 'Income Categories',
              onTap: () => Navigator.of(dialogContext).pop(CategoryType.income),
            ),
            _CategoryOption(
              icon: Icons.notifications_none,
              color: Colors.indigo,
              label: 'Reminder Categories',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  "Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              // ─── PROFILE CONTAINER ───
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1C6B47),
                      const Color(0xFF1C6B47).withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          avatarLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 22),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── STATS ROW ───
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '$activeGoals',
                      label: 'Active Goals',
                      icon: Icons.flag_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: healthScore == null
                          ? '—'
                          : healthScore.round().toString(),
                      label: 'Health Score',
                      icon: Icons.favorite_border_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ─── MANAGE SECTION TITLE ───
              Text(
                'Manage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              // ─── MENU CARDS ───
              _MenuCard(
                icon: Icons.note_alt_outlined,
                label: 'Create Notes',
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const NoteScreen())),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Budget Planner',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BudgetPlannerScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.savings_outlined,
                label: 'Savings Goals',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                ),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.notifications_none_rounded,
                label: 'Reminders',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BillsSubscriptionsScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.category_outlined,
                label: 'Manage Categories',
                onTap: () => _openCategoryChooser(context),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.info_outline_rounded,
                label: 'About Us',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                ),
              ),

              const SizedBox(height: 10),

              _MenuCard(
                icon: Icons.bug_report_outlined,
                label: 'Report a Problem',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportProblemScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── LOGOUT ───
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    backgroundColor: Colors.red.shade50,
                    side: const BorderSide(color: Colors.transparent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Developed By',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                
                    Text(
                      'Luminous Technology Pvt. Ltd.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1C6B47).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1C6B47)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColors.paragraphColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuCard({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardsBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.04),
          //   blurRadius: 8,
          //   offset: const Offset(0, 2),
          // ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}



















// import 'package:expense_tracking/screens/note_screen.dart';
// import 'package:expense_tracking/providers/saving_goal_provider.dart';
// import 'package:expense_tracking/screens/about_us_screen.dart';
// import 'package:expense_tracking/screens/bills_subscription_screen.dart';
// import 'package:expense_tracking/screens/manage_category_screen.dart';
// import 'package:expense_tracking/screens/report_screen.dart';
// import 'package:expense_tracking/screens/saving_goal_screen.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:expense_tracking/screens/budgets_palnner_screen.dart';
// import 'package:expense_tracking/providers/auth_provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/providers/budgets_provider.dart';
// import 'package:expense_tracking/models/budgets_model.dart';
// import 'package:expense_tracking/controllers/budget_period_controller.dart';
// import 'package:expense_tracking/screens/login_screen.dart';
// import 'package:expense_tracking/models/category_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// double? _computeHealthScore(
//   List<BudgetModel> budgets,
//   ExpensesController controller,
// ) {
//   if (budgets.isEmpty) return null;

//   double totalScore = 0;
//   for (final budget in budgets) {
//     final spent = controller.spentForCategorySince(
//       budget.category,
//       periodStartFor(budget.period),
//     );

//     double score;
//     if (budget.targetAmount <= 0 || spent <= budget.targetAmount) {
//       score = 100;
//     } else {
//       final overRatio = (spent - budget.targetAmount) / budget.targetAmount;
//       score = (100 - overRatio * 100).clamp(0, 100);
//     }
//     totalScore += score;
//   }
//   return totalScore / budgets.length;
// }

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   Future<void> _openCategoryChooser(BuildContext context) async {
//     final type = await showDialog<CategoryType>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Manage Categories'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _CategoryOption(
//               icon: Icons.arrow_upward,
//               color: Colors.red,
//               label: 'Expense Categories',
//               onTap: () => Navigator.of(dialogContext).pop(CategoryType.expense),
//             ),
//             _CategoryOption(
//               icon: Icons.arrow_downward,
//               color: Colors.green,
//               label: 'Income Categories',
//               onTap: () => Navigator.of(dialogContext).pop(CategoryType.income),
//             ),
//             _CategoryOption(
//               icon: Icons.notifications_none,
//               color: Colors.indigo,
//               label: 'Reminder Categories',
//               onTap: () => Navigator.of(dialogContext).pop(CategoryType.reminder),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (type != null && context.mounted) {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (_) => ManageCategoriesScreen(type: type)),
//       );
//     }
//   }

//   Future<void> _logout(BuildContext context) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Logout'),
//         content: const Text(
//           'Are you sure you want to logout?',
//           style: TextStyle(fontSize: 15),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(false),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(true),
//             child: const Text(
//               'Logout',
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true || !context.mounted) return;

//     await context.read<AuthProvider>().signOut();
//     if (!context.mounted) return;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.watch<AuthProvider>().user;
//     final activeGoals = context.watch<SavingsGoalProvider>().goals.length;
//     final budgets = context.watch<BudgetProvider>().budgets;
//     final expensesController = context.watch<ExpensesController>();
//     final healthScore = _computeHealthScore(budgets, expensesController);

//     final email = user?.email ?? '';
//     final displayName = (user?.displayName?.isNotEmpty ?? false)
//         ? user!.displayName!
//         : (email.contains('@') ? email.split('@').first : 'Friend');
//     final avatarLetter = displayName.isNotEmpty
//         ? displayName[0].toUpperCase()
//         : '?';

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ─── PROFILE CONTAINER ───
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFF1C6B47),
//                       const Color(0xFF1C6B47).withOpacity(0.85),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF1C6B47).withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.2),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.4),
//                           width: 2,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           avatarLetter,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 34,
//                             fontWeight: FontWeight.w700,
//                             // fontFamily: 'Roboto', // Add your font family
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Text(
//                       displayName,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         // fontFamily: 'Roboto', // Add your font family
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       email,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                         // fontFamily: 'Roboto', // Add your font family
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // ─── STATS ROW ───
//               Row(
//                 children: [
//                   Expanded(
//                     child: _StatCard(
//                       value: '$activeGoals',
//                       label: 'Active Goals',
//                       icon: Icons.flag_outlined,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _StatCard(
//                       value: healthScore == null
//                           ? '—'
//                           : healthScore.round().toString(),
//                       label: 'Health Score',
//                       icon: Icons.favorite_border_rounded,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 28),

//               // ─── MANAGE SECTION TITLE ───
//               Text(
//                 'Manage',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: Theme.of(context).colorScheme.onSurface,
//                   // fontFamily: 'Roboto', // Add your font family
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // ─── MENU CARDS ───
//               _MenuCard(
//                 icon: Icons.note_alt_outlined,
//                 label: 'Create Notes',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(builder: (_) => const NoteScreen()),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               _MenuCard(
//                 icon: Icons.account_balance_wallet_outlined,
//                 label: 'Budget Planner',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const BudgetPlannerScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               _MenuCard(
//                 icon: Icons.savings_outlined,
//                 label: 'Savings Goals',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const SavingsGoalsScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               _MenuCard(
//                 icon: Icons.notifications_none_rounded,
//                 label: 'Reminders',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const BillsSubscriptionsScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               _MenuCard(
//                 icon: Icons.category_outlined,
//                 label: 'Manage Categories',
//                 onTap: () => _openCategoryChooser(context),
//               ),
              
//               const SizedBox(height: 10),
              
//               _MenuCard(
//                 icon: Icons.info_outline_rounded,
//                 label: 'About Us',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const AboutUsScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               _MenuCard(
//                 icon: Icons.bug_report_outlined,
//                 label: 'Report a Problem',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const ReportProblemScreen(),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // ─── LOGOUT ───
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () => _logout(context),
//                   icon: const Icon(Icons.logout_rounded, size: 18),
//                   label: const Text(
//                     'Logout',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                       // fontFamily: 'Roboto', // Add your font family
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.red.shade600,
//                     backgroundColor: Colors.red.shade50,
//                     side: const BorderSide(color: Colors.transparent),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String value;
//   final String label;
//   final IconData icon;

//   const _StatCard({
//     required this.value,
//     required this.label,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: context.appColors.cardsBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: const Color(0xFF1C6B47).withOpacity(0.12),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               size: 20,
//               color: const Color(0xFF1C6B47),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Theme.of(context).colorScheme.onSurface,
//                     // fontFamily: 'Roboto', // Add your font family
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: context.appColors.paragraphColor,
//                     fontWeight: FontWeight.w500,
//                     // fontFamily: 'Roboto', // Add your font family
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MenuCard extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback? onTap;

//   const _MenuCard({
//     required this.label,
//     required this.icon,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textColor = Theme.of(context).colorScheme.onSurface;

//     return Container(
//       decoration: BoxDecoration(
//         color: context.appColors.cardsBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Row(
//           children: [
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     const Color(0xFF1C6B47).withOpacity(0.15),
//                     const Color(0xFF1C6B47).withOpacity(0.08),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 size: 22,
//                 color: const Color(0xFF1C6B47),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   color: textColor,
//                   // letterSpacing: 0.7
//                   // fontFamily: 'Roboto', // Add your font family
//                 ),
//               ),
//             ),
//             Container(
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.chevron_right_rounded,
//                 size: 18,
//                 color: context.appColors.paragraphColor.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CategoryOption extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label;
//   final VoidCallback onTap;

//   const _CategoryOption({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: color, size: 20),
//       ),
//       title: Text(
//         label,
//         style: const TextStyle(
//           fontWeight: FontWeight.w500,
//           // fontFamily: 'Roboto', // Add your font family
//         ),
//       ),
//       trailing: const Icon(
//         Icons.chevron_right_rounded,
//         color: Colors.grey,
//         size: 20,
//       ),
//       onTap: onTap,
//     );
//   }
// }






















// import 'package:expense_tracking/screens/note_screen.dart';
// import 'package:expense_tracking/providers/saving_goal_provider.dart';
// import 'package:expense_tracking/screens/about_us_screen.dart';
// import 'package:expense_tracking/screens/bills_subscription_screen.dart';
// import 'package:expense_tracking/screens/manage_category_screen.dart';
// import 'package:expense_tracking/screens/report_screen.dart';
// import 'package:expense_tracking/screens/saving_goal_screen.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:expense_tracking/screens/budgets_palnner_screen.dart';
// import 'package:expense_tracking/providers/auth_provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/providers/budgets_provider.dart';
// import 'package:expense_tracking/models/budgets_model.dart';
// import 'package:expense_tracking/controllers/budget_period_controller.dart';
// import 'package:expense_tracking/screens/login_screen.dart';
// import 'package:expense_tracking/models/category_model.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// double? _computeHealthScore(
//   List<BudgetModel> budgets,
//   ExpensesController controller,
// ) {
//   if (budgets.isEmpty) return null;

//   double totalScore = 0;
//   for (final budget in budgets) {
//     final spent = controller.spentForCategorySince(
//       budget.category,
//       periodStartFor(budget.period),
//     );

//     double score;
//     if (budget.targetAmount <= 0 || spent <= budget.targetAmount) {
//       score = 100;
//     } else {
//       final overRatio = (spent - budget.targetAmount) / budget.targetAmount;
//       score = (100 - overRatio * 100).clamp(0, 100);
//     }
//     totalScore += score;
//   }
//   return totalScore / budgets.length;
// }

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   Future<void> _openCategoryChooser(BuildContext context) async {
//     final type = await showDialog<CategoryType>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Manage Categories'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _CategoryOption(
//               icon: Icons.arrow_upward,
//               color: Colors.red,
//               label: 'Expense Categories',
//               onTap: () => Navigator.of(dialogContext).pop(CategoryType.expense),
//             ),
//             _CategoryOption(
//               icon: Icons.arrow_downward,
//               color: Colors.green,
//               label: 'Income Categories',
//               onTap: () => Navigator.of(dialogContext).pop(CategoryType.income),
//             ),
//             _CategoryOption(
//               icon: Icons.notifications_none,
//               color: Colors.indigo,
//               label: 'Reminder Categories',
//               onTap: () => Navigator.of(dialogContext).pop(CategoryType.reminder),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (type != null && context.mounted) {
//       Navigator.of(context).push(
//         MaterialPageRoute(builder: (_) => ManageCategoriesScreen(type: type)),
//       );
//     }
//   }

//   Future<void> _logout(BuildContext context) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Logout'),
//         content: const Text(
//           'Are you sure you want to logout?',
//           style: TextStyle(fontSize: 15),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(false),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(true),
//             child: const Text(
//               'Logout',
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true || !context.mounted) return;

//     await context.read<AuthProvider>().signOut();
//     if (!context.mounted) return;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.watch<AuthProvider>().user;
//     final activeGoals = context.watch<SavingsGoalProvider>().goals.length;
//     final budgets = context.watch<BudgetProvider>().budgets;
//     final expensesController = context.watch<ExpensesController>();
//     final healthScore = _computeHealthScore(budgets, expensesController);

//     final email = user?.email ?? '';
//     final displayName = (user?.displayName?.isNotEmpty ?? false)
//         ? user!.displayName!
//         : (email.contains('@') ? email.split('@').first : 'Friend');
//     final avatarLetter = displayName.isNotEmpty
//         ? displayName[0].toUpperCase()
//         : '?';

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ─── PROFILE CONTAINER ───
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFF1C6B47),
//                       const Color(0xFF1C6B47).withOpacity(0.85),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF1C6B47).withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.2),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.4),
//                           width: 2,
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           avatarLetter,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 34,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     Text(
//                       displayName,
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       email,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // const SizedBox(height: 24),

//               // // ─── STATS ROW ───
//               // Row(
//               //   children: [
//               //     Expanded(
//               //       child: _StatCard(
//               //         value: '$activeGoals',
//               //         label: 'Active Goals',
//               //         icon: Icons.flag_outlined,
//               //       ),
//               //     ),
//               //     const SizedBox(width: 12),
//               //     Expanded(
//               //       child: _StatCard(
//               //         value: healthScore == null
//               //             ? '—'
//               //             : healthScore.round().toString(),
//               //         label: 'Health Score',
//               //         icon: Icons.favorite_border_rounded,
//               //       ),
//               //     ),
//               //   ],
//               // ),

//               const SizedBox(height: 28),

//               // ─── MANAGE SECTION TITLE ───
//               Text(
//                 'Manage',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: Theme.of(context).colorScheme.onSurface,
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // ─── MENU CARDS ───
//               // Create Notes Card
//               _MenuCard(
//                 icon: Icons.note_alt_outlined,
//                 label: 'Create Notes',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(builder: (_) => const NoteScreen()),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               // Budget Planner Card
//               _MenuCard(
//                 icon: Icons.account_balance_wallet_outlined,
//                 label: 'Budget Planner',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const BudgetPlannerScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               // Savings Goals Card
//               _MenuCard(
//                 icon: Icons.savings_outlined,
//                 label: 'Savings Goals',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const SavingsGoalsScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               // Reminders Card
//               _MenuCard(
//                 icon: Icons.notifications_none_rounded,
//                 label: 'Reminders',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const BillsSubscriptionsScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               // Manage Categories Card
//               _MenuCard(
//                 icon: Icons.category_outlined,
//                 label: 'Manage Categories',
//                 onTap: () => _openCategoryChooser(context),
//               ),
              
//               const SizedBox(height: 10),
              
//               // About Us Card
//               _MenuCard(
//                 icon: Icons.info_outline_rounded,
//                 label: 'About Us',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const AboutUsScreen(),
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 10),
              
//               // Report a Problem Card
//               _MenuCard(
//                 icon: Icons.bug_report_outlined,
//                 label: 'Report a Problem',
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => const ReportProblemScreen(),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // ─── LOGOUT ───
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton.icon(
//                   onPressed: () => _logout(context),
//                   icon: const Icon(Icons.logout_rounded, size: 18),
//                   label: const Text(
//                     'Logout',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                     ),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.red.shade600,
//                     backgroundColor: Colors.red.shade50,
//                     side: const BorderSide(color: Colors.transparent),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String value;
//   final String label;
//   final IconData icon;

//   const _StatCard({
//     required this.value,
//     required this.label,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: context.appColors.cardsBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: const Color(0xFF1C6B47).withOpacity(0.12),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               size: 20,
//               color: const Color(0xFF1C6B47),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                     color: Theme.of(context).colorScheme.onSurface,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: context.appColors.paragraphColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MenuCard extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback? onTap;

//   const _MenuCard({
//     required this.label,
//     required this.icon,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textColor = Theme.of(context).colorScheme.onSurface;

//     return Container(
//       decoration: BoxDecoration(
//         color: context.appColors.cardsBackground,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFF1C6B47).withOpacity(0.15),
//                       const Color(0xFF1C6B47).withOpacity(0.08),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 22,
//                   color: const Color(0xFF1C6B47),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: textColor,
//                   ),
//                 ),
//               ),
//               Container(
//                 width: 28,
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.chevron_right_rounded,
//                   size: 18,
//                   color: context.appColors.paragraphColor.withOpacity(0.5),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CategoryOption extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String label;
//   final VoidCallback onTap;

//   const _CategoryOption({
//     required this.icon,
//     required this.color,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.12),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: color, size: 20),
//       ),
//       title: Text(
//         label,
//         style: const TextStyle(fontWeight: FontWeight.w500),
//       ),
//       trailing: const Icon(
//         Icons.chevron_right_rounded,
//         color: Colors.grey,
//         size: 20,
//       ),
//       onTap: onTap,
//     );
//   }
// }




