import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_core/core.dart';

typedef NutritionRecallOpener =
    void Function(NutritionRecallRecord record, bool editable);

class NutritionHistoryScreen extends StatefulWidget {
  final StudySubject subject;
  final NutritionTask task;
  final NutritionRecallOpener onOpenRecall;

  const NutritionHistoryScreen({
    required this.subject,
    required this.task,
    required this.onOpenRecall,
    super.key,
  });

  static MaterialPageRoute<void> route({
    required StudySubject subject,
    required NutritionTask task,
    required NutritionRecallOpener onOpenRecall,
  }) => MaterialPageRoute(
    builder: (_) => NutritionHistoryScreen(
      subject: subject,
      task: task,
      onOpenRecall: onOpenRecall,
    ),
  );

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends State<NutritionHistoryScreen> {
  late final Future<List<NutritionRecallRecord>> _records;

  @override
  void initState() {
    super.initState();
    _records = loadNutritionRecallRecords(
      subject: widget.subject,
      taskId: widget.task.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentStudyDay = widget.subject.getDayOfStudyFor(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nutrition_history)),
      body: FutureBuilder<List<NutritionRecallRecord>>(
        future: _records,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data!
              .where((record) => record.studyDaySnapshot < currentStudyDay)
              .toList();
          if (records.isEmpty) {
            return Center(child: Text(l10n.nutrition_history_empty));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final editable = isEditableNutritionRecallDay(
                studyDaySnapshot: record.studyDaySnapshot,
                currentStudyDay: currentStudyDay,
                hasUnambiguousPeriod:
                    record.hasUnambiguousPeriod &&
                    _hasCompletionPeriod(record.periodId),
              );
              return Card(
                child: ListTile(
                  onTap: () => widget.onOpenRecall(record, editable),
                  title: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(record.recall.date),
                  ),
                  subtitle: Text(
                    editable
                        ? l10n.nutrition_editable
                        : l10n.nutrition_read_only,
                  ),
                  trailing: Icon(
                    editable ? Icons.edit_outlined : Icons.visibility_outlined,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _hasCompletionPeriod(String? id) =>
      id != null &&
      widget.task.schedule.completionPeriods.any((period) => period.id == id);
}
