// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_recruit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyRecruitController)
const studyRecruitControllerProvider = StudyRecruitControllerFamily._();

final class StudyRecruitControllerProvider
    extends
        $NotifierProvider<StudyRecruitController, StudyRecruitControllerState> {
  const StudyRecruitControllerProvider._({
    required StudyRecruitControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyRecruitControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyRecruitControllerHash();

  @override
  String toString() {
    return r'studyRecruitControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudyRecruitController create() => StudyRecruitController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyRecruitControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyRecruitControllerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyRecruitControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyRecruitControllerHash() =>
    r'f08121f3722c1facaee6b9f812a1c2b740402fe5';

final class StudyRecruitControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudyRecruitController,
          StudyRecruitControllerState,
          StudyRecruitControllerState,
          StudyRecruitControllerState,
          StudyID
        > {
  const StudyRecruitControllerFamily._()
    : super(
        retry: null,
        name: r'studyRecruitControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyRecruitControllerProvider call(StudyID studyId) =>
      StudyRecruitControllerProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyRecruitControllerProvider';
}

abstract class _$StudyRecruitController
    extends $Notifier<StudyRecruitControllerState> {
  late final _$args = ref.$arg as StudyID;
  StudyID get studyId => _$args;

  StudyRecruitControllerState build(StudyID studyId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<StudyRecruitControllerState, StudyRecruitControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                StudyRecruitControllerState,
                StudyRecruitControllerState
              >,
              StudyRecruitControllerState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
