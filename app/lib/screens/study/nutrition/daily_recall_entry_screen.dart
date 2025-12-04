import 'dart:io';

import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
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

class _DailyRecallEntryScreenState extends State<DailyRecallEntryScreen> {
  late DailyRecall _recall;
  late DateTime _selectedDate;
  late RecallMode _recallMode;
  bool _isUsualIntakeDay = true;
  String? _specialOccasion;
  DateTime? _lastClickTime;
  bool _isLoading = false;
  bool _instructionsExpanded = true;

  bool get _isInTaskMode =>
      widget.task != null && widget.completionPeriod != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecall != null) {
      _recall = widget.existingRecall!;
      _selectedDate = _recall.date;
      _recallMode = _recall.recallMode;
      _isUsualIntakeDay = _recall.isUsualIntakeDay ?? true;
      _specialOccasion = _recall.specialOccasion;
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
        );
      });
    }
  }

  Future<void> _addMeal() async {
    final result = await Navigator.of(context).push(MealEntryScreen.route());
    if (result != null) {
      setState(() {
        _recall.meals.add(result);
      });
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
    }
  }

  void _removeMeal(int index) {
    setState(() {
      _recall.meals.removeAt(index);
    });
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

  Future<void> _submitTask() async {
    if (isRedundantClick(_lastClickTime)) return;

    setState(() {
      _isLoading = true;
      _lastClickTime = DateTime.now();
    });

    // Mark recall as completed
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

    await handleTaskCompletion(context, (subject) async {
      try {
        await subject!.addResult<DailyRecall>(
          taskId: widget.task!.id,
          periodId: widget.completionPeriod!.id,
          result: _recall,
        );
      } on SocketException catch (_) {
        await subject!.addResult<DailyRecall>(
          taskId: widget.task!.id,
          periodId: widget.completionPeriod!.id,
          result: _recall,
          offline: true,
        );
        rethrow;
      }
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context, _recall);
    }
  }

  bool _isRecallComplete() {
    if (!_isInTaskMode) {
      return _recall.meals.isNotEmpty;
    }

    if (widget.task?.minimumMealsRequired != null) {
      final nonSkippedMeals = _recall.meals.where((m) => !m.isSkipped).length;
      return nonSkippedMeals >= widget.task!.minimumMealsRequired!;
    }

    return _recall.meals.isNotEmpty;
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
    final isComplete = _isInTaskMode ? _isRecallComplete() : false;

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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Header
                  if (widget.task?.header != null) ...[
                    HtmlText(widget.task!.header, centered: true),
                    const SizedBox(height: 20),
                  ],

                  // Instructions Card (for task mode)
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
                                }
                              });
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
                              },
                              controller: TextEditingController(
                                text: _specialOccasion ?? '',
                              ),
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
                                color: theme.colorScheme.primary.withOpacity(
                                  0.5,
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

                  // Add nutrition summary if there are meals
                  if (_recall.meals.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    DailyNutritionSummaryCard(dailyRecall: _recall),
                  ],

                  // Task Footer
                  if (widget.task?.footer != null) ...[
                    const SizedBox(height: 20),
                    HtmlText(widget.task!.footer, centered: true),
                  ],
                ],
              ),
            ),
          ),

          if (_isInTaskMode && isComplete) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                  minimumSize: WidgetStateProperty.all(
                    const Size(double.infinity, 56),
                  ),
                ),
                onPressed: _isLoading ? null : _submitTask,
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
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
