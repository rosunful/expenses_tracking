// import 'package:expense_tracking/models/category_model.dart';
// import 'package:expense_tracking/providers/category_provider.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/models/transaction_model.dart';
// import 'package:expense_tracking/providers/budgets_provider.dart';
// import 'package:expense_tracking/providers/reminder_provider.dart';
// import 'package:expense_tracking/widgets/category_icon.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// /// Centered dialog for picking one icon out of categoryIconLibrary —
// /// used both when adding a new category and when changing an existing
// /// custom category's icon later. Returns the chosen key, or null if
// /// the user cancels.
// Future<String?> _pickCategoryIcon(BuildContext context, {String? currentKey}) {
//   return showDialog<String>(
//     context: context,
//     builder: (dialogContext) {
//       return Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(dialogContext).size.height * 0.6,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Choose an icon',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                 ),
//                 const SizedBox(height: 14),
//                 Flexible(
//                   child: SingleChildScrollView(
//                     child: GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: categoryIconLibrary.length,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 5,
//                             mainAxisSpacing: 10,
//                             crossAxisSpacing: 10,
//                           ),
//                       itemBuilder: (context, index) {
//                         final entry = categoryIconLibrary.entries.elementAt(
//                           index,
//                         );
//                         final isSelected = entry.key == currentKey;
//                         return InkWell(
//                           borderRadius: BorderRadius.circular(30),
//                           onTap: () =>
//                               Navigator.of(dialogContext).pop(entry.key),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? const Color(0xFF1C6B47)
//                                   : const Color(0xFF1C6B47).withOpacity(0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               entry.value,
//                               size: 20,
//                               color: isSelected
//                                   ? Colors.white
//                                   : const Color(0xFF1C6B47),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// class ManageCategoriesScreen extends StatefulWidget {
//   final CategoryType type;
//   const ManageCategoriesScreen({super.key, required this.type});

//   @override
//   State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
// }

// class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
//   final TextEditingController _newCategoryController = TextEditingController();
//   final FocusNode _newCategoryFocusNode = FocusNode();
//   bool _isAdding = false;

//   // Defaults to the generic "category" icon until the user explicitly
//   // picks something else — always sent along with addCategory, so
//   // every new category gets a real, intentional icon rather than
//   // silently falling back to the name-based guess.
//   String _selectedIconKey = 'category';

//   @override
//   void dispose() {
//     _newCategoryController.dispose();
//     _newCategoryFocusNode.dispose();
//     super.dispose();
//   }

//   void _showTopMessage(String message, {bool isError = false}) {
//     final messenger = ScaffoldMessenger.of(context);
//     messenger.clearMaterialBanners();
//     messenger.showMaterialBanner(
//       MaterialBanner(
//         backgroundColor: isError
//             ? const Color(0xFFFCEBEA)
//             : const Color(0xFFEAF4EF),
//         content: Text(
//           message,
//           style: TextStyle(
//             color: isError ? Colors.red.shade700 : const Color(0xFF1C6B47),
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//           ),
//         ),
//         leading: Icon(
//           isError ? Icons.error_outline : Icons.check_circle_outline,
//           color: isError ? Colors.red.shade700 : const Color(0xFF1C6B47),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => messenger.hideCurrentMaterialBanner(),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) messenger.hideCurrentMaterialBanner();
//     });
//   }

//   Future<void> _pickIconForNewCategory() async {
//     final key = await _pickCategoryIcon(context, currentKey: _selectedIconKey);
//     if (key != null) setState(() => _selectedIconKey = key);
//   }

//   Future<void> _addCategory() async {
//     final name = _newCategoryController.text.trim();
//     if (name.isEmpty) return;

//     setState(() => _isAdding = true);

//     final added = await context.read<CategoryProvider>().addCategory(
//       name,
//       widget.type,
//       iconKey: _selectedIconKey,
//     );

//     if (!mounted) return;
//     setState(() => _isAdding = false);

