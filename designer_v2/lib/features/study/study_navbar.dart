import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';

abstract class IStudyNavViewModel {
  bool get isEditTabEnabled;
  bool get isTestTabEnabled;
  bool get isRecruitTabEnabled;
  bool get isMonitorTabEnabled;
  bool get isAnalyzeTabEnabled;
  bool get isSettingsEnabled;
}

class StudyNav {
  static tabs(StudyID studyId, IStudyNavViewModel viewModel) => <NavbarTab>[
        edit(studyId, enabled: viewModel.isEditTabEnabled),
        test(studyId, enabled: viewModel.isTestTabEnabled),
        recruit(studyId, enabled: viewModel.isRecruitTabEnabled),
        monitor(studyId, enabled: viewModel.isMonitorTabEnabled),
        analyze(studyId, enabled: viewModel.isAnalyzeTabEnabled)
      ];

  static edit(studyId, {enabled = true}) => NavbarTab(
        index: 0,
        title: tr.navlink_study_design,
        intent: RoutingIntents.studyEdit(studyId),
        enabled: enabled,
      );
  static test(studyId, {enabled = true}) => NavbarTab(
        index: 1,
        title: tr.navlink_study_test,
        intent: RoutingIntents.studyTest(studyId),
        enabled: enabled,
      );
  static recruit(studyId, {enabled = true}) => NavbarTab(
        index: 2,
        title: tr.navlink_study_recruit,
        intent: RoutingIntents.studyRecruit(studyId),
        enabled: enabled,
      );
  static monitor(studyId, {enabled = true}) => NavbarTab(
        index: 3,
        title: tr.navlink_study_monitor,
        intent: RoutingIntents.studyMonitor(studyId),
        enabled: enabled,
      );
  static analyze(studyId, {enabled = true}) => NavbarTab(
        index: 4,
        title: tr.navlink_study_analyze,
        intent: RoutingIntents.studyAnalyze(studyId),
        enabled: enabled,
      );
}

class StudyDesignNav {
  static tabs(studyId) => <NavbarTab>[
        info(studyId),
        enrollment(studyId),
        interventions(studyId),
        measurements(studyId),
        reports(studyId),
      ];

  static info(studyId) =>
      NavbarTab(index: 0, title: tr.navlink_study_design_info, intent: RoutingIntents.studyEditInfo(studyId));
  static enrollment(studyId) => NavbarTab(
      index: 1, title: tr.navlink_study_design_enrollment, intent: RoutingIntents.studyEditEnrollment(studyId));
  static interventions(studyId) => NavbarTab(
      index: 2, title: tr.navlink_study_design_interventions, intent: RoutingIntents.studyEditInterventions(studyId));
  static measurements(studyId) => NavbarTab(
      index: 3, title: tr.navlink_study_design_measurements, intent: RoutingIntents.studyEditMeasurements(studyId));
  static reports(studyId) => NavbarTab(index: 4, title: "Reports", intent: RoutingIntents.studyEditReports(studyId));
}
