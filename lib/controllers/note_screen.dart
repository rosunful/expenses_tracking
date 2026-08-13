import 'package:expense_tracking/controllers/adding_note_screen.dart';
import 'package:expense_tracking/controllers/database_controller.dart';
import 'package:expense_tracking/controllers/updating_note_screen.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreen();
}

class _NoteScreen extends State<NoteScreen> {
  List<Map<String, dynamic>> allNoteHere = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Note Adding")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allNoteHere.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(allNoteHere[index][db!.COLUMN_TITLE]),
                  subtitle: Text(allNoteHere[index][db!.COLUMN_DESC]),
                  leading: Text(allNoteHere[index][db!.COLUMN_SN].toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 15,
                    children: [
                      // EDIT
                      InkWell(
                        onTap: () async {
                          final note = allNoteHere[index];

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
                        child: const Icon(Icons.edit),
                      ),

                      // DELETE
                      InkWell(
                        onTap: () async {
                          final note = allNoteHere[index];

                          int snNo = note[db!.COLUMN_SN];

                          bool result = await db!.deleteNote(sn_no: snNo);

                          if (result) {
                            fetchNote();
                          }
                        },

                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddingNoteScreen(),
                ),
              );

              if (result == true) {
                fetchNote();
              }
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }
}
