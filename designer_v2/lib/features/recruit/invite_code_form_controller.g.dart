// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_code_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

@ProviderFor(inviteCodeFormViewModel)
final inviteCodeFormViewModelProvider = InviteCodeFormViewModelFamily._();

/// Provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

final class InviteCodeFormViewModelProvider
    extends
        $FunctionalProvider<
          InviteCodeFormViewModel,
          InviteCodeFormViewModel,
          InviteCodeFormViewModel
        >
    with $Provider<InviteCodeFormViewModel> {
  /// Provide a controller parametrized by [StudyID]
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
  InviteCodeFormViewModelProvider._({
    required InviteCodeFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'inviteCodeFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inviteCodeFormViewModelHash();

  @override
  String toString() {
    return r'inviteCodeFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<InviteCodeFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InviteCodeFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return inviteCodeFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteCodeFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteCodeFormViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InviteCodeFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inviteCodeFormViewModelHash() =>
    r'5969813e69fd802ade043cd7bab5f00ce6981fab';

/// Provide a controller parametrized by [StudyID]
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

final class InviteCodeFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<InviteCodeFormViewModel, StudyID> {
  InviteCodeFormViewModelFamily._()
    : super(
        retry: null,
        name: r'inviteCodeFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provide a controller parametrized by [StudyID]
  ///
  /// Note: This is not safe to use in widgets (or other providers) that are built
  /// before the [StudyController]'s [Study] is available (see also: [AsyncValue])

  InviteCodeFormViewModelProvider call(StudyID studyId) =>
      InviteCodeFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'inviteCodeFormViewModelProvider';
}
