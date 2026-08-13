// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {}

class SingletonGG {

  String TABLE_NAME = "note";
  String COLUMN_SN = "sn";
  SingletonGG._();

  Database? _database;

  Future<Database> checkDatabase() async {
    if (_database == null) {
      return await createDatabase();
    } else {
      return _database!;
    }
  }

  //THIS IS FOR THE CHECKING THE DATABASE HAS BE CREATED OR NOT IF 
  //CREATED RETURN THE CREATED DATABASE 
  Future<Database> createDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();

    String path = join(appDir.path, " Database_Folder");

    return await openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE note (id INTEGER PRIMARY KEY AUTOINCREMENT ,title TEXT ,desc TEXT)',
        );
      },
      version: 1,
    );
  }

  // THIS FOR THE ADDING NOTE
  Future<void> addNote({required String title, required String desc}) async{
    Database db = await createDatabase();
    await db.insert("note" , {
      "title" : title,
      "desc" : desc,
    });
  }

  // THIS IS FOR THE READING ALL NOTES
  Future<List <Map<String , dynamic >>> readAllNote() async{
    
    Database db = await createDatabase();
    List<Map<String,dynamic>> mao = await db.query("note");
    return mao ;
  }

  
}
