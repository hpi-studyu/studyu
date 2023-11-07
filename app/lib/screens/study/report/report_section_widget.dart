import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

abstract class ReportSectionWidget extends StatelessWidget {
  final StudySubject subject;

  const ReportSectionWidget(this.subject, {super.key});
}
