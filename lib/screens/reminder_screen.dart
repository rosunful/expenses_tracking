import 'package:expense_tracking/models/reminder_model.dart';
import 'package:expense_tracking/providers/reminder_provider.dart';
import 'package:expense_tracking/widgets/add_income_widgets/category_chip_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Reuses the same category infrastructure as expense/income categories —
// CategoryType.reminder is a third branch of the same system.
import 'package:expense_tracking/models/category_model.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dayOfMonthController = TextEditingController();

  ReminderType _type = ReminderType.bill;
  String _selectedCategory = 'Other';
  bool _isRecurringMonthly = true; // defaults to "every month", matches your original ask
  DateTime? _oneOffDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayOfMonthController.dispose();
    super.dispose();
  }

  Future<void> _pickOneOffDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _oneOffDueDate = picked);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title')),
      );
      return;
    }

    int? dayOfMonth;
    if (_isRecurringMonthly) {
      dayOfMonth = int.tryParse(_dayOfMonthController.text.trim());
      if (dayOfMonth == null || dayOfMonth < 1 || dayOfMonth > 31) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid day of month (1–31)')),
        );
        return;
      }
    } else if (_oneOffDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a due date')),
      );
      return;
    }

    final reminder = ReminderModel(
      id: '',
      title: title,
      type: _type,
      category: _selectedCategory,
      amount: double.tryParse(_amountController.text.trim()),
      isRecurringMonthly: _isRecurringMonthly,
      dueDayOfMonth: _isRecurringMonthly ? dayOfMonth : null,
      dueDate: _isRecurringMonthly ? null : _oneOffDueDate,
    );

    await context.read<ReminderProvider>().addReminder(reminder);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _typeChip(ReminderType type, String label) {
    final isSelected = _type == type;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _type = type),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C6B47) : const Color(0xffE9EEEA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldDecoration = const InputDecoration(
      filled: true,
      fillColor: Color(0xFFF1F5F2),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFDCE5DF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFDCE5DF)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('New Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: fieldDecoration.copyWith(hintText: 'e.g. Pay electricity bill'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _typeChip(ReminderType.bill, 'Bill'),
                  _typeChip(ReminderType.emi, 'EMI'),
                  _typeChip(ReminderType.task, 'Task'),
                ],
              ),
              const SizedBox(height: 20),

              // The category system already built for expense/income —
              // reused as-is, just pointed at CategoryType.reminder.
              // "+ New" here pushes ManageCategoriesScreen as a real
              // screen (not a popup), same as you asked for.
              CategoryChipPicker(
                type: CategoryType.reminder,
                selectedCategory: _selectedCategory,
                onSelected: (category) => setState(() => _selectedCategory = category),
              ),
              const SizedBox(height: 20),

              // This switch is the actual feature you asked for earlier:
              // choosing between "every month on this date" vs a
              // one-time due date.
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Repeats every month', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isRecurringMonthly,
                activeThumbColor: const Color(0xFF1C6B47),
                onChanged: (value) => setState(() => _isRecurringMonthly = value),
              ),

              if (_isRecurringMonthly)
                TextField(
                  controller: _dayOfMonthController,
                  keyboardType: TextInputType.number,
                  decoration: fieldDecoration.copyWith(
                    labelText: 'Day of month',
                    hintText: 'e.g. 5 (for the 5th every month)',
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickOneOffDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _oneOffDueDate == null
                        ? 'Pick due date'
                        : '${_oneOffDueDate!.year}-${_oneOffDueDate!.month.toString().padLeft(2, '0')}-${_oneOffDueDate!.day.toString().padLeft(2, '0')}',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    side: const BorderSide(color: Color(0xFFDCE5DF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: fieldDecoration.copyWith(labelText: 'Amount (optional)'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C6B47),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Add Reminder',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}