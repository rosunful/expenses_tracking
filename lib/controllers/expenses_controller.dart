import 'package:expense_tracking/models/expenses_model.dart';
import 'package:flutter/material.dart';

class ExpensesController extends ChangeNotifier {

//FOR THE STORING THE EXPENSES IN THE PRIVATE LIST  
  final List<ExpensesModel> _expenses = [];

//FOR THE MAKING THE EXPENSES LIST ACCESSABLE TO THE UI 
  List<ExpensesModel> get expensesNoPrivate => _expenses;


//FOR THE ADDING THE EXPENSES IN THE LIST 
  void addExpenses(ExpensesModel expenseswillcome) {
    _expenses.add(expenseswillcome);

    notifyListeners();
  }


//FOR THE DELETING THE EXPENSES FROM THE LIST
  void deleteExpenses(ExpensesModel expenseswillcome) {
    _expenses.remove(expenseswillcome);

    notifyListeners();
  }


//FOR THE GETTING TOTAL EXPENSES 
  //fun fact the reason we are writing the get in thsi function because we dont need to write the ()
  //just to avoid these () the developer use get . eg: after doing this we can print(viewModel.totalExpenses); ui
  // Clean! No parentheses () needed
  double get totalExpenses {
    double total = 0;
    //to undersatnding the eachListExpenses variable is created right on the spot
    for (final robotLookAndReturn in _expenses) {
      total = total + robotLookAndReturn.amount;
    }
    return total;
  }


//FOR THE LIST SHOWING OF THAT PARTICULAR OR TARGETED CATEGORY 
  List<ExpensesModel> filterCategory(String targetCategory) {
    //twist here we see the singleExpense is created on the spot and this is the variable
    return _expenses.where((singleExpense) {
      return singleExpense.category.toLowerCase() ==
          targetCategory.toLowerCase();
    }).toList();
  }


//FOR THE TOTAL SUM OF THE PARTICULAR OR TARGETED CATEGORY
  Map<String, double> get categoryTotals {
  Map<String, double> totals = {};

  for (final expense in _expenses) {
    if (totals.containsKey(expense.category)) {
      totals[expense.category] =
          totals[expense.category]! + expense.amount;
    } else {
      totals[expense.category] = expense.amount;
    }
  }

  return totals;
}
}
