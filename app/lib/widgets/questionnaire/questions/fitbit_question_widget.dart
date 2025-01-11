import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

import '../../../util/fitbit_handler.dart';

class FitbitQuestionWidget extends QuestionWidget {
  final FitbitQuestion question;
  final String taskId;
  final Function(Answer)? onDone;

  const FitbitQuestionWidget({
    super.key,
    required this.question,
    required this.taskId,
    this.onDone,
  });

  @override
  State<FitbitQuestionWidget> createState() => _FitbitQuestionWidgetState();
}

class _FitbitQuestionWidgetState extends State<FitbitQuestionWidget> {
  List<FitbitData>? value;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _syncFitbitData() async {
    final Study study = context.read<AppState>().activeSubject!.study;

    final success = await FitbitHandler.syncFitbitData(
      study,
      widget.question,
      widget.taskId,
      context.read<AppState>().activeSubject!,
    );

    for (final data in success) {
      StudyULogger.info(
          'Synced Fitbit Data: ${(data as FitbitHeartData).value}');
    }
    StudyULogger.info('Synced Fitbit Data');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _syncFitbitData,
          child: const Text('Sync Fitbit Data'),
        ),
      ],
    );
  }
}
