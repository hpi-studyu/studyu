import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/food_analysis_service.dart';
import 'package:studyu_app/services/photo_gallery_service.dart';
import 'package:studyu_app/widgets/food_item_selection_dialog.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
import 'package:studyu_app/widgets/photo_viewer_dialog.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_core/core.dart';

sealed class MealEntryResult {
  const MealEntryResult();
}

final class SavedMealEntryResult extends MealEntryResult {
  final MealLog meal;

  const SavedMealEntryResult(this.meal);
}

final class DeletedMealEntryResult extends MealEntryResult {
  const DeletedMealEntryResult();
}

enum _UnsavedMealAction { save, discard, continueEditing }

enum _FoodAction { adjustQuantity, edit, saveTemplate, remove }

class _MealTypeSelection {
  final MealType type;
  final String? customLabel;

  const _MealTypeSelection(this.type, [this.customLabel]);
}

class _TimeSelection {
  final DateTime? timestamp;
  final MealOccurrenceTimePrecision precision;

  const _TimeSelection(this.timestamp, this.precision);
}

class _MealDetailsSelection {
  final MealContext mealContext;
  final CompanyContext? companyContext;
  final DistractionContext? distractionContext;
  final String? locationDescription;

  const _MealDetailsSelection({
    required this.mealContext,
    required this.companyContext,
    required this.distractionContext,
    required this.locationDescription,
  });
}

class MealEntryScreen extends StatefulWidget {
  final MealLog? existingMeal;
  final NutritionTask? task;
  final MealType? initialMealType;
  final String? initialCustomMealLabel;
  final DateTime? occurrenceDate;
  final bool openFoodSearch;

  const MealEntryScreen({
    this.existingMeal,
    this.task,
    this.initialMealType,
    this.initialCustomMealLabel,
    this.occurrenceDate,
    this.openFoodSearch = false,
    super.key,
  });

  static MaterialPageRoute<MealEntryResult> route({
    MealLog? existingMeal,
    NutritionTask? task,
    MealType? initialMealType,
    String? initialCustomMealLabel,
    DateTime? occurrenceDate,
    bool openFoodSearch = false,
  }) => MaterialPageRoute(
    builder: (_) => MealEntryScreen(
      existingMeal: existingMeal,
      task: task,
      initialMealType: initialMealType,
      initialCustomMealLabel: initialCustomMealLabel,
      occurrenceDate: occurrenceDate,
      openFoodSearch: openFoodSearch,
    ),
  );

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  late MealLog _meal;
  late MealType _mealType;
  late MealContext _mealContext;
  DateTime? _timestamp;
  late MealOccurrenceTimePrecision _timePrecision;
  late bool _hasSelectedTime;
  late bool _isSkipped;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  String? _customMealLabel;
  late bool _isLabelExplicitlyUnset;
  String? _locationDescription;
  String? _skipReason;
  late final String _initialMealSnapshot;
  bool _allowPop = false;
  bool _hasAttemptedSave = false;

  late TextEditingController _skipReasonController;

