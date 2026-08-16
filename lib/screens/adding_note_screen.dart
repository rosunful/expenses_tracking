import 'package:expense_tracking/controllers/database_controller.dart';
import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddingNoteScreen extends StatefulWidget {
  const AddingNoteScreen({super.key});

  @override
  State<AddingNoteScreen> createState() => _AddingNoteScreenState();
}

class _AddingNoteScreenState extends State<AddingNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  DbHelper? db;

  // static const Color primaryGreen = Color(0xFF1C6B47);

  @override
  void initState() {
    super.initState();
    db = DbHelper.instance;
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> addNote() async {
    final String title = titleController.text.trim();
    final String description = descController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      context.read<NotifyingProvider>().showMessage(
        'Please enter both title and description',
        isError: true,
      );
      return;
    }

    final bool result = await db!.addNote(title, description);

    if (!mounted) return;

    if (result) {
      Navigator.pop(context, true);
    } else {
      context.read<NotifyingProvider>().showMessage(
        'Failed to add note',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,

        title: Text(
          'New Note',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: 
          NotepadEditAddWidget(titleController: titleController, descController: descController, onAddNote: addNote)       
        ),
      ),
    );
  }
}



class NotepadEditAddWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final VoidCallback onAddNote;

  const NotepadEditAddWidget({
    super.key,
    required this.titleController,
    required this.descController,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE
        const Text(
          'Title',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: titleController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Give your note a title',
            filled: true,
            fillColor: context.appColors.card,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF1C6B47),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // DESCRIPTION
        const Text(
          'Description',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: descController,
          maxLines: 12,
          minLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Write your note here...',

            alignLabelWithHint: true,
            filled: true,
            fillColor: context.appColors.card,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF1C6B47),
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        // BUTTONS
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close_rounded, size: 20),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: context.appColors.cardsBackground,
                  foregroundColor: Colors.red.shade700,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Colors.transparent),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: FilledButton.icon(
                onPressed: onAddNote,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: const Text('Add Note'),
                style: FilledButton.styleFrom(
                  // backgroundColor: primaryGreen,
                  backgroundColor: context.appColors.cardsBackground,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
