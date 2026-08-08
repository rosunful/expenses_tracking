import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking/models/saving_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavingsGoalRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user — cannot access savings goals.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _goalsRef =>
      _db.collection('users').doc(_uid).collection('savingsGoals');

  /// Goals use an auto-generated Firestore id (unlike budgets, which
  /// used category as the id) — two goals CAN share a title
  /// ("Vacation" this year, "Vacation" next year), so there's no
  /// natural unique key to reuse.
  Future<void> addGoal(String title, double targetAmount) async {
    await _goalsRef.add({
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': 0,
      'isHidden': false,
    });
  }

  /// Edits the goal's title/target only — never touches savedAmount,
  /// so editing a goal can't accidentally wipe out progress already made.
  Future<void> updateGoal(String id, String title, double targetAmount) async {
    await _goalsRef.doc(id).update({'title': title, 'targetAmount': targetAmount});
  }

  /// Adds to savedAmount atomically using Firestore's increment — this
  /// is safer than "read current value, add, write back", which could
  /// lose a contribution if two writes happened at nearly the same time.
  Future<void> contribute(String id, double amount) async {
    await _goalsRef.doc(id).update({'savedAmount': FieldValue.increment(amount)});
  }

  Future<void> hideGoal(String id) async {
    await _goalsRef.doc(id).update({'isHidden': true});
  }

  Future<void> unhideGoal(String id) async {
    await _goalsRef.doc(id).update({'isHidden': false});
  }

  Future<void> permanentlyDeleteGoal(String id) async {
    await _goalsRef.doc(id).delete();
  }

  Stream<List<SavingsGoalModel>> streamGoals() {
    return _goalsRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => SavingsGoalModel.fromMap(doc.id, doc.data()))
        .toList());
  }
}