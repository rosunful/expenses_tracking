import 'package:expense_tracking/providers/auth_provider.dart';
import 'package:expense_tracking/theme/app_theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'there';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greeting(), style: Theme.of(context).textTheme.bodySmall),
            Text(name, style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            )),
          ],
        ),
        const _ThemeToggle(),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ThemeNotifier>();
    final isLight = notifier.themeMode == ThemeMode.light;

    return IconButton(
      tooltip: isLight ? 'Use dark theme' : 'Use light theme',
      onPressed: notifier.toggleTheme,
      icon: Icon(
        isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      ),
    );
  }
}
