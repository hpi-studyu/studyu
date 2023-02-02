import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class QuestionWidget extends StatefulWidget {
  const QuestionWidget({Key key}) : super(key: key);

  String get subtitle => null;
}
