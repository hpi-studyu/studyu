import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/domain/study_monitoring.dart';
import 'package:studyu_designer_v2/features/monitor/participant_details_view.dart';
import 'package:studyu_designer_v2/features/monitor/study_monitor_table.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyMonitorScreen extends StudyPageWidget {
  const StudyMonitorScreen(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));
    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final studyMonitorData = study.monitorData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _monitorSectionHeader(context, studyMonitorData),
            const SizedBox(height: 40.0), // spacing between body elements
            if (studyMonitorData.items.isNotEmpty)
              StudyMonitorTable(
                ref: ref,
                studyMonitorItems: studyMonitorData.items,
                onSelectItem: (item) =>
                    _onSelectParticipant(context, ref, item, study),
              )
            else
              EmptyBody(
                icon: Icons.person_off_rounded,
                title: tr.monitoring_no_participants_title,
                description: tr.monitoring_no_participants_description,
              ),
          ],
        );
      },
    );
  }

  Widget _monitorSectionHeader(
      BuildContext context, StudyMonitorData monitorData) {
    final int total = monitorData.items.length;
    const double minPercentage = 0.05; // Minimum percentage for visibility

    double activePercentage = monitorData.activeParticipants / total;
    double inactivePercentage = monitorData.inactiveParticipants / total;
    double dropoutPercentage = monitorData.dropoutParticipants / total;
    double completedPercentage = monitorData.completedParticipants / total;

    // Adjust for minimum percentage visibility
    if (monitorData.activeParticipants == 0) activePercentage = minPercentage;
    if (monitorData.inactiveParticipants == 0) {
      inactivePercentage = minPercentage;
    }
    if (monitorData.dropoutParticipants == 0) dropoutPercentage = minPercentage;
    if (monitorData.completedParticipants == 0) {
      completedPercentage = minPercentage;
    }

    // Normalize the percentages so they add up to 1.0
    final double sumOfPercentages = activePercentage +
        inactivePercentage +
        dropoutPercentage +
        completedPercentage;

    activePercentage /= sumOfPercentages;
    inactivePercentage /= sumOfPercentages;
    dropoutPercentage /= sumOfPercentages;
    completedPercentage /= sumOfPercentages;

    const Color activeColor = Color(0xFF0072B2);
    const Color inactiveColor = Color(0xFFD55E00);
    const Color dropoutColor = Color(0xFFCC79A7);
    const Color completedColor = Color(0xFF009E73);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(tr.monitoring_participants_title,
            style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        SizedBox(
          width: 420,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Text('${tr.monitoring_total}: $total'),
                  ),
                ],
              ),
              Stack(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      _buildStat(
                        percentage: activePercentage,
                        color: activeColor,
                        tooltip: tr.monitoring_active,
                      ),
                      _buildStat(
                        percentage: inactivePercentage,
                        color: inactiveColor,
                        tooltip: tr.monitoring_inactive,
                      ),
                      _buildStat(
                        percentage: dropoutPercentage,
                        color: dropoutColor,
                        tooltip: tr.monitoring_dropout,
                      ),
                      _buildStat(
                        percentage: completedPercentage,
                        color: completedColor,
                        tooltip: tr.monitoring_completed,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLegend(
                      color: activeColor,
                      text:
                          '${tr.monitoring_active}: ${monitorData.activeParticipants}',
                      tooltip: tr.monitoring_active_tooltip),
                  const SizedBox(width: 10),
                  _buildLegend(
                      color: inactiveColor,
                      text:
                          '${tr.monitoring_inactive}: ${monitorData.inactiveParticipants}',
                      tooltip: tr.monitoring_inactive_tooltip),
                  const SizedBox(width: 10),
                  _buildLegend(
                      color: dropoutColor,
                      text:
                          '${tr.monitoring_dropout}: ${monitorData.dropoutParticipants}',
                      tooltip: tr.monitoring_dropout_tooltip),
                  const SizedBox(width: 10),
                  _buildLegend(
                      color: completedColor,
                      text:
                          '${tr.monitoring_completed}: ${monitorData.completedParticipants}',
                      tooltip: tr.monitoring_completed_tooltip),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(
      {required double percentage,
      required Color color,
      required String tooltip}) {
    return Expanded(
        flex: (percentage * 1000).toInt(),
        child: Tooltip(
          message: tooltip,
          child: Container(
            height: 20,
            color: color,
          ),
        ));
  }

  Widget _buildLegend(
      {required Color color, required String text, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(text),
        ],
      ),
    );
  }

  _onSelectParticipant(
      BuildContext context, WidgetRef ref, StudyMonitorItem item, Study study) {
    // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
    showModalSideSheet(
      context: context,
      title: tr.participant_details_title,
      body: ParticipantDetailsView(
        monitorItem: item,
        interventions: study.interventions,
        observations: study.observations,
      ),
      actionButtons: [
        retainSizeInAppBar(
          DismissButton(
            text: tr.dialog_close,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ],
    );
  }
}
