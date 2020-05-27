import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'answer.dart';

class BooleanAnswer extends Answer {
  static const String answerType = 'potato';
  @override
  String get type => answerType;

  bool answerValue;

  BooleanAnswer(int id, DateTime timestamp, int questionId, {@required this.answerValue}) : super(id, timestamp, questionId);

  BooleanAnswer.fromJson(Map<String, dynamic> data) : super.fromJsonScaffold(data) {
    answerValue = data['value'];
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    'value': answerValue
  });

}