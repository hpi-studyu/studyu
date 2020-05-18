import 'dart:async';

import 'database.dart';
import 'models/question.dart';

class QuestionDao {
  final DatabaseProvider dbProvider = DatabaseProvider.dbProvider;

  Future<int> createQuestion(Question question) async {
    final db = await dbProvider.database;
    var result = db.insert(questionTable, question.toDatabaseMap());
    return result;
  }

  Future<List<Question>> getQuestions({List<String> columns, int id}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (id != null) {
      result = await db.query(questionTable, columns: columns, where: 'id = ?', whereArgs: [id.toString()]);
    } else {
      result = await db.query(questionTable, columns: columns);
    }

    return result.isNotEmpty ? result.map((e) => Question.fromDatabaseMap(e)).toList() : [];
  }
}
