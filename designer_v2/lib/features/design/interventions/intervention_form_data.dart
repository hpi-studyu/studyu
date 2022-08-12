import 'package:studyu_designer_v2/domain/intervention.dart';
import 'package:studyu_designer_v2/features/design/interventions/intervention_task_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:uuid/uuid.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class InterventionFormData extends IFormData {
  InterventionFormData({
    required this.interventionId,
    required this.title,
    this.description,
    this.tasksData,
  });

  final InterventionID interventionId;
  final String title;
  final String? description;
  final List<InterventionTaskFormData>? tasksData;

  @override
  FormDataID get id => interventionId;

  factory InterventionFormData.fromDomainModel(Intervention intervention) {
    return InterventionFormData(
      interventionId: intervention.id,
      title: intervention.name ?? '',
      description: intervention.description,
      tasksData: intervention.tasks
          .map((task) =>
              InterventionTaskFormData.fromDomainModel(task as CheckmarkTask))
          .toList(),
    );
  }

  Intervention toIntervention() {
    final intervention = Intervention(interventionId, title);
    intervention.description = description;
    intervention.tasks = (tasksData != null)
        ? tasksData!.map((formData) => formData.toTask()).toList()
        : [];
    return intervention;
  }

  @override
  InterventionFormData copy() {
    return InterventionFormData(
      interventionId: const Uuid().v4(), // assign new id
      title: title.withDuplicateLabel(),
      description: description,
      tasksData: tasksData?.map((formData) => formData.copy()).toList(),
    );
  }
}
