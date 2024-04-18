import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/monitor/study_monitor_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ParticipantDetailsFormViewModel extends FormViewModel<StudyMonitorItem> {
  ParticipantDetailsFormViewModel() : super();

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: tr.participant_details_title,
        FormMode.readonly: tr.participant_details_title,
      };

  final participantIdControl = FormControl<String>(value: '');

  final rawDataControl = FormControl<String>(value: '');

  @override
  late final form = FormGroup({
    'participantId': participantIdControl,
    'rawData': rawDataControl,
  });

  @override
  void initControls() {}

  @override
  StudyMonitorItem buildFormData() {
    throw UnsupportedError("This form is read-only");
  }

  @override
  void setControlsFrom(StudyMonitorItem data) {
    participantIdControl.value = data.participantId;
    rawDataControl.value = data.rawData;
  }
}

final participantDetailsFormViewModelProvider = Provider.autoDispose
    .family<ParticipantDetailsFormViewModel, StudyMonitorItem>((ref, item) => ParticipantDetailsFormViewModel());
