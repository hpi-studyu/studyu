import 'dart:ui';

String translateLocaleName({required Locale locale}) {
  switch (locale.toLanguageTag()) {
    case ("de-DE"):
      {
        return "Deutsch";
      }
    case ("en-US"):
      {
        return "English";
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

