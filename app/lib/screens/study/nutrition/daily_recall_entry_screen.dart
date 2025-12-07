import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

class DailyRecallEntryScreen extends StatefulWidget {
  final DailyRecall? existingRecall;
  final NutritionTask? task;
  final CompletionPeriod? completionPeriod;

  const DailyRecallEntryScreen({
    this.existingRecall,
    this.task,
    this.completionPeriod,
    super.key,
  });

  static MaterialPageRoute<DailyRecall> route({
    DailyRecall? existingRecall,
    NutritionTask? task,
    CompletionPeriod? completionPeriod,
  }) => MaterialPageRoute(
    builder: (_) => DailyRecallEntryScreen(
      existingRecall: existingRecall,
      task: task,
      completionPeriod: completionPeriod,
    ),
  );

  @override
  State<DailyRecallEntryScreen> createState() => _DailyRecallEntryScreenState();
}

class _DailyRecallEntryScreenState extends State<DailyRecallEntryScreen>
    with WidgetsBindingObserver {
  late DailyRecall _recall;
  late DateTime _selectedDate;
  late RecallMode _recallMode;
  bool _isUsualIntakeDay = true;
  String? _specialOccasion;
  bool _instructionsExpanded = true;

  Timer? _autoSaveTimer;
  final _autoSaveManager = NutritionRecallAutoSaveManager();
  bool _isSaving = false;
  DateTime? _lastSaveTime;
  int? _studyDaySnapshot;
  String? _interventionId;
  String? _periodId;
  StudySubject? _subject;
  late TextEditingController _specialOccasionController;

  bool get _isInTaskMode =>
      widget.task != null && widget.completionPeriod != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.existingRecall != null) {
      _recall = widget.existingRecall!;
      _selectedDate = _recall.date;
      _recallMode = _recall.recallMode;
      _isUsualIntakeDay = _recall.isUsualIntakeDay ?? true;
      _specialOccasion = _recall.specialOccasion;
      _studyDaySnapshot = _recall.studyDaySnapshot;
      _lastSaveTime = _recall.lastAutoSavedAt;
    } else {
      _selectedDate = DateTime.now();
      _recallMode = RecallMode.realtimeRecord;
      _recall = DailyRecall.withId(
        date: _selectedDate,
        recallMode: _recallMode,
        entryStartedAt: DateTime.now(),
        meals: [],
      );
    }

    _specialOccasionController = TextEditingController(text: _specialOccasion ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAutoSave();
    });
  }

  Future<void> _initializeAutoSave() async {
    _subject = Provider.of<AppState>(context, listen: false).activeSubject;

    if (_subject == null) return;

    _studyDaySnapshot ??= _subject!.getDayOfStudyFor(DateTime.now());
    _interventionId ??= _subject!.getInterventionForDate(DateTime.now())?.id;

    if (widget.task != null && widget.completionPeriod != null) {
      _periodId = widget.completionPeriod!.id;
    }

    if (_studyDaySnapshot == null) return;

    if (widget.existingRecall == null) {
      final existing = await _autoSaveManager.loadRecall(
        subjectId: _subject!.id,
        taskId: widget.task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: _studyDaySnapshot!,
      );

      if (existing != null && mounted) {
        setState(() {
          _recall = existing;
          _selectedDate = existing.date;
          _recallMode = existing.recallMode;
          _isUsualIntakeDay = existing.isUsualIntakeDay ?? true;
          _specialOccasion = existing.specialOccasion;
          _specialOccasionController.text = _specialOccasion ?? '';
          _lastSaveTime = existing.lastAutoSavedAt;
        });
      } else if (mounted) {
        setState(() {
          _recall = DailyRecall.withId(
            date: _selectedDate,
            recallMode: _recallMode,
            entryStartedAt: DateTime.now(),
            meals: [],
            studyDaySnapshot: _studyDaySnapshot,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();
    _specialOccasionController.dispose();
    if (_recall.meals.isNotEmpty && _subject != null) {
      _performAutoSaveSync();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _autoSaveTimer?.cancel();
      if (_recall.meals.isNotEmpty && _subject != null) {
        _performAutoSaveSync();
      }
    }
  }

  void _performAutoSaveSync() {
    if (_subject == null || _studyDaySnapshot == null) return;

    StudyULogger.debug(
      '[DailyRecall] Sync auto-save (dispose/pause) | meals=${_recall.meals.length} '
      'studyDay=$_studyDaySnapshot subject=${_subject?.id}',
    );

    _autoSaveManager.saveRecall(
      recall: DailyRecall(
        id: _recall.id,
        date: _recall.date,
        isUsualIntakeDay: _isUsualIntakeDay,
        specialOccasion: _specialOccasion,
        recallMode: _recallMode,
        entryStartedAt: _recall.entryStartedAt,
        entryCompletedAt: _recall.entryCompletedAt,
        meals: _recall.meals,
        studyDaySnapshot: _studyDaySnapshot,
        lastAutoSavedAt: DateTime.now(),
      ),
      subjectId: _subject!.id,
      taskId: widget.task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
      interventionId: _interventionId ?? NutritionRecallAutoSaveManager.unknownInterventionId,
      periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
      studyDaySnapshot: _studyDaySnapshot!,
    );
  }

  void _scheduleAutoSave([String reason = 'unspecified']) {
    if (_subject == null || _studyDaySnapshot == null) return;

    StudyULogger.debug(
      '[DailyRecall] Schedule auto-save ($reason) | meals=${_recall.meals.length} '
      'studyDay=$_studyDaySnapshot subject=${_subject?.id}',
    );

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(NutritionRecallAutoSaveManager.debounceDuration, () {
      _performAutoSave();
    });
  }

  Future<void> _performAutoSave() async {
    if (_isSaving || _subject == null || _studyDaySnapshot == null) return;
    if (!_isInTaskMode) {
      StudyULogger.debug('[DailyRecall] Skip auto-save (not in task mode)');
      return; // Only auto-save to DB in task mode
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final shouldSaveToDb = appState.trackParticipantProgress;

    setState(() {
      _isSaving = true;
    });

    try {
      final now = DateTime.now();
      final recallToSave = DailyRecall(
        id: _recall.id,
        date: _recall.date,
        isUsualIntakeDay: _isUsualIntakeDay,
        specialOccasion: _specialOccasion,
        recallMode: _recallMode,
        entryStartedAt: _recall.entryStartedAt,
        entryCompletedAt: _recall.entryCompletedAt,
        meals: _recall.meals,
        studyDaySnapshot: _studyDaySnapshot,
        lastAutoSavedAt: now,
      );
      // Keep the in-memory recall in sync so subsequent saves reuse the same
      // lastAutoSavedAt and avoid duplicate progress rows for the same day.
      _recall = recallToSave;

      StudyULogger.debug(
        '[DailyRecall] Auto-save firing | meals=${recallToSave.meals.length} '
        'studyDay=$_studyDaySnapshot shouldSaveToDb=$shouldSaveToDb '
        'recallMode=$_recallMode usualDay=$_isUsualIntakeDay '
        'specialOccasion=${_specialOccasion ?? '-'} '
        'lastAutoSavedAt=${recallToSave.lastAutoSavedAt}',
      );

      // Save to local SharedPreferences as backup
      await _autoSaveManager.saveRecall(
        recall: recallToSave,
        subjectId: _subject!.id,
        taskId: widget.task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
        interventionId: _interventionId ?? NutritionRecallAutoSaveManager.unknownInterventionId,
        periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
        studyDaySnapshot: _studyDaySnapshot!,
      );

      // Also upsert to database (subject_progress)
      if (shouldSaveToDb) {
        await _subject!.upsertNutritionResult(
          taskId: widget.task!.id,
          periodId: widget.completionPeriod!.id,
          recall: recallToSave,
        );
      }

      if (mounted) {
        setState(() {
          _lastSaveTime = now;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatTimeSince(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) {
      return 'just now';
    } else if (diff.inSeconds < 60) {
      return '${diff.inSeconds} seconds ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _recall = DailyRecall(
          id: _recall.id,
          date: _selectedDate,
          isUsualIntakeDay: _isUsualIntakeDay,
          specialOccasion: _specialOccasion,
          recallMode: _recallMode,
          entryStartedAt: _recall.entryStartedAt,
          entryCompletedAt: _recall.entryCompletedAt,
          meals: _recall.meals,
          studyDaySnapshot: _studyDaySnapshot,
          lastAutoSavedAt: _recall.lastAutoSavedAt,
        );
      });
      _scheduleAutoSave('date changed');
    }
  }

  Future<void> _addMeal() async {
    final result = await Navigator.of(context).push(MealEntryScreen.route());
    if (result != null) {
      setState(() {
        _recall.meals.add(result);
      });
      _scheduleAutoSave('meal added');
    }
  }

  Future<void> _editMeal(MealLog meal, int index) async {
    final result = await Navigator.of(
      context,
    ).push(MealEntryScreen.route(existingMeal: meal));
    if (result != null) {
      setState(() {
        _recall.meals[index] = result;
      });
      _scheduleAutoSave('meal edited');
    }
  }

  void _removeMeal(int index) {
    setState(() {
      _recall.meals.removeAt(index);
    });
    _scheduleAutoSave('meal removed');
  }

  void _completeRecall() {
    _recall = DailyRecall(
      id: _recall.id,
      date: _recall.date,
      isUsualIntakeDay: _isUsualIntakeDay,
      specialOccasion: _specialOccasion,
      recallMode: _recallMode,
      entryStartedAt: _recall.entryStartedAt,
      entryCompletedAt: DateTime.now(),
      meals: _recall.meals,
    );
    Navigator.of(context).pop(_recall);
  }

  String _getMealTypeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.brunch:
        return 'Brunch';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      case MealType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task?.title ?? 'Daily Food Diary'),
        actions: [
          if (!_isInTaskMode && _recall.meals.isNotEmpty)
            TextButton(
              onPressed: _completeRecall,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('COMPLETE'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_lastSaveTime != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(
                    _isSaving ? Icons.cloud_queue : Icons.cloud_done,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSaving ? 'Saving...' : 'Saved ${_formatTimeSince(_lastSaveTime!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.task?.header != null) ...[
                    HtmlText(widget.task!.header, centered: true),
                    const SizedBox(height: 20),
                  ],
                  if (_isInTaskMode) ...[
                    Card(
                      child: Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: _instructionsExpanded,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _instructionsExpanded = expanded;
                            });
                          },
                          leading: Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            'Instructions',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.task!.instructions ??
                                        'Please record all the foods and beverages you consumed today. '
                                            'For each meal or snack, provide as much detail as possible including '
                                            'portion sizes and preparation methods.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (widget.task!.minimumMealsRequired !=
                                      null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.restaurant,
                                            color: theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Please record at least ${widget.task!.minimumMealsRequired} meal(s)',
                                              style: TextStyle(
                                                color: theme
                                                    .colorScheme
                                                    .onPrimaryContainer,
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recall Details',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: const Text('Date'),
                            subtitle: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                            trailing: const Icon(Icons.edit),
                            onTap: _selectDate,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.access_time),
                            title: const Text('Recall Mode'),
                            subtitle: DropdownButton<RecallMode>(
                              value: _recallMode,
                              isExpanded: true,
                              underline: Container(),
                              items: const [
                                DropdownMenuItem(
                                  value: RecallMode.realtimeRecord,
                                  child: Text('Real-time Recording'),
                                ),
                                DropdownMenuItem(
                                  value: RecallMode.yesterdayRecall,
                                  child: Text('Yesterday Recall'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _recallMode = value;
                                  });
                                  _scheduleAutoSave('recall mode changed');
                                }
                              },
                            ),
                          ),
                          const Divider(),
                          SwitchListTile(
                            secondary: const Icon(Icons.calendar_month),
                            title: const Text('Usual Intake Day'),
                            subtitle: const Text(
                              'Was this a typical day for your diet?',
                            ),
                            value: _isUsualIntakeDay,
                            onChanged: (value) {
                              setState(() {
                                _isUsualIntakeDay = value;
                                if (value == true) {
                                  _specialOccasion = null;
                                  _specialOccasionController.clear();
                                }
                              });
                              _scheduleAutoSave('usual day toggled');
                            },
                          ),
                          if (_isUsualIntakeDay == false) ...[
                            const Divider(),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Special Occasion',
                                hintText: 'e.g., Birthday, Holiday, etc.',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _specialOccasion = value.isEmpty ? null : value;
                                _scheduleAutoSave('special occasion changed');
                              },
                              controller: _specialOccasionController,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meals (${_recall.meals.length})',
                        style: theme.textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        onPressed: _addMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Meal'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_recall.meals.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 48,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('No meals recorded yet'),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_recall.meals.length, (index) {
                      final meal = _recall.meals[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${meal.foods.length}'),
                          ),
                          title: Text(
                            meal.customMealLabel ??
                                _getMealTypeLabel(meal.mealType),
                          ),
                          subtitle: Text(
                            '${meal.foods.length} food items • ${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editMeal(meal, index);
                              } else if (value == 'delete') {
                                _removeMeal(index);
                              }
                            },
                          ),
                          onTap: () => _editMeal(meal, index),
                        ),
                      );
                    }),
                  if (_recall.meals.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    DailyNutritionSummaryCard(dailyRecall: _recall),
                  ],
                  if (widget.task?.footer != null) ...[
                    const SizedBox(height: 20),
                    HtmlText(widget.task!.footer, centered: true),
                  ],
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
