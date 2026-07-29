import 'package:flutter/material.dart';

class NoteField extends StatelessWidget {
  final TextEditingController controller;

  const NoteField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Add a note...",
        prefixIcon: const Icon(Icons.note_add_rounded),

        filled: true,
        fillColor: Colors.grey.shade100,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
