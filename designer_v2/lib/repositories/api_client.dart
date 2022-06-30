import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';

abstract class StudyUApi {
  Future<List<Study>> getUserStudies();
  Future<void> deleteStudy(Study study);
}

/// The StudyU API client that loads data
class StudyUApiClient implements StudyUApi {
  @override
  Future<List<Study>> getUserStudies() async {
    final studies = Study.getResearcherDashboardStudies();
    return studies;
  }

  @override
  Future<void> deleteStudy(Study study) async {
    // Delegate to [SupabaseObjectMethods]
    await study.delete();
  }
}

final apiClientProvider = Provider<StudyUApi>((ref) => StudyUApiClient());
