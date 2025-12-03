import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_screen.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class NutritionQuestionWidget extends QuestionWidget {
  final NutritionQuestion question;
  final Function(Answer)? onDone;
  final Answer? initialAnswer;

  const NutritionQuestionWidget({
    super.key,
    required this.question,
    this.onDone,
    this.initialAnswer,
  });

  @override
  State<NutritionQuestionWidget> createState() =>
      _NutritionQuestionWidgetState();
}

class _NutritionQuestionWidgetState extends State<NutritionQuestionWidget> {
  DailyRecall? _dailyRecall;

  @override
  void initState() {
    super.initState();
    if (widget.initialAnswer != null) {
      final result = widget.initialAnswer!.response;
      if (result is DailyRecall) {
        _dailyRecall = result;
      } else if (result is Map<String, dynamic>) {
        _dailyRecall = DailyRecall.fromJson(result);
      }
    }
  }

  void _openNutritionDiary() async {
    final result = await Navigator.of(context).push(
      DailyRecallEntryScreen.route(
        existingRecall: _dailyRecall,
        onUpdate: (recall) {
          setState(() {
            _dailyRecall = recall;
          });
          if (widget.onDone != null) {
            widget.onDone!(widget.question.constructAnswer(recall));
          }
        },
      ),
    );

    if (result != null) {
      setState(() {
        _dailyRecall = result;
      });
      if (widget.onDone != null) {
        widget.onDone!(widget.question.constructAnswer(result));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealsCount = _dailyRecall?.meals.length ?? 0;
    final isComplete = _dailyRecall?.entryCompletedAt != null;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      isComplete ? Icons.check_circle : Icons.edit_note,
                      color: isComplete ? Colors.green : Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status', style: theme.textTheme.bodySmall),
                          Text(
                            isComplete
                                ? 'Completed ($mealsCount meals recorded)'
                                : 'In progress ($mealsCount meals recorded)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _openNutritionDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  icon: Icon(
                    _dailyRecall == null
                        ? Icons.add_circle_outline
                        : Icons.edit,
                  ),
                  label: Text(
                    _dailyRecall == null
                        ? 'Start Recording'
                        : 'Continue Recording',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
