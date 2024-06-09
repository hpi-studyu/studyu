import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/theme.dart';

extension RouterConvencienceX on GoRouter {
  String get currentPath => routerDelegate.currentConfiguration.fullPath;

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
  late final RouteSettings currentRouteSettings;
  Navigator.popUntil(context, (route) {
    currentRouteSettings = route.settings;
    //_currentRoute = route.settings.name;
    return true; // don't pop anything
  });
  return currentRouteSettings;
}

CustomTransitionPage<void> buildModalTransitionPage(BuildContext context, GoRouterState state, Widget body) {
  final theme = Theme.of(context);

  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: body,
    opaque: false,
    barrierColor: ThemeConfig.modalBarrierColor(theme),
    barrierDismissible: true,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}
