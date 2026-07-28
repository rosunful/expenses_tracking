import 'package:expense_tracking/theme/app_theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeaderSection extends StatefulWidget {
  final dynamic value;

  const HeaderSection({super.key, required this.value});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //THIS IS FOR THE GOOD MORNING
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Evening",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
            Text(
              "Roshan Gunadey",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        // Switch(

        //   value: widget.value,
        //   activeThumbColor: Colors.amber,
        //   onChanged: (_) => context.read<ThemeNotifier>().toggleTheme(),
        // ),
        //THIS IS THE AREA OF THE THEME CHANGING AREA
        ThemeToggle(),
      ],

      //THIS IS THE AREA OF THE CARD
    );
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ThemeNotifier>();
    final isLight = notifier.themeMode == ThemeMode.light;

    return GestureDetector(
      onTap: () => notifier.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLight ? Icons.light_mode : Icons.dark_mode,
              size: 18,
              color: Colors.amber,
            ),
            const SizedBox(width: 6),
            Text(
              isLight ? "Light" : "Dark",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
