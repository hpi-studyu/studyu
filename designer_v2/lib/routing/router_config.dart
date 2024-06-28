import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_designer_v2/common_views/layout_single_column.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/common_views/pages/error_page.dart';
import 'package:studyu_designer_v2/common_views/pages/splash_page.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/consent.dart';
import 'package:studyu_designer_v2/domain/intervention.dart';
import 'package:studyu_designer_v2/domain/question.dart';
import 'package:studyu_designer_v2/domain/section.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/task.dart';
import 'package:studyu_designer_v2/features/account/account_settings.dart';
import 'package:studyu_designer_v2/features/analyze/study_analyze_page.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/auth_scaffold.dart';
import 'package:studyu_designer_v2/features/auth/login_form_view.dart';
import 'package:studyu_designer_v2/features/auth/password_forgot_form_view.dart';
import 'package:studyu_designer_v2/features/auth/password_recovery_form_view.dart';
import 'package:studyu_designer_v2/features/auth/signup_form_view.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_page.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_view.dart';
import 'package:studyu_designer_v2/features/design/info/study_info_form_view.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_controller.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_form_view.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_preview_view.dart';
import 'package:studyu_designer_v2/features/design/interventions/interventions_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_preview_view.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/design/study_form_scaffold.dart';
import 'package:studyu_designer_v2/features/monitor/study_monitor_page.dart';
import 'package:studyu_designer_v2/features/recruit/study_recruit_page.dart';
import 'package:studyu_designer_v2/features/study/settings/study_settings_dialog.dart';
import 'package:studyu_designer_v2/features/study/study_navbar.dart';
import 'package:studyu_designer_v2/features/study/study_scaffold.dart';
import 'package:studyu_designer_v2/features/study/study_test_page.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/routing/router_utils.dart';

class RouterKeys {
  static const studyKey = ValueKey("study"); // shared key for study page tabs
  static const authKey = ValueKey("auth"); // shared key for auth pages
}

class RouteParams {
  static const studiesFilter = 'filter';
  static const studyId = 'studyId';
  static const parentTemplate = 'parentTemplate';
  static const isTemplate = 'isTemplate';
  static const measurementId = 'measurementId';
  static const interventionId = 'interventionId';
  static const testAppRoute = 'appRoute';
}

/// The route configuration passed to [GoRouter] during instantiation.
/// Note: Make sure to always specify [GoRoute.name] so that [RoutingIntent]s
/// can be dispatched correctly.
class RouterConf {
  static late GoRouter router;

  static final List<GoRoute> routes = publicRoutes + privateRoutes;

  static final List<GoRoute> publicRoutes = [
    GoRoute(
      path: "/splash",
      name: splashRouteName,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: "/login",
      name: loginRouteName,
      pageBuilder: (context, state) => const MaterialPage(
        key: RouterKeys.authKey,
        child: AuthScaffold(
          formKey: AuthFormKey.login,
          body: LoginForm(),
        ),
      ),
    ),
    GoRoute(
      path: "/signup",
      name: signupRouteName,
      pageBuilder: (context, state) => const MaterialPage(
        key: RouterKeys.authKey,
        child: AuthScaffold(
          formKey: AuthFormKey.signup,
          body: SignupForm(),
        ),
      ),
    ),
    GoRoute(
      path: "/forgot_password",
      name: forgotPasswordRouteName,
      pageBuilder: (context, state) => const MaterialPage(
        key: RouterKeys.authKey,
        child: AuthScaffold(
          formKey: AuthFormKey.passwordForgot,
          body: PasswordForgotForm(),
        ),
      ),
    ),
    GoRoute(
      path: "/error",
      name: errorRouteName,
      builder: (context, state) => ErrorPage(error: state.extra! as Exception),
    ),
  ];

