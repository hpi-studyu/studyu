import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/main_page_scaffold_state.dart';

class LocalizationController extends StateNotifier<LocalizationState> {
  LocalizationController({this.sharedLoc}) : super(LocalizationState());

  init() {
    print(sharedLoc ?? "Null");
    // Initialize localization with shared_pref value or set default
    setLocalization(sharedLoc ?? state.defaultLocalization);
    print("Set localization to: " + getLocalization.displayName);
  }

  final Localization? sharedLoc;

  static const String locPrefKey = 'lang';

  final locForm = FormGroup({
    'localization': FormControl<Localization>(validators: [Validators.required]),
  });

  Localization get getLocalization => locForm.control('localization').value;

  setLocalization(Localization newLoc) {
    locForm.control('localization').value = newLoc;
    _saveLocalization();
  }

  // async?
  _saveLocalization() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(locPrefKey, getLocalization.regional.name);
    });
  }
}

final localizationProvider = FutureProvider<Localization?>((_) async => SharedPreferences.getInstance().then((prefs) {
  const String locPrefKey = LocalizationController.locPrefKey;
  Regional selectedLang;
  Localization? selectedLoc;

  String? locString = prefs.getString(locPrefKey);
  if (locString != null) {
    selectedLang = Regional.values.byName(locString);
    selectedLoc = Localization.values.firstWhere((localization) => localization.regional == selectedLang);
    return selectedLoc;
  } else {
    return null;
  }
}));

final mainPageControllerProvider = StateNotifierProvider.autoDispose<LocalizationController, LocalizationState>((ref) {
  final prefLocalization = ref.watch(localizationProvider);
  return prefLocalization.when(
    data: (value) {
      final mainPageController = LocalizationController(sharedLoc: value);
      mainPageController.init();
      return mainPageController;
    },
    loading: () => LocalizationController(),
    error: (Object error, StackTrace? stackTrace) {
      final mainPageController = LocalizationController(sharedLoc: null);
      mainPageController.init();
      return mainPageController;
      },
  );
});
