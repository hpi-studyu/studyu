import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_quantity_sheet.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/food_analysis_service.dart';
import 'package:studyu_app/services/photo_gallery_service.dart';
import 'package:studyu_app/widgets/food_item_selection_dialog.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';
import 'package:studyu_app/widgets/photo_viewer_dialog.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_app/widgets/template_selection_sheet.dart';
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

class _MealTypeSelection {
  final MealType type;
  final String? customLabel;

  const _MealTypeSelection(this.type, [this.customLabel]);
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

  const MealEntryScreen({
    this.existingMeal,
    this.task,
    this.initialMealType,
    this.initialCustomMealLabel,
    super.key,
  });

  static MaterialPageRoute<MealEntryResult> route({
    MealLog? existingMeal,
    NutritionTask? task,
    MealType? initialMealType,
    String? initialCustomMealLabel,
  }) => MaterialPageRoute(
    builder: (_) => MealEntryScreen(
      existingMeal: existingMeal,
      task: task,
      initialMealType: initialMealType,
      initialCustomMealLabel: initialCustomMealLabel,
    ),
  );

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  static const int _breakfastStart = 6;
  static const int _brunchStart = 10;
  static const int _lunchStart = 12;
  static const int _dinnerStart = 16;
  static const int _dinnerEnd = 21;

  late MealLog _meal;
  late MealType _mealType;
  late MealContext _mealContext;
  late DateTime _timestamp;
  late bool _isSkipped;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  String? _customMealLabel;
  String? _locationDescription;
  String? _skipReason;
  late final String _initialMealSnapshot;
  bool _allowPop = false;
  bool _hasAttemptedSave = false;

  late TextEditingController _skipReasonController;

  bool _isSavingTemplate = false;
  bool _isSavingFoodTemplate = false;
  String? _analyzingPhotoId;

