import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';

// Use global variable tr for translation
AppLocalizations get tr => _tr!;
late AppLocalizations? _tr;

class AppTranslation {
  static Future<void> init(WidgetRef ref) async {
    // Loads the currently selected locale from localeProvider and sets the localization
    _tr = await AppLocalizations.delegate.load(ref.watch(localeProvider));
  }
}

typedef LocalizedStringResolver = String Function();
