import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'dashboard.dart';
import 'designer.dart';
import 'models/app_state.dart';
import 'widgets/login_page.dart';
import 'widgets/study_detail/notebook_viewer.dart';
import 'widgets/study_detail/study_details.dart';

/// Transforms String to Enum value. Dart does not have support for this (yet)
T enumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split('.').last == value, orElse: () => null);
}

extension ListGetExtension<T> on List<T> {
  T tryGet(int index) => index < 0 || index >= length ? null : this[index];
}

class RootRouteInformationParser extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);

    if (uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.first == DesignerPath.newPath) {
        return DesignerPath();
      }

      if (Uuid.isValidUUID(fromString: uri.pathSegments.first)) {
        final studyId = uri.pathSegments.first;

        if (uri.pathSegments.length >= 2 && uri.pathSegments[1].isNotEmpty) {
          switch (uri.pathSegments[1]) {
            case DesignerPath.basePath:
              final page = enumFromString<DesignerPage>(DesignerPage.values, uri.pathSegments.tryGet(2));
              // /:id/designer/:page
              return DesignerPath(studyId: studyId, page: page);
            case NotebookPath.basePath:
              if (uri.pathSegments.length >= 3 && uri.pathSegments[2].isNotEmpty) {
                // /:id/notebook/:notebook
                return NotebookPath(studyId: studyId, notebook: uri.pathSegments[2]);
              }
          }
        }

        return DetailsPath(studyId: studyId);
      }
    }

    return HomePath();
  }

  @override
  RouteInformation restoreRouteInformation(RoutePath configuration) {
    if (configuration is HomePath) {
      return const RouteInformation(location: '/');
    }
    if (configuration is DetailsPath) {
      var location = '/${configuration.studyId}';

      if (configuration is DesignerPath) {
        if (configuration.isNew) {
          location = '/${DesignerPath.newPath}';
        }

        location += '/${DesignerPath.basePath}';
        if (configuration.page != null) {
          location += '/${configuration.page.toString().split('.')[1]}';
        }
      } else if (configuration is NotebookPath) {
        location += '/${NotebookPath.basePath}';
        if (configuration.notebook != null) {
          location += '/${configuration.notebook}';
        }
      }
      return RouteInformation(location: location);
    }
    return null;
  }
}

class RootRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final AppState appState;

  RootRouterDelegate(this.appState) : navigatorKey = GlobalObjectKey<NavigatorState>(appState) {
    appState
      ..addListener(notifyListeners)
      ..registerAuthListener();
  }

  @override
  RoutePath get currentConfiguration {
    if (appState.isDetails) {
      return DetailsPath(studyId: appState.selectedStudyId);
    } else if (appState.isDesigner) {
      return DesignerPath(studyId: appState.selectedStudyId, page: appState.selectedDesignerPage);
    } else if (appState.isNotebook) {
      return NotebookPath(studyId: appState.selectedStudyId, notebook: appState.selectedNotebook);
    }
    return HomePath();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(key: const ValueKey('Dashboard'), child: Dashboard()),
        if (appState.selectedStudyId != null)
          MaterialPage(
            key: ValueKey('Details ${appState.selectedStudyId}'),
            child: StudyDetails(appState.selectedStudyId),
          ),
        if (appState.draftStudy != null)
          MaterialPage(
            key: ValueKey('Designer ${appState.selectedStudyId}'),
            child: Designer(studyId: appState.selectedStudyId),
          ),
        if (appState.selectedNotebook != null)
          MaterialPage(
            key: ValueKey('Notebook ${appState.selectedStudyId} ${appState.selectedNotebook}'),
            child: NotebookViewer(studyId: appState.selectedStudyId, notebook: appState.selectedNotebook),
          ),
        if (appState.showLoginPage)
          MaterialPage(
            key: const ValueKey('LoginPage'),
            child: LoginPage(),
          ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (appState.isDetails) {
          appState
            ..goToDashboard()
            ..reloadStudies();
        } else if (appState.isDesigner || appState.isNotebook) {
          appState.goBackToDetails();
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath path) async {
    if (path is HomePath) {
      appState.goToDashboard();
    } else if (path is DesignerPath) {
      if (path.studyId != null) {
        appState.openDesigner(path.studyId, page: path.page);
      } else {
        appState.createStudy(page: path.page);
      }
    } else if (path is NotebookPath) {
      appState.openNotebook(path.studyId, path.notebook);
    } else if (path is DetailsPath) {
      appState.openDetails(path.studyId);
    } else if (path is DesignerPath) {
      if (path.studyId != null) {
        appState.openDesigner(path.studyId, page: path.page);
      } else {
        appState.createStudy(page: path.page);
      }
    } else if (path is NotebookPath) {
      appState.openNotebook(path.studyId, path.notebook);
    }
  }
}

abstract class RoutePath {}

class HomePath extends RoutePath {}

class DetailsPath extends RoutePath {
  final String studyId;

  DetailsPath({@required this.studyId});
}

class DesignerPath implements DetailsPath {
  static const String basePath = 'designer';
  static const String newPath = 'new';
  final DesignerPage page;
  @override
  final String studyId;

  bool get isNew => studyId == null;

  DesignerPath({this.studyId, this.page = DesignerPage.about});
}

class NotebookPath extends DetailsPath {
  static const String basePath = 'notebook';
  final String notebook;

  NotebookPath({@required String studyId, @required this.notebook}) : super(studyId: studyId);
}
