import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/monitor/participant_details_form_controller.dart';
import 'package:studyu_designer_v2/features/monitor/participant_details_form_view.dart';
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
          final studyMonitorItems = StudyMonitorItem.fromStudy(study);
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _monitorSectionHeader(context, study),
              const SizedBox(height: 40.0), // spacing between body elements
              studyMonitorItems.isNotEmpty
                  ? StudyMonitorTable(
                      studyMonitorItems: studyMonitorItems,
                      onSelectItem: (item) => _onSelectParticipant(context, ref, item),
                    )
                  : EmptyBody(
                      icon: Icons.person_off_rounded,
                      title: tr.monitoring_no_participants_title,
                      description: tr.monitoring_no_participants_description),
            ],
          );
        });
  }

  Widget _monitorSectionHeader(BuildContext context, Study study) {
    // Using study.participants.length because participantCount does not include soft deleted participants
    final enrolled = study.participants?.length ?? study.participantCount;
    // Active participants are those who were active in the last 3 days
    final active = study.activeSubjectCount;
    // Ended participants are those with days in study >= study duration
    final ended = study.endedCount;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(tr.monitoring_participants_title, style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: _buildStat(context, tr.monitoring_active, tr.monitoring_active_tooltip, active, enrolled)),
              const SizedBox(width: 20.0),
              Expanded(child: _buildStat(context, tr.monitoring_ended, tr.monitoring_ended_tooltip, ended, enrolled)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String title, String tooltip, int value, int total) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          Row(
            children: [
              Text("$title:"),
              const SizedBox(width: 8.0),
              Text("$value/$total", style: theme.textTheme.headlineSmall),
            ],
          ),
          SizedBox(
              height: 4.0,
              child: LinearProgressIndicator(
                value: total <= 0 ? 0 : value / total,
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
              )),
        ],
      ),
    );
  }

  _onSelectParticipant(BuildContext context, WidgetRef ref, StudyMonitorItem item) {
    // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
    final formViewModel = ref.read(participantDetailsFormViewModelProvider(item));
    formViewModel.setControlsFrom(item);
    showFormSideSheet<ParticipantDetailsFormViewModel>(
      context: context,
      formViewModel: formViewModel,
      formViewBuilder: (formViewModel) => ParticipantDetailsFormView(
        formViewModel: formViewModel,
      ),
      actionButtons: [
        retainSizeInAppBar(DismissButton(
          text: tr.dialog_close,
          onPressed: () => Navigator.maybePop(context),
        ))
      ],
    );
  }
}
