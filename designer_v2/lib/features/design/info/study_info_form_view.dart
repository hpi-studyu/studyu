import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_country_selector/flutter_country_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:phone_numbers_parser/metadata.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyDesignInfoFormView extends StudyDesignPageWidget {
  const StudyDesignInfoFormView(super.studyId, {super.key});

  static const _singleLineFieldHeight = 56.0;
  static const _studyTitleMaxLength = 100;
  static const _studyDescriptionMaxLength = 500;
  static const _contactFieldMaxLength = 100;
  static const _websiteMaxLength = 300;
  static const _additionalInfoMaxLength = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(
          studyInfoFormViewModelProvider(studyId),
        );
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(text: tr.form_study_design_info_description),
              const SizedBox(height: 24.0),
              FormTableLayout(
                rows: [
                  FormTableRow(
                    control: formViewModel.titleControl,
                    label: tr.form_field_study_title,
                    labelHelpText: tr.form_field_study_title_tooltip,
                    input: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: responsive layout (input field gets too small)
                        Expanded(
                          child: _CharacterCountTextField(
                            formControl: formViewModel.titleControl,
                            hintText: tr.form_field_study_title,
                            maxLength: _studyTitleMaxLength,
                            validationMessages:
                                formViewModel.titleControl.validationMessages,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        ReactiveValueListenableBuilder<IconOption>(
                          formControl: formViewModel.iconControl,
                          builder: (context, control, child) {
                            return SizedBox(
                              height: StudyDesignInfoFormView
                                  ._singleLineFieldHeight,
                              child: Align(
                                child: IntrinsicWidth(
                                  child: ReactiveIconPicker(
                                    formControl: formViewModel.iconControl,
                                    iconOptions: IconPack.material,
                                    selectedIconSize: 24.0,
                                    validationMessages: formViewModel
                                        .iconControl
                                        .validationMessages,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.descriptionControl,
                    label: tr.form_field_study_description,
                    labelHelpText: tr.form_field_study_description_tooltip,
                    input: _CharacterCountTextField(
                      formControl: formViewModel.descriptionControl,
                      hintText: tr.form_field_study_description_hint,
                      maxLength: _studyDescriptionMaxLength,
                      validationMessages:
                          formViewModel.descriptionControl.validationMessages,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 5,
                    ),
                  ),
                ],
                columnWidths: const {
                  0: FixedColumnWidth(185.0),
                  1: FlexColumnWidth(),
                },
              ),
              const SizedBox(height: 32.0),
              FormSectionHeader(title: tr.form_section_publisher),
              const SizedBox(height: 12.0),
              TextParagraph(text: tr.form_section_publisher_description),
              const SizedBox(height: 24.0),
              FormTableLayout(
                rows: [
                  FormTableRow(
                    control: formViewModel.organizationControl,
                    label: tr.form_field_organization,
                    input: _CharacterCountTextField(
                      formControl: formViewModel.organizationControl,
                      hintText: tr.form_field_organization,
                      maxLength: _contactFieldMaxLength,
                      validationMessages:
                          formViewModel.organizationControl.validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.reviewBoardControl,
                    label: tr.form_field_review_board,
                    input: _CharacterCountTextField(
                      formControl: formViewModel.reviewBoardControl,
                      hintText: tr.form_field_review_board,
                      maxLength: _contactFieldMaxLength,
                      validationMessages:
                          formViewModel.reviewBoardControl.validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.reviewBoardNumberControl,
                    label: tr.form_field_review_board_number,
                    input: _CharacterCountTextField(
                      formControl: formViewModel.reviewBoardNumberControl,
                      hintText: tr.form_field_review_board_number,
                      maxLength: _contactFieldMaxLength,
                      validationMessages: formViewModel
                          .reviewBoardNumberControl
                          .validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.researchersControl,
                    label: tr.form_field_researchers,
                    input: _CharacterCountTextField(
                      formControl: formViewModel.researchersControl,
                      hintText: tr.form_field_researchers,
                      maxLength: _contactFieldMaxLength,
                      validationMessages:
                          formViewModel.researchersControl.validationMessages,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.websiteControl,
                    label: tr.form_field_website,
                    input: ReactiveValueListenableBuilder<String>(
                      formControl: formViewModel.websiteControl,
                      builder: (context, control, child) {
                        final showUnsavedWarning =
                            control.invalid && control.dirty;

                        return ReactiveTextField(
                          formControl: formViewModel.websiteControl,
                          decoration: InputDecoration(
                            hintText: tr.form_field_website,
                            helperText: showUnsavedWarning
                                ? tr.sync_dirty
                                : null,
                          ),
                          maxLength: _websiteMaxLength,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(_websiteMaxLength),
                          ],
                          showErrors: (control) =>
                              control.invalid && control.dirty,
                          validationMessages:
                              formViewModel.websiteControl.validationMessages,
                        );
                      },
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.emailControl,
                    label: tr.form_field_contact_email,
                    input: ReactiveValueListenableBuilder<String>(
                      formControl: formViewModel.emailControl,
                      builder: (context, control, child) {
                        final showUnsavedWarning =
                            control.invalid && control.dirty;

                        return ReactiveTextField(
                          formControl: formViewModel.emailControl,
                          decoration: InputDecoration(
                            hintText: tr.form_field_contact_email,
                            helperText: showUnsavedWarning
                                ? tr.sync_dirty
                                : null,
                          ),
                          maxLength: _contactFieldMaxLength,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                              _contactFieldMaxLength,
                            ),
                          ],
                          showErrors: (control) =>
                              control.invalid && control.dirty,
                          validationMessages:
                              formViewModel.emailControl.validationMessages,
                        );
                      },
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.phoneControl,
                    label: tr.form_field_contact_phone,
                    input: _SplitPhoneField(
                      formControl: formViewModel.phoneControl,
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.additionalInfoControl,
                    label: tr.form_field_contact_additional_info,
                    input: _CharacterCountTextField(
                      formControl: formViewModel.additionalInfoControl,
                      hintText: tr.form_field_contact_additional_info,
                      maxLength: _additionalInfoMaxLength,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 5,
                    ),
                  ),
                ],
                columnWidths: const {
                  0: FixedColumnWidth(180.0),
                  1: FlexColumnWidth(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CharacterCountTextField extends StatelessWidget {
  const _CharacterCountTextField({
    required this.formControl,
    required this.hintText,
    required this.maxLength,
    this.validationMessages,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final FormControl<String> formControl;
  final String hintText;
  final int maxLength;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return ReactiveTextField(
      formControl: formControl,
      decoration: InputDecoration(hintText: hintText),
      maxLength: maxLength,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      validationMessages: validationMessages,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
    );
  }
}

class _SplitPhoneField extends StatefulWidget {
  const _SplitPhoneField({required this.formControl});

  final FormControl<String> formControl;

  @override
  State<_SplitPhoneField> createState() => _SplitPhoneFieldState();
}

class _SplitPhoneFieldState extends State<_SplitPhoneField> {
  static const _phoneValidationKey = 'phone';
  static const _countryMenuMaxHeight = 360.0;
  static const _countryMenuMinWidth = 280.0;

  late final PhoneController _phoneController;
  late final TextEditingController _nationalNumberController;
  late final FocusNode _focusNode;
  StreamSubscription<String?>? _controlSubscription;

  String _lastControlValue = '';
  bool _isSyncingControl = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    _phoneController = PhoneController(
      initialValue: _resolvePhoneNumber(widget.formControl.value),
    );
    _nationalNumberController = TextEditingController(
      text: _phoneController.value.formatNsn(),
    );
    _focusNode = FocusNode();
    _lastControlValue = widget.formControl.value?.trim() ?? '';
    _controlSubscription = widget.formControl.valueChanges.listen(
      _handleExternalControlChange,
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _controlSubscription?.cancel();
    if (_initialized) {
      _focusNode.dispose();
      _nationalNumberController.dispose();
      _phoneController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.formControl;
    final showError = control.invalid && control.dirty;
    final errorText = _resolveErrorText(control, showError);
    final maxPhoneLength = _resolveMaxPhoneLength(
      _phoneController.value.isoCode,
    );
    final currentPhoneLength = _phoneController.value.nsn.length;

    return TextField(
      controller: _nationalNumberController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: tr.form_field_contact_phone,
        helperText: showError ? tr.sync_dirty : null,
        errorText: errorText,
        counterText: '$currentPhoneLength/$maxPhoneLength',
        prefixIcon: _CountryPopupButton(
          isoCode: _phoneController.value.isoCode,
          countries: _sortedIsoCodes(context),
          onSelected: _handleCountryChanged,
        ),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        _PhoneDigitLengthFormatter(maxDigits: maxPhoneLength),
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
      ],
      onChanged: _handlePhoneChanged,
      onEditingComplete: () {
        _markControlInteracted();
        _focusNode.unfocus();
      },
      onTapOutside: (_) => _markControlInteracted(),
    );
  }

  List<IsoCode> _sortedIsoCodes(BuildContext context) {
    final countryLocalization =
        CountrySelectorLocalization.of(context) ??
        CountrySelectorLocalizationEn();
    final countries = IsoCode.values.toList();
    countries.sort(
      (left, right) => countryLocalization
          .countryName(left)
          .compareTo(countryLocalization.countryName(right)),
    );
    return countries;
  }

  void _handlePhoneChanged(String value) {
    if (_isSyncingControl) {
      return;
    }

    _phoneController.changeNationalNumber(value);
    _syncDisplayedNationalNumber();
    if (mounted) {
      setState(() {});
    }
    _markControlInteracted();
    final nextValue = _phoneController.value.nsn.trim().isEmpty
        ? ''
        : _phoneController.value.international;
    _setControlValue(nextValue);
  }

  void _handleCountryChanged(IsoCode isoCode) {
    _phoneController.changeCountry(isoCode);
    _syncDisplayedNationalNumber();
    if (mounted) {
      setState(() {});
    }
    _markControlInteracted();
    final nextValue = _phoneController.value.nsn.trim().isEmpty
        ? ''
        : _phoneController.value.international;
    _setControlValue(nextValue);
    _focusNode.requestFocus();
  }

  void _setControlValue(String value) {
    if (widget.formControl.value == value) {
      return;
    }

    _lastControlValue = value;
    widget.formControl.updateValue(value);
    widget.formControl.markAsDirty();
  }

  void _markControlInteracted() {
    widget.formControl.markAsTouched();
  }

  void _handleExternalControlChange(String? value) {
    final nextValue = value ?? '';
    if (_isSyncingControl || nextValue == _lastControlValue) {
      return;
    }

    _isSyncingControl = true;
    _phoneController.value = _resolvePhoneNumber(value);
    _syncDisplayedNationalNumber();
    _isSyncingControl = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _syncDisplayedNationalNumber() {
    final formattedNationalNumber = _phoneController.value.formatNsn();
    if (_nationalNumberController.text == formattedNationalNumber) {
      return;
    }
    _nationalNumberController.value = TextEditingValue(
      text: formattedNationalNumber,
      selection: TextSelection.collapsed(
        offset: formattedNationalNumber.length,
      ),
    );
  }

  PhoneNumber _resolvePhoneNumber(String? rawValue) {
    final trimmed = rawValue?.trim() ?? '';
    _lastControlValue = trimmed;

    if (trimmed.isEmpty) {
      return PhoneNumber(isoCode: _resolveInitialIsoCode(context), nsn: '');
    }

    try {
      return PhoneNumber.parse(trimmed);
    } catch (_) {
      return PhoneNumber(
        isoCode: _resolveInitialIsoCode(context),
        nsn: trimmed.replaceAll(RegExp(r'\D'), ''),
      );
    }
  }

  IsoCode _resolveInitialIsoCode(BuildContext context) {
    final countryCode = Localizations.localeOf(context).countryCode;
    if (countryCode == null) {
      return IsoCode.US;
    }

    try {
      return IsoCode.values.byName(countryCode.toUpperCase());
    } catch (_) {
      return IsoCode.US;
    }
  }

  int _resolveMaxPhoneLength(IsoCode isoCode) {
    final lengths = metadataLenghtsByIsoCode[isoCode];
    final mobileLength = _lastLength(lengths?.mobile);
    final fixedLineLength = _lastLength(lengths?.fixedLine);

    return [mobileLength, fixedLineLength].fold<int>(0, (maxLength, length) {
      if (length > maxLength) {
        return length;
      }
      return maxLength;
    });
  }

  int _lastLength(List<int>? lengths) {
    if (lengths == null || lengths.isEmpty) {
      return 0;
    }
    return lengths.last;
  }

  String? _resolveErrorText(FormControl<String> control, bool showError) {
    if (!showError) {
      return null;
    }
    if (control.hasError(ValidationMessage.required)) {
      return tr.form_field_contact_phone_required;
    }
    if (control.hasError(_phoneValidationKey)) {
      return tr.form_invalid_prompt;
    }
    return tr.form_invalid_prompt;
  }
}

class _CountryPopupButton extends StatelessWidget {
  const _CountryPopupButton({
    required this.isoCode,
    required this.countries,
    required this.onSelected,
  });

  final IsoCode isoCode;
  final List<IsoCode> countries;
  final ValueChanged<IsoCode> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countryLocalization =
        CountrySelectorLocalization.of(context) ??
        CountrySelectorLocalizationEn();
    final dialCode = countryLocalization.countryDialCode(isoCode);

    return PopupMenuButton<IsoCode>(
      initialValue: isoCode,
      tooltip: tr.form_field_contact_phone,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(
        minWidth: _SplitPhoneFieldState._countryMenuMinWidth,
        maxHeight: _SplitPhoneFieldState._countryMenuMaxHeight,
      ),
      itemBuilder: (context) {
        return countries.map((country) {
          final isSelected = country == isoCode;
          return PopupMenuItem<IsoCode>(
            value: country,
            child: Row(
              children: [
                Text(_emojiFlag(country), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    countryLocalization.countryName(country),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text('+${countryLocalization.countryDialCode(country)}'),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
                ],
              ],
            ),
          );
        }).toList();
      },
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emojiFlag(isoCode), style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text('+$dialCode', style: theme.textTheme.bodyLarge),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  static String _emojiFlag(IsoCode isoCode) {
    final codeUnits = isoCode.name.toUpperCase().codeUnits;
    return String.fromCharCodes(codeUnits.map((codeUnit) => codeUnit + 127397));
  }
}

class _PhoneDigitLengthFormatter extends TextInputFormatter {
  const _PhoneDigitLengthFormatter({required this.maxDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxDigits <= 0) {
      return newValue;
    }

    final digitCount = newValue.text.replaceAll(RegExp(r'\D'), '').length;
    if (digitCount > maxDigits) {
      return oldValue;
    }

    return newValue;
  }
}
