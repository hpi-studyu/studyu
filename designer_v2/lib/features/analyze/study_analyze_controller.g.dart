// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_analyze_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyAnalyzeController)
const studyAnalyzeControllerProvider = StudyAnalyzeControllerFamily._();

final class StudyAnalyzeControllerProvider
    extends
        $NotifierProvider<StudyAnalyzeController, StudyAnalyzeControllerState> {
  const StudyAnalyzeControllerProvider._({
    required StudyAnalyzeControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyAnalyzeControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyAnalyzeControllerHash();

  @override
  String toString() {
    return r'studyAnalyzeControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudyAnalyzeController create() => StudyAnalyzeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyAnalyzeControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyAnalyzeControllerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyAnalyzeControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyAnalyzeControllerHash() =>
    r'5bdb6dc7be94dc93d7ac1c4b414fab82647d8124';

final class StudyAnalyzeControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudyAnalyzeController,
          StudyAnalyzeControllerState,
          StudyAnalyzeControllerState,
          StudyAnalyzeControllerState,
          StudyID
        > {
  const StudyAnalyzeControllerFamily._()
    : super(
        retry: null,
        name: r'studyAnalyzeControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyAnalyzeControllerProvider call(StudyID studyId) =>
      StudyAnalyzeControllerProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyAnalyzeControllerProvider';
}

abstract class _$StudyAnalyzeController
    extends $Notifier<StudyAnalyzeControllerState> {
  late final _$args = ref.$arg as StudyID;
  StudyID get studyId => _$args;

  StudyAnalyzeControllerState build(StudyID studyId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<StudyAnalyzeControllerState, StudyAnalyzeControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                StudyAnalyzeControllerState,
                StudyAnalyzeControllerState
              >,
              StudyAnalyzeControllerState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
