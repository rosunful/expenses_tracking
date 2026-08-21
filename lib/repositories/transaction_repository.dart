import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user — cannot access transactions.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _db.collection('users').doc(_uid).collection('transactions');


  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsRef.add(transaction.toMap());
  }


  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsRef.doc(transaction.id).update(transaction.toMap());
  }

  Future<void> hideTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).update({'isHidden': true});
  }

  Future<void> unhideTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).update({'isHidden': false});
  }


  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).delete();
  }

 
  Stream<List<TransactionModel>> streamTransactions() {
    return _transactionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}



