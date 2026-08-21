import 'package:expense_tracking/models/saving_model.dart';
import 'package:expense_tracking/providers/saving_goal_provider.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/screens/saving_goal_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_goal_contribution_screen.dart';


class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<SavingsGoalProvider>().goals;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Goal history',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavingsGoalHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final goal in goals) ...[
                _GoalCard(goal: goal),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              // OutlinedButton(
              //   onPressed: () => Navigator.of(context).push(
              //     MaterialPageRoute(builder: (_) => const GoalFormScreen()),
              //   ),
              //   style: OutlinedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     side: BorderSide(color: Colors.grey.shade400, style: BorderStyle.solid),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(14),
              //     ),
              //   ),
              //   child: const Text(
              //     '+ New goal',
              //     style: TextStyle(color: Color(0xFF1C6B47), fontWeight: FontWeight.bold),
              //   ),
              // ),
          
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C6B47),
          onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GoalFormScreen()), 
          ),
       child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<CurrencyProvider>().selected.symbol;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF3F5F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Tapping the whole card (minus the menu button) opens the
          // "add money" screen — the primary action for a goal card.
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddGoalContributionScreen(goal: goal)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: goal.progress,
                          strokeWidth: 4,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.indigo,
                        ),
                        Text(
                          '${goal.progressPercent}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 , color: Theme.of(context).colorScheme.onSurface),
                        maxLines: 1,),
                        Text(
                          '$symbol${goal.savedAmount.toStringAsFixed(0)} of $symbol${goal.targetAmount.toStringAsFixed(0)} saved',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Separate tap target for edit/delete, so it doesn't collide
          // with "tap card to add money".
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black45),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GoalFormScreen(existing: goal)),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit goal')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Renamed from _GoalFormDialog and made public (no leading underscore)
/// since it's now a full screen pushed via Navigator, not a dialog
/// built inline within this file's own widget tree.
class GoalFormScreen extends StatefulWidget {
  final SavingsGoalModel? existing;
  const GoalFormScreen({super.key, this.existing});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _targetController.text = widget.existing!.targetAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final target = double.tryParse(_targetController.text.trim());

