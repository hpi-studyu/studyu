import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';

abstract class StudyUApi {
  Future<List<Study>> getUserStudies();
}

/// The StudyU API client that loads data
class StudyUApiClient implements StudyUApi {
  @override
  Future<List<Study>> getUserStudies() async {
    final studies = Study.getResearcherDashboardStudies();
    return studies;
  }
}

final apiClientProvider = Provider<StudyUApi>((ref) => StudyUApiClient());
