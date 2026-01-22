import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_core/core.dart';

class FoodEntryScreen extends StatefulWidget {
  final FoodEntry? existingFood;

  const FoodEntryScreen({this.existingFood, super.key});

  static MaterialPageRoute<FoodEntry> route({FoodEntry? existingFood}) =>
      MaterialPageRoute(
        builder: (_) => FoodEntryScreen(existingFood: existingFood),
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

  void _saveFood() {
    if (_formKey.currentState!.validate()) {
      final nutrition = NutritionProfile(
        energyKcal: double.tryParse(_energyController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
        sugars: double.tryParse(_sugarsController.text) ?? 0,
        fiber: double.tryParse(_fiberController.text) ?? 0,
        saturatedFat: double.tryParse(_saturatedFatController.text) ?? 0,
        transFat: 0,
        cholesterol: 0,
        sodium: double.tryParse(_sodiumController.text) ?? 0,
        waterContent: 0,
        micros: {},
      );

      final food = FoodEntry.withId(
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

      Navigator.of(context).pop(food);
    }
  }

  String _getEntryTypeLabel(FoodEntryType type) {
    switch (type) {
      case FoodEntryType.singleIngredient:
        return AppLocalizations.of(context)!.entry_type_single_ingredient;
      case FoodEntryType.recipe:
        return AppLocalizations.of(context)!.entry_type_recipe;
      case FoodEntryType.brandedProduct:
        return AppLocalizations.of(context)!.entry_type_branded_product;
      case FoodEntryType.manualCustom:
        return AppLocalizations.of(context)!.entry_type_manual_entry;
    }
  }

  String _getPortionMethodLabel(PortionEstimationMethod method) {
    switch (method) {
      case PortionEstimationMethod.householdMeasure:
        return AppLocalizations.of(context)!.portion_method_household;
      case PortionEstimationMethod.photograph:
        return AppLocalizations.of(context)!.portion_method_photograph;
      case PortionEstimationMethod.standardUnit:
        return AppLocalizations.of(context)!.portion_method_standard_unit;
      case PortionEstimationMethod.userWeighted:
        return AppLocalizations.of(context)!.portion_method_user_weighted;
      case PortionEstimationMethod.unknown:
        return AppLocalizations.of(context)!.portion_method_unknown;
    }
  }

  String _getPortionStateLabel(PortionState state) {
    switch (state) {
      case PortionState.raw:
        return AppLocalizations.of(context)!.portion_state_raw;
      case PortionState.cooked:
        return AppLocalizations.of(context)!.portion_state_cooked;
      case PortionState.asServed:
        return AppLocalizations.of(context)!.portion_state_as_served;
    }
  }

  FoodEntry? _buildFoodEntry() {
    if (!_formKey.currentState!.validate()) return null;

    final nutrition = NutritionProfile(
      energyKcal: double.tryParse(_energyController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      sugars: double.tryParse(_sugarsController.text) ?? 0,
      fiber: double.tryParse(_fiberController.text) ?? 0,
      saturatedFat: double.tryParse(_saturatedFatController.text) ?? 0,
      transFat: 0,
      cholesterol: 0,
      sodium: double.tryParse(_sodiumController.text) ?? 0,
      waterContent: 0,
      micros: {},
    );

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

  Future<void> _saveAsTemplate() async {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enter_food_name)));
      return;
    }

    final food = _buildFoodEntry();
    if (food == null) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final templateType = _entryType == FoodEntryType.recipe
        ? TemplateType.recipe
        : TemplateType.food;

    final result = await SaveTemplateDialog.show(
      context,
      initialName: _nameController.text,
      templateType: templateType,
    );

    if (result != null && mounted) {
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveFoodAsTemplate(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingFood != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Food' : 'Add Food Manually'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                FoodSearchScreen.route(),
              );
              if (result != null) {
                Navigator.of(context).pop(result);
              }
            },
            icon: const Icon(Icons.search),
            tooltip: 'Search Food Database',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            tooltip: l10n.save_as_template,
            onPressed: _saveAsTemplate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveFood,
        icon: const Icon(Icons.check),
        label: Text(l10n.save),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ========== ESSENTIAL FIELDS (Always Visible) ==========
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Name - PRIMARY
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '${l10n.food_name} *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.restaurant),
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
                    const SizedBox(height: 16),

                    // Amount + Unit (side by side)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: l10n.amount,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required_error;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _unitController,
                            decoration: InputDecoration(
                              labelText: l10n.unit,
                              border: const OutlineInputBorder(),
                              hintText: 'serving, cup, g...',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required_error;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Calories - MOST IMPORTANT NUTRITION
                    TextFormField(
                      controller: _energyController,
                      decoration: InputDecoration(
                        labelText: l10n.energy_kcal,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.local_fire_department),
                        hintText: '0',
                        suffixText: 'kcal',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ========== MACROS (Always visible) ==========
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Macronutrients',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _proteinController,
                            decoration: InputDecoration(
                              labelText: l10n.protein_g,
                              border: const OutlineInputBorder(),
                              hintText: '0',
                              suffixText: 'g',
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
                            controller: _carbsController,
                            decoration: InputDecoration(
                              labelText: l10n.carbs_g,
                              border: const OutlineInputBorder(),
                              hintText: '0',
                              suffixText: 'g',
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
                            controller: _fatController,
                            decoration: InputDecoration(
                              labelText: l10n.fat_g,
                              border: const OutlineInputBorder(),
                              hintText: '0',
                              suffixText: 'g',
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
            ),

            const SizedBox(height: 12),

            // ========== DETAILED NUTRITION (Collapsed) ==========
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: Icon(Icons.science, color: Colors.grey.shade600),
                title: const Text('Detailed Nutrition'),
                subtitle: const Text('Fiber, Sugar, Sodium, etc.'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fiberController,
                                decoration: InputDecoration(
                                  labelText: l10n.fiber_g,
                                  border: const OutlineInputBorder(),
                                  hintText: '0',
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
                                controller: _sugarsController,
                                decoration: InputDecoration(
                                  labelText: l10n.sugars_g,
                                  border: const OutlineInputBorder(),
                                  hintText: '0',
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _saturatedFatController,
                                decoration: InputDecoration(
                                  labelText: l10n.saturated_fat_g,
                                  border: const OutlineInputBorder(),
                                  hintText: '0',
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
                                controller: _sodiumController,
                                decoration: InputDecoration(
                                  labelText: l10n.sodium_mg,
                                  border: const OutlineInputBorder(),
                                  hintText: '0',
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
            ),

            const SizedBox(height: 12),

            // ========== ADVANCED OPTIONS (Collapsed) ==========
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: Icon(Icons.tune, color: Colors.grey.shade600),
                title: const Text('Advanced Options'),
                subtitle: const Text(
                  'Food type, serving size, portion details',
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        // Entry Type
                        DropdownButtonFormField<FoodEntryType>(
                          value: _entryType == FoodEntryType.recipe
                              ? FoodEntryType.manualCustom
                              : _entryType,
                          decoration: InputDecoration(
                            labelText: l10n.entry_type,
                            border: const OutlineInputBorder(),
                          ),
                          items: FoodEntryType.values
                              .where((type) => type != FoodEntryType.recipe)
                              .map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getEntryTypeLabel(type)),
                                );
                              })
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _entryType = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Brand (conditional)
                        if (_entryType == FoodEntryType.brandedProduct) ...[
                          TextFormField(
                            controller: _brandController,
                            decoration: InputDecoration(
                              labelText: l10n.brand_name,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: l10n.description,
                            border: const OutlineInputBorder(),
                            hintText: l10n.description_hint,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),

                        // Serving Size
                        TextFormField(
                          controller: _servingSizeController,
                          decoration: InputDecoration(
                            labelText: l10n.serving_size,
                            border: const OutlineInputBorder(),
                            suffixText: 'g',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Portion Reference
                        TextFormField(
                          controller: _portionReferenceController,
                          decoration: InputDecoration(
                            labelText: l10n.portion_reference,
                            border: const OutlineInputBorder(),
                            hintText: l10n.portion_reference_hint,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Portion Method
                        DropdownButtonFormField<PortionEstimationMethod>(
                          value: _portionMethod,
                          decoration: InputDecoration(
                            labelText: l10n.portion_estimation_method,
                            border: const OutlineInputBorder(),
                          ),
                          items: PortionEstimationMethod.values.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(_getPortionMethodLabel(method)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _portionMethod = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Portion State
                        DropdownButtonFormField<PortionState>(
                          value: _portionState,
                          decoration: InputDecoration(
                            labelText: l10n.portion_state,
                            border: const OutlineInputBorder(),
                          ),
                          items: PortionState.values.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(_getPortionStateLabel(state)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _portionState = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Yield & Edible Portion
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _yieldFactorController,
                                decoration: InputDecoration(
                                  labelText: l10n.yield_factor,
                                  border: const OutlineInputBorder(),
                                  hintText: l10n.yield_factor_hint,
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
                                controller: _ediblePortionController,
                                decoration: InputDecoration(
                                  labelText: l10n.edible_portion,
                                  border: const OutlineInputBorder(),
                                  hintText: l10n.edible_portion_hint,
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
            ),

            // Bottom padding for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
