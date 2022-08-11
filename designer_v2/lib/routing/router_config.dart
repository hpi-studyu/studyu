import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/common_views/layout_single_column.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/common_views/pages/error_page.dart';
import 'package:studyu_designer_v2/common_views/pages/splash_page.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/auth/authform_scaffold.dart';
import 'package:studyu_designer_v2/features/auth/login_page.dart';
import 'package:studyu_designer_v2/features/auth/password_forgot_page.dart';
import 'package:studyu_designer_v2/features/auth/password_recovery_page.dart';
import 'package:studyu_designer_v2/features/auth/signup_page.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_page.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/design/common_views/study_form_scaffold.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_preview_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/main_page_scaffold.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_page.dart';
import 'package:studyu_designer_v2/features/study/study_analyze_page.dart';
import 'package:studyu_designer_v2/features/study/study_edit_page.dart';
import 'package:studyu_designer_v2/features/study/study_monitor_page.dart';
import 'package:studyu_designer_v2/features/study/study_scaffold.dart';
import 'package:studyu_designer_v2/features/study/study_test_page.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/routing/router_navbars.dart';

class RouterKeys {
  static const studyKey = ValueKey("study"); // shared key for study page tabs
}

class RouteParams {
  static const studiesFilter = 'filter';
  static const studyId = 'studyId';
  static const measurementId = 'measurementId';
}

/// The route configuration passed to [GoRouter] during instantiation.
///
/// Any route that should be accessible from the app must be registered as
/// a [topLevelRoutes] (or as a subroute of a top-level route)
///
/// Note: Make sure to always specify [GoRoute.name] so that [RoutingIntent]s
/// can be dispatched correctly.
class RouterConfig {

  /// Public routes can be accessed without login
  static final topLevelPublicRoutes = [
    root,
    splash,
    error,
    login,
    signup,
    passwordForgot,
  ];

  /// Private routes can only be accessed after login
  static final topLevelPrivateRoutes = [
    studies,
    study,
    studyEdit,
    studyEditInfo,
    studyEditEnrollment,
    studyEditInterventions,
    studyEditMeasurements,
    studyTest,
    studyMonitor,
    studyRecruit,
    studyAnalyze,
    passwordRecovery,
  ];

  /// This list is provided to [GoRouter.routes] during instantiation.
  /// See router.dart
  static final topLevelRoutes = topLevelPublicRoutes + topLevelPrivateRoutes;

  static final root = GoRoute(
    path: "/",
    name: "root",
    redirect: (GoRouterState state) => state.namedLocation(studies.name!),
  );

  static final studies = GoRoute(
      path: "/studies",
      name: "studies",
      builder: (context, state) => DashboardScreen(
          filter: (){
            if (state.queryParams[RouteParams.studiesFilter] == null) {
              return null;
            }
            final idx = StudiesFilter.values.map((v) => v.toShortString())
                .toList().indexOf(state.queryParams[RouteParams.studiesFilter]!);
            return (idx != -1) ? StudiesFilter.values[idx] : null;
          }() // call anonymous closure to resolve param to enum
      ),
  );

  static final study = GoRoute(
    path: "/studies/:${RouteParams.studyId}",
    name: "study",
    redirect: (GoRouterState state) => state.namedLocation(
        studyEdit.name!,
        params: {
          RouteParams.studyId: state.params[RouteParams.studyId]!
        }
    ),
  );

