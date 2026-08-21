import 'dart:async';
import 'package:expense_tracking/models/reminder_model.dart';
import 'package:expense_tracking/repositories/reminder_repository.dart';
import 'package:flutter/material.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderRepository _repository = ReminderRepository();

  
  List<ReminderModel> _allReminders = [];
  StreamSubscription<List<ReminderModel>>? _subscription;

  ReminderProvider() {
    _subscription = _repository.streamReminders().listen((reminders) {
      _allReminders = reminders;
      notifyListeners();
    });
  }

  /// Visible reminders, sorted soonest-due first — nextDueDate is
  /// computed live on the model, so this re-sorts correctly every
  /// rebuild without needing Firestore to know about it.
  List<ReminderModel> get reminders {
    final visible = _allReminders.where((r) => !r.isHidden).toList();
    visible.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return visible;
  }

  List<ReminderModel> get hiddenReminders =>
      _allReminders.where((r) => r.isHidden).toList();

  Future<void> addReminder(ReminderModel reminder) async {
    await _repository.addReminder(reminder);
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _repository.updateReminder(reminder);
  }

  /// Toggles paid/done depending on which kind of reminder this is.
  /// Recurring reminders get the CURRENT period stamped (or cleared);
  /// one-off reminders just flip isDone.
  Future<void> toggleCompleted(ReminderModel reminder) async {
    if (reminder.isRecurringMonthly) {
      final isCurrentlyPaid = reminder.lastPaidPeriod == ReminderModel.currentPeriodKey;
      await _repository.setPaidPeriod(
        reminder.id,
        isCurrentlyPaid ? null : ReminderModel.currentPeriodKey,
      );
    } else {
      await _repository.setDone(reminder.id, !reminder.isDone);
    }
  }

  /// Swipe-to-delete calls this.
  Future<void> hideReminder(String id) async {
    await _repository.hideReminder(id);
  }

  Future<void> unhideReminder(String id) async {
    await _repository.unhideReminder(id);
  }

  Future<void> permanentlyDeleteReminder(String id) async {
    await _repository.permanentlyDeleteReminder(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}