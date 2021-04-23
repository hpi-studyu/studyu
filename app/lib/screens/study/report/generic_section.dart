import 'package:flutter/material.dart';
import 'package:studyou_core/core.dart';

abstract class GenericSection extends StatelessWidget {
  final StudySubject subject;
  final GestureTapCallback onTap;

  const GenericSection(this.subject, {this.onTap});

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: buildContent(context),
          ),
        ),
      );
}
