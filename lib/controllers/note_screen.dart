import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/screens/adding_note_screen.dart';
import 'package:expense_tracking/controllers/database_controller.dart';
import 'package:expense_tracking/controllers/updating_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreen();
}

class _NoteScreen extends State<NoteScreen> {
  List<Map<String, dynamic>> allNoteHere = [];

  Set<int> expandedNotes = {};

  DbHelper? db;

  @override
  void initState() {
    super.initState();
    db = DbHelper.instance;
    fetchNote();
  }

  Future<void> fetchNote() async {
    allNoteHere = await db!.readAllNOte();

    if (mounted) {
      setState(() {});
    }
  }

  Widget buildNoteCard(int index, {bool expanded = false}) {
    final note = allNoteHere[index];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            if (expandedNotes.contains(index)) {
              expandedNotes.remove(index);
            } else {
              expandedNotes.add(index);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Text(
                note[db!.COLUMN_TITLE],
                maxLines: expanded ? null : 2,
                overflow: expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // DESCRIPTION
              Text(
                note[db!.COLUMN_DESC],
                maxLines: expanded ? null : 5,
                overflow: expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),

              const SizedBox(height: 16),

              // ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdaingNoteScreen(
                            snNo: note[db!.COLUMN_SN],
                            oldTitle: note[db!.COLUMN_TITLE],
                            oldDesc: note[db!.COLUMN_DESC],
                          ),
                        ),
                      );

                      if (result == true) {
                        fetchNote();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),

                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () async {
                      final bool? shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete note?'),
                            content: Text(
                              'Are you sure you want to delete '
                              '"${note[db!.COLUMN_TITLE]}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Cancel'),
                              ),

                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      // User pressed Cancel or closed the dialog
                      if (shouldDelete != true) {
                        return;
                      }

                      // User confirmed deletion
                      int snNo = note[db!.COLUMN_SN];

                      bool result = await db!.deleteNote(sn_no: snNo);

                      if (result) {
                        fetchNote();
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notepad"),
       actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('"Notice: The notes you create are not synced with your Google account. Therefore, we do not store any notes in our database. All your notes are saved locally on your device storage !"'),
              ),
            );
          },
          icon: const Icon(Icons.info_outline),
        ),
        const SizedBox(width: 8,)
      ],),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: (allNoteHere.length / 2).ceil(),
              itemBuilder: (context, rowIndex) {
                int firstIndex = rowIndex * 2;

                int secondIndex = firstIndex + 1;

                // If the first card in this row is expanded
                if (expandedNotes.contains(firstIndex)) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildNoteCard(firstIndex, expanded: true),
                  );
                }

                // If the second card in this row is expanded
                if (secondIndex < allNoteHere.length &&
                    expandedNotes.contains(secondIndex)) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildNoteCard(secondIndex, expanded: true),
                  );
                }

                // Normal two-column row
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: buildNoteCard(firstIndex)),

                      const SizedBox(width: 12),

                      if (secondIndex < allNoteHere.length)
                        Expanded(child: buildNoteCard(secondIndex))
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xFF1C6B47),
      //   onPressed: () async {
      //     final notifyingProvider = context.read<NotifyingProvider>();

      //     bool? result = await Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const AddingNoteScreen()),
      //     );
      //     if (result == true) {
      //       await fetchNote();

      //        if (!mounted) return;

      //   context.read<NotifyingProvider>().showMessage(
      //   'Note added successfully',
      // );
      //     }
      //   },
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1C6B47),
        onPressed: () async {
          // Get the provider BEFORE the async gap.
          final notifyingProvider = context.read<NotifyingProvider>();

          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddingNoteScreen()),
          );

          if (result == true) {
            await fetchNote();

            if (!mounted) return;

            notifyingProvider.showMessage('Note added successfully');
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
