import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension RouterConvencienceX on GoRouter {
  get currentPath => routerDelegate.currentConfiguration.path;

  bool isOn(String routeName) {
    return namedLocation(routeName) == currentPath;
  }
}

mixin GoRouteParamEnum {
  String toRouteParam() {
    return toShortString();
  }

  String toShortString() {
    return toString().split('.').last;
  }
}

RouteSettings readCurrentRouteSettingsFrom(BuildContext context) {
  late final currentRouteSettings;
  Navigator.popUntil(context, (route) {
    currentRouteSettings = route.settings;
    //_currentRoute = route.settings.name;
    return true; // don't pop anything
  });
  return currentRouteSettings;
}