  final PhotoGalleryService _photoService = PhotoGalleryService();

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _meal = cloneMealLog(widget.existingMeal!);
      _mealType = _meal.mealType;
      _mealContext = _meal.mealContext;
      _timestamp = _meal.timestamp;
      _timePrecision = _meal.timePrecision;
      _hasSelectedTime = true;
      _isSkipped = _meal.isSkipped;
      _companyContext = _meal.companyContext;
      _distractionContext = _meal.distractionContext;
      _customMealLabel = _meal.customMealLabel;
      _isLabelExplicitlyUnset = _meal.isLabelExplicitlyUnset;
      _locationDescription = _meal.locationDescription;
      _skipReason = _meal.skipReason;
    } else {
      _timestamp = null;
      _timePrecision = MealOccurrenceTimePrecision.unknown;
      _hasSelectedTime = false;
      _mealType = widget.initialMealType ?? MealType.other;
      _customMealLabel = widget.initialCustomMealLabel;
      _isLabelExplicitlyUnset =
          _mealType == MealType.other && _customMealLabel == null;
      _mealContext = MealContext.home;
      _isSkipped = false;
      _meal = MealLog.withId(
        mealType: _mealType,
        customMealLabel: _customMealLabel,
        mealContext: _mealContext,
        timestamp: _timestamp,
        timePrecision: _timePrecision,
        isLabelExplicitlyUnset: _isLabelExplicitlyUnset,
        timezone: DateTime.now().timeZoneName,
        isSkipped: _isSkipped,
        foods: [],
      );
    }

    _skipReasonController = TextEditingController(text: _skipReason ?? '');
    _initialMealSnapshot = _mealSnapshot;
    if (widget.openFoodSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _addFood();
      });
    }
  }

  @override
  void dispose() {
    _skipReasonController.dispose();
    super.dispose();
  }

  Future<void> _addFood() async {
    final result = await FoodSearchScreen.show(
      context,
      mealLabel: _mealLabel,
      allowMeals: widget.task?.allowMeals ?? true,
    );
    if (result != null && mounted) {
      setState(() => _meal.foods.addAll(result.foods));
    }
  }

  int _foodIndex(String foodId) =>
      _meal.foods.indexWhere((food) => food.id == foodId);

  Future<void> _editFood(FoodEntry food) async {
    final result = await Navigator.of(
      context,
    ).push(FoodEntryScreen.route(existingFood: food, showSearchAction: false));
    if (result == null || !mounted) return;

    final index = _foodIndex(food.id);
    if (index == -1) return;
    setState(() => _meal.foods[index] = result);
  }

  void _removeFood(FoodEntry food) {
    final index = _foodIndex(food.id);
    if (index == -1) return;
    setState(() => _meal.foods.removeAt(index));
  }

  Future<void> _adjustFoodQuantity(FoodEntry food) async {
    final result = await FoodQuantitySheet.show(
      context,
      food: food,
      mealLabel: _mealLabel,
    );
    if (result == null || !mounted) return;

    final index = _foodIndex(food.id);
    if (index == -1) return;
    setState(() => _meal.foods[index] = result);
  }

  Future<void> _showFoodActions(FoodEntry food) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final action = await showModalBottomSheet<_FoodAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _foodActionSubtitle(food, l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.straighten_outlined),
              title: Text(l10n.adjust_quantity),
              onTap: () =>
                  Navigator.pop(sheetContext, _FoodAction.adjustQuantity),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.edit_this_entry),
              onTap: () => Navigator.pop(sheetContext, _FoodAction.edit),
            ),
            if (food.templateId == null)
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: Text(l10n.save_to_my_items_action),
                onTap: () =>
                    Navigator.pop(sheetContext, _FoodAction.saveTemplate),
              ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              title: Text(
                l10n.remove_from_meal,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.pop(sheetContext, _FoodAction.remove),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _FoodAction.adjustQuantity:
        // The menu is already dismissed before the quantity sheet opens.
        await _adjustFoodQuantity(food);
      case _FoodAction.edit:
        await _editFood(food);
      case _FoodAction.saveTemplate:
        await _saveFoodAsTemplate(food);
      case _FoodAction.remove:
        _removeFood(food);
      case null:
        break;
    }
  }

  String _foodActionSubtitle(FoodEntry food, AppLocalizations l10n) {
    final amount = food.amount == food.amount.roundToDouble()
        ? food.amount.round().toString()
        : food.amount.toStringAsFixed(1);
    final serving = food.unit.trim().isEmpty
        ? l10n.serving_amount(food.amount)
        : '$amount ${food.unit.trim()}';
    return '$serving · ${l10n.kcal_value(food.nutrition.energyKcal.round().toString())}';
  }

  MealLog _buildMeal({bool normalizeSkipped = false}) {
    final clearDetails = normalizeSkipped && _isSkipped;
    return MealLog(
      id: _meal.id,
      mealType: _mealType,
      customMealLabel: _customMealLabel?.trim().isEmpty == true
          ? null
          : _customMealLabel?.trim(),
      isLabelExplicitlyUnset: _isLabelExplicitlyUnset,
      mealContext: _mealContext,
      locationDescription: clearDetails || _mealContext != MealContext.other
          ? null
          : _locationDescription?.trim(),
      timestamp: _timestamp,
      timePrecision: _timePrecision,
      timezone: _meal.timezone,
      isSkipped: _isSkipped,
      skipReason: normalizeSkipped && !_isSkipped ? null : _skipReason?.trim(),
      companyContext: clearDetails ? null : _companyContext,
      distractionContext: clearDetails ? null : _distractionContext,
      templateId: clearDetails ? null : _meal.templateId,
      foods: clearDetails ? [] : _meal.foods,
    );
  }

  String get _mealSnapshot => jsonEncode(_buildMeal().toJson());

  bool get _hasUnsavedChanges => _mealSnapshot != _initialMealSnapshot;

  bool get _isMealValid =>
      (!_isSkipped && _meal.foods.isNotEmpty && _hasSelectedTime) ||
      (_isSkipped && _skipReason?.trim().isNotEmpty == true);

  String get _mealLabel {
    final customLabel = _customMealLabel?.trim();
    return customLabel?.isNotEmpty == true
        ? customLabel!
        : _mealType == MealType.other && _isLabelExplicitlyUnset
        ? AppLocalizations.of(context)!.meal_neutral_label
        : _getMealTypeLabel(_mealType);
  }

  String get _pageTitle => AppLocalizations.of(context)!.log_meal;

  void _pop([MealEntryResult? result]) {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  void _saveMeal() {
    if (!_isMealValid) {
      setState(() => _hasAttemptedSave = true);
      return;
    }

    _meal = _buildMeal(normalizeSkipped: true);
    _pop(SavedMealEntryResult(_meal));
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showDialog<_UnsavedMealAction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.discard_meal_changes_title),
        content: Text(l10n.discard_meal_changes_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_UnsavedMealAction.continueEditing),
            child: Text(l10n.continue_editing),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_UnsavedMealAction.discard),
            child: Text(l10n.discard_changes),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(_UnsavedMealAction.save),
            child: Text(l10n.save_and_leave),
          ),
        ],
      ),
    );
    if (!mounted) return;

    switch (action) {
      case _UnsavedMealAction.save:
        _saveMeal();
      case _UnsavedMealAction.discard:
        _pop();
      case _UnsavedMealAction.continueEditing:
      case null:
        return;
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete_meal_title),
        content: Text(l10n.delete_meal_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      _pop(const DeletedMealEntryResult());
    }
  }

  Future<void> _selectMealType() async {
    final selection = await showModalBottomSheet<_MealTypeSelection>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => _MealTypeSheet(
        mealType: _mealType,
        customMealLabel: _customMealLabel,
        customMealTypes: widget.task?.customMealTypes,
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _mealType = selection.type;
      _customMealLabel = selection.type == MealType.other
          ? selection.customLabel?.trim()
          : null;
      _isLabelExplicitlyUnset =
          selection.type == MealType.other &&
          (selection.customLabel?.trim().isEmpty ?? true);
    });
  }

  Future<void> _editMealDetails() async {
    final selection = await showModalBottomSheet<_MealDetailsSelection>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => _MealDetailsSheet(
        mealContext: _mealContext,
        companyContext: _companyContext,
        distractionContext: _distractionContext,
        locationDescription: _locationDescription,
      ),
    );
    if (selection == null || !mounted) return;

    setState(() {
      _mealContext = selection.mealContext;
      _companyContext = selection.companyContext;
      _distractionContext = selection.distractionContext;
      _locationDescription = selection.locationDescription;
    });
  }

  String _mealDetailsSummary(AppLocalizations l10n) {
    final details = <String>[
      if (_mealContext == MealContext.other &&
          _locationDescription?.trim().isNotEmpty == true)
        _locationDescription!.trim()
      else
        _getMealContextLabel(_mealContext, l10n),
      if (_companyContext != null)
        _getCompanyContextLabel(_companyContext!, l10n),
      if (_distractionContext != null)
        _getDistractionContextLabel(_distractionContext!, l10n),
    ];
    return details.join(' • ');
  }

  Future<void> _selectTime() async {
    final selection = await showModalBottomSheet<_TimeSelection>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => _TimeSelectionSheet(
        timestamp: _timestamp,
        precision: _hasSelectedTime ? _timePrecision : null,
      ),
    );
    if (selection == null || !mounted) return;

    if (selection.precision == MealOccurrenceTimePrecision.unknown) {
      setState(() {
        _timestamp = null;
        _timePrecision = selection.precision;
        _hasSelectedTime = true;
      });
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: _timestamp == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(_timestamp!),
    );
    if (picked == null || !mounted) return;
    final date = _timePrecision == MealOccurrenceTimePrecision.unknown
        ? widget.occurrenceDate ?? DateTime.now()
        : _timestamp ?? widget.occurrenceDate ?? DateTime.now();
    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        picked.hour,
        picked.minute,
      );
      _timePrecision = selection.precision;
      _hasSelectedTime = true;
    });
  }

  String _getMealTypeLabel(MealType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case MealType.breakfast:
        return l10n.meal_type_breakfast;
      case MealType.brunch:
        return l10n.meal_type_brunch;
      case MealType.lunch:
        return l10n.meal_type_lunch;
      case MealType.dinner:
        return l10n.meal_type_dinner;
      case MealType.snack:
        return l10n.meal_type_snack;
      case MealType.other:
        return l10n.meal_type_other;
    }
  }

  Future<void> _openMealBuilder() => Navigator.of(context).push(
    MealCreatorScreen.route(initialFoods: _meal.foods, initialName: _mealLabel),
  );

  Future<void> _saveFoodAsTemplate(FoodEntry food) async {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final templateType = food.entryType == FoodEntryType.meal
        ? TemplateType.meal
        : TemplateType.food;

    final result = await SaveTemplateDialog.show(
      context,
      initialName: food.name,
      templateType: templateType,
    );

    if (result != null && mounted) {
      final viewModel = TemplateViewModel(userId: userId);
      food.templateId = await viewModel.saveFoodAsTemplate(
        name: result.name,
        food: food,
        tags: result.tags,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  Future<void> _showPhotoRecall() async {
    if (_timestamp == null ||
        _timePrecision == MealOccurrenceTimePrecision.unknown) {
      final l10n = AppLocalizations.of(context)!;
      final shouldSetTime = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.photo_recall_time_required_title),
          content: Text(l10n.photo_recall_time_required_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.set_time),
            ),
          ],
        ),
      );
      if (shouldSetTime != true || !mounted) return;
      await _selectTime();
      if (_timestamp == null || !mounted) return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        String? analyzingPhotoId;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> analyzePhoto(PhotoReference photo) async {
              if (!sheetContext.mounted) return;
              setSheetState(() => analyzingPhotoId = photo.id);
              await _analyzeAndAddFood(photo);
              if (sheetContext.mounted) {
                setSheetState(() => analyzingPhotoId = null);
              }
            }

            final l10n = AppLocalizations.of(context)!;
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 8, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.photoRecallTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.photoRecallSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: PhotoRecallSection(
                        mealTime: _timestamp!,
                        onPhotoTap: (photo) {
                          PhotoViewerDialog.show(
                            context,
                            photoId: photo.id,
                            photoDate: photo.createDateTime,
                            onAnalyze: () => analyzePhoto(photo),
                          );
                        },
                        onAnalyzePhoto: analyzePhoto,
                        analyzingPhotoId: analyzingPhotoId,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _analyzeAndAddFood(PhotoReference photo) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Get the full image bytes
      final asset = await _photoService.getAsset(photo.id);
      if (asset == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.foodAnalysisError)));
        }
        return;
      }

      // Get the origin file (full resolution)
      final file = await asset.originFile;
      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.foodAnalysisError)));
        }
        return;
      }

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Call the analysis service
      final result = await FoodAnalysisService.analyzeImage(
        imageBytes: bytes,
        mealTime: _timestamp,
        mealType: _mealType,
      );

      if (!mounted) return;

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? l10n.foodAnalysisError),
          ),
        );
        return;
      }

      if (result.items.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.foodAnalysisNoItems)));
        return;
      }

      // Handle single item directly
      if (result.items.length == 1) {
        final item = result.items.first;
        final food = await FoodQuantitySheet.show(
          context,
          food: item.foodEntry,
          mealLabel: _mealLabel,
        );
        if (food != null && mounted) {
          setState(() => _meal.foods.add(food));
        }
        return;
      }

      // Handle multiple items with selection dialog
      final selectedItems = await FoodItemSelectionDialog.show(
        context,
        items: result.items,
        overallConfidence: result.overallConfidence,
        notes: result.notes,
      );

      if (selectedItems == null) {
        // User chose to analyze again - retry
        await _analyzeAndAddFood(photo);
        return;
      }

      // Add each selected food
      for (final item in selectedItems) {
        if (!mounted) return;
        final food = await FoodQuantitySheet.show(
          context,
          food: item.foodEntry,
          mealLabel: _mealLabel,
        );
        if (food != null && mounted) {
          setState(() => _meal.foods.add(food));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.foodAnalysisError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _allowPop || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_pageTitle),
          actions: [
            TextButton(
              onPressed: _saveMeal,
              child: Text(
                widget.existingMeal == null ? l10n.done_label : l10n.save,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isSkipped) ...[
                _FoodListSection(
                  meal: _meal,
                  isSkipped: false,
                  showValidationError: _hasAttemptedSave && _meal.foods.isEmpty,
                  onAddFood: _addFood,
                  onFoodActions: _showFoodActions,
                  onSaveToLibrary: _openMealBuilder,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.existingMeal?.isSkipped == true)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(l10n.skipped_this_meal),
                          value: _isSkipped,
                          onChanged: (value) {
                            setState(() => _isSkipped = value);
                          },
                        ),
                        if (_isSkipped)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            child: TextField(
                              controller: _skipReasonController,
                              decoration: InputDecoration(
                                labelText: l10n.reason_for_skipping,
                                errorText:
                                    _hasAttemptedSave &&
                                        _skipReason?.trim().isNotEmpty != true
                                    ? l10n.enter_skip_reason
                                    : null,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() => _skipReason = value);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (!_isSkipped) ...[
                const SizedBox(height: 16),
                _SettingsRow(
                  icon: Icons.label_outline,
                  label: l10n.meal_label,
                  value: _mealLabel == l10n.meal_neutral_label
                      ? l10n.no_meal_label
                      : _mealLabel,
                  onTap: _selectMealType,
                ),
                const SizedBox(height: 8),
                _TimeSelector(
                  timestamp: _timestamp,
                  precision: _timePrecision,
                  hasSelection: _hasSelectedTime,
                  showValidationError: _hasAttemptedSave && !_hasSelectedTime,
                  onSelectTime: _selectTime,
                ),
                const SizedBox(height: 16),
                _SettingsRow(
                  icon: Icons.photo_library_outlined,
                  label: l10n.photoRecallTitle,
                  value: l10n.photoRecallSubtitle,
                  onTap: _showPhotoRecall,
                ),
                if (widget.task?.collectMealContext ?? true) ...[
                  const SizedBox(height: 16),
                  _SettingsRow(
                    icon: Icons.tune,
                    label: l10n.meal_details,
                    value: _mealDetailsSummary(l10n),
                    onTap: _editMealDetails,
                  ),
                ],
                if (_meal.foods.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  MealNutritionSummaryCard(meal: _meal),
                ],
              ],
              if (widget.existingMeal != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete_meal),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final String? errorText;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value),
            if (errorText != null)
              Text(
                errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _MealTypeSheet extends StatefulWidget {
  final MealType mealType;
  final String? customMealLabel;
  final List<String>? customMealTypes;

  const _MealTypeSheet({
    required this.mealType,
    required this.customMealLabel,
    this.customMealTypes,
  });

  @override
  State<_MealTypeSheet> createState() => _MealTypeSheetState();
}

class _MealTypeSheetState extends State<_MealTypeSheet> {
  late final TextEditingController _customLabelController;
  late String _selectedKey;
  bool _editingOther = false;

  @override
  void initState() {
    super.initState();
    _customLabelController = TextEditingController(
      text: widget.customMealLabel ?? '',
    );
    _selectedKey = _initialChoiceKey;
  }

  String get _initialChoiceKey {
    if (widget.mealType != MealType.other) return widget.mealType.name;
    final customLabel = widget.customMealLabel?.trim();
    if (customLabel?.isNotEmpty == true) {
      if (widget.customMealTypes?.contains(customLabel) == true) {
        return 'custom:$customLabel';
      }
      return 'custom-editor';
    }
    return 'none';
  }

  void _onChoiceChanged(String? key) {
    if (key == null) return;
    if (key == 'custom-editor') {
      setState(() {
        _selectedKey = key;
        _editingOther = true;
      });
      return;
    }
    if (key == 'none') {
      Navigator.of(context).pop(const _MealTypeSelection(MealType.other, ''));
      return;
    }
    if (key.startsWith('custom:')) {
      Navigator.of(
        context,
      ).pop(_MealTypeSelection(MealType.other, key.substring(7)));
      return;
    }
    final type = MealType.values.firstWhere((value) => value.name == key);
    Navigator.of(context).pop(_MealTypeSelection(type));
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final customTypes = widget.customMealTypes;
    final visibleCustomTypes =
        customTypes?.where((label) => label != l10n.meal_type_other).toList() ??
        const <String>[];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.meal_type_label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selectedKey == 'custom-editor' && !_editingOther
                  ? null
                  : _selectedKey,
              onChanged: _onChoiceChanged,
              child: Column(
                children: [
                  for (final type in [
                    MealType.breakfast,
                    MealType.lunch,
                    MealType.dinner,
                    MealType.snack,
                  ])
                    RadioListTile<String>(
                      value: type.name,
                      title: Text(_getMealTypeLabel(type, l10n)),
                    ),
                  ...visibleCustomTypes.map(
                    (label) => RadioListTile<String>(
                      value: 'custom:$label',
                      title: Text(label),
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'custom-editor',
                    title: Text(l10n.custom_meal_label),
                  ),
                  RadioListTile<String>(
                    value: 'none',
                    title: Text(l10n.no_meal_label),
                  ),
                ],
              ),
            ),
            if (_editingOther) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customLabelController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.custom_meal_label,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  _MealTypeSelection(
                    MealType.other,
                    _customLabelController.text.trim(),
                  ),
                ),
                child: Text(l10n.apply),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSelectionSheet extends StatelessWidget {
  final DateTime? timestamp;
  final MealOccurrenceTimePrecision? precision;

  const _TimeSelectionSheet({required this.timestamp, required this.precision});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: RadioGroup<MealOccurrenceTimePrecision>(
        groupValue: precision,
        onChanged: (value) {
          if (value != null) {
            Navigator.of(context).pop(_TimeSelection(null, value));
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<MealOccurrenceTimePrecision>(
              value: MealOccurrenceTimePrecision.exact,
              secondary: const Icon(Icons.schedule),
              title: Text(l10n.time_exact),
              subtitle: Text(l10n.time_exact_description),
            ),
            RadioListTile<MealOccurrenceTimePrecision>(
              value: MealOccurrenceTimePrecision.approximate,
              secondary: const Icon(Icons.more_time),
              title: Text(l10n.time_approximate),
              subtitle: Text(l10n.time_approximate_description),
            ),
            RadioListTile<MealOccurrenceTimePrecision>(
              value: MealOccurrenceTimePrecision.unknown,
              secondary: const Icon(Icons.help_outline),
              title: Text(l10n.time_unknown),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final DateTime? timestamp;
  final MealOccurrenceTimePrecision precision;
  final bool hasSelection;
  final bool showValidationError;
  final VoidCallback onSelectTime;

  const _TimeSelector({
    required this.timestamp,
    required this.precision,
    required this.hasSelection,
    required this.showValidationError,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = !hasSelection
        ? l10n.time_picker_hint
        : timestamp == null || precision == MealOccurrenceTimePrecision.unknown
        ? l10n.time_not_remembered
        : precision == MealOccurrenceTimePrecision.approximate
        ? l10n.about_time(TimeOfDay.fromDateTime(timestamp!).format(context))
        : TimeOfDay.fromDateTime(timestamp!).format(context);
    return _SettingsRow(
      icon: Icons.access_time_rounded,
      label: l10n.time,
      value: value,
      errorText: showValidationError ? l10n.required_error : null,
      onTap: onSelectTime,
    );
  }
}

class _FoodListSection extends StatelessWidget {
  final MealLog meal;
  final bool isSkipped;
  final VoidCallback onAddFood;
  final Future<void> Function(FoodEntry) onFoodActions;
  final VoidCallback onSaveToLibrary;
  final bool showValidationError;

  const _FoodListSection({
    required this.meal,
    required this.isSkipped,
    required this.onAddFood,
    required this.onFoodActions,
    required this.onSaveToLibrary,
    this.showValidationError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (isSkipped) {
      return const SizedBox.shrink();
    }

    if (meal.foods.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.food_items,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _EmptyFoodState(
            theme: theme,
            l10n: l10n,
            onAddFood: onAddFood,
            showValidationError: showValidationError,
          ),
        ],
      );
    }

    final compactActions = MediaQuery.sizeOf(context).width < 480;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.food_items,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (compactActions)
                  IconButton(
                    tooltip: l10n.save_meal,
                    onPressed: onSaveToLibrary,
                    icon: const Icon(Icons.bookmark_add_outlined),
                  )
                else
                  TextButton.icon(
                    onPressed: onSaveToLibrary,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(l10n.save_meal),
                  ),
                Semantics(
                  label: l10n.add_items,
                  button: true,
                  child: FilledButton(
                    onPressed: onAddFood,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 18),
                        const SizedBox(width: 6),
                        Text(l10n.add_items),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...meal.foods.map(
          (food) => _FoodCard(food: food, onTap: () => onFoodActions(food)),
        ),
      ],
    );
  }
}

class _EmptyFoodState extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onAddFood;
  final bool showValidationError;

  const _EmptyFoodState({
    required this.theme,
    required this.l10n,
    required this.onAddFood,
    required this.showValidationError,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onAddFood,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 36,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.add_items,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tap_to_add_food,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (showValidationError) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.add_food_before_saving,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodEntry food;
  final VoidCallback onTap;

  const _FoodCard({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final icon = food.entryType == FoodEntryType.meal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final imageUrl = _getFoodImageUrl(food);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: imageUrl == null
                    ? _buildFallbackIcon(theme, icon)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _buildFallbackIcon(theme, icon),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${food.amount} ${food.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${food.nutrition.energyKcal.toStringAsFixed(0)} kcal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                tooltip: l10n.more_options,
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(ThemeData theme, IconData icon) => Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
  );

  String? _getFoodImageUrl(FoodEntry food) {
    for (final key in [
      'image_front_small_url',
      'image_front_url',
      'image_url',
      'imageUrl',
    ]) {
      final value = food.originalValues[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}

class _MealDetailsSheet extends StatefulWidget {
  final MealContext mealContext;
  final CompanyContext? companyContext;
  final DistractionContext? distractionContext;
  final String? locationDescription;

  const _MealDetailsSheet({
    required this.mealContext,
    required this.companyContext,
    required this.distractionContext,
    required this.locationDescription,
  });

  @override
  State<_MealDetailsSheet> createState() => _MealDetailsSheetState();
}

class _MealDetailsSheetState extends State<_MealDetailsSheet> {
  late MealContext _mealContext;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _mealContext = widget.mealContext;
    _companyContext = widget.companyContext;
    _distractionContext = widget.distractionContext;
    _locationController = TextEditingController(
      text: widget.locationDescription ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.meal_details,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _DropdownField<MealContext>(
              label: l10n.where_did_you_eat,
              value: _mealContext,
              items: MealContext.values,
              itemLabel: (value) => _getMealContextLabel(value!, l10n),
              onChanged: (value) {
                if (value != null) setState(() => _mealContext = value);
              },
            ),
            if (_mealContext == MealContext.other) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: l10n.location_description,
                  hintText: l10n.location_description_hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _DropdownField<CompanyContext>(
              label: l10n.who_were_you_with,
              value: _companyContext,
              items: const [null, ...CompanyContext.values],
              itemLabel: (value) => value == null
                  ? l10n.not_specified
                  : _getCompanyContextLabel(value, l10n),
              onChanged: (value) => setState(() => _companyContext = value),
            ),
            const SizedBox(height: 12),
            _DropdownField<DistractionContext>(
              label: l10n.distractions_during_meal,
              value: _distractionContext,
              items: const [null, ...DistractionContext.values],
              itemLabel: (value) => value == null
                  ? l10n.not_specified
                  : _getDistractionContextLabel(value, l10n),
              onChanged: (value) => setState(() => _distractionContext = value),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final location = _locationController.text.trim();
                    Navigator.of(context).pop(
                      _MealDetailsSelection(
                        mealContext: _mealContext,
                        companyContext: _companyContext,
                        distractionContext: _distractionContext,
                        locationDescription:
                            _mealContext == MealContext.other &&
                                location.isNotEmpty
                            ? location
                            : null,
                      ),
                    );
                  },
                  child: Text(l10n.apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _getMealTypeLabel(MealType type, AppLocalizations l10n) {
  switch (type) {
    case MealType.breakfast:
      return l10n.meal_type_breakfast;
    case MealType.brunch:
      return l10n.meal_type_brunch;
    case MealType.lunch:
      return l10n.meal_type_lunch;
    case MealType.dinner:
      return l10n.meal_type_dinner;
    case MealType.snack:
      return l10n.meal_type_snack;
    case MealType.other:
      return l10n.meal_type_other;
  }
}

String _getMealContextLabel(MealContext value, AppLocalizations l10n) {
  switch (value) {
    case MealContext.home:
      return l10n.context_home;
    case MealContext.restaurant:
      return l10n.context_restaurant;
    case MealContext.takeout:
      return l10n.context_takeout;
    case MealContext.vending:
      return l10n.context_vending;
    case MealContext.other:
      return l10n.context_other;
  }
}

String _getCompanyContextLabel(CompanyContext value, AppLocalizations l10n) {
  switch (value) {
    case CompanyContext.alone:
      return l10n.company_alone;
    case CompanyContext.family:
      return l10n.company_family;
    case CompanyContext.friends:
      return l10n.company_friends;
    case CompanyContext.colleagues:
      return l10n.company_colleagues;
    case CompanyContext.other:
      return l10n.company_other;
  }
}

String _getDistractionContextLabel(
  DistractionContext value,
  AppLocalizations l10n,
) {
  switch (value) {
    case DistractionContext.none:
      return l10n.distraction_none;
    case DistractionContext.tv:
      return l10n.distraction_tv;
    case DistractionContext.phone:
      return l10n.distraction_phone;
    case DistractionContext.work:
      return l10n.distraction_work;
    case DistractionContext.other:
      return l10n.distraction_other;
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T?> items;
  final String Function(T?) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T?>(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
