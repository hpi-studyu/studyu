import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';

class ReportDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(MdiIcons.download),
              // TODO add pdf download
              onPressed: () => null,
            ),
          ],
        ),
        body: Consumer<AppModel>(
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReportModule(ReportGeneralDetailsModule(value.reportStudy)),
              ReportModule(ReportPerformanceModule(value.reportStudy)),
              ReportModule(ReportOutcomeModule(value.reportStudy)),
            ],
          ),
        ),
      );
}

class ReportModule extends StatelessWidget {
  final ReportModuleContent module;

  const ReportModule(this.module);

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: module,
          ),
        ),
      );
}

abstract class ReportModuleContent extends StatelessWidget {
  final StudyInstance instance;

  const ReportModuleContent(this.instance);
}

class ReportGeneralDetailsModule extends ReportModuleContent {
  const ReportGeneralDetailsModule(StudyInstance instance) : super(instance);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(instance.description),
        ],
      );
}

class ReportPerformanceModule extends ReportModuleContent {
  const ReportPerformanceModule(StudyInstance instance) : super(instance);

  @override
  Widget build(BuildContext context) => Card();
}

class ReportOutcomeModule extends ReportModuleContent {
  const ReportOutcomeModule(StudyInstance instance) : super(instance);

  @override
  Widget build(BuildContext context) => Card();
}
