import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String localeName(BuildContext context, String countryCode) {
  final localeStrings = {
    'en': AppLocalizations.of(context).en,
    'de': AppLocalizations.of(context).de,
  };
  return localeStrings[countryCode];
}
