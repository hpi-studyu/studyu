import 'package:flutter/material.dart';

/// https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/material_state.dart
/// TODO: remove with new flutter version

/// Manages a set of [MaterialState]s and notifies listeners of changes.
///
/// Used by widgets that expose their internal state for the sake of
/// extensions that add support for additional states. See
/// [TextButton.statesController] for example.
///
/// The controller's [value] is its current set of states. Listeners
/// are notified whenever the [value] changes. The [value] should only be
/// changed with [update]; it should not be modified directly.
class MaterialStatesController extends ValueNotifier<Set<MaterialState>> {
  /// Creates a MaterialStatesController.
  MaterialStatesController([Set<MaterialState>? value]) : super(<MaterialState>{...?value});

  /// Adds [state] to [value] if [add] is true, and removes it otherwise,
  /// and notifies listeners if [value] has changed.
  void update(MaterialState state, bool add) {
    final bool valueChanged = add ? value.add(state) : value.remove(state);
    if (valueChanged) {
      notifyListeners();
    }
  }
}
