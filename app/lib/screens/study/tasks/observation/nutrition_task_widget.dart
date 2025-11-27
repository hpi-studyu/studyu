import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_screen.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';

class NutritionTaskWidget extends StatefulWidget {
  final NutritionTask task;
  final CompletionPeriod completionPeriod;

  const NutritionTaskWidget({
    required this.task,
    required this.completionPeriod,
    super.key,
  });

  @override
  State<NutritionTaskWidget> createState() => _NutritionTaskWidgetState();
}

class _NutritionTaskWidgetState extends State<NutritionTaskWidget> {
  DailyRecall? _dailyRecall;
  DateTime? _lastClickTime;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingResult();
  }

  void _loadExistingResult() {
    if (_dailyRecall != null) return;

    final subject = context.read<AppState>().activeSubject;
    if (subject == null) return;

    final existingProgress = subject.progress
        .where(
          (p) =>
              p.taskId == widget.task.id &&
              p.result.periodId == widget.completionPeriod.id,
        )
        .toList();

    if (existingProgress.isNotEmpty) {
      existingProgress.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
      final latestProgress = existingProgress.first;
      final resultData = latestProgress.result.result;
      if (resultData is DailyRecall) {
        setState(() {
          _dailyRecall = resultData;
        });
      } else if (resultData is Map<String, dynamic>) {
        setState(() {
          _dailyRecall = DailyRecall.fromJson(resultData);
        });
      }
    }
  }

  Future<void> _addNutritionResult(
    DailyRecall recall,
    BuildContext context, {
    bool closeScreen = true,
  }) async {
    await handleTaskCompletion(context, (StudySubject? subject) async {
      try {
        await subject!.addResult<DailyRecall>(
          taskId: widget.task.id,
          periodId: widget.completionPeriod.id,
          result: recall,
        );
      } on SocketException catch (_) {
        await subject!.addResult<DailyRecall>(
          taskId: widget.task.id,
          periodId: widget.completionPeriod.id,
          result: recall,
          offline: true,
        );
        rethrow;
      }
    });
    if (!context.mounted || !closeScreen) return;
    Navigator.pop(context, true);
  }

  void _openNutritionDiary() async {
    final result = await Navigator.of(
      context,
    ).push(DailyRecallEntryScreen.route(existingRecall: _dailyRecall));

    if (result != null) {
      setState(() {
        _dailyRecall = result;
      });
      if (mounted) {
        _addNutritionResult(result, context, closeScreen: false);
      }
    }
  }

  bool _isRecallComplete() {
    if (_dailyRecall == null) return false;
    if (_dailyRecall!.entryCompletedAt == null) return false;
    if (widget.task.minimumMealsRequired != null) {
      final nonSkippedMeals = _dailyRecall!.meals
          .where((m) => !m.isSkipped)
          .length;
      return nonSkippedMeals >= widget.task.minimumMealsRequired!;
    }
    return true;
  }

  String _getCompletionStatus() {
    if (_dailyRecall == null) {
      return 'Not started';
    }
    if (_dailyRecall!.entryCompletedAt == null) {
      return 'In progress (${_dailyRecall!.meals.length} meals recorded)';
    }
    final nonSkippedMeals = _dailyRecall!.meals
        .where((m) => !m.isSkipped)
        .length;
    return 'Completed ($nonSkippedMeals meals recorded)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = _isRecallComplete();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                if (widget.task.header != null) ...[
                  HtmlText(widget.task.header, centered: true),
                  const SizedBox(height: 20),
                ],

                // Instructions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.task.instructions ??
                              'Please record all the foods and beverages you consumed today. '
                                  'For each meal or snack, provide as much detail as possible including '
                                  'portion sizes and preparation methods.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (widget.task.minimumMealsRequired != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Please record at least ${widget.task.minimumMealsRequired} meal(s)',
                                    style: TextStyle(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Status Card
                Card(
                  color: isComplete
                      ? Colors.green.shade50
                      : theme.colorScheme.surfaceContainerHighest,
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
                                  Text(
                                    'Status',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    _getCompletionStatus(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
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

                const SizedBox(height: 20),

                // Quick Summary if data exists
                if (_dailyRecall != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Summary',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow(
                            Icons.calendar_today,
                            'Date',
                            '${_dailyRecall!.date.day}/${_dailyRecall!.date.month}/${_dailyRecall!.date.year}',
                          ),
                          const Divider(height: 20),
                          _buildSummaryRow(
                            Icons.restaurant_menu,
                            'Total Meals',
                            '${_dailyRecall!.meals.length}',
                          ),
                          const Divider(height: 20),
                          _buildSummaryRow(
                            Icons.skip_next,
                            'Skipped Meals',
                            '${_dailyRecall!.meals.where((m) => m.isSkipped).length}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Footer
                if (widget.task.footer != null) ...[
                  const SizedBox(height: 20),
                  HtmlText(widget.task.footer, centered: true),
                ],
              ],
            ),
          ),
        ),

        // Submit Button
        if (isComplete) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
              minimumSize: WidgetStateProperty.all(
                const Size(double.infinity, 56),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    if (isRedundantClick(_lastClickTime)) return;
                    setState(() {
                      _isLoading = true;
                      _lastClickTime = DateTime.now();
                    });
                    await _addNutritionResult(_dailyRecall!, context);
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_circle, size: 24),
            label: Text(
              _isLoading ? 'Saving...' : 'Submit',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
