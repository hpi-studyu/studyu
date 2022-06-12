import 'model.dart';

enum EnrollmentType {
  invitation,
  open
}

enum StudyActionType {
  addCollaborator,
  recruit,
  export,
  delete
}

extension EnrollmentTypeFormatted on EnrollmentType {
  String get value {
    switch (this) {
      case EnrollmentType.invitation:
        return "Private";
      case EnrollmentType.open:
        return "Open";
      default:
        return "[Invalid EnrollmentTypeFormatted]";
    }
  }
}

class Study implements IModelActionProvider<StudyActionType> {
  final String title;
  final String status;
  final EnrollmentType enrollmentType;
  final String? startDate;
  final int countEnrolled;
  final int countActive;
  final int countCompleted;

  const Study({
    required this.title,
    required this.status,
    this.startDate,
    this.enrollmentType = EnrollmentType.invitation,
    this.countEnrolled = 0,
    this.countActive = 0,
    this.countCompleted = 0
  });

  String get enrollmentTypeValue => enrollmentType.value;

  // - IActionProvider<StudyActions>

  @override
  List<ModelAction<StudyActionType>> availableActions() {
    return [
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Add collaborator",
        onExecute: () => print("Adding collaborator: " + title),
      ),
      ModelAction(
        type: StudyActionType.recruit,
        label: "Recruit participants",
        onExecute: () => print("Recruit participants: " + title),
        isAvailable: status == "RUNNING",
      ),
      ModelAction(
        type: StudyActionType.addCollaborator,
        label: "Export results",
        onExecute: () => print("Export results: " + title),
        isAvailable: status != "DRAFT",
      ),
      ModelAction(
          type: StudyActionType.addCollaborator,
          label: "Delete",
          onExecute: () => print("Delete: " + title),
          isAvailable: status == "DRAFT",
          isDestructive: true
      ),
    ];
  }
}