  static final List<GoRoute> privateRoutes = [
    GoRoute(
      path: "/",
      name: rootRouteName,
      redirect: (BuildContext context, GoRouterState state) =>
          context.namedLocation('studies'),
    ),
    GoRoute(
      path: "/studies",
      name: studiesRouteName,
      builder: (context, state) => DashboardScreen(
        filter: () {
          if (state.uri.queryParameters[RouteParams.studiesFilter] == null) {
            return null;
          }
          final idx = StudiesFilter.values
              .map((v) => v.toShortString())
              .toList()
              .indexOf(state.uri.queryParameters[RouteParams.studiesFilter]!);
          return (idx != -1) ? StudiesFilter.values[idx] : null;
        }(), // call anonymous closure to resolve param to enum
      ),
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}",
      name: studyRouteName,
      redirect: (BuildContext context, GoRouterState state) =>
          router.namedLocation(
        'studyEdit',
        pathParameters: {
          RouteParams.studyId: state.pathParameters[RouteParams.studyId]!,
        },
      ),
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit",
      name: studyEditRouteName,
      redirect: (BuildContext context, GoRouterState state) =>
          router.namedLocation(
        'studyEditInfo',
        pathParameters: {
          RouteParams.studyId: state.pathParameters[RouteParams.studyId]!,
        },
      ),
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/info",
      name: studyEditInfoRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            tabsSubnav: StudyDesignNav.tabs(studyCreationArgs.studyID),
            selectedTab: StudyNav.edit(studyCreationArgs.studyID),
            selectedTabSubnav: StudyDesignNav.info(studyCreationArgs.studyID),
            body: StudyDesignInfoFormView(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedNarrow,
          ),
        );
      },
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/enrollment",
      name: studyEditEnrollmentRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            tabsSubnav: StudyDesignNav.tabs(studyCreationArgs.studyID),
            selectedTab: StudyNav.edit(studyCreationArgs.studyID),
            selectedTabSubnav:
                StudyDesignNav.enrollment(studyCreationArgs.studyID),
            body: StudyDesignEnrollmentFormView(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedNarrow,
          ),
        );
      },
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/interventions",
      name: studyEditInterventionsRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            tabsSubnav: StudyDesignNav.tabs(studyCreationArgs.studyID),
            selectedTab: StudyNav.edit(studyCreationArgs.studyID),
            selectedTabSubnav:
                StudyDesignNav.interventions(studyCreationArgs.studyID),
            body: StudyDesignInterventionsFormView(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedNarrow,
          ),
        );
      },
      routes: [
        GoRoute(
          path: ":${RouteParams.interventionId}",
          name: studyEditInterventionRouteName,
          pageBuilder: (context, state) {
            final studyCreationArgs = StudyCreationArgs.fromRoute(state);

            final routeArgs = InterventionFormRouteArgs(
              studyCreationArgs: studyCreationArgs,
              interventionId: state.pathParameters[RouteParams.interventionId]!,
            );
            return MaterialPage(
              child: StudyFormScaffold<InterventionFormViewModel>(
                studyCreationArgs: studyCreationArgs,
                formViewModelBuilder: (ref) =>
                    ref.read(interventionFormViewModelProvider(routeArgs)),
                formViewBuilder: (formViewModel) => TwoColumnLayout.split(
                  leftWidget:
                      InterventionFormView(formViewModel: formViewModel),
                  rightWidget: InterventionPreview(routeArgs: routeArgs),
                  flexLeft: 7,
                  constraintsLeft: const BoxConstraints(minWidth: 500.0),
                  scrollRight: false,
                  paddingRight: null,
                ),
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/measurements",
      name: studyEditMeasurementsRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            tabsSubnav: StudyDesignNav.tabs(studyCreationArgs.studyID),
            selectedTab: StudyNav.edit(studyCreationArgs.studyID),
            selectedTabSubnav:
                StudyDesignNav.measurements(studyCreationArgs.studyID),
            body: StudyDesignMeasurementsFormView(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedNarrow,
          ),
        );
      },
      routes: [
        GoRoute(
          path: ":${RouteParams.measurementId}",
          name: studyEditMeasurementRouteName,
          pageBuilder: (context, state) {
            final studyCreationArgs = StudyCreationArgs.fromRoute(state);
            final routeArgs = MeasurementFormRouteArgs(
              studyCreationArgs: studyCreationArgs,
              measurementId: state.pathParameters[RouteParams.measurementId]!,
            );
            return MaterialPage(
              child: StudyFormScaffold<MeasurementSurveyFormViewModel>(
                studyCreationArgs: studyCreationArgs,
                formViewModelBuilder: (ref) =>
                    ref.read(surveyFormViewModelProvider(routeArgs)),
                formViewBuilder: (formViewModel) => TwoColumnLayout.split(
                  leftWidget:
                      MeasurementSurveyFormView(formViewModel: formViewModel),
                  rightWidget: SurveyPreview(routeArgs: routeArgs),
                  flexLeft: 7,
                  constraintsLeft: const BoxConstraints(minWidth: 500.0),
                  scrollRight: false,
                  paddingRight: null,
                ),
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/edit/reports",
      name: studyEditReportsRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            tabsSubnav: StudyDesignNav.tabs(studyCreationArgs.studyID),
            selectedTab: StudyNav.edit(studyCreationArgs.studyID),
            selectedTabSubnav:
                StudyDesignNav.reports(studyCreationArgs.studyID),
            body: StudyDesignReportsFormView(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedNarrow,
          ),
        );
      },
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/test",
      name: studyTestRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        final appRoute = state.uri.queryParameters[RouteParams.testAppRoute];
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            selectedTab: StudyNav.test(studyCreationArgs.studyID),
            body: StudyTestScreen(studyCreationArgs, previewRoute: appRoute),
            layoutType: SingleColumnLayoutType.stretched,
          ),
        );
      },
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/recruit",
      name: studyRecruitRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            selectedTab: StudyNav.recruit(studyCreationArgs.studyID),
            body: StudyRecruitScreen(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedWide,
          ),
        );
      },
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/monitor",
      name: studyMonitorRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            selectedTab: StudyNav.monitor(studyCreationArgs.studyID),
            body: StudyMonitorScreen(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedWide,
          ),
        );
      },
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/analyze",
      name: studyAnalyzeRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return MaterialPage(
          key: RouterKeys.studyKey,
          child: StudyScaffold(
            studyCreationArgs: studyCreationArgs,
            selectedTab: StudyNav.analyze(studyCreationArgs.studyID),
            body: StudyAnalyzeScreen(studyCreationArgs),
            layoutType: SingleColumnLayoutType.boundedWide,
          ),
        );
      },
    ),
    GoRoute(
      path: "/studies/:${RouteParams.studyId}/settings",
      name: studySettingsRouteName,
      pageBuilder: (context, state) {
        final studyCreationArgs = StudyCreationArgs.fromRoute(state);
        return buildModalTransitionPage(
          context,
          state,
          StudySettingsDialog(studyCreationArgs),
        );
      },
    ),
    GoRoute(
      path: "/settings",
      name: accountSettingsRouteName,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return buildModalTransitionPage(
          context,
          state,
          const AccountSettingsDialog(),
        );
      },
    ),
    GoRoute(
      path: "/password_recovery",
      name: recoverPasswordRouteName,
      pageBuilder: (context, state) => const MaterialPage(
        key: RouterKeys.authKey,
        child: AuthScaffold(
          formKey: AuthFormKey.passwordRecovery,
          body: PasswordRecoveryForm(),
        ),
      ),
    ),
  ];

  static GoRoute route(String name) {
    GoRoute? searchRouteNames(List<GoRoute> subRoutes) {
      if (subRoutes.isEmpty) return null;
      for (final GoRoute route in subRoutes) {
        if (route.name == name) return route;
        final GoRoute? newRoute =
            searchRouteNames(List<GoRoute>.from(route.routes));
        if (newRoute != null) return newRoute;
      }
      return null;
    }

    return searchRouteNames(routes)!;
  }
}

