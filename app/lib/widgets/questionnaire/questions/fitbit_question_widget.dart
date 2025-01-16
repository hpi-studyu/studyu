import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class FitbitQuestionWidget extends QuestionWidget {
  final FitbitQuestion question;
  final String taskId;
  final Function(Answer) onDone;

  const FitbitQuestionWidget({
    super.key,
    required this.question,
    required this.taskId,
    required this.onDone,
  });

  @override
  State<FitbitQuestionWidget> createState() => _FitbitQuestionWidgetState();
}

class _FitbitQuestionWidgetState extends State<FitbitQuestionWidget> {
  late List<FitbitData> value;

  @override
  void initState() {
    super.initState();
    value = [];
  }

  Future<void> _syncFitbitData() async {
    final Study study = context.read<AppState>().activeSubject!.study;

    /*try {*/

    final data = await FitbitHandler.syncFitbitData(
      study,
      widget.question,
      widget.taskId,
      context.read<AppState>().activeSubject!,
    );

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitbit data could not be synced'),
        ),
      );
      return;
    }

    setState(() {
      value = data;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitbit data synced successfully'),
      ),
    );

    widget.onDone(widget.question.constructAnswer(value));
    /*} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error syncing Fitbit data. Please try again later. Error: $e')));
      StudyULogger.error('Error syncing Fitbit data: $e');
    }*/
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
