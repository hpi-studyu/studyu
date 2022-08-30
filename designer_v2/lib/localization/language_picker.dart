import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/localization/locale_translate_name.dart';
import 'package:studyu_designer_v2/utils/font.dart';

class LanguagePicker extends ConsumerStatefulWidget {
  const LanguagePicker({Key? key}) : super(key: key);

  @override
  ConsumerState<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends ConsumerState<LanguagePicker> {
  late final FormGroup localeForm = FormGroup({
    'localization': FormControl<Locale>(
      value: ref.watch(localeProvider),
      validators: [Validators.required],
    ),
  });

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(localeStateProvider.notifier);

    return ReactiveForm(
      formGroup: localeForm,
      child: ReactiveDropdownField<Locale>(
        formControlName: 'localization',
        isExpanded: true,
        items: _buildLanguageOptions(context),
        icon: const Icon(Icons.language),
        onChanged: (locale) => controller.setLocale(locale.value!),
      ),
    );
  }

  _buildLanguageOptions(BuildContext context) {
    List<DropdownMenuItem<Locale>> options = [];

    Config.supportedLocales.forEach((languageCode, countryCode) {
      final locale = Locale(languageCode, countryCode);
      options.add(DropdownMenuItem(
        value: locale,
        child: Text('${getEmojiFlag(countryCode)} '
            '${translateLocaleName(locale: locale)}'),
      ));
    });

    return options;
  }
}
