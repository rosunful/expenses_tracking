import 'package:expense_tracking/controllers/database_controller.dart';
import 'package:flutter/material.dart';

class AddingNoteScreen extends StatefulWidget {
  const AddingNoteScreen({super.key});

  @override
  State<AddingNoteScreen> createState() => _AddingNoteScreenState();
}

class _AddingNoteScreenState extends State<AddingNoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  DbHelper? db;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Note"), backgroundColor: Colors.green),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 10,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter the Title",
                  label: Text("Title"),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),

              TextField(
                controller: descController,
                maxLines: 12,
                decoration: InputDecoration(
                  label: Text("Description"),
                  hint: Text("Note here..."),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),

              Row(
                spacing: 2,
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        var mTitle = titleController.text;
                        var mDesc = descController.text;
                        if (mTitle.isNotEmpty && mDesc.isNotEmpty) {
                          bool result = await db!.addNote(mTitle, mDesc);

                          if (result) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to Add")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter both title and description",
                              ),
                            ),
                          );
                        }
                      },
                      child: Text("Add"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("cancel"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