  final PhotoGalleryService _photoService = PhotoGalleryService();

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _meal = cloneMealLog(widget.existingMeal!);
      _mealType = _meal.mealType;
      _mealContext = _meal.mealContext;
      _timestamp = _meal.timestamp;
      _isSkipped = _meal.isSkipped;
      _companyContext = _meal.companyContext;
      _distractionContext = _meal.distractionContext;
      _customMealLabel = _meal.customMealLabel;
      _locationDescription = _meal.locationDescription;
      _skipReason = _meal.skipReason;
    } else {
      _timestamp = DateTime.now();
      _mealType = widget.initialMealType ?? _getMealTypeByTime(_timestamp);
      _customMealLabel = widget.initialCustomMealLabel;
      _mealContext = MealContext.home;
      _isSkipped = false;
      _meal = MealLog.withId(
        mealType: _mealType,
        customMealLabel: _customMealLabel,
        mealContext: _mealContext,
        timestamp: _timestamp,
        timezone: DateTime.now().timeZoneName,
        isSkipped: _isSkipped,
        foods: [],
      );
    }

    _skipReasonController = TextEditingController(text: _skipReason ?? '');
    _initialMealSnapshot = _mealSnapshot;
  }

  @override
  void dispose() {
    _skipReasonController.dispose();
    super.dispose();
  }

  MealType _getMealTypeByTime(DateTime time) {
    final hour = time.hour;
    if (hour >= _breakfastStart && hour < _brunchStart) {
      return MealType.breakfast;
    }
    if (hour >= _brunchStart && hour < _lunchStart) return MealType.brunch;
    if (hour >= _lunchStart && hour < _dinnerStart) return MealType.lunch;
    if (hour >= _dinnerStart && hour < _dinnerEnd) return MealType.dinner;
    return MealType.snack;
  }

  Future<void> _addFood() async {
    final result = await FoodSearchScreen.show(
      context,
      mealLabel: _mealLabel,
      allowRecipes: widget.task?.allowRecipes ?? true,
    );
    if (result != null && mounted) {
      setState(() {
        _meal.foods.add(result);
      });
    }
  }

  Future<void> _editFood(FoodEntry food, int index) async {
    final result = await Navigator.of(
      context,
    ).push(FoodEntryScreen.route(existingFood: food, showSearchAction: false));
    if (result != null) {
      setState(() {
        _meal.foods[index] = result;
      });
    }
  }

  void _removeFood(int index) {
    setState(() {
      _meal.foods.removeAt(index);
    });
  }

  MealLog _buildMeal({bool normalizeSkipped = false}) {
    final clearDetails = normalizeSkipped && _isSkipped;
    return MealLog(
      id: _meal.id,
      mealType: _mealType,
      customMealLabel: clearDetails || _mealType != MealType.other
          ? null
          : _customMealLabel,
      mealContext: _mealContext,
      locationDescription: clearDetails || _mealContext != MealContext.other
          ? null
          : _locationDescription?.trim(),
      timestamp: _timestamp,
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
      (!_isSkipped && _meal.foods.isNotEmpty) ||
      (_isSkipped && _skipReason?.trim().isNotEmpty == true);

  String get _mealLabel {
    final customLabel = _customMealLabel?.trim();
    return _mealType == MealType.other && customLabel?.isNotEmpty == true
        ? customLabel!
        : _getMealTypeLabel(_mealType);
  }

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
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          _timestamp.year,
          _timestamp.month,
          _timestamp.day,
          picked.hour,
          picked.minute,
        );
      });
    }
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

  Future<void> _saveAsTemplate() async {
    if (_isSkipped) return;

    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await SaveTemplateDialog.show(
      context,
      initialName: _customMealLabel ?? _getMealTypeLabel(_mealType),
      templateType: TemplateType.meal,
    );

    if (result != null && mounted) {
      setState(() => _isSavingTemplate = true);
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveMealAsTemplate(
        name: result.name,
        meal: _buildMeal(),
        tags: result.tags,
      );
      if (mounted) {
        setState(() => _isSavingTemplate = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  Future<void> _addFoodFromTemplate() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final selectedFood = await TemplateSelectionSheet.show(
      context,
      mode: TemplateSelectionMode.food,
      userId: userId,
    );
    if (selectedFood is! FoodEntry || !mounted) return;

    final food = await FoodQuantitySheet.show(
      context,
      food: selectedFood,
      mealLabel: _mealLabel,
    );
    if (food != null && mounted) {
      setState(() => _meal.foods.add(food));
    }
  }

  Future<void> _saveFoodAsTemplate(FoodEntry food) async {
    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final templateType = food.entryType == FoodEntryType.recipe
        ? TemplateType.recipe
        : TemplateType.food;

    final result = await SaveTemplateDialog.show(
      context,
      initialName: food.name,
      templateType: templateType,
    );

    if (result != null && mounted) {
      setState(() => _isSavingFoodTemplate = true);
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveFoodAsTemplate(
        name: result.name,
        food: food,
        tags: result.tags,
      );
      if (mounted) {
        setState(() => _isSavingFoodTemplate = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  Future<void> _analyzeAndAddFood(PhotoReference photo) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _analyzingPhotoId = photo.id);

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
        final editedFood = await Navigator.of(context).push<FoodEntry>(
          FoodEntryScreen.route(
            existingFood: item.foodEntry,
            confidenceScore: item.confidenceScore,
            showSearchAction: false,
          ),
        );
        if (editedFood != null && mounted) {
          setState(() => _meal.foods.add(editedFood));
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
        final editedFood = await Navigator.of(context).push<FoodEntry>(
          FoodEntryScreen.route(
            existingFood: item.foodEntry,
            confidenceScore: item.confidenceScore,
            showSearchAction: false,
          ),
        );
        if (editedFood != null && mounted) {
          setState(() => _meal.foods.add(editedFood));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.foodAnalysisError)));
      }
    } finally {
      if (mounted) {
        setState(() => _analyzingPhotoId = null);
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
          title: Text(_mealLabel),
          actions: [
            if (_meal.foods.isNotEmpty && !_isSkipped)
              IconButton(
                icon: _isSavingTemplate
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                tooltip: l10n.save_as_template,
                onPressed: _isSavingTemplate ? null : _saveAsTemplate,
              ),
            TextButton(onPressed: _saveMeal, child: Text(l10n.save)),
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
                  onAddFoodFromTemplate: _addFoodFromTemplate,
                  onEditFood: _editFood,
                  onRemoveFood: _removeFood,
                  onSaveFoodAsTemplate: _saveFoodAsTemplate,
                  isSavingFoodTemplate: _isSavingFoodTemplate,
                ),
                const SizedBox(height: 16),
              ],
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
                  icon: Icons.restaurant_menu,
                  label: l10n.meal_type_label,
                  value: _mealLabel,
                  onTap: _selectMealType,
                ),
                const SizedBox(height: 8),
                _TimeSelector(timestamp: _timestamp, onSelectTime: _selectTime),
                const SizedBox(height: 16),
                PhotoRecallSection(
                  mealTime: _timestamp,
                  onPhotoTap: (photo) {
                    PhotoViewerDialog.show(
                      context,
                      photoId: photo.id,
                      photoDate: photo.createDateTime,
                      onAnalyze: () => _analyzeAndAddFood(photo),
                    );
                  },
                  onAnalyzePhoto: _analyzeAndAddFood,
                  analyzingPhotoId: _analyzingPhotoId,
                ),
                if (_meal.foods.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  MealNutritionSummaryCard(meal: _meal),
                ],
                const SizedBox(height: 16),
                if (widget.task?.collectMealContext ?? true)
                  _SettingsRow(
                    icon: Icons.tune,
                    label: l10n.meal_details,
                    value: _mealDetailsSummary(l10n),
                    onTap: _editMealDetails,
                  ),
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

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
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
  bool _editingOther = false;

  @override
  void initState() {
    super.initState();
    _customLabelController = TextEditingController(
      text: widget.customMealLabel ?? '',
    );
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
    final visibleCustomTypes = customTypes
        ?.where((label) => label != l10n.meal_type_other)
        .toList();

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
            if (customTypes != null && customTypes.isNotEmpty) ...[
              ...visibleCustomTypes!.map(
                (label) => ListTile(
                  title: Text(label),
                  leading: Icon(
                    widget.mealType == MealType.other &&
                            widget.customMealLabel == label
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pop(_MealTypeSelection(MealType.other, label)),
                ),
              ),
              ListTile(
                title: Text(l10n.meal_type_other),
                leading: Icon(
                  widget.mealType == MealType.other &&
                          (widget.customMealLabel?.trim().isEmpty ?? true)
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pop(const _MealTypeSelection(MealType.other, '')),
              ),
            ] else
              ...MealType.values.map(
                (type) => ListTile(
                  title: Text(_getMealTypeLabel(type, l10n)),
                  leading: Icon(
                    widget.mealType == type
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () {
                    if (type == MealType.other) {
                      setState(() => _editingOther = true);
                    } else {
                      Navigator.of(context).pop(_MealTypeSelection(type));
                    }
                  },
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
                    _customLabelController.text,
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

class _TimeSelector extends StatelessWidget {
  final DateTime timestamp;
  final VoidCallback onSelectTime;

  const _TimeSelector({required this.timestamp, required this.onSelectTime});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SettingsRow(
      icon: Icons.access_time_rounded,
      label: l10n.time,
      value: TimeOfDay.fromDateTime(timestamp).format(context),
      onTap: onSelectTime,
    );
  }
}

class _FoodListSection extends StatelessWidget {
  final MealLog meal;
  final bool isSkipped;
  final VoidCallback onAddFood;
  final VoidCallback onAddFoodFromTemplate;
  final Function(FoodEntry, int) onEditFood;
  final Function(int) onRemoveFood;
  final Function(FoodEntry) onSaveFoodAsTemplate;
  final bool isSavingFoodTemplate;
  final bool showValidationError;

  const _FoodListSection({
    required this.meal,
    required this.isSkipped,
    required this.onAddFood,
    required this.onAddFoodFromTemplate,
    required this.onEditFood,
    required this.onRemoveFood,
    required this.onSaveFoodAsTemplate,
    this.isSavingFoodTemplate = false,
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
              children: [
                Semantics(
                  label: l10n.from_template,
                  button: true,
                  child: IconButton.outlined(
                    onPressed: onAddFoodFromTemplate,
                    icon: const Icon(Icons.bookmark, size: 18),
                    tooltip: l10n.from_template,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: l10n.add_food,
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
                        Text(l10n.add_food),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(meal.foods.length, (index) {
          final food = meal.foods[index];
          return _FoodCard(
            food: food,
            index: index,
            onTap: () => onEditFood(food, index),
            onEdit: () => onEditFood(food, index),
            onDelete: () => onRemoveFood(index),
            onSaveTemplate: () => onSaveFoodAsTemplate(food),
            isSavingTemplate: isSavingFoodTemplate,
          );
        }),
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
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.add_food,
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
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSaveTemplate;
  final bool isSavingTemplate;

  const _FoodCard({
    required this.food,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onSaveTemplate,
    this.isSavingTemplate = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final (icon, color) = _getFoodIconAndColor(food.entryType);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, size: 22, color: color)),
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                tooltip: l10n.more_options,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (isSavingTemplate) return;
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'save_template':
                      onSaveTemplate();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: _PopupMenuItem(
                      icon: Icons.edit_outlined,
                      label: l10n.edit,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'save_template',
                    enabled: !isSavingTemplate,
                    child: isSavingTemplate
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.saving),
                            ],
                          )
                        : _PopupMenuItem(
                            icon: Icons.bookmark_add_outlined,
                            label: l10n.save_as_template,
                          ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: _PopupMenuItem(
                      icon: Icons.delete_outline,
                      label: l10n.delete,
                      isDestructive: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getFoodIconAndColor(FoodEntryType entryType) {
    switch (entryType) {
      case FoodEntryType.recipe:
        return (Icons.menu_book_outlined, Colors.orange);
      case FoodEntryType.brandedProduct:
        return (Icons.shopping_bag_outlined, Colors.blue);
      case FoodEntryType.manualCustom:
        return (Icons.edit_note_outlined, Colors.purple);
      default:
        return (Icons.restaurant_outlined, Colors.green);
    }
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

class _PopupMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _PopupMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}
