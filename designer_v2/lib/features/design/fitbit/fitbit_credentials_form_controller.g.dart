// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_credentials_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fitbitCredentialsFormViewModel)
const fitbitCredentialsFormViewModelProvider =
    FitbitCredentialsFormViewModelFamily._();

final class FitbitCredentialsFormViewModelProvider
    extends
        $FunctionalProvider<
          FitbitCredentialsFormViewModel,
          FitbitCredentialsFormViewModel,
          FitbitCredentialsFormViewModel
        >
    with $Provider<FitbitCredentialsFormViewModel> {
  const FitbitCredentialsFormViewModelProvider._({
    required FitbitCredentialsFormViewModelFamily super.from,
    required StudyID super.argument,
  }) : super(
         retry: null,
         name: r'fitbitCredentialsFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fitbitCredentialsFormViewModelHash();

  @override
  String toString() {
    return r'fitbitCredentialsFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<FitbitCredentialsFormViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FitbitCredentialsFormViewModel create(Ref ref) {
    final argument = this.argument as StudyID;
    return fitbitCredentialsFormViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FitbitCredentialsFormViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FitbitCredentialsFormViewModel>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FitbitCredentialsFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fitbitCredentialsFormViewModelHash() =>
    r'd975b7edada5bd981f787fc25f4cdbadada6a79d';

final class FitbitCredentialsFormViewModelFamily extends $Family
    with $FunctionalFamilyOverride<FitbitCredentialsFormViewModel, StudyID> {
  const FitbitCredentialsFormViewModelFamily._()
    : super(
        retry: null,
        name: r'fitbitCredentialsFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FitbitCredentialsFormViewModelProvider call(StudyID studyId) =>
      FitbitCredentialsFormViewModelProvider._(argument: studyId, from: this);

  @override
  String toString() => r'fitbitCredentialsFormViewModelProvider';
}
