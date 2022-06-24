import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/subjects.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';


abstract class IStudyRepository {
  // - Studies
  Stream<List<Study>> watchUserStudies({fetchOnSubscribe = true});
  Future<List<Study>> fetchUserStudies();
  Future<void> deleteStudy(String id);
  // - Lifecycle
  void dispose();
}

class StudyNotFoundException implements Exception {}

class FakeStudyRepository implements IStudyRepository {
  /// A stream controller for broadcasting the studies that can be accessed by the current user
  final BehaviorSubject<List<Study>> _studiesStreamController =
      BehaviorSubject();

  /// A reference to the StudyU API injected via Riverpod
  final StudyUApi apiClient;

  FakeStudyRepository({required this.apiClient});

  @override
  Stream<List<Study>> watchUserStudies({fetchOnSubscribe = true}) {
    // We don't want to use Stream.fromFuture because it automatically
    // closes the stream when the future resolves, but we want to keep
    // it open for future updates
    if (fetchOnSubscribe) {
      fetchUserStudies().then((value) => _studiesStreamController.add(value));
    }
    return _studiesStreamController.stream;
  }

  @override
  Future<List<Study>> fetchUserStudies() async {
    final studies = await apiClient.getUserStudies();
    return studies;
  }

  @override
  Future<void> deleteStudy(String id) async {
    // Re-emits the latest value added to the stream controller
    // minus the deleted object
    final studies = [..._studiesStreamController.value];
    final studyIdx = studies.indexWhere((t) => t.id == id);
    if (studyIdx == -1) {
      throw StudyNotFoundException();
    } else {
      studies.removeAt(studyIdx);
      _studiesStreamController.add(studies);
    }
  }

  @override
  dispose() {
    _studiesStreamController.close();
  }
}

final studyRepositoryProvider = Provider<IStudyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final studyRepository = FakeStudyRepository(apiClient: apiClient);
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    studyRepository.dispose();
  });
  return studyRepository;
});
