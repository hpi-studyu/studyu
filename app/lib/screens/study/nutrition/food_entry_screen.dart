import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_recall_records.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/nutrition_food_snapshots.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart';
import 'package:uuid/uuid.dart';

class FoodEntryScreen extends StatefulWidget {
  final FoodEntry? existingFood;

  /// Confidence score from AI analysis (0.0 to 1.0).
  /// If provided, shows a banner indicating AI-estimated values.
  final double? confidenceScore;
  final bool showSearchAction;
  final String? mealLabel;
  final NutritionRecallPersistenceTarget? historicalTarget;
  final bool editReusableDefinition;
  final NutritionFoodRepository? repository;

  const FoodEntryScreen({
    this.existingFood,
    this.confidenceScore,
    this.showSearchAction = true,
    this.mealLabel,
    this.historicalTarget,
    this.editReusableDefinition = false,
    this.repository,
    super.key,
  }) : assert(!editReusableDefinition || historicalTarget != null);

  static MaterialPageRoute<FoodEntry> route({
    FoodEntry? existingFood,
    double? confidenceScore,
    bool showSearchAction = true,
    String? mealLabel,
    NutritionRecallPersistenceTarget? historicalTarget,
    bool editReusableDefinition = false,
    NutritionFoodRepository? repository,
  }) => MaterialPageRoute(
    builder: (_) => FoodEntryScreen(
      existingFood: existingFood,
      confidenceScore: confidenceScore,
      showSearchAction: showSearchAction,
      mealLabel: mealLabel,
      historicalTarget: historicalTarget,
      editReusableDefinition: editReusableDefinition,
      repository: repository,
    ),
  );

  @override
  State<FoodEntryScreen> createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends State<FoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _unitController;
  late TextEditingController _servingSizeController;
  late TextEditingController _portionReferenceController;
  late TextEditingController _yieldFactorController;
  late TextEditingController _ediblePortionController;

  // Nutrition controllers
  late TextEditingController _energyController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _sugarsController;
  late TextEditingController _fiberController;
  late TextEditingController _saturatedFatController;
  late TextEditingController _sodiumController;

  FoodEntryType _entryType = FoodEntryType.singleIngredient;
  PortionEstimationMethod _portionMethod =
      PortionEstimationMethod.householdMeasure;
  PortionState _portionState = PortionState.asServed;
  FoodSource _source = FoodSource.manual;
  bool _saveToMyItems = true;
  late final String _initialSnapshot;
  bool _allowPop = false;
  final String _mutationId = const Uuid().v4();

  bool get _isNewFoodForMeal =>
      widget.existingFood == null && widget.mealLabel != null;

  /// Whether the food entry data comes from AI analysis.
  bool get _isAiAnalyzed => widget.confidenceScore != null;

  /// Whether the confidence is low and fields should be highlighted.
  bool get _isLowConfidence =>
      widget.confidenceScore != null && widget.confidenceScore! < 0.6;

