import 'package:expense_tracking/models/reminder_model.dart';
import 'package:expense_tracking/providers/reminder_provider.dart';
import 'package:expense_tracking/screens/reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reminder_history_screen.dart';

class BillsSubscriptionsScreen extends StatelessWidget {
  const BillsSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<ReminderProvider>().reminders;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Bills & Subscriptions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Reminder history',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReminderHistoryScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C6B47),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddReminderScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: reminders.isEmpty
            ? const Center(
                child: Text(
                  "No bills or reminders yet.\nTap + to add one.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reminders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _SwipeableReminderTile(reminder: reminders[index]),
              ),
      ),
    );
  }
}

class _SwipeableReminderTile extends StatefulWidget {
  final ReminderModel reminder;
  const _SwipeableReminderTile({required this.reminder});

  @override
  State<_SwipeableReminderTile> createState() => _SwipeableReminderTileState();
}

class _SwipeableReminderTileState extends State<_SwipeableReminderTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpen = false;

  static const double _revealFraction = 0.3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxOffset) {
    final delta = details.primaryDelta ?? 0;

    final newValue = _controller.value - (delta / maxOffset);
    _controller.value = newValue.clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final shouldOpen = _controller.value > 0.5;
    _controller.animateTo(shouldOpen ? 1.0 : 0.0, curve: Curves.easeOut);
    setState(() => _isOpen = shouldOpen);
  }

  void _close() {
    _controller.animateTo(0.0, curve: Curves.easeOut);
    setState(() => _isOpen = false);
  }

  void _delete(BuildContext context) {
    final reminder = widget.reminder;

    context.read<ReminderProvider>().hideReminder(reminder.id);
    _close();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${reminder.title}" moved to history'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () =>
              context.read<ReminderProvider>().unhideReminder(reminder.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxOffset = constraints.maxWidth * _revealFraction;

        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, maxOffset),
          onHorizontalDragEnd: _handleDragEnd,
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: maxOffset,
                    child: Material(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _isOpen ? () => _delete(context) : null,
                        child: const Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(-_controller.value * maxOffset, 0),
                  child: child,
                ),
                child: Stack(
                  children: [
                    _ReminderCardContent(reminder: widget.reminder),
                    if (_isOpen)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _close,
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReminderCardContent extends StatelessWidget {
  final ReminderModel reminder;
  const _ReminderCardContent({required this.reminder});

  String _statusText() {
    if (reminder.isCompletedForCurrentPeriod) {
      return reminder.isRecurringMonthly ? 'Paid this month' : 'Done';
    }
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final due = reminder.nextDueDate;
    final dueDay = DateTime(due.year, due.month, due.day);
    final daysUntil = dueDay.difference(now).inDays;

    if (daysUntil == 0) return 'Due today';
    if (daysUntil > 0) {
      return 'Due in $daysUntil day${daysUntil == 1 ? '' : 's'}';
    }
    return 'Overdue by ${-daysUntil} day${-daysUntil == 1 ? '' : 's'}';
  }

  Color _statusColor() {
    if (reminder.isCompletedForCurrentPeriod) return const Color(0xFF1C6B47);
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final due = reminder.nextDueDate;
    final dueDay = DateTime(due.year, due.month, due.day);
    final daysUntil = dueDay.difference(now).inDays;
    if (daysUntil < 0) return Colors.red;
    if (daysUntil <= 2) return Colors.orange;
    return Colors.black54;
  }

  Color _typeColor() => switch (reminder.type) {
    ReminderType.bill => const Color(0xFFE57373),
    ReminderType.emi => Colors.indigo,
    ReminderType.task => const Color(0xFF1C6B47),
  };

  @override
  Widget build(BuildContext context) {
    final isCompleted = reminder.isCompletedForCurrentPeriod;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF3F5F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () =>
                context.read<ReminderProvider>().toggleCompleted(reminder),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isCompleted ? const Color(0xFF1C6B47) : _typeColor())
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.notifications_none,
                color: isCompleted ? const Color(0xFF1C6B47) : _typeColor(),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminder.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _typeColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reminder.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _typeColor(),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  [
                    if (reminder.amount != null)
                      '\$${reminder.amount!.toStringAsFixed(2)}',
                    _statusText(),
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
