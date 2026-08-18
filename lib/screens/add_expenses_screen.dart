import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/repositories/currency_repository.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/expense_form.dart';
import 'package:expense_tracking/widgets/add_expenses_widgets/expense_income_switch.dart';
import 'package:expense_tracking/providers/transaction_provider.dart';
import 'package:expense_tracking/widgets/add_income_widgets/income_form.dart';
import 'package:expense_tracking/screens/currency_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:expense_tracking/controllers/expenses_controller.dart';
// import 'package:expense_tracking/providers/currency_repository.dart';

class AddExpensesScreen extends StatefulWidget {
  const AddExpensesScreen({super.key});

  @override
  State<AddExpensesScreen> createState() => _AddExpensesScreen();
}

class _AddExpensesScreen extends State<AddExpensesScreen> {
  String amount = "0";
  String selectedCategory = "Food";
  String selectedIncomeCategory = "Salary";
  String selectedAccount = "Cash";

  TextEditingController noteController = TextEditingController();

  bool _isSaving = false;

  void _handleKeyPress(String key) {
    setState(() {
      if (key == "⌫") {
        if (amount.length > 1) {
          amount = amount.substring(0, amount.length - 1);
        } else {
          amount = "0";
        }
      } else if (key == ".") {
        if (!amount.contains(".")) {
          amount += ".";
        }
      } else {
        if (amount == "0") {
          amount = key;
        } else {
          amount += key;
        }
      }
    });
  }

  AccountType _accountFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'bank':
        return AccountType.bank;
      case 'card':
        return AccountType.card;
      default:
        return AccountType.cash;
    }
  }

  Future<void> _saveExpense() async {
    if (_isSaving) return;

    final parsedAmount = double.tryParse(amount) ?? 0;
    if (parsedAmount <= 0) {
      context.read<NotifyingProvider>().showMessage("Enter an amount first");
      return;
    }

    setState(() => _isSaving = true);

    final isExpense = context.read<TransactionProvider>().isExpense;
    final category = isExpense ? selectedCategory : selectedIncomeCategory;

    final transaction = TransactionModel(
      id: '',
      title: category,
      amount: parsedAmount,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      category: category,
      account: _accountFromLabel(selectedAccount),
      note: noteController.text.trim(),
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    try {
      await context.read<ExpensesController>().addExpenses(transaction);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.read<NotifyingProvider>().showMessage("Couldn't save — please try again");
      }
      return;
    }

    if (!mounted) return;

    context.read<NotifyingProvider>().showMessage(isExpense ? "Expense Saved" : "Income Saved");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = context.watch<TransactionProvider>().isExpense;
    // watch() so the button's label updates immediately if the currency
    // is changed and this screen is still open underneath.
    final currencyCode = context.watch<CurrencyProvider>().selected.code;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 28, height: 36),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "Add Transaction",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Now wired: tap opens the currency picker, and the
                  // label shows the actual selected code instead of a
                  // static "CURRENCY" placeholder.
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.appColors.cardsBackground,
                        border: Border.all(
                          color: Colors.black12,
                          width: 0.9,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currencyCode,
                            style: TextStyle(fontSize: 14,color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.expand_more_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const ExpenseIncomeSwitch(),
              const SizedBox(height: 8),
              Expanded(
                child: isExpense
                    ? ExpenseForm(
                        amount: amount,
                        onKeyPressed: _handleKeyPress,
                        noteController: noteController,
                        onSave: _isSaving ? () {} : _saveExpense,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        selectedAccount: selectedAccount,
                        onAccountSelected: (account) {
                          setState(() {
                            selectedAccount = account;
                          });
                        },
                      )
                    : IncomeForm(
                        amount: amount,
                        onKeyPressed: _handleKeyPress,
                        noteController: noteController,
                        onSave: _isSaving ? () {} : _saveExpense,
                        selectedCategory: selectedIncomeCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            selectedIncomeCategory = category;
                          });
                        },
                        selectedAccount: selectedAccount,
                        onAccountSelected: (account) {
                          setState(() {
                            selectedAccount = account;
                          });
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}















































// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/theme/app_theme.dart';
// import 'package:expense_tracking/widgets/add_expenses_widgets/expense_form.dart';
// import 'package:expense_tracking/widgets/add_expenses_widgets/expense_income_switch.dart';
// import 'package:expense_tracking/providers/transaction_provider.dart';
// import 'package:expense_tracking/widgets/add_income_widgets/income_form.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/models/transaction_model.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';

// class AddExpensesScreen extends StatefulWidget {
//   const AddExpensesScreen({super.key});

//   @override
//   State<AddExpensesScreen> createState() => _AddExpensesScreen();
// }

// class _AddExpensesScreen extends State<AddExpensesScreen> {
//   String amount = "0";
//   String selectedCategory = "Food";
//   String selectedIncomeCategory = "Salary";
//   String selectedAccount = "Cash";

//   // Renamed from titleController — this was always the source of real
//   // confusion: it's bound to the UI's NoteField widget (the "Add a
//   // note (optional)" input), but the old variable name made it look
//   // like a title field, which is exactly how the bug below happened.
//   TextEditingController noteController = TextEditingController();

//   bool _isSaving = false;

//   void _handleKeyPress(String key) {
//     setState(() {
//       if (key == "⌫") {
//         if (amount.length > 1) {
//           amount = amount.substring(0, amount.length - 1);
//         } else {
//           amount = "0";
//         }
//       } else if (key == ".") {
//         if (!amount.contains(".")) {
//           amount += ".";
//         }
//       } else {
//         if (amount == "0") {
//           amount = key;
//         } else {
//           amount += key;
//         }
//       }
//     });
//   }

//   AccountType _accountFromLabel(String label) {
//     switch (label.toLowerCase()) {
//       case 'bank':
//         return AccountType.bank;
//       case 'card':
//         return AccountType.card;
//       default:
//         return AccountType.cash;
//     }
//   }

//   Future<void> _saveExpense() async {
//     if (_isSaving) return;

//     final parsedAmount = double.tryParse(amount) ?? 0;
//     if (parsedAmount <= 0) {
//       context.read<NotifyingProvider>().showMessage("Enter an amount first");
//       // ScaffoldMessenger.of(
//       //   context,
//       // ).showSnackBar(const SnackBar(content: Text("Enter an amount first")));
//       return;
//     }

//     setState(() => _isSaving = true);

//     final isExpense = context.read<TransactionProvider>().isExpense;
//     final category = isExpense ? selectedCategory : selectedIncomeCategory;

//     // THE actual fix: what the user types in the "Add a note" field
//     // now genuinely becomes the transaction's note. Title is always
//     // the category name — there was never a separate Title input in
//     // this UI to begin with, so there's nothing else it could be.
//     // Before, this text was being used as `title` and `note` was never
//     // set at all, which is why notes never showed up anywhere.
//     final transaction = TransactionModel(
//       id: '',
//       title: category,
//       amount: parsedAmount,
//       type: isExpense ? TransactionType.expense : TransactionType.income,
//       category: category,
//       account: _accountFromLabel(selectedAccount),
//       note: noteController.text.trim(),
//       date: DateTime.now(),
//       createdAt: DateTime.now(),
//     );

//     try {
//       await context.read<ExpensesController>().addExpenses(transaction);
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSaving = false);
//         context.read<NotifyingProvider>().showMessage(
//           "Couldn't save -please try again",
//         );
//         // ScaffoldMessenger.of(context).showSnackBar(
//         //   const SnackBar(content: Text("Couldn't save — please try again.")),
//         // );
//       }
//       return;
//     }

