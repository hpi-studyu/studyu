import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/services/medication_barcode_parser.dart';
import 'package:studyu_app/widgets/questionnaire/barcode_scanner_screen.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class const MedicationQuestionWidget({
  required final MedicationQuestion question,
  required final void Function(Answer<MedicationAnswer>) onDone,
  final Answer<MedicationAnswer>? initialAnswer,
  final VoidCallback? onCleared,
  final Future<List<MedicationProductSnapshot>> Function(String)? nameSearch,
  final Future<MedicationProductSnapshot?> Function(String)? exactLookup,
  final Future<Barcode?> Function()? scanBarcode,
  final Duration debounceDuration = const Duration(milliseconds: 300),
  super.key,
}) extends QuestionWidget {
  static Future<List<MedicationProductSnapshot>> Function(String)
  defaultNameSearch = MedicationCatalog.searchByName;
  static Future<MedicationProductSnapshot?> Function(String)
  defaultExactLookup = MedicationCatalog.lookupByPzn;
  static BuildContext? _scannerContext;
  static Future<Barcode?> Function() defaultScanBarcode = _openScanner;

  static Future<Barcode?> _openScanner() async {
    final context = _scannerContext;
    if (context == null || !context.mounted) return null;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return null;

    return await Navigator.of(context).push<Barcode>(
      MaterialPageRoute(
        builder: (_) => BarcodeScannerScreen(
          title: l10n.medicationScanTitle,
          description: l10n.medicationScanDescription,
          formats: const [BarcodeFormat.code39, BarcodeFormat.dataMatrix],
        ),
      ),
    );
  }

  @override
  State<MedicationQuestionWidget> createState() =>
      _MedicationQuestionWidgetState();
}

enum _MedicationSearchState() {
  idle,
  needMoreCharacters,
  loading,
  noResults,
  error,
  scanNothingFound,
}

enum _MedicationRequestKind() {
  name,
  exact,
}

class _MedicationQuestionWidgetState() extends State<MedicationQuestionWidget> {
  static final RegExp _quantityPattern = RegExp(r'^\d*[.,]?\d*$');
  static final RegExp _normalizationDiscardPattern = RegExp(
    r'[^\p{L}\p{N} ]',
    unicode: true,
  );
  static final RegExp _whitespacePattern = RegExp(r'\s+');

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Timer? _debounce;
  int _requestSequence = 0;
  MedicationProductSnapshot? _selectedMedication;
  List<MedicationProductSnapshot> _results = const [];
  _MedicationSearchState _searchState = _MedicationSearchState.idle;
  _MedicationRequestKind? _lastRequestKind;
  String? _lastRequestQuery;
  bool _quantityTouched = false;

