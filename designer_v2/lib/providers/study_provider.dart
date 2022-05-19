import '../domain/study.dart';

class StudyProvider {
  static final StudyProvider _instance = StudyProvider();
  static StudyProvider get shared => _instance;

  List<Study> get studies => const [
      Study(
          title: 'Backpain Interventions (Demo Template)',
          status: 'DRAFT',
          enrollmentType: EnrollmentType.invitation,
          startDate: null,
          countEnrolled: 0,
          countActive: 0,
          countCompleted: 0
      ),
      Study(
          title: 'Meditation Techniques for Anxiety (copy)',
          status: 'DRAFT',
          enrollmentType: EnrollmentType.invitation,
          startDate: null,
          countEnrolled: 0,
          countActive: 0,
          countCompleted: 0
      ),
      Study(
          title: 'Meditation Techniques for Anxiety',
          status: 'RUNNING',
          enrollmentType: EnrollmentType.invitation,
          startDate: null,
          countEnrolled: 12,
          countActive: 4,
          countCompleted: 2
      )
  ];
}
