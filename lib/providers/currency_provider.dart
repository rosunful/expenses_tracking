import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Only stores a single field — the currency CODE ("NPR", "USD") — on
/// the user's own document, not a subcollection. The full CurrencyModel
/// (name + symbol) is looked up from the static supportedCurrencies
/// list by this code, so there's nothing else worth persisting.
class CurrencyRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user — cannot access currency preference.');
    }
    return uid;
  }

  Future<String?> getCurrencyCode() async {
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data()?['currencyCode'] as String?;
  }

  /// merge: true so this never overwrites other fields already on the
  /// user's document (display name, etc.) — it only ever touches
  /// currencyCode.
  Future<void> setCurrencyCode(String code) async {
    await _db.collection('users').doc(_uid).set(
      {'currencyCode': code},
      SetOptions(merge: true),
    );
  }
}