  @override
  void initState() {
    super.initState();
    if (widget.existingFood != null) {
      final food = widget.existingFood!;
      _nameController = TextEditingController(text: food.name);
      _brandController = TextEditingController(text: food.brandName ?? '');
      _descriptionController = TextEditingController(
        text: food.description ?? '',
      );
      _amountController = TextEditingController(text: food.amount.toString());
      _unitController = TextEditingController(text: food.unit);
      _servingSizeController = TextEditingController(
        text: food.servingSizeGrams.toString(),
      );
      _portionReferenceController = TextEditingController(
        text: food.portionReference ?? '',
      );
      _yieldFactorController = TextEditingController(
        text: food.yieldFactor?.toString() ?? '',
      );
      _ediblePortionController = TextEditingController(
        text: food.ediblePortion?.toString() ?? '',
      );

      _energyController = TextEditingController(
        text: food.nutrition.energyKcal.toString(),
      );
      _proteinController = TextEditingController(
        text: food.nutrition.protein.toString(),
      );
      _carbsController = TextEditingController(
        text: food.nutrition.carbs.toString(),
      );
      _fatController = TextEditingController(
        text: food.nutrition.fat.toString(),
      );
      _sugarsController = TextEditingController(
        text: food.nutrition.sugars.toString(),
      );
      _fiberController = TextEditingController(
        text: food.nutrition.fiber.toString(),
      );
      _saturatedFatController = TextEditingController(
        text: food.nutrition.saturatedFat.toString(),
      );
      _sodiumController = TextEditingController(
        text: food.nutrition.sodium.toString(),
      );

      _entryType = food.entryType;
      _portionMethod = food.portionEstimationMethod;
      _portionState = food.portionState;
      _source = food.source;
    } else {
      _nameController = TextEditingController();
      _brandController = TextEditingController();
      _descriptionController = TextEditingController();
      _amountController = TextEditingController(text: '1');
      _unitController = TextEditingController(text: 'serving');
      _servingSizeController = TextEditingController(text: '100');
      _portionReferenceController = TextEditingController();
      _yieldFactorController = TextEditingController();
      _ediblePortionController = TextEditingController();

      _energyController = TextEditingController();
      _proteinController = TextEditingController();
      _carbsController = TextEditingController();
      _fatController = TextEditingController();
      _sugarsController = TextEditingController();
      _fiberController = TextEditingController();
      _saturatedFatController = TextEditingController();
      _sodiumController = TextEditingController();
    }
    _initialSnapshot = _snapshot;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    _servingSizeController.dispose();
    _portionReferenceController.dispose();
    _yieldFactorController.dispose();
    _ediblePortionController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarsController.dispose();
    _fiberController.dispose();
    _saturatedFatController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  Future<void> _saveFood() async {
    var food = _buildFoodEntry();
    if (food == null) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final historicalTarget = widget.historicalTarget;
    final subject = appState.activeSubject;
    final existingFood = widget.existingFood;
    int? currentStudyDay;
    if (historicalTarget != null) {
      if (subject == null || existingFood == null) return;
      currentStudyDay = nutritionStudyDayFor(subject, DateTime.now());
      if (!isEditableNutritionRecallDay(
        studyDaySnapshot: historicalTarget.studyDaySnapshot,
        currentStudyDay: currentStudyDay,
        hasUnambiguousPeriod: true,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.historical_edit_expired)));
          _pop();
        }
        return;
      }
    }
    if (widget.editReusableDefinition) {
      try {
        final result = await (widget.repository ?? NutritionFoodRepository())
            .mutateHistoricalDefinition(
              subjectId: subject!.id,
              snapshot: normalizeNutritionFoodDefinition(food),
              expectedVersionId: existingFood!.foodVersionId,
              entryId: existingFood.id,
              target: historicalTarget!.toJson(),
              currentStudyDay: currentStudyDay!,
              mutationId: _mutationId,
            );
        food = applyNutritionFoodSnapshot(
          existingFood,
          result.definition.snapshot,
        );
        _reconcileProgress(subject, result.progress);
        final autoSaveManager = NutritionRecallAutoSaveManager();
        await autoSaveManager.rewriteFoodDefinition(
          subjectId: subject.id,
          studyDaySnapshot: currentStudyDay,
          definition: result.definition.snapshot,
        );
        await autoSaveManager.rewriteFoodDefinition(
          subjectId: subject.id,
          studyDaySnapshot: historicalTarget.studyDaySnapshot,
          definition: result.definition.snapshot,
          entryId: existingFood.id,
        );
        if (mounted) {
          final message = result.todayUpdateCount == 0
              ? l10n.food_definition_updated_no_today(
                  result.selectedHistoricalUpdateCount,
                )
              : l10n.food_definition_updated_today(
                  result.selectedHistoricalUpdateCount,
                  result.todayUpdateCount,
                );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (error, stackTrace) {
        StudyULogger.error(
          'Failed to update historical nutrition definition: '
          '$error\n$stackTrace',
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
        }
        return;
      }
    }

    if (_isNewFoodForMeal && _saveToMyItems) {
      final userId = appState.activeSubject?.id ?? 'anonymous';
      try {
        food.templateId = await TemplateViewModel(
          userId: userId,
        ).saveFoodAsTemplate(name: food.name, food: food);
      } catch (error) {
        StudyULogger.error('Failed to save food to My items: $error');
      }
    }

    if (mounted) _pop(food);
  }

  void _reconcileProgress(
    StudySubject subject,
    List<Map<String, dynamic>> canonicalRows,
  ) {
    for (final row in canonicalRows) {
      final canonical = SubjectProgress.fromJson(row);
      final index = subject.progress.indexWhere(
        (progress) =>
            progress.subjectId == canonical.subjectId &&
            progress.completedAt == canonical.completedAt,
      );
      if (index < 0) {
        subject.progress.add(canonical);
      } else {
        subject.progress[index] = canonical;
      }
    }
  }

  void _pop([FoodEntry? result]) {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  Future<void> _confirmDiscard({FoodEntry? replacement}) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showUnsavedChangesDialog(
      context,
      title: l10n.unsaved_changes_title,
      message: l10n.unsaved_changes_message,
      discardLabel: l10n.discard_changes,
      continueLabel: l10n.continue_editing,
    );
    if (!mounted) return;

    switch (action) {
      case UnsavedChangesAction.discard:
        _pop(replacement);
      case null:
        return;
    }
  }

  FoodEntry? _buildFoodEntry() {
    if (!_formKey.currentState!.validate()) return null;

    final existingNutrition = widget.existingFood?.nutrition;
    final nutrition = NutritionProfile(
      energyKcal: double.tryParse(_energyController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      sugars: double.tryParse(_sugarsController.text) ?? 0,
      fiber: double.tryParse(_fiberController.text) ?? 0,
      saturatedFat: double.tryParse(_saturatedFatController.text) ?? 0,
      transFat: existingNutrition?.transFat ?? 0,
      cholesterol: existingNutrition?.cholesterol ?? 0,
      sodium: double.tryParse(_sodiumController.text) ?? 0,
      waterContent: existingNutrition?.waterContent ?? 0,
      micros: existingNutrition?.micros ?? {},
    );

    final existingFood = widget.existingFood;
    if (existingFood == null) {
      return FoodEntry.withId(
        entryType: _entryType,
        name: _nameController.text,
        brandName: _brandController.text.isEmpty ? null : _brandController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        amount: double.parse(_amountController.text),
        unit: _unitController.text,
        servingSizeGrams: double.parse(_servingSizeController.text),
        portionReference: _portionReferenceController.text.isEmpty
            ? null
            : _portionReferenceController.text,
        portionEstimationMethod: _portionMethod,
        portionState: _portionState,
        yieldFactor: _yieldFactorController.text.isEmpty
            ? null
            : double.tryParse(_yieldFactorController.text),
        ediblePortion: _ediblePortionController.text.isEmpty
            ? null
            : double.tryParse(_ediblePortionController.text),
        nutrition: nutrition,
        source: _source,
        confidenceScore: 1.0,
        originalValues: {},
      );
    }

    return FoodEntry(
      id: existingFood.id,
      foodId: existingFood.foodId,
      foodVersionId: existingFood.foodVersionId,
      entryType: _entryType,
      name: _nameController.text,
      brandName: _brandController.text.isEmpty ? null : _brandController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      amount: double.parse(_amountController.text),
      unit: _unitController.text,
      servingSizeGrams: double.parse(_servingSizeController.text),
      portionReference: _portionReferenceController.text.isEmpty
          ? null
          : _portionReferenceController.text,
      portionEstimationMethod: _portionMethod,
      portionState: _portionState,
      yieldFactor: _yieldFactorController.text.isEmpty
          ? null
          : double.tryParse(_yieldFactorController.text),
      ediblePortion: _ediblePortionController.text.isEmpty
          ? null
          : double.tryParse(_ediblePortionController.text),
      nutrition: nutrition,
      foodCode: existingFood.foodCode,
      externalId: existingFood.externalId,
      source: existingFood.source,
      confidenceScore: existingFood.confidenceScore,
      templateId: existingFood.templateId,
      createdAt: existingFood.createdAt,
      modifiedAt: DateTime.now(),
      originalValues: existingFood.originalValues,
      parentEntryId: existingFood.parentEntryId,
      preparationDetails: existingFood.preparationDetails,
      componentFoods: existingFood.componentFoods,
      componentSnapshots: existingFood.componentSnapshots,
    );
  }

  String get _snapshot => jsonEncode({
    'name': _nameController.text,
    'brand': _brandController.text,
    'description': _descriptionController.text,
    'amount': _amountController.text,
    'unit': _unitController.text,
    'servingSize': _servingSizeController.text,
    'portionReference': _portionReferenceController.text,
    'yieldFactor': _yieldFactorController.text,
    'ediblePortion': _ediblePortionController.text,
    'energy': _energyController.text,
    'protein': _proteinController.text,
    'carbs': _carbsController.text,
    'fat': _fatController.text,
    'sugars': _sugarsController.text,
    'fiber': _fiberController.text,
    'saturatedFat': _saturatedFatController.text,
    'sodium': _sodiumController.text,
    'entryType': _entryType.name,
    'portionMethod': _portionMethod.name,
    'portionState': _portionState.name,
  });

  bool get _hasUnsavedChanges => _snapshot != _initialSnapshot;

  String? get _productImageUrl {
    final value = widget.existingFood?.originalValues['image_front_small_url'];
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingFood != null;

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.edit_food_title : l10n.add_food_manually),
        actions: [
          if (widget.showSearchAction)
            IconButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  FoodSearchScreen.route(),
                );
                if (result == null || !context.mounted) return;
                if (_hasUnsavedChanges) {
                  await _confirmDiscard(replacement: result);
                } else {
                  _pop(result);
                }
              },
              icon: const Icon(Icons.search_outlined),
              tooltip: l10n.search_food_database,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _saveFood,
            icon: const Icon(Icons.check),
            label: Text(
              _isNewFoodForMeal
                  ? l10n.save_and_add_to_meal(widget.mealLabel!)
                  : l10n.save,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ========== AI ESTIMATION BANNER ==========
            if (_isAiAnalyzed)
              _AiEstimationBanner(
                confidenceScore: widget.confidenceScore!,
                isLowConfidence: _isLowConfidence,
                l10n: l10n,
                theme: theme,
              ),
            if (_isAiAnalyzed) const SizedBox(height: 12),

            if (widget.editReusableDefinition) ...[
              Text(
                l10n.food_definition_edit_helper,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_productImageUrl case final imageUrl?)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                semanticLabel: widget.existingFood!.name,
                frameBuilder: (_, child, _, _) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                ),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),

            // ========== ESSENTIAL FIELDS ==========
            _EssentialFieldsCard(
              nameController: _nameController,
              servingSizeController: _servingSizeController,
              energyController: _energyController,
              proteinController: _proteinController,
              carbsController: _carbsController,
              fatController: _fatController,
              l10n: l10n,
              theme: theme,
              isEditing: isEditing,
            ),

            if (_isNewFoodForMeal)
              CheckboxListTile(
                value: _saveToMyItems,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.save_to_my_items),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) =>
                    setState(() => _saveToMyItems = value ?? false),
              ),

            const SizedBox(height: 12),

            // ========== DETAILED NUTRITION (Collapsed) ==========
            _DetailedNutritionCard(
              fiberController: _fiberController,
              sugarsController: _sugarsController,
              saturatedFatController: _saturatedFatController,
              sodiumController: _sodiumController,
              l10n: l10n,
            ),

            const SizedBox(height: 12),

            // ========== ADVANCED OPTIONS (Collapsed) ==========
            _AdvancedOptionsCard(
              entryType: _entryType,
              brandController: _brandController,
              descriptionController: _descriptionController,
              portionReferenceController: _portionReferenceController,
              portionMethod: _portionMethod,
              portionState: _portionState,
              yieldFactorController: _yieldFactorController,
              ediblePortionController: _ediblePortionController,
              l10n: l10n,
              onEntryTypeChanged: (value) {
                if (value != null) setState(() => _entryType = value);
              },
              onPortionMethodChanged: (value) {
                if (value != null) setState(() => _portionMethod = value);
              },
              onPortionStateChanged: (value) {
                if (value != null) setState(() => _portionState = value);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_hasUnsavedChanges) {
          _confirmDiscard();
        } else {
          _pop();
        }
      },
      child: scaffold,
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

