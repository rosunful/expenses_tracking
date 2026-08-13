// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

 final String valuesJsonType = '''
    {"name" : "justin", 
    "releaseYear" : 2016,
    "superHit" : true ,
    "collab" : "drake",
    "viewsCount" : 100000
    } ''';

  JB valuesObjType = JB(
    name: "drake",
    releaseYear: 2003,
    superHit: true,
    collab: 'nokia',
    viewsCount: 1000,
  );


  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> encode = valuesObjType.toMap();
    String encoded = jsonEncode(encode);

    //converting to obj
    Map<String, dynamic> decoded = jsonDecode(valuesJsonType);
    JB obj = JB.fromMap(decoded);

    return MaterialApp(home: Scaffold(
      body: 
      Column(
        children: [
          Text(encoded),
          Text(obj.name)
        ],
      ),
    ));
  }
}

class JB {
  String name;
  int releaseYear;
  bool superHit;
  String collab;
  double viewsCount;

  JB({
    required this.name,
    required this.releaseYear,
    required this.superHit,
    required this.collab,
    required this.viewsCount,
  });

  //object to json
  Map<String, Object> toMap() {
    return {
      'name': name,
      'releaseYear ': releaseYear,
      'superHit': superHit,
      'collab': collab,
      'viewsCount': viewsCount,
    };
  }

  //json to object
  factory JB.fromMap(Map<String, dynamic> map) {
    return JB(
      name: map['name'],
      releaseYear: map['releaseYear'],
      superHit: map['superHit'],
      collab: map['collab'],
      viewsCount: map['viewsCount'].toDouble(),
    );
  }
}