    if (title.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title and a valid target amount')),
      );
      return;
    }

    final provider = context.read<SavingsGoalProvider>();
    if (_isEditing) {
      await provider.updateGoal(widget.existing!.id, title, target);
    } else {
      await provider.addGoal(title, target);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _hide() async {
    if (widget.existing == null) return;
    await context.read<SavingsGoalProvider>().hideGoal(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_isEditing ? 'Edit Goal' : 'New Goal'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Goal name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                autofocus: !_isEditing,
                decoration: const InputDecoration(hintText: 'e.g. Vacation'),
              ),
              const SizedBox(height: 20),
              const Text('Target amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'e.g. 3200'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C6B47),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Create Goal',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _hide,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Delete Goal', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}






















// import 'package:expense_tracking/models/saving_model.dart';
// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/providers/saving_goal_provider.dart';
// import 'package:expense_tracking/screens/saving_goal_history_screen.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'add_goal_contribution_screen.dart';

// class SavingsGoalsScreen extends StatelessWidget {
//   const SavingsGoalsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final goals = context.watch<SavingsGoalProvider>().goals;


//     final totalGoals = goals.length;

// final completedGoals = goals.where(
//   (goal) => goal.savedAmount >= goal.targetAmount,
// ).length;

// final progress = totalGoals == 0
//     ? 0.0
//     : completedGoals / totalGoals;

// final progressPercent = (progress * 100).round();

//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text(
//           'Savings Goals',
//           style: TextStyle( fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             tooltip: 'Goal history',
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => const SavingsGoalHistoryScreen(),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
        
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
            
//             children: [
//               //   OutlinedButton(
//               //   onPressed: () => Navigator.of(context).push(
//               //     MaterialPageRoute(builder: (_) => const GoalFormScreen()),
//               //   ),
//               //   style: OutlinedButton.styleFrom(
//               //     backgroundColor: context.appColors.cardsBackground,
//               //     padding: const EdgeInsets.symmetric(vertical: 12),
//               //     side: const BorderSide(color: Color.fromARGB(255, 205, 208, 206)),
//               //     shape: RoundedRectangleBorder(
//               //       borderRadius: BorderRadius.circular(10),
//               //     ),
//               //   ),
//               //   child: Center(
//               //     child: Text(
//               //       '+ New goal',
//               //       style: TextStyle(
                      
//               //         color:Theme.of(context).colorScheme.onSurface ,
//               //         fontWeight: FontWeight.w700,
//               //         fontSize: 12,
//               //       ),
//               //     ),
//               //   ),
//               // ),
//               // SizedBox(height: 4,),
//               for (final goal in goals) ...[
//                 _GoalCard(goal: goal),
//                 const SizedBox(height: 12),
//               ],
              
              
//             ],
//           ),
//         ),
//       ),
//         floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFF1C6B47),
//         onPressed: () => Navigator.of(context).push(
//                   MaterialPageRoute(builder: (_) => const GoalFormScreen()),
//                 ),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }

// class _GoalCard extends StatelessWidget {
//   final SavingsGoalModel goal;
//   const _GoalCard({required this.goal});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: context.appColors.cardsBackground,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
         
//           Expanded(
//             child: InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => AddGoalContributionScreen(goal: goal),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   SizedBox(
//                     width: 46,
//                     height: 46,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           value: goal.progress,
//                           strokeWidth: 4,
//                           backgroundColor: Colors.grey.shade300,
//                           color: const Color(0xFF1C6B47),
//                         ),
//                         Text(
//                           '${goal.progressPercent}%',
//                           style:  TextStyle(
//                             color: Theme.of(context).colorScheme.onSurface,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           goal.title,
//                           maxLines: 1,
//                           style:  TextStyle(
//                             color:  Theme.of(context).colorScheme.onSurface,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 13,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Text(
//                           '\$${goal.savedAmount.toStringAsFixed(0)} of \$${goal.targetAmount.toStringAsFixed(0)} saved',
//                           style:  TextStyle(
//                             fontSize: 11,
//                             color: context.appColors.paragraphColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           PopupMenuButton<String>(
//             icon:  Icon(Icons.more_vert, color: context.appColors.paragraphColor,),
//             onSelected: (value) {
//               if (value == 'edit') {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => GoalFormScreen(existing: goal),
//                   ),
//                 );
//               }
//             },
//             itemBuilder: (context) => const [
//               PopupMenuItem(value: 'edit', child: Text('Edit goal')),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


// class GoalFormScreen extends StatefulWidget {
//   final SavingsGoalModel? existing;
//   const GoalFormScreen({super.key, this.existing});

//   @override
//   State<GoalFormScreen> createState() => _GoalFormScreenState();
// }

// class _GoalFormScreenState extends State<GoalFormScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _targetController = TextEditingController();

//   bool get _isEditing => widget.existing != null;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.existing != null) {
//       _titleController.text = widget.existing!.title;
//       _targetController.text = widget.existing!.targetAmount.toStringAsFixed(0);
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _targetController.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     final title = _titleController.text.trim();
//     final target = double.tryParse(_targetController.text.trim());

//     if (title.isEmpty || target == null || target <= 0) {
//       context.read<NotifyingProvider>().showMessage('Enter a title and a valid target amount');
     
//       return;
//     }
   

//     final provider = context.read<SavingsGoalProvider>();
//     if (_isEditing) {
//       await provider.updateGoal(widget.existing!.id, title, target);
//     } else {
//       await provider.addGoal(title, target);
//     }
//     if (mounted) Navigator.of(context).pop();
//   }

//   Future<void> _hide() async {
//     if (widget.existing == null) return;
//     await context.read<SavingsGoalProvider>().hideGoal(widget.existing!.id);
//     if (mounted) Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: Text(
//           _isEditing ? 'Edit Goal' : 'New Goal',
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//         ),
//         elevation: 0,
       
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'GOAL NAME',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 10,
//                   letterSpacing: .7,
//                   color:  Theme.of(context).colorScheme.onSurface
//                 ),
//               ),
//               const SizedBox(height: 6),
//               TextField(
//                 controller: _titleController,
//                 autofocus: !_isEditing,
//                 decoration: _fieldDecoration('Vacation'),
//                 style: TextStyle(color:Colors.black),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'TARGET AMOUNT',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 10,
//                   letterSpacing: .7,
//                   color:  Theme.of(context).colorScheme.onSurface
//                 ),
//               ),
//               const SizedBox(height: 6),
//               TextField(
//                 controller: _targetController,
//                 keyboardType: const TextInputType.numberWithOptions(
//                   decimal: true,
//                 ),
//                 style: TextStyle(color:Colors.black),
//                 decoration: _fieldDecoration('3200'),
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _save,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1C6B47),
//                     padding: const EdgeInsets.symmetric(vertical: 13),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text(
//                     _isEditing ? 'Save Changes' : 'Create Goal',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ),
//               if (_isEditing) ...[
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: _hide,
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       side: const BorderSide(color: Colors.red),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: const Text(
//                       'Delete Goal',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _fieldDecoration(String hint) => InputDecoration(
//     hintText: hint,
//     hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
//     filled: true,
//     fillColor: const Color(0xFFF1F5F2),
//     isDense: true,
//     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8),
//       borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(8),
//       borderSide: const BorderSide(color: Color(0xFFDCE5DF)),
//     ),
//   );
// }
