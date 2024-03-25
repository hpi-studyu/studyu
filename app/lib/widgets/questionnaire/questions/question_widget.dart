import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class QuestionWidget extends StatefulWidget {
  const QuestionWidget({super.key});

  String? get subtitle => null;
}
