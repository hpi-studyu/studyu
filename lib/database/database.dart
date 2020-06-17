import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

//import 'models/questions/question.dart';

const String questionTable = 'Question';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    return createDatabase();
  }

  Future<Database> createDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'Nof1.db');

    final database = await openDatabase(path, version: 1, onCreate: initDB, onUpgrade: onUpgrade);
    return database;
  }

  Future<void> initDB(Database db, int version) async {
    await db.execute('CREATE TABLE $questionTable ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'question TEXT, '
        'option1 TEXT, '
        'option2 TEXT '
        ')');

    /*await db.insert(
        questionTable,
        Question(id: 0, question: 'Have you had back pain in the last 2 weeks?', option1: 'yes', option2: 'no')
            .toDatabaseMap());
    await db.insert(
        questionTable, Question(id: 1, question: 'Are you pregnant?', option1: 'yes', option2: 'no').toDatabaseMap());
    await db.insert(questionTable,
        Question(id: 2, question: 'Select the best number.', option1: '12', option2: '42').toDatabaseMap());*/
  }

  void onUpgrade(Database db, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }
}
