import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    value = [];
  }

  Future<void> _syncFitbitData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final study = context.read<AppState>().activeSubject!.study;
      final data = await FitbitHandler.syncFitbitData(
        study,
        widget.question,
        widget.taskId,
        context.read<AppState>().activeSubject!,
      );

      setState(() {
        value = data;
        _isLoading = false;
      });

      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.fitbit_data_not_synced,
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.fitbit_data_synced,
          ),
        ),
      );
      widget.onDone(widget.question.constructAnswer(value));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .error_syncing_fitbit_data(e.toString()),
          ),
        ),
      );
      StudyULogger.error('Error syncing Fitbit data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          onPressed: _isLoading ? null : _syncFitbitData,
          child: _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                )
              : Text(
                  AppLocalizations.of(context)!.sync_fitbit_data,
                ),
        ),
      ],
    );
  }
}