//     if (!mounted) return;

//     context.read<NotifyingProvider>().showMessage(
//       isExpense ? "Expense Saved" : "Income Saved",
//     );
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isExpense = context.watch<TransactionProvider>().isExpense;

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       size: 18,
//                     ),
//                     visualDensity: VisualDensity.compact,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints.tightFor(
//                       width: 28,
//                       height: 36,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     "Add Transaction",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                   InkWell(
//                     child: Container(
//                       padding: EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         color: context.appColors.cardsBackground,
//                         border: Border.all(
//                           color: Colors.black54,
//                           width: 0.9,
//                           strokeAlign: BorderSide.strokeAlignOutside,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         "CURRENCY",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight(800),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               const ExpenseIncomeSwitch(),
//               const SizedBox(height: 8),
//               Expanded(
//                 child: isExpense
//                     ? ExpenseForm(
//                         amount: amount,
//                         onKeyPressed: _handleKeyPress,
//                         noteController: noteController,
//                         onSave: _isSaving ? () {} : _saveExpense,
//                         selectedCategory: selectedCategory,
//                         onCategorySelected: (category) {
//                           setState(() {
//                             selectedCategory = category;
//                           });
//                         },
//                         selectedAccount: selectedAccount,
//                         onAccountSelected: (account) {
//                           setState(() {
//                             selectedAccount = account;
//                           });
//                         },
//                       )
//                     : IncomeForm(
//                         amount: amount,
//                         onKeyPressed: _handleKeyPress,
//                         noteController: noteController,
//                         onSave: _isSaving ? () {} : _saveExpense,
//                         selectedCategory: selectedIncomeCategory,
//                         onCategorySelected: (category) {
//                           setState(() {
//                             selectedIncomeCategory = category;
//                           });
//                         },
//                         selectedAccount: selectedAccount,
//                         onAccountSelected: (account) {
//                           setState(() {
//                             selectedAccount = account;
//                           });
//                         },
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






























































// import 'package:expense_tracking/providers/notifying_provider.dart';
// import 'package:expense_tracking/widgets/add_expenses_widgets/expense_form.dart';
// import 'package:expense_tracking/widgets/add_expenses_widgets/expense_income_switch.dart';
// import 'package:expense_tracking/providers/transaction_provider.dart';
// import 'package:expense_tracking/widgets/add_income_widgets/income_form.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:expense_tracking/models/transaction_model.dart';
// import 'package:expense_tracking/controllers/expenses_controller.dart';

