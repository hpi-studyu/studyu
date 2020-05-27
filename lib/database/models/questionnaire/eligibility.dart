import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'conditions/condition.dart';
import 'questions/question.dart';

class Eligibility extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'Eligibility';
  static const keyQuestions = 'questions';
  static const keyConditions = 'conditions';

  Eligibility() : super(_keyTableName);

  Eligibility.clone() : this();

  @override
  Eligibility clone(Map<String, dynamic> map) => Eligibility.clone()..fromJson(map);

  List<Question> get questions => get<List<dynamic>>(keyQuestions)?.map((e) => Question.fromJson(e))?.toList() ?? [];

  set questions(List<Question> questions) =>
      set<List<Map<String, dynamic>>>(keyQuestions, questions.map((e) => e.toJson()).toList());

  List<Condition> get conditions =>
      get<List<dynamic>>(keyConditions)?.map((e) => Condition.fromJson(e))?.toList() ?? [];

  set conditions(List<Condition> conditions) =>
      set<List<Map<String, dynamic>>>(keyConditions, conditions.map((e) => e.toJson()).toList());
}
