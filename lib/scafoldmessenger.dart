import 'package:flutter/material.dart';

void main() {
  runApp(Hora());
}

class Hora extends StatelessWidget {
  const Hora({super.key});

  @override
  Widget build(BuildContext contextxxx) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (contextBuilder) {
            return TextButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  contextBuilder,
                ).showSnackBar(SnackBar(content: Text("data")));
              },
              child: Text("click"),
            );
          }
        ),
      ),
    );
  }
}
