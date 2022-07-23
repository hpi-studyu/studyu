import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';

abstract class IInviteCodeRepository {
  // - StudyInvite
  //List<ModelAction<StudyActionType>> getAvailableActionsFor(InviteCode study);
  Future<StudyInvite> saveStudyInvite(StudyInvite invite);
  Future<bool> isCodeAlreadyUsed(String code);
  Future<void> deleteStudyInvite(String id);
  // - Lifecycle
  void dispose();
}

class InviteCodeRepository implements IInviteCodeRepository {
  InviteCodeRepository({
    required this.apiClient,
    required this.studyRepository
  });

  final StudyUApi apiClient;
  final IStudyRepository studyRepository;

  @override
  Future<bool> isCodeAlreadyUsed(String code) async {
    try {
      await apiClient.fetchStudyInvite(code);
    } on StudyInviteNotFoundException {
      return false;
    }
    return true;
  }

  @override
  Future<StudyInvite> saveStudyInvite(StudyInvite invite) async {
    final savedStudyInvite = await apiClient.saveStudyInvite(invite);
    // TODO: update study locally in repository
    //_upsertStudyLocally(savedStudy);
    print("saved invite");
    print(savedStudyInvite);
    return savedStudyInvite;
  }

  @override
  Future<void> deleteStudyInvite(String id) {
    // TODO: implement deleteStudyInvite
    throw UnimplementedError();
  }

  @override
  void dispose() {
    return;
  }
}

final inviteCodeRepositoryProvider = Provider<IInviteCodeRepository>((ref) {
  final repository = InviteCodeRepository(
    apiClient: ref.watch(apiClientProvider),
    studyRepository: ref.watch(studyRepositoryProvider),
  );
  // Bind lifecycle to Riverpod
  ref.onDispose(() {
    repository.dispose();
  });
  return repository;
});
