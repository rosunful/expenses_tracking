// // NOTE: assumed path — adjust if your AuthProvider file lives elsewhere.
// import 'package:expense_tracking/providers/auth_provider.dart';
// import 'package:expense_tracking/theme/app_theme_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class HeaderSection extends StatelessWidget {
//   const HeaderSection({super.key});

//   /// "Good Morning" / "Good Afternoon" / "Good Evening" based on the
//   /// actual time of day, instead of a hardcoded string.
//   String _greeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Good Morning';
//     if (hour < 17) return 'Good Afternoon';
//     return 'Good Evening';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = context.watch<AuthProvider>().user;
//     // displayName is usually empty unless you explicitly set it on
//     // signup, so falling back to the part of the email before "@" gives
//     // a real name-shaped string instead of "null" or a raw email.
//     final name = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
//         ? user.displayName!
//         : (user?.email?.split('@').first ?? 'there');

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _greeting(),
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
//                 fontSize: 12,
//               ),
//             ),
//             Text(
//               name,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ],
//         ),
//         const ThemeToggle(),
//       ],
//     );
//   }
// }

// class ThemeToggle extends StatelessWidget {
//   const ThemeToggle({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final notifier = context.watch<ThemeNotifier>();
//     final colorScheme = Theme.of(context).colorScheme;
//     final isLight = notifier.themeMode == ThemeMode.light;

//     return GestureDetector(
//       onTap: () => notifier.toggleTheme(),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//         decoration: BoxDecoration(
//           // Theme-aware now instead of hardcoded white, so this doesn't
//           // look like a stray light-mode chip when dark mode is on.
//           color: colorScheme.surfaceContainerHighest,
//           borderRadius: BorderRadius.circular(30),
//           border: Border.all(color: colorScheme.outlineVariant),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isLight ? Icons.light_mode : Icons.dark_mode,
//               size: 18,
//               color: Colors.amber,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               isLight ? 'Light' : 'Dark',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }