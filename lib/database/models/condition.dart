import 'package:flutter/cupertino.dart';

import 'answer.dart';

class Condition {
  final bool negated;
  final Answer condition;

  Condition(this.condition, {@required this.negated});

  bool matches(Answer answer) {
    return negated != answer.matches(condition);
  }
}