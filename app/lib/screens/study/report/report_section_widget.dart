import 'package:flutter/material.dart';
import 'package:studyou_core/models/study/parse_user_study.dart';

abstract class ReportSectionWidget extends StatelessWidget {
  final ParseUserStudy instance;

  const ReportSectionWidget(this.instance);
}
