import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// bottom_nav_viewmodel.dart
class BottomNav extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    //THIS IS FOR CREATING THE OBJECT OF THE BOTTOMNAV
    final vm = context.watch<BottomNav>();
    return SafeArea(
      child: Container(
        height: 70,

        decoration: BoxDecoration(color: context.appColors.verticalLine,),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, icon: LucideIcons.home, index: 0, vm: vm),
            _navItem(context, icon: LucideIcons.activity, index: 1, vm: vm),
            SizedBox(width: 8),
            _navItem(context, icon: Icons.bar_chart_rounded, index: 2, vm: vm),
            _navItem(
              context,
              icon: LucideIcons.personStanding,
              index: 3,
              vm: vm,
            ),
          ],
        ),
      ),
    );
  }
}

//Icon + Index + vm(object)
Widget _navItem(
  BuildContext context, {
  required IconData icon,
  required int index,
  required BottomNav vm,
}) {
  //THIS IS FOR THE BOTTOMNAV_ICON COLOR TO SHOW THE ACTIVE ICON
  final isActive = vm.selectedIndex == index;

  return GestureDetector(
    //THIS IS THE FUNCTION DEFINED IN BOTTOMNAV_CONTROLLER TO CHANGE THE PAGE
    onTap: () => vm.setIndex(index),
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      height: 70, 
      child: Center(
        
        child: Icon(
          icon,
          size: 26,
          color: isActive ? context.appColors.activeIcon : context.appColors.inactiveIcon,
        ),
      ),
    ),
  );
}
