// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  String TABLE_NAME = "note_table";
  String COLUMN_SN = "s_n";
  String COLUMN_TITLE = "title";
  String COLUMN_DESC = "desc";

  DbHelper._();

  static final instance = DbHelper._();

  Database? _database;

  Future<Database> checkDatabase() async {
    if (_database == null) {
      _database = await createDatabase();
      return _database!;
    } else {
      return _database!;
    }
  }

  Future<Database> createDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();

    String path = join(appDir.path, "Expense_Tracker_Note_Storage");

    return await openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE $TABLE_NAME($COLUMN_SN INTEGER PRIMARY KEY AUTOINCREMENT ,$COLUMN_TITLE TEXT , $COLUMN_DESC TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<bool> addNote(String uTitle, String uDesc) async {
    Database db = await checkDatabase();

    int rowAffected = await db.insert(TABLE_NAME, {
      COLUMN_TITLE: uTitle,
      COLUMN_DESC: uDesc,
    });

    return rowAffected > 0;
  }

  Future<List<Map<String, dynamic>>> readAllNOte() async {
    Database db = await checkDatabase();
    List<Map<String, dynamic>> map = await db.query(TABLE_NAME);
    return map;
  }

  Future<bool> updateNote({
    required String getTitle,
    required String getDesc,
    required int sn_no,
  }) async {
    Database db = await checkDatabase();

    int rowEffected = await db.update(
      TABLE_NAME,
      {COLUMN_TITLE: getTitle, COLUMN_DESC: getDesc},
      where: "$COLUMN_SN = ?",
      whereArgs: [sn_no],
    );

    return rowEffected > 0;
  }

  Future<bool> deleteNote({required int sn_no}) async {
    Database db = await checkDatabase();

    int rowAffected = await db.delete(
      TABLE_NAME,
      where: "$COLUMN_SN = ?",
      whereArgs: [sn_no],
    );

    return rowAffected > 0;
  }
}