  static final studyEdit = GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit",
      name: "studyEdit",
      redirect: (GoRouterState state) => state.namedLocation(
          studyEditInfo.name!,
          params: {
            RouteParams.studyId: state.params[RouteParams.studyId]!
          }
      ),
  );

  static final studyEditInfo = GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/info",
      name: "studyEditInfo",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              tabsSubnav: StudyDesignNav.tabs(studyId),
              selectedTab: StudyNav.edit(studyId),
              selectedTabSubnav: StudyDesignNav.info(studyId),
              body: StudyEditScreen(studyId),
              layoutType: SingleColumnLayoutType.split,
        ));
      }
  );

  static final studyEditEnrollment = GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/enrollment",
      name: "studyEditEnrollment",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              tabsSubnav: StudyDesignNav.tabs(studyId),
              selectedTab: StudyNav.edit(studyId),
              selectedTabSubnav: StudyDesignNav.enrollment(studyId),
              body: StudyEditScreen(studyId),
              layoutType: SingleColumnLayoutType.split,
        ));
      }
  );

  static final studyEditInterventions = GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/interventions",
      name: "studyEditInterventions",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              tabsSubnav: StudyDesignNav.tabs(studyId),
              selectedTab: StudyNav.edit(studyId),
              selectedTabSubnav: StudyDesignNav.interventions(studyId),
              body: StudyEditScreen(studyId),
              layoutType: SingleColumnLayoutType.split,
        ));
      }
  );

  static final studyEditMeasurements = GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/measurements",
      name: "studyEditMeasurements",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              tabsSubnav: StudyDesignNav.tabs(studyId),
              selectedTab: StudyNav.edit(studyId),
              selectedTabSubnav: StudyDesignNav.measurements(studyId),
              body: StudyDesignMeasurementsFormView(studyId),
              layoutType: SingleColumnLayoutType.split,
        ));
      },
      routes: [studyEditMeasurement]
  );

  static final studyEditMeasurement = GoRoute(
      path: ":${RouteParams.measurementId}",
      name: "studyEditMeasurement",
      pageBuilder: (context, state) {
        final routeArgs = MeasurementFormRouteArgs(
            studyId: state.params[RouteParams.studyId]!,
            measurementId: state.params[RouteParams.measurementId]!
        );
        return MaterialPage(
          child: StudyFormScaffold<MeasurementSurveyFormViewModel>(
            studyId: routeArgs.studyId,
            formViewModelBuilder: (ref) => ref.read(
                surveyFormViewModelProvider(routeArgs)
            ),
            formViewBuilder: (formViewModel) => TwoColumnLayout.split(
              leftWidget: MeasurementSurveyFormView(formViewModel: formViewModel),
              rightWidget: SurveyPreview(routeArgs: routeArgs),
              flexLeft: 7,
              flexRight: 8,
              scrollLeft: true,
              scrollRight: false,
              paddingRight: null,
            ),
          )
        );
      }
  );

  static final studyTest = GoRoute(
      path: "/studies/:${RouteParams.studyId}/test",
      name: "studyTest",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              selectedTab: StudyNav.test(studyId),
              body: StudyTestScreen(studyId),
              layoutType: SingleColumnLayoutType.stretched,
        ));
      }
  );

  static final studyRecruit = GoRoute(
      path: "/studies/:${RouteParams.studyId}/recruit",
      name: "studyRecruit",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              selectedTab: StudyNav.recruit(studyId),
              body: StudyRecruitScreen(studyId),
              layoutType: SingleColumnLayoutType.bounded,
        ));
      }
  );

  static final studyMonitor = GoRoute(
      path: "/studies/:${RouteParams.studyId}/monitor",
      name: "studyMonitor",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              selectedTab: StudyNav.monitor(studyId),
              body: StudyMonitorScreen(studyId),
              layoutType: SingleColumnLayoutType.bounded,
        ));
      }
  );

  static final studyAnalyze = GoRoute(
      path: "/studies/:${RouteParams.studyId}/analyze",
      name: "studyAnalyze",
      pageBuilder: (context, state) {
        final studyId = state.params[RouteParams.studyId]!;
        return MaterialPage(
            key: RouterKeys.studyKey,
            child: StudyScaffold(
              studyId: studyId,
              tabs: StudyNav.tabs(studyId),
              selectedTab: StudyNav.analyze(studyId),
              body: StudyAnalyzeScreen(studyId),
              layoutType: SingleColumnLayoutType.bounded,
        ));
      }
  );

  static final splash = GoRoute(
    path: "/splash",
    name: "splash",
    builder: (context, state) => const SplashPage(),
  );

  static final login = GoRoute(
    path: "/login",
    name: "login",
      pageBuilder: (context, state) =>
          MaterialPage(
              child: MainPageScaffold(
                  childName: state.name!,
                  child: AuthFormScaffold(
                      childName: state.name!,
                      children: const LoginPage()
                  )
              )
          )
  );

  static final signup = GoRoute(
      path: "/signup",
      name: "signup",
      pageBuilder: (context, state) =>
          MaterialPage(
              child: MainPageScaffold(
              childName: state.name!,
              child: AuthFormScaffold(
                  childName: state.name!,
                  children: const SignupPage()
              )
          )
          )
  );

  static final passwordForgot = GoRoute(
      path: "/forgot_password",
      name: "forgotPassword",
      pageBuilder: (context, state) =>
          MaterialPage(
              child: MainPageScaffold(
                childName: state.name!,
                child: AuthFormScaffold(
                  childName: state.name!,
                  children: PasswordForgotPage(email: state.extra as String?),
                )
              )
          )
  );

  static final passwordRecovery = GoRoute(
      path: "/password_recovery",
      name: "recoverPassword",
      pageBuilder: (context, state) =>
          MaterialPage(
              child: MainPageScaffold(
                  childName: state.name!,
                  child: AuthFormScaffold(
                      childName: state.name!,
                      children: const PasswordRecoveryPage()
                  )
              )
          )
  );

  static final error = GoRoute(
    path: "/error",
    name: "error",
    builder: (context, state) => ErrorPage(error: state.extra as Exception),
  );
}

// - Route Args

class MeasurementFormRouteArgs {
  MeasurementFormRouteArgs({required this.studyId, required this.measurementId});

  final StudyID studyId;
  final MeasurementID measurementId;
}

class SurveyQuestionFormRouteArgs extends MeasurementFormRouteArgs {
  SurveyQuestionFormRouteArgs({
    required super.studyId,
    required super.measurementId,
    required this.questionId
  });

  final QuestionID questionId;
}