/// Banner displayed when food entry data comes from AI analysis.
class _AiEstimationBanner extends StatelessWidget {
  final double confidenceScore;
  final bool isLowConfidence;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _AiEstimationBanner({
    required this.confidenceScore,
    required this.isLowConfidence,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLowConfidence
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowConfidence
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLowConfidence ? Icons.warning_amber : Icons.auto_awesome,
            color: isLowConfidence
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiEstimatedBanner,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLowConfidence
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.confidenceLabel((confidenceScore * 100).round()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isLowConfidence
                        ? theme.colorScheme.onErrorContainer.withValues(
                            alpha: 0.8,
                          )
                        : theme.colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.8,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EssentialFieldsCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController servingSizeController;
  final TextEditingController energyController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;
  final AppLocalizations l10n;
  final ThemeData theme;
  final bool isEditing;

  const _EssentialFieldsCard({
    required this.nameController,
    required this.servingSizeController,
    required this.energyController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
    required this.l10n,
    required this.theme,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.basic_information,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Food Name
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.food_name,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
              ),
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enter_food_name;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: servingSizeController,
              decoration: InputDecoration(
                labelText: l10n.nutrition_values_are_for,
                border: const OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.required_error;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Calories
            TextFormField(
              controller: energyController,
              decoration: InputDecoration(
                labelText: l10n.energy_kcal,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_fire_department),
                hintText: '0',
                suffixText: 'kcal',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),

            // Macros Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.pie_chart_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.macronutrients,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Macros Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: proteinController,
                    decoration: InputDecoration(
                      labelText: l10n.protein,
                      helperText: l10n.optional,
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      suffixText: 'g',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: carbsController,
                    decoration: InputDecoration(
                      labelText: l10n.carbohydrate,
                      helperText: l10n.optional,
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      suffixText: 'g',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: fatController,
                    decoration: InputDecoration(
                      labelText: l10n.fat,
                      helperText: l10n.optional,
                      border: const OutlineInputBorder(),
                      hintText: '0',
                      suffixText: 'g',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailedNutritionCard extends StatefulWidget {
  final TextEditingController fiberController;
  final TextEditingController sugarsController;
  final TextEditingController saturatedFatController;
  final TextEditingController sodiumController;
  final AppLocalizations l10n;

  const _DetailedNutritionCard({
    required this.fiberController,
    required this.sugarsController,
    required this.saturatedFatController,
    required this.sodiumController,
    required this.l10n,
  });

  @override
  State<_DetailedNutritionCard> createState() => _DetailedNutritionCardState();
}

class _DetailedNutritionCardState extends State<_DetailedNutritionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.l10n.detailed_nutrition,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.l10n.detailed_nutrition_subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.fiberController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.fiber_g,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: widget.sugarsController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.sugars_g,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.saturatedFatController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.saturated_fat_g,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: widget.sodiumController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.sodium_mg,
                            border: const OutlineInputBorder(),
                            hintText: '0',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AdvancedOptionsCard extends StatefulWidget {
  final FoodEntryType entryType;
  final TextEditingController brandController;
  final TextEditingController descriptionController;
  final TextEditingController portionReferenceController;
  final PortionEstimationMethod portionMethod;
  final PortionState portionState;
  final TextEditingController yieldFactorController;
  final TextEditingController ediblePortionController;
  final AppLocalizations l10n;
  final ValueChanged<FoodEntryType?> onEntryTypeChanged;
  final ValueChanged<PortionEstimationMethod?> onPortionMethodChanged;
  final ValueChanged<PortionState?> onPortionStateChanged;

  const _AdvancedOptionsCard({
    required this.entryType,
    required this.brandController,
    required this.descriptionController,
    required this.portionReferenceController,
    required this.portionMethod,
    required this.portionState,
    required this.yieldFactorController,
    required this.ediblePortionController,
    required this.l10n,
    required this.onEntryTypeChanged,
    required this.onPortionMethodChanged,
    required this.onPortionStateChanged,
  });

  @override
  State<_AdvancedOptionsCard> createState() => _AdvancedOptionsCardState();
}

class _AdvancedOptionsCardState extends State<_AdvancedOptionsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.tune_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.l10n.advanced_options,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.l10n.advanced_options_subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Entry Type Dropdown
                  DropdownButtonFormField<FoodEntryType>(
                    initialValue: widget.entryType == FoodEntryType.meal
                        ? FoodEntryType.manualCustom
                        : widget.entryType,
                    decoration: InputDecoration(
                      labelText: widget.l10n.entry_type,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    isExpanded: true,
                    items: FoodEntryType.values
                        .where((type) => type != FoodEntryType.meal)
                        .map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              _getEntryTypeLabel(type),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                        .toList(),
                    onChanged: widget.onEntryTypeChanged,
                  ),
                  const SizedBox(height: 8),

                  // Brand (conditional)
                  if (widget.entryType == FoodEntryType.brandedProduct) ...[
                    TextFormField(
                      controller: widget.brandController,
                      decoration: InputDecoration(
                        labelText: widget.l10n.brand_name,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Description
                  TextFormField(
                    controller: widget.descriptionController,
                    decoration: InputDecoration(
                      labelText: widget.l10n.description,
                      border: const OutlineInputBorder(),
                      hintText: widget.l10n.description_hint,
                    ),
                    maxLines: 2,
                    minLines: 1,
                  ),
                  const SizedBox(height: 8),

                  // Portion Reference
                  TextFormField(
                    controller: widget.portionReferenceController,
                    decoration: InputDecoration(
                      labelText: widget.l10n.portion_reference,
                      border: const OutlineInputBorder(),
                      hintText: widget.l10n.portion_reference_hint,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Portion Method & State (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<PortionEstimationMethod>(
                          initialValue: widget.portionMethod,
                          decoration: InputDecoration(
                            labelText: widget.l10n.portion_estimation_method,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          isExpanded: true,
                          items: PortionEstimationMethod.values.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(
                                _getPortionMethodLabel(method),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: widget.onPortionMethodChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<PortionState>(
                          initialValue: widget.portionState,
                          decoration: InputDecoration(
                            labelText: widget.l10n.portion_state,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          isExpanded: true,
                          items: PortionState.values.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(
                                _getPortionStateLabel(state),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: widget.onPortionStateChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Yield & Edible Portion (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.yieldFactorController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.yield_factor,
                            border: const OutlineInputBorder(),
                            hintText: widget.l10n.yield_factor_hint,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,4}'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: widget.ediblePortionController,
                          decoration: InputDecoration(
                            labelText: widget.l10n.edible_portion,
                            border: const OutlineInputBorder(),
                            hintText: widget.l10n.edible_portion_hint,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,4}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getEntryTypeLabel(FoodEntryType type) {
    switch (type) {
      case FoodEntryType.singleIngredient:
        return widget.l10n.entry_type_single_ingredient;
      case FoodEntryType.meal:
        return widget.l10n.entry_type_meal;
      case FoodEntryType.brandedProduct:
        return widget.l10n.entry_type_branded_product;
      case FoodEntryType.manualCustom:
        return widget.l10n.entry_type_manual_entry;
    }
  }

  String _getPortionMethodLabel(PortionEstimationMethod method) {
    switch (method) {
      case PortionEstimationMethod.householdMeasure:
        return widget.l10n.portion_method_household;
      case PortionEstimationMethod.photograph:
        return widget.l10n.portion_method_photograph;
      case PortionEstimationMethod.standardUnit:
        return widget.l10n.portion_method_standard_unit;
      case PortionEstimationMethod.userWeighted:
        return widget.l10n.portion_method_user_weighted;
      case PortionEstimationMethod.unknown:
        return widget.l10n.portion_method_unknown;
    }
  }

  String _getPortionStateLabel(PortionState state) {
    switch (state) {
      case PortionState.raw:
        return widget.l10n.portion_state_raw;
      case PortionState.cooked:
        return widget.l10n.portion_state_cooked;
      case PortionState.asServed:
        return widget.l10n.portion_state_as_served;
    }
  }
}
