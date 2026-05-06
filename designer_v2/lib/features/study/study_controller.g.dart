// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StudyController)
final studyControllerProvider = StudyControllerFamily._();

final class StudyControllerProvider
    extends $NotifierProvider<StudyController, StudyControllerState> {
  StudyControllerProvider._({
    required StudyControllerFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'studyControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$studyControllerHash();

  @override
  String toString() {
    return r'studyControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StudyController create() => StudyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StudyControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StudyControllerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StudyControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$studyControllerHash() => r'55ac77a76b14f53e995d7b0f4c4ea6a13c8b5307';

final class StudyControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          StudyController,
          StudyControllerState,
          StudyControllerState,
          StudyControllerState,
          StudyID
        > {
  StudyControllerFamily._()
    : super(
        retry: null,
        name: r'studyControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StudyControllerProvider call(StudyID studyId) =>
      StudyControllerProvider._(argument: studyId, from: this);

  @override
  String toString() => r'studyControllerProvider';
}

abstract class _$StudyController extends $Notifier<StudyControllerState> {
  late final _$args = ref.$arg as StudyID;
  StudyID get studyId => _$args;

  StudyControllerState build(StudyID studyId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StudyControllerState, StudyControllerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StudyControllerState, StudyControllerState>,
              StudyControllerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
