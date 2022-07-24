import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

/// Full list of routing events used across the app.
///
/// Each [RoutingIntent] represents a call to [GoRouter.goNamed] and can be
/// dispatched through a [GoRouter] reference like so:
///
///   final router = ref.read(routerProvider) // get router ref via riverpod
///   router.dispatch(RoutingIntents.someIntent)
///
/// For parametrized routes, consider using [RoutingIntentFactory] instead.
///
/// Some guidelines:
/// - If your route has a parameter that takes a fixed set of values, you
/// probably want to specify multiple [RoutingIntent]s (one for each value)
/// - If your route has a parameter that takes an infinite range of values,
/// your [RoutingIntent] should be a [RoutingIntentFactory] instead.
///
class RoutingIntents {
  static final studies = RoutingIntent(
      route: RouterConfig.studies,
  );
  static final studiesShared = RoutingIntent(
      route: RouterConfig.studies,
      queryParams: {
        RouteParams.studiesFilter: StudiesFilter.shared.toShortString(),
      }
  );
  static final publicRegistry = RoutingIntent(
      route: RouterConfig.studies,
      queryParams: {
        RouteParams.studiesFilter: StudiesFilter.public.toShortString(),
      }
  );
  static final studyEdit = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyEdit,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyEditInfo = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyEditInfo,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyEditEnrollment = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyEditEnrollment,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyEditInterventions = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyEditInterventions,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyEditMeasurements = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyEditMeasurements,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyTest = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyTest,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyRecruit = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyRecruit,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyMonitor = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyMonitor,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyAnalyze = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyAnalyze,
      params: {
        RouteParams.studyId: studyId,
      }
  );
  static final studyNew = studyEdit(Config.newStudyId);
  static final error = (Exception error) => RoutingIntent(
      route: RouterConfig.error,
      extra: error,
  );
}

/// Signature for a function that returns a [RoutingIntent]
/// Helpful for parametrized routes with an infinite or indeterminate range of values
typedef RoutingIntentFactory = RoutingIntent Function(String);

/// Represent a unique routing event in the app, encapsulating a call to
/// [GoRouter.goNamed]. The intent is unpacked & results in a route change
/// when calling [GoRouter.dispatch].
class RoutingIntent extends Equatable {
  RoutingIntent({
    required this.route,
    this.params = const <String, String>{},
    this.queryParams = const <String, String>{},
    this.extra,
  }) {
    _validateRoute();
  }

  final GoRoute route;
  final Map<String,String> params;
  final Map<String,String> queryParams;
  final Object? extra;

  String get routeName => route.name!;
  Map<String,String> get arguments => {...params, ...queryParams};

  _validateRoute() {
    if (route.name == null) {
      throw Exception("Failed to declare RoutingIntent for Route "
          "(path=${route.path}) because Route.name is not defined");
    }
  }

  bool matches(RouteSettings settings) {
    if (settings.name != route.name) {
      return false;
    }
    if (settings.arguments is! Map) {
      return false;
    }
    if (!mapEquals(settings.arguments as Map, arguments)) {
      return false;
    }
    return true;
  }

  // - Equatable

  @override
  List<Object?> get props => [route, params, queryParams, extra];
}

extension GoRouterX on GoRouter {
  /// Transforms a [RoutingIntent] into a call to [goNamed]
  void dispatch(RoutingIntent intent) {
    goNamed(intent.route.name!, params: intent.params,
        queryParams:intent.queryParams, extra: intent.extra);
  }
}
