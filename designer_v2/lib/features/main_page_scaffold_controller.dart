
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/main_page_scaffold_state.dart';

class MainPageController extends StateNotifier<MainPageState> {
  MainPageController(this.sharedLoc) : super(MainPageState()) {
    state.selectedLocalization = sharedLoc ?? state.defaultLocalization;
  }

  final Localization? sharedLoc;

  static const String locPrefKey = 'lang';

  setLocalization(Localization newLoc) {
    state.selectedLocalization = newLoc;
    _saveLocalization();
  }

  Localization get getLocalization => state.selectedLocalization;

  _saveLocalization() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(locPrefKey, state.selectedLocalization.regional.name);
    });
  }
}

final localizationProvider = FutureProvider<Localization?>((_) async => await SharedPreferences.getInstance().then((prefs) {
  const String locPrefKey = MainPageController.locPrefKey;
  Regional selectedLang;
  Localization? selectedLoc;

  String? locString = prefs.getString(locPrefKey);
  if (locString != null) {
    selectedLang = Regional.values.byName(locString);
    selectedLoc =
        Localization.values.firstWhere((localization) =>
        localization
            .regional == selectedLang);
    return selectedLoc;
  }
}));

final mainPageControllerProvider =
StateNotifierProvider.autoDispose<MainPageController, MainPageState>((ref) {
  final pref = ref.watch(localizationProvider).maybeWhen(
    data: (value) => value,
    orElse: () => null,
  );
  return MainPageController(pref);
});
