import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/locale_translate_name.dart';
import 'package:studyu_designer_v2/utils/font.dart';

enum LanguagePickerType { field, icon }

class LanguagePicker extends ConsumerStatefulWidget {
  const LanguagePicker({
    super.key,
    this.languagePickerType = LanguagePickerType.field,
    this.iconColor,
    this.offset,
  });

  final LanguagePickerType languagePickerType;
  final Color? iconColor;
  final Offset? offset;

  @override
  ConsumerState<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends ConsumerState<LanguagePicker> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(localeStateProvider.notifier);
    final currentLocalization = ref.watch(localeProvider.select((value) => value));
    switch (widget.languagePickerType) {
      case LanguagePickerType.field:
        final FormGroup localeForm = FormGroup({
          'localization': FormControl<Locale>(
            validators: [Validators.required],
            value: currentLocalization,
          ),
        });
        return SizedBox(
            width: 250,
            child: ReactiveForm(
              formGroup: localeForm,
              child: ReactiveDropdownField<Locale>(
                formControlName: 'localization',
                //isExpanded: false,
                //isDense: true,
                items: _buildLanguageOptionsField(context),
                icon: Icon(Icons.language, color: widget.iconColor),
                onChanged: (locale) => controller.setLocale(locale.value!),
              ),
            ));
      case LanguagePickerType.icon:
        return PopupMenuButton<Locale>(
          tooltip: tr.language_select_tooltip,
          offset: widget.offset ?? Offset.zero,
          position: PopupMenuPosition.over,
          icon: Icon(Icons.language, color: widget.iconColor),
          itemBuilder: (BuildContext context) {
            return _buildLanguageOptionsIcon(context);
          },
          onSelected: (locale) => controller.setLocale(locale),
        );
    }
  }

  _buildLanguageOptionsIcon(BuildContext context) {
    List<PopupMenuItem<Locale>> options = [];
    Config.supportedLocales.forEach((languageCode, countryCode) {
      final locale = Locale(languageCode, countryCode);
      options.add(PopupMenuItem(
        value: locale,
        child: Text('${getEmojiFlag(countryCode)}  ${translateLocaleName(locale: locale)}'),
      ));
    });
    return options;
  }

  _buildLanguageOptionsField(BuildContext context) {
    List<DropdownMenuItem<Locale>> options = [];
    Config.supportedLocales.forEach((languageCode, countryCode) {
      final locale = Locale(languageCode, countryCode);
      options.add(DropdownMenuItem(
        value: locale,
        child: Text('${getEmojiFlag(countryCode)} ${translateLocaleName(locale: locale)}'),
      ));
    });
    return options;
  }
}
