class Config {
  static const isDebugMode = false;

  static const defaultLocale = {'en', 'US'};

  static const supportedLocales = {
    'en': 'US',
    'de': 'DE',
  };

  /// Default id for new studies that haven't been saved yet
  static const newStudyId = 'new';

  static const newModelId = 'new';

  /// Number of milliseconds the splash screen should be displayed at minimum
  /// Set to 0 to avoid displaying the splash screen any longer than necessary
  /// (may result in the splash screen not being shown at all)
  static const minSplashTime = 0;

  static const formAutosaveDebounce = 1000;
}

const kPathSeparator = '   /   ';
const kDuplicateLabel = "Copy"; // .hardcoded
