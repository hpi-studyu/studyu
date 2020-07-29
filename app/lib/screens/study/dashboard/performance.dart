import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';

class PerformanceScreen extends StatefulWidget {
  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  StudyInstance study;

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().activeStudy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    study.resultCount();
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Text('This is your performance', style: theme.textTheme.subtitle1),
            Card(
              child: Column(
                children: const [
                  LinearProgressIndicator(
                    minHeight: 16,
                    value: 0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
