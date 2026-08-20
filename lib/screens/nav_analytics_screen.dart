import 'package:expense_tracking/widgets/analytics_widgets/account_chart.dart';
import 'package:expense_tracking/widgets/analytics_widgets/expenses_chart.dart';
import 'package:expense_tracking/widgets/analytics_widgets/ranking_item_section.dart';
import 'package:expense_tracking/widgets/analytics_widgets/spending_progressbar.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:  14.0 , vertical: 6),
            child: Column(
             
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0 , vertical: 6.0),
                  child: Text(
                    "Analysis",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                // const SizedBox(height: 10,),

                SizedBox(
                  height: 230,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: const [ExpensesChart(), AccountAnalyticsChart()],
                  ),
                ),
                const SizedBox(height: 10,),

                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF1C6B47)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),

                const SpendingCategoryCard(),
                const SizedBox(height: 10,),

                const TopCategoryCard(),
                 const SizedBox(height: 25),

                
              ],
            ),
          ),
        ),
      ),
    );
  }
}























// class AnalyticsScreen extends StatelessWidget {
//   const AnalyticsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      
      
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(12,4,12,0),
//           child: Column(
//             spacing: 10,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [

//               ExpensesChart(),

//               SpendingCategoryCard(),

//               TopCategoryCard(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






