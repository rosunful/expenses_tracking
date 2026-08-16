import 'package:expense_tracking/controllers/database_controller.dart';
import 'package:expense_tracking/providers/notifying_provider.dart';
import 'package:expense_tracking/screens/adding_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdaingNoteScreen extends StatefulWidget {
  final int snNo;
  final String oldTitle;
  final String oldDesc;

  const UpdaingNoteScreen({
    super.key,
    required this.snNo,
    required this.oldTitle,
    required this.oldDesc,
  });

  @override
  State<UpdaingNoteScreen> createState() => _UpdatingNoteScreen();
}

class _UpdatingNoteScreen extends State<UpdaingNoteScreen> {
  DbHelper? db;

  final TextEditingController titleController = TextEditingController();

  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    db = DbHelper.instance;
    titleController.text = widget.oldTitle;
    descController.text = widget.oldDesc;
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> onBackBtn() async {
    String newTitle = titleController.text.trim();

    String newDesc = descController.text.trim();

    if (newTitle.isNotEmpty && newDesc.isNotEmpty) {
      bool result = await db!.updateNote(
        getTitle: newTitle,
        getDesc: newDesc,
        sn_no: widget.snNo,
      );

      if (result) {
        Navigator.pop(context, true);
      } else {
          context.read<NotifyingProvider>().showMessage(
          'Failed To Add'
        );
      }
    } else {
      context.read<NotifyingProvider>().showMessage(
        "Please enter the both title and description !"
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Note"),backgroundColor:Color.fromARGB(255, 39, 175, 112) , ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: NotepadEditAddWidget(
              titleController: titleController,
              descController: descController,
              onAddNote: onBackBtn,
            ),
          ),
        ),
      ),
    );
  }
}