// - Route Args

abstract class StudyFormRouteArgs extends Equatable {
  const StudyFormRouteArgs({required this.studyCreationArgs});

  final StudyCreationArgs studyCreationArgs;
}

abstract class QuestionFormRouteArgs extends StudyFormRouteArgs {
  const QuestionFormRouteArgs({
    required this.questionId,
    required super.studyCreationArgs,
  });

  final QuestionID questionId;
}

class ScreenerQuestionFormRouteArgs extends QuestionFormRouteArgs {
  const ScreenerQuestionFormRouteArgs({
    required super.questionId,
    required super.studyCreationArgs,
  });

  @override
  List<Object> get props => [questionId, studyCreationArgs];
}

class ConsentItemFormRouteArgs extends StudyFormRouteArgs {
  const ConsentItemFormRouteArgs({
    required super.studyCreationArgs,
    required this.consentId,
  });

  final ConsentID consentId;

  @override
  List<Object> get props => [studyCreationArgs, consentId];
}

class MeasurementFormRouteArgs extends StudyFormRouteArgs {
  const MeasurementFormRouteArgs({
    required this.measurementId,
    required super.studyCreationArgs,
  });

  final MeasurementID measurementId;

  @override
  List<Object> get props => [studyCreationArgs, measurementId];
}

class SurveyQuestionFormRouteArgs extends MeasurementFormRouteArgs
    implements QuestionFormRouteArgs {
  const SurveyQuestionFormRouteArgs({
    required this.questionId,
    required super.studyCreationArgs,
    required super.measurementId,
  });

  @override
  final QuestionID questionId;

  @override
  List<Object> get props => [studyCreationArgs, measurementId, questionId];
}

class InterventionFormRouteArgs extends StudyFormRouteArgs {
  const InterventionFormRouteArgs({
    required this.interventionId,
    required super.studyCreationArgs,
  });

  final InterventionID interventionId;

  @override
  List<Object> get props => [studyCreationArgs, interventionId];
}

class InterventionTaskFormRouteArgs extends InterventionFormRouteArgs {
  const InterventionTaskFormRouteArgs({
    required this.taskId,
    required super.studyCreationArgs,
    required super.interventionId,
  });

  final TaskID taskId;

  @override
  List<Object> get props => [studyCreationArgs, interventionId, taskId];
}

class ReportItemFormRouteArgs extends StudyFormRouteArgs {
  const ReportItemFormRouteArgs({
    required super.studyCreationArgs,
    required this.sectionId,
  });

  final SectionID sectionId;

  @override
  List<Object> get props => [studyCreationArgs, sectionId];
}
