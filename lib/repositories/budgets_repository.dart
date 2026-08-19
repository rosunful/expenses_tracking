import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracking/models/budgets_model.dart';
import 'package:expense_tracking/controllers/budget_period_controller.dart';

class BudgetRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user — cannot access budgets.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _budgetsRef =>
      _db.collection('users').doc(_uid).collection('budgets');

  /// Category name is used AS the document id — at most one budget per
  /// category. A brand-new budget always starts visible (isHidden: false),
  /// even if a budget for this category was hidden before and is being
  /// re-created — the old copyWith("hidden") state shouldn't leak into
  /// a fresh save.
  Future<void> setBudget(String category, double targetAmount, BudgetPeriod period) async {
    await _budgetsRef.doc(category).set(
      BudgetModel(
        id: category,
        category: category,
        targetAmount: targetAmount,
        period: period,
        isHidden: false,
      ).toMap(),
    );
  }

  /// Soft delete — the document stays in Firestore, just marked hidden.
  Future<void> hideBudget(String category) async {
    await _budgetsRef.doc(category).update({'isHidden': true});
  }

  /// Brings a hidden budget back to the main list.
  Future<void> unhideBudget(String category) async {
    await _budgetsRef.doc(category).update({'isHidden': false});
  }

  /// The ONLY method that actually removes data from Firestore. Only
  /// called from the History screen, after an explicit confirmation.
  Future<void> permanentlyDeleteBudget(String category) async {
    await _budgetsRef.doc(category).delete();
  }

  /// Streams every budget — hidden and visible together. BudgetProvider
  /// splits them into two lists; keeping one stream/query is simpler
  /// than running two separate Firestore listeners.
  Stream<List<BudgetModel>> streamBudgets() {
    return _budgetsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BudgetModel.fromMap(doc.id, doc.data())).toList());
  }
}






// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:expense_tracking/models/budgets_model.dart';
// import 'package:expense_tracking/widgets/budget_period/budget_period.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class BudgetRepository {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   String get _uid {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) {
//       throw Exception('No logged-in user — cannot access budgets.');
//     }
//     return uid;
//   }

//   CollectionReference<Map<String, dynamic>> get _budgetsRef =>
//       _db.collection('users').doc(_uid).collection('budgets');

//   /// Category name is used AS the document id. This guarantees at most
//   /// one budget per category — setting a budget for "Food" twice just
//   /// overwrites the existing one instead of creating a duplicate, which
//   /// keeps "add" and "edit" the same simple operation.
//   Future<void> setBudget(
//     String category,
//     double targetAmount,
//     BudgetPeriod period,
//   ) async {
//     await _budgetsRef
//         .doc(category)
//         .set(
//           BudgetModel(
//             id: category,
//             category: category,
//             targetAmount: targetAmount,
//             period: period,
//           ).toMap(),
//         );
//   }

//   Future<void> deleteBudget(String category) async {
//     await _budgetsRef.doc(category).delete();
//   }

//   Stream<List<BudgetModel>> streamBudgets() {
//     return _budgetsRef.snapshots().map(
//       (snapshot) => snapshot.docs
//           .map((doc) => BudgetModel.fromMap(doc.id, doc.data()))
//           .toList(),
//     );
//   }
// }