//     if (!added) {
//       _showTopMessage('"$name" already exists', isError: true);
//       return;
//     }

//     _showTopMessage('"$name" added');
//     _newCategoryController.clear();
//     setState(() => _selectedIconKey = 'category'); // reset for the next one
//     _newCategoryFocusNode.requestFocus();
//   }

//   Future<void> _changeIcon(CategoryModel category) async {
//     final key = await _pickCategoryIcon(context, currentKey: category.iconKey);
//     if (key == null || !mounted) return;
//     await context.read<CategoryProvider>().updateCategoryIcon(category.id, key);
//     if (mounted) _showTopMessage('Icon updated');
//   }

//   int _usageCount(CategoryModel category) {
//     switch (widget.type) {
//       case CategoryType.expense:
//         return context
//             .read<ExpensesController>()
//             .expensesNoPrivate
//             .where(
//               (e) =>
//                   e.type == TransactionType.expense &&
//                   e.category == category.name,
//             )
//             .length;
//       case CategoryType.income:
//         return context
//             .read<ExpensesController>()
//             .expensesNoPrivate
//             .where(
//               (e) =>
//                   e.type == TransactionType.income &&
//                   e.category == category.name,
//             )
//             .length;
//       case CategoryType.reminder:
//         final reminders = context.read<ReminderProvider>();
//         return [
//           ...reminders.reminders,
//           ...reminders.hiddenReminders,
//         ].where((r) => r.category == category.name).length;
//     }
//   }

//   bool _hasActiveBudget(CategoryModel category) {
//     if (widget.type != CategoryType.expense) return false;
//     return context.read<BudgetProvider>().budgets.any(
//       (b) => b.category == category.name,
//     );
//   }

//   Future<void> _confirmDelete(CategoryModel category) async {
//     final usageCount = _usageCount(category);
//     final hasBudget = _hasActiveBudget(category);

//     final buffer = StringBuffer(
//       '"${category.name}" will be removed from your category list.',
//     );
//     if (usageCount > 0) {
//       buffer.write(
//         ' $usageCount existing ${usageCount == 1 ? "entry" : "entries"} already '
//         'use this category and will keep showing "${category.name}" — you just '
//         "won't be able to pick it for new ones.",
//       );
//     }
//     if (hasBudget) {
//       buffer.write(
//         ' Note: you also have a budget set for this category — deleting the '
//         "category here won't remove that budget.",
//       );
//     }

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete category?'),
//         content: Text(buffer.toString()),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true && mounted) {
//       await context.read<CategoryProvider>().deleteCategory(category.id);
//       if (mounted) _showTopMessage('"${category.name}" deleted');
//     }
//   }

//   Future<void> _renameCategory(CategoryModel category) async {
//     final controller = TextEditingController(text: category.name);

//     final newName = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Rename category'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextField(controller: controller, autofocus: true),
//             const SizedBox(height: 10),
//             const Text(
//               'Existing entries using the old name will be updated to the new name too.',
//               style: TextStyle(fontSize: 12, color: Colors.black54),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(dialogContext).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () =>
//                 Navigator.of(dialogContext).pop(controller.text.trim()),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1C6B47),
//             ),
//             child: const Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (newName == null || newName.isEmpty || newName == category.name) return;
//     if (!mounted) return;

//     final renamed = await context.read<CategoryProvider>().renameCategory(
//       category.id,
//       category.name,
//       newName,
//       widget.type,
//     );

