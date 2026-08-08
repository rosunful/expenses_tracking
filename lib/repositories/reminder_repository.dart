import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracking/models/reminder_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ReminderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('No logged-in user — cannot access reminders.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _remindersRef =>
      _db.collection('users').doc(_uid).collection('reminders');

  Future<void> addReminder(ReminderModel reminder) async {
    await _remindersRef.add(reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _remindersRef.doc(reminder.id).update(reminder.toMap());
  }

  /// Marks a RECURRING reminder as paid for the given period (e.g.
  /// "2026-08"). Only touches this one field — everything else about
  /// the reminder (title, day of month, amount) stays untouched.
  Future<void> setPaidPeriod(String id, String? periodKey) async {
    await _remindersRef.doc(id).update({'lastPaidPeriod': periodKey});
  }

  /// Marks a ONE-OFF reminder (typically a Task) done or not done.
  Future<void> setDone(String id, bool isDone) async {
    await _remindersRef.doc(id).update({'isDone': isDone});
  }

  /// Swipe-to-delete calls this — soft delete, not a real removal.
  Future<void> hideReminder(String id) async {
    await _remindersRef.doc(id).update({'isHidden': true});
  }

  /// Brings an archived reminder back to the main list.
  Future<void> unhideReminder(String id) async {
    await _remindersRef.doc(id).update({'isHidden': false});
  }

  /// The ONLY method that actually removes data from Firestore. Only
  /// called from the History screen, after explicit confirmation.
  Future<void> permanentlyDeleteReminder(String id) async {
    await _remindersRef.doc(id).delete();
  }

  Stream<List<ReminderModel>> streamReminders() {
    return _remindersRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ReminderModel.fromMap(doc.id, doc.data()))
        .toList());
  }
}