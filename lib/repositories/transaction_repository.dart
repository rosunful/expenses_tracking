import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Talks directly to Firestore for everything under
/// users/{uid}/transactions. Nothing else in the app should call
/// FirebaseFirestore.instance for transactions directly — it all
/// goes through here, same pattern as AuthService for auth.
class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Every method needs the current user's uid to know which
  /// subcollection to read/write. If nobody's logged in, something
  /// upstream (AuthWrapper) has already gone wrong, so we throw
  /// loudly rather than silently doing nothing.
  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user — cannot access transactions.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _transactionsRef =>
      _db.collection('users').doc(_uid).collection('transactions');

  /// Adds a new transaction. Firestore auto-generates the document ID,
  /// so the TransactionModel you pass in doesn't need a real id yet.
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionsRef.add(transaction.toMap());
  }

  /// Updates an existing transaction by its document id.
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionsRef.doc(transaction.id).update(transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).delete();
  }

  /// A live stream of all transactions, newest first. Your provider
  /// listens to this so the UI updates automatically whenever data
  /// changes — no manual refresh needed, and it works across devices.
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