//     if (!mounted) return;
//     if (!renamed) {
//       _showTopMessage('"$newName" already exists', isError: true);
//     } else {
//       _showTopMessage('Renamed to "$newName"');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = context.watch<CategoryProvider>().categoriesFor(
//       widget.type,
//     );
//     final defaults = categories.where((c) => c.isDefault).toList();
//     final custom = categories.where((c) => !c.isDefault).toList();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F8F7),
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text(
//           'Manage Categories',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: ListView(
//                   children: [
//                     const Text(
//                       'BUILT-IN',
//                       style: TextStyle(
//                         fontSize: 10,
//                         letterSpacing: .7,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black45,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: defaults.length,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 4,
//                             mainAxisSpacing: 12,
//                             crossAxisSpacing: 8,
//                             childAspectRatio: 0.78,
//                           ),
//                       itemBuilder: (context, index) =>
//                           _DefaultCategoryTile(category: defaults[index]),
//                     ),
//                     const SizedBox(height: 22),
//                     Text(
//                       'YOUR CATEGORIES (${custom.length})',
//                       style: const TextStyle(
//                         fontSize: 10,
//                         letterSpacing: .7,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black45,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     if (custom.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                         child: Text(
//                           "You haven't added any custom categories yet.",
//                           style: TextStyle(fontSize: 12, color: Colors.black45),
//                         ),
//                       )
//                     else
//                       for (final category in custom) ...[
//                         _CustomCategoryRow(
//                           category: category,
//                           onRename: () => _renameCategory(category),
//                           onDelete: () => _confirmDelete(category),
//                           onChangeIcon: () => _changeIcon(category),
//                         ),
//                         const SizedBox(height: 10),
//                       ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 18),
//               const Text(
//                 "ADD CATEGORY",
//                 style: TextStyle(
//                   fontSize: 10,
//                   letterSpacing: .7,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   // Tappable icon preview — shows whatever's currently
//                   // chosen for the category about to be created.
//                   InkWell(
//                     borderRadius: BorderRadius.circular(10),
//                     onTap: _isAdding ? null : _pickIconForNewCategory,
//                     child: Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1C6B47).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         iconFromKey(_selectedIconKey),
//                         size: 20,
//                         color: const Color(0xFF1C6B47),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextField(
//                       controller: _newCategoryController,
//                       focusNode: _newCategoryFocusNode,
//                       enabled: !_isAdding,
//                       decoration: InputDecoration(
//                         hintText: 'e.g. Pets',
//                         hintStyle: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.black38,
//                         ),
//                         isDense: true,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 12,
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFDCE5DF),
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFDCE5DF),
//                           ),
//                         ),
//                       ),
//                       onSubmitted: (_) => _addCategory(),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   ElevatedButton(
//                     onPressed: _isAdding ? null : _addCategory,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF1C6B47),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(60, 44),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isAdding
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             'Add',
//                             style: TextStyle(fontWeight: FontWeight.w700),
//                           ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _DefaultCategoryTile extends StatelessWidget {
//   final CategoryModel category;
//   const _DefaultCategoryTile({required this.category});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 46,
//           height: 46,
//           decoration: BoxDecoration(
//             color: const Color(0xFF1C6B47).withOpacity(0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             resolveCategoryIcon(category),
//             size: 20,
//             color: const Color(0xFF1C6B47),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           category.name,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
// }

// class _CustomCategoryRow extends StatelessWidget {
//   final CategoryModel category;
//   final VoidCallback onRename;
//   final VoidCallback onDelete;
//   final VoidCallback onChangeIcon;

//   const _CustomCategoryRow({
//     required this.category,
//     required this.onRename,
//     required this.onDelete,
//     required this.onChangeIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         // Tapping the avatar itself changes the icon — same "the thing
//         // you see is the thing you tap to edit" idea as the pencil icon
//         // does for the name.
//         leading: InkWell(
//           borderRadius: BorderRadius.circular(19),
//           onTap: onChangeIcon,
//           child: Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: const Color(0xFF1C6B47).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               resolveCategoryIcon(category),
//               size: 18,
//               color: const Color(0xFF1C6B47),
//             ),
//           ),
//         ),
//         title: Text(
//           category.name,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(
//                 Icons.edit_outlined,
//                 size: 20,
//                 color: Colors.black45,
//               ),
//               onPressed: onRename,
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//               onPressed: onDelete,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
