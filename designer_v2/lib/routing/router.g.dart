// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerHash() => r'4823ca87e814f1c807b04a0e6bdfbd55462ee325';

/// How to create a new page & use it for navigation:
///
/// 1. Add the [GoRoute] in router_config.dart and register it as
/// a [RouterConf.topLevelRoute] (most likely it should be a top-level
/// route, unless you know what you are doing with subroutes)
///
/// 2. To navigate to the new route from your code, specify one or more
/// [RoutingIntent]s in router_intent.dart. These intents correspond to
/// route changes in the app. See router_intent.dart for more details.
///
/// Copied from [router].
@ProviderFor(router)
final routerProvider = AutoDisposeProvider<GoRouter>.internal(
  router,
  name: r'routerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
