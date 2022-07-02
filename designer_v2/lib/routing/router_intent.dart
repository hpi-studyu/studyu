import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

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
        RouteParams.studiesFilter: StudiesFilter.all.toShortString(),
      }
  );
  static final studyEdit = (StudyID studyId) => RoutingIntent(
      route: RouterConfig.studyEdit,
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
}

typedef RoutingIntentFactory = RoutingIntent Function(String);

/// Encapsulates a call to [GoRouter.goNamed]
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
  void dispatch(RoutingIntent intent) {
    goNamed(intent.route.name!, params: intent.params,
        queryParams:intent.queryParams, extra: intent.extra);
  }
}