  @override
  void initState() {
    super.initState();
    final initialAnswer = widget.initialAnswer?.response;
    if (initialAnswer != null) {
      _selectedMedication = initialAnswer.medication;
      _quantityController.text = initialAnswer.quantity.toString();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String _normalizeName(String value) {
    return value
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(_normalizationDiscardPattern, '')
        .replaceAll(_whitespacePattern, ' ')
        .trim();
  }

  num? get _quantity {
    final value = _quantityController.text.replaceAll(',', '.');
    final quantity = num.tryParse(value);
    if (quantity == null || !quantity.isFinite || quantity <= 0) return null;
    return quantity;
  }

  bool get _hasValidQuantity => _quantity != null;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    final sequence = ++_requestSequence;
    final exactPzn = pznFromManualInput(value);
    if (exactPzn != null) {
      _discardSelectionForReselection();
      _lookupPzn(exactPzn, sequence);
      return;
    }

    final normalized = _normalizeName(value);
    if (normalized.length < 2) {
      _discardSelectionForReselection();
      setState(() {
        _results = const [];
        _lastRequestKind = null;
        _lastRequestQuery = null;
        _searchState = value.trim().isEmpty
            ? _MedicationSearchState.idle
            : _MedicationSearchState.needMoreCharacters;
      });
      return;
    }

    _discardSelectionForReselection();
    _debounce = Timer(widget.debounceDuration, () {
      _searchByName(value, sequence);
    });
  }

  void _discardSelectionForReselection() {
    if (_selectedMedication == null) return;
    setState(() {
      _selectedMedication = null;
      _quantityController.clear();
      _quantityTouched = false;
    });
    widget.onCleared?.call();
  }

  Future<void> _lookupPzn(String pzn, int sequence) async {
    setState(() {
      _searchState = _MedicationSearchState.loading;
      _results = const [];
      _lastRequestKind = _MedicationRequestKind.exact;
      _lastRequestQuery = pzn;
    });

    try {
      final result =
          await (widget.exactLookup ??
              MedicationQuestionWidget.defaultExactLookup)(pzn);
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _results = result == null ? const [] : [result];
        _searchState = result == null
            ? _MedicationSearchState.noResults
            : _MedicationSearchState.idle;
      });
    } catch (_) {
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _results = const [];
        _searchState = _MedicationSearchState.error;
      });
    }
  }

  Future<void> _searchByName(String query, int sequence) async {
    if (!mounted || sequence != _requestSequence) return;
    setState(() {
      _searchState = _MedicationSearchState.loading;
      _results = const [];
      _lastRequestKind = _MedicationRequestKind.name;
      _lastRequestQuery = query;
    });

    try {
      final results =
          await (widget.nameSearch ??
              MedicationQuestionWidget.defaultNameSearch)(query);
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _results = results.take(20).toList(growable: false);
        _searchState = _results.isEmpty
            ? _MedicationSearchState.noResults
            : _MedicationSearchState.idle;
      });
    } catch (_) {
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _results = const [];
        _searchState = _MedicationSearchState.error;
      });
    }
  }

  void _retrySearch() {
    final kind = _lastRequestKind;
    final query = _lastRequestQuery;
    if (kind == null || query == null) return;

    final sequence = ++_requestSequence;
    switch (kind) {
      case _MedicationRequestKind.name:
        _searchByName(query, sequence);
      case _MedicationRequestKind.exact:
        _lookupPzn(query, sequence);
    }
  }

  Future<void> _scanMedicationCode() async {
    try {
      final barcode =
          await (widget.scanBarcode ??
              MedicationQuestionWidget.defaultScanBarcode)();
      if (!mounted || barcode == null) return;

      final pzn = pznFromBarcode(barcode);
      _discardSelectionForReselection();
      if (pzn == null) {
        setState(() {
          _results = const [];
          _lastRequestKind = null;
          _lastRequestQuery = null;
          _searchState = _MedicationSearchState.scanNothingFound;
        });
        return;
      }

      _searchController.text = pzn;
      _lookupPzn(pzn, ++_requestSequence);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _searchState = _MedicationSearchState.error;
      });
    }
  }

  void _selectMedication(MedicationProductSnapshot medication) {
    final didChangeProduct = _selectedMedication?.pzn != medication.pzn;
    setState(() {
      _selectedMedication = medication;
      _results = const [];
      _searchState = _MedicationSearchState.idle;
      if (didChangeProduct) {
        _quantityController.clear();
        _quantityTouched = true;
      }
    });
    if (didChangeProduct && widget.initialAnswer != null) {
      widget.onCleared?.call();
    }
  }

  void _clearSelection() {
    _debounce?.cancel();
    ++_requestSequence;
    setState(() {
      _selectedMedication = null;
      _results = const [];
      _searchState = _MedicationSearchState.idle;
      _lastRequestKind = null;
      _lastRequestQuery = null;
      _quantityController.clear();
      _quantityTouched = false;
      _searchController.clear();
    });
    widget.onCleared?.call();
  }

  void _confirmSelection() {
    final medication = _selectedMedication;
    final quantity = _quantity;
    if (medication == null || quantity == null) {
      setState(() => _quantityTouched = true);
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onDone(
      widget.question.constructAnswer(
        MedicationAnswer(medication: medication, quantity: quantity),
      ),
    );
  }

  String _ingredientText(MedicationProductSnapshot medication) {
    return medication.components
        .expand((component) => component.activeIngredients)
        .map(
          (ingredient) =>
              ingredient.strength == null || ingredient.strength!.isEmpty
              ? ingredient.name
              : '${ingredient.name} ${ingredient.strength}',
        )
        .join(', ');
  }

  Widget _buildResultTile(MedicationProductSnapshot medication) {
    final dosageForm = medication.dosageForm.patientFriendlyShort;
    final ingredients = _ingredientText(medication);
    final details = <String>[
      if (dosageForm != null && dosageForm.isNotEmpty) dosageForm,
      if (ingredients.isNotEmpty) ingredients,
      'PZN ${medication.pzn}',
    ];

    return ListTile(
      key: ValueKey('medication_result_${medication.pzn}'),
      contentPadding: EdgeInsets.zero,
      title: Text(medication.officialName),
      subtitle: Text(details.join('\n')),
      isThreeLine: details.length > 1,
      onTap: () => _selectMedication(medication),
    );
  }

  Widget _buildSearchFeedback(AppLocalizations l10n) {
    switch (_searchState) {
      case _MedicationSearchState.idle:
        if (_results.isEmpty) return const SizedBox.shrink();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (_, index) => _buildResultTile(_results[index]),
          separatorBuilder: (_, _) => const Divider(height: 1),
        );
      case _MedicationSearchState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      case _MedicationSearchState.needMoreCharacters:
        return _SearchMessage(message: l10n.medicationSearchNeedMoreChars);
      case _MedicationSearchState.noResults:
        return _SearchMessage(message: l10n.medicationSearchNoResults);
      case _MedicationSearchState.scanNothingFound:
        return _SearchMessage(message: l10n.medicationScanNothingFound);
      case _MedicationSearchState.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchMessage(message: l10n.medicationSearchError),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _retrySearch,
              child: Text(l10n.medicationRetry),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    MedicationQuestionWidget._scannerContext = context;
    final l10n = AppLocalizations.of(context)!;
    final medication = _selectedMedication;
    final dosageForm = medication?.dosageForm.patientFriendlyShort;
    final showQuantityError =
        medication != null && _quantityTouched && !_hasValidQuantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.medicationSearchHint,
            suffixIcon: IconButton(
              tooltip: l10n.medicationScanButtonTooltip,
              onPressed: _scanMedicationCode,
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 8),
        _buildSearchFeedback(l10n),
        if (medication != null) ...[
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.officialName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('PZN ${medication.pzn}'),
                  if (dosageForm != null && dosageForm.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(dosageForm),
                  ],
                  if (_ingredientText(medication).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_ingredientText(medication)),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _clearSelection,
                      child: Text(l10n.medicationClearSelection),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            key: const ValueKey('medication_quantity'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                return _quantityPattern.hasMatch(newValue.text)
                    ? newValue
                    : oldValue;
              }),
            ],
            decoration: InputDecoration(
              labelText: dosageForm == null || dosageForm.isEmpty
                  ? l10n.medicationQuantityLabel
                  : '${l10n.medicationQuantityLabel} ($dosageForm)',
              errorText: showQuantityError
                  ? l10n.medicationQuantityInvalid
                  : null,
            ),
            onChanged: (_) {
              setState(() => _quantityTouched = true);
            },
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _hasValidQuantity ? _confirmSelection : null,
            child: Text(l10n.medicationConfirm),
          ),
        ],
      ],
    );
  }
}

class const _SearchMessage({required final String message})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(message),
  );
}
