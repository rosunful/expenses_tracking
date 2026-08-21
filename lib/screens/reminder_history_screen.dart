import 'package:expense_tracking/models/reminder_model.dart';
import 'package:expense_tracking/providers/reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReminderHistoryScreen extends StatelessWidget {
  const ReminderHistoryScreen({super.key});

  Future<void> _confirmPermanentDelete(
    BuildContext context,
    ReminderModel reminder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: Text(
          '"${reminder.title}" will be permanently removed and cannot be recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete Permanently',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ReminderProvider>().permanentlyDeleteReminder(
        reminder.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiddenReminders = context.watch<ReminderProvider>().hiddenReminders;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminder History')),
      body: SafeArea(
        child: hiddenReminders.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "No archived reminders.\nSwiping a reminder away moves it here first, "
                    "so nothing is lost by accident.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: hiddenReminders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final reminder = hiddenReminders[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF3F5F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                reminder.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context
                              .read<ReminderProvider>()
                              .unhideReminder(reminder.id),
                          child: const Text('Undo'),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _confirmPermanentDelete(context, reminder),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
