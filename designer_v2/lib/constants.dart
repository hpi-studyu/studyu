import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class Config {
  static const isDebugMode = true;

  /// Default id for new studies that haven't been saved yet
  static const newStudyId = 'new';

  static const newModelId = 'new';

  /// Number of milliseconds the splash screen should be displayed at minimum
  /// Set to 0 to avoid displaying the splash screen any longer than necessary
  /// (may result in the splash screen not being shown at all)
  static const minSplashTime = 500;
}

const kPathSeparator = '   /   ';
const kDuplicateLabel = "Copy"; // .hardcoded
