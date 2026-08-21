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


  Future<void> addGoal(String title, double targetAmount) async {
    await _goalsRef.add({
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': 0,
      'isHidden': false,
    });
  }

  Future<void> updateGoal(String id, String title, double targetAmount) async {
    await _goalsRef.doc(id).update({'title': title, 'targetAmount': targetAmount});
  }

 

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