// class AddExpensesScreen extends StatefulWidget {
//   const AddExpensesScreen({super.key});

//   @override
//   State<AddExpensesScreen> createState() => _AddExpensesScreen();
// }

// class _AddExpensesScreen extends State<AddExpensesScreen> {
//   String amount = "0";
//   String selectedCategory = "Food";
//   String selectedIncomeCategory = "Salary";
//   String selectedAccount = "Cash";

//   TextEditingController titleController = TextEditingController();
//   TextEditingController categoryController = TextEditingController();

//   // The actual fix: blocks a second _saveExpense() call from doing
//   // anything while the first one is still in flight. Without this,
//   // a fast double-tap runs the whole async function twice — two
//   // transactions get saved, and the screen gets popped twice, which
//   // crashes since the second pop() has nothing left to pop.
//   bool _isSaving = false;

//   void _handleKeyPress(String key) {
//     setState(() {
//       if (key == "⌫") {
//         if (amount.length > 1) {
//           amount = amount.substring(0, amount.length - 1);
//         } else {
//           amount = "0";
//         }
//       } else if (key == ".") {
//         if (!amount.contains(".")) {
//           amount += ".";
//         }
//       } else {
//         if (amount == "0") {
//           amount = key;
//         } else {
//           amount += key;
//         }
//       }
//     });
//   }

//   AccountType _accountFromLabel(String label) {
//     switch (label.toLowerCase()) {
//       case 'bank':
//         return AccountType.bank;
//       case 'card':
//         return AccountType.card;
//       default:
//         return AccountType.cash;
//     }
//   }

//   Future<void> _saveExpense() async {
//     // Guard checked FIRST and synchronously — if a save is already
//     // running, every subsequent call (from extra taps) exits here
//     // immediately, before touching Firestore or the navigator at all.
//     if (_isSaving) return;

//     final parsedAmount = double.tryParse(amount) ?? 0;
//     if (parsedAmount <= 0) {
//       context.read<NotifyingProvider>().showMessage(
//         "Enter an amount first",
//         isError: true,
//       );
//       return;
//     }

//     setState(() => _isSaving = true);

//     final isExpense = context.read<TransactionProvider>().isExpense;
//     final category = isExpense ? selectedCategory : selectedIncomeCategory;

//     final transaction = TransactionModel(
//       id: '',
//       title: titleController.text.trim().isNotEmpty
//           ? titleController.text.trim()
//           : category,
//       amount: parsedAmount,
//       type: isExpense ? TransactionType.expense : TransactionType.income,
//       category: category,
//       account: _accountFromLabel(selectedAccount),
//       date: DateTime.now(),
//       createdAt: DateTime.now(),
//     );

//     try {
//       await context.read<ExpensesController>().addExpenses(transaction);
//     } catch (e) {
//       // Something actually failed (e.g. no network) — reset the guard
//       // so the user can retry, instead of the button staying stuck
//       // disabled forever.
//       if (mounted) {
//         setState(() => _isSaving = false);
//         context.read<NotifyingProvider>().showMessage(
//           "Couldn't save. Please try again.",
//           isError: true,
//         );
//       }
//       return;
//     }

//     if (!mounted) return;

//     context.read<NotifyingProvider>().showMessage(
//       isExpense ? "Expense Saved" : "Income Saved",
//     );
//     // No need to reset _isSaving here — pop() removes this screen
//     // entirely, so there's no button left to re-enable.
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isExpense = context.watch<TransactionProvider>().isExpense;

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       size: 18,
//                     ),
//                     visualDensity: VisualDensity.compact,
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints.tightFor(
//                       width: 28,
//                       height: 36,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     "Add Transaction",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               const ExpenseIncomeSwitch(),
//               const SizedBox(height: 8),
//               Expanded(
//                 child: isExpense
//                     ? ExpenseForm(
//                         amount: amount,
//                         onKeyPressed: _handleKeyPress,
//                         noteController: titleController,
//                         onSave: _isSaving ? () {} : _saveExpense,
//                         selectedCategory: selectedCategory,
//                         onCategorySelected: (category) {
//                           setState(() {
//                             selectedCategory = category;
//                           });
//                         },
//                         selectedAccount: selectedAccount,
//                         onAccountSelected: (account) {
//                           setState(() {
//                             selectedAccount = account;
//                           });
//                         },
//                       )
//                     : IncomeForm(
//                         amount: amount,
//                         onKeyPressed: _handleKeyPress,
//                         noteController: titleController,
//                         onSave: _isSaving ? () {} : _saveExpense,
//                         selectedCategory: selectedIncomeCategory,
//                         onCategorySelected: (category) {
//                           setState(() {
//                             selectedIncomeCategory = category;
//                           });
//                         },
//                         selectedAccount: selectedAccount,
//                         onAccountSelected: (account) {
//                           setState(() {
//                             selectedAccount = account;
//                           });
//                         },
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












