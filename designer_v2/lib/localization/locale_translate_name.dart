import 'dart:ui';

import 'package:studyu_designer_v2/localization/app_translation.dart';

String translateLocaleName({required Locale locale}) {
  switch (locale.toLanguageTag()) {
    case ("de-DE"):
      {
        return tr.locale_de;
      }
    case ("en-US"):
      {
        return tr.locale_en;
      }
    case ("es-ES"):
      {
        return "Español";
      }
    case ("fr-FR"):
      {
        return "Français";
      }
    case ("it-IT"):
      {
        return "Italiano";
      }
    case ("ja-JP"):
      {
        return "日本語";
      }
    case ("ko-KR"):
      {
        return "한국어";
      }
    case ("pt-BR"):
      {
        return "Português";
      }
    default:
      {
        return "N/A";
      }
  }
}

