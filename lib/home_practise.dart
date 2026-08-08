// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';

void main() {
  runApp(Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  List<String> songs = ["pehla", "payyar", "mera"];

  String jsonn = '{"j.name" : "roshan", "j.age":20,"j.funny":true}';

  MeroModel obj = MeroModel(name: "haro", age: 32, funny: false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> decoded = jsonDecode(jsonn);

                MeroModel obj = MeroModel.fromMap(decoded);

                print(obj.name);
              },
              child: Text("Decoded"),
            ),

            ElevatedButton(onPressed: () {

              Map<String,dynamic> encoded =  obj.tomap();

              String encodedDone = jsonEncode(encoded);

              print(encodedDone);


            }, child: Text("Encoded")),
          ],
        ),
      ),
    );
  }
}

class MeroModel {
  String name;
  int age;
  bool funny;

  MeroModel({required this.name, required this.age, this.funny = true});

  // Obj To Json
  Map<String, dynamic> tomap() {
    return {"j.name": name, "j.age": age, "j.funny": funny};
  }

  //json to obj
  factory MeroModel.fromMap(Map<String, dynamic> map) {
    return MeroModel(
      name: map["j.name"],
      age: map['j.age'],
      funny: map["j.funny"],
    );
  }
}
