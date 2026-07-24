// import 'package:expense_tracking/theme/app_theme_notifier.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class HeaderSection extends StatefulWidget {
//   final dynamic value;

//   const HeaderSection({super.key, required this.value});

//   @override
//   State<HeaderSection> createState() => _HeaderSectionState();
// }

// class _HeaderSectionState extends State<HeaderSection> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         //THIS IS FOR THE GOOD MORNING
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Good Evening",
//               style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//             ),
//             Text(
//               "Roshan Gunadey",
//               style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//             ),
//           ],
//         ),

//         Switch(
//           value: widget.value,
//           activeThumbColor: Colors.amber,
//           onChanged: (_) => context.read<ThemeNotifier>().toggleTheme(),
//         ),
//         //THIS IS THE AREA OF THE THEME CHANGING AREA
//       ],

//       //THIS IS THE AREA OF THE CARD
//     );
//   }
// }
