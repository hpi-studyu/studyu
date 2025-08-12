// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_form_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyInfoFormViewModelHash() =>
    r'5c8e15ba88d7868835fab650519ae93111c380aa';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [studyInfoFormViewModel].
@ProviderFor(studyInfoFormViewModel)
const studyInfoFormViewModelProvider = StudyInfoFormViewModelFamily();

/// See also [studyInfoFormViewModel].
class StudyInfoFormViewModelFamily extends Family<StudyInfoFormViewModel> {
  /// See also [studyInfoFormViewModel].
  const StudyInfoFormViewModelFamily();

  /// See also [studyInfoFormViewModel].
  StudyInfoFormViewModelProvider call(String studyId) {
    return StudyInfoFormViewModelProvider(studyId);
  }

  @override
  StudyInfoFormViewModelProvider getProviderOverride(
    covariant StudyInfoFormViewModelProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studyInfoFormViewModelProvider';
}

/// See also [studyInfoFormViewModel].
class StudyInfoFormViewModelProvider
    extends AutoDisposeProvider<StudyInfoFormViewModel> {
  /// See also [studyInfoFormViewModel].
  StudyInfoFormViewModelProvider(String studyId)
    : this._internal(
        (ref) =>
            studyInfoFormViewModel(ref as StudyInfoFormViewModelRef, studyId),
        from: studyInfoFormViewModelProvider,
        name: r'studyInfoFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studyInfoFormViewModelHash,
        dependencies: StudyInfoFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            StudyInfoFormViewModelFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  StudyInfoFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  Override overrideWith(
    StudyInfoFormViewModel Function(StudyInfoFormViewModelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudyInfoFormViewModelProvider._internal(
        (ref) => create(ref as StudyInfoFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<StudyInfoFormViewModel> createElement() {
    return _StudyInfoFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyInfoFormViewModelProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudyInfoFormViewModelRef
    on AutoDisposeProviderRef<StudyInfoFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyInfoFormViewModelProviderElement
    extends AutoDisposeProviderElement<StudyInfoFormViewModel>
    with StudyInfoFormViewModelRef {
  _StudyInfoFormViewModelProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyInfoFormViewModelProvider).studyId;
}

String _$enrollmentFormViewModelHash() =>
    r'd41cdb067044c6a683bb9e3cbf7260561a681657';

/// See also [enrollmentFormViewModel].
@ProviderFor(enrollmentFormViewModel)
const enrollmentFormViewModelProvider = EnrollmentFormViewModelFamily();

/// See also [enrollmentFormViewModel].
class EnrollmentFormViewModelFamily extends Family<EnrollmentFormViewModel> {
  /// See also [enrollmentFormViewModel].
  const EnrollmentFormViewModelFamily();

  /// See also [enrollmentFormViewModel].
  EnrollmentFormViewModelProvider call(String studyId) {
    return EnrollmentFormViewModelProvider(studyId);
  }

  @override
  EnrollmentFormViewModelProvider getProviderOverride(
    covariant EnrollmentFormViewModelProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'enrollmentFormViewModelProvider';
}

/// See also [enrollmentFormViewModel].
class EnrollmentFormViewModelProvider
    extends AutoDisposeProvider<EnrollmentFormViewModel> {
  /// See also [enrollmentFormViewModel].
  EnrollmentFormViewModelProvider(String studyId)
    : this._internal(
        (ref) =>
            enrollmentFormViewModel(ref as EnrollmentFormViewModelRef, studyId),
        from: enrollmentFormViewModelProvider,
        name: r'enrollmentFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$enrollmentFormViewModelHash,
        dependencies: EnrollmentFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            EnrollmentFormViewModelFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  EnrollmentFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  Override overrideWith(
    EnrollmentFormViewModel Function(EnrollmentFormViewModelRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EnrollmentFormViewModelProvider._internal(
        (ref) => create(ref as EnrollmentFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EnrollmentFormViewModel> createElement() {
    return _EnrollmentFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnrollmentFormViewModelProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EnrollmentFormViewModelRef
    on AutoDisposeProviderRef<EnrollmentFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _EnrollmentFormViewModelProviderElement
    extends AutoDisposeProviderElement<EnrollmentFormViewModel>
    with EnrollmentFormViewModelRef {
  _EnrollmentFormViewModelProviderElement(super.provider);

  @override
  String get studyId => (origin as EnrollmentFormViewModelProvider).studyId;
}

String _$screenerQuestionFormViewModelHash() =>
    r'59315db1776e5f6fcc23580a90b137c08d5e6b7f';

/// See also [screenerQuestionFormViewModel].
@ProviderFor(screenerQuestionFormViewModel)
const screenerQuestionFormViewModelProvider =
    ScreenerQuestionFormViewModelFamily();

/// See also [screenerQuestionFormViewModel].
class ScreenerQuestionFormViewModelFamily
    extends Family<ScreenerQuestionFormViewModel> {
  /// See also [screenerQuestionFormViewModel].
  const ScreenerQuestionFormViewModelFamily();

  /// See also [screenerQuestionFormViewModel].
  ScreenerQuestionFormViewModelProvider call(
    ScreenerQuestionFormRouteArgs args,
  ) {
    return ScreenerQuestionFormViewModelProvider(args);
  }

  @override
  ScreenerQuestionFormViewModelProvider getProviderOverride(
    covariant ScreenerQuestionFormViewModelProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'screenerQuestionFormViewModelProvider';
}

/// See also [screenerQuestionFormViewModel].
class ScreenerQuestionFormViewModelProvider
    extends AutoDisposeProvider<ScreenerQuestionFormViewModel> {
  /// See also [screenerQuestionFormViewModel].
  ScreenerQuestionFormViewModelProvider(ScreenerQuestionFormRouteArgs args)
    : this._internal(
        (ref) => screenerQuestionFormViewModel(
          ref as ScreenerQuestionFormViewModelRef,
          args,
        ),
        from: screenerQuestionFormViewModelProvider,
        name: r'screenerQuestionFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$screenerQuestionFormViewModelHash,
        dependencies: ScreenerQuestionFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            ScreenerQuestionFormViewModelFamily._allTransitiveDependencies,
        args: args,
      );

  ScreenerQuestionFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final ScreenerQuestionFormRouteArgs args;

  @override
  Override overrideWith(
    ScreenerQuestionFormViewModel Function(
      ScreenerQuestionFormViewModelRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ScreenerQuestionFormViewModelProvider._internal(
        (ref) => create(ref as ScreenerQuestionFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<ScreenerQuestionFormViewModel> createElement() {
    return _ScreenerQuestionFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScreenerQuestionFormViewModelProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ScreenerQuestionFormViewModelRef
    on AutoDisposeProviderRef<ScreenerQuestionFormViewModel> {
  /// The parameter `args` of this provider.
  ScreenerQuestionFormRouteArgs get args;
}

class _ScreenerQuestionFormViewModelProviderElement
    extends AutoDisposeProviderElement<ScreenerQuestionFormViewModel>
    with ScreenerQuestionFormViewModelRef {
  _ScreenerQuestionFormViewModelProviderElement(super.provider);

  @override
  ScreenerQuestionFormRouteArgs get args =>
      (origin as ScreenerQuestionFormViewModelProvider).args;
}

String _$consentItemFormViewModelHash() =>
    r'2e27c1f83cafe5e2e578b9f5421915d299540c1f';

/// See also [consentItemFormViewModel].
@ProviderFor(consentItemFormViewModel)
const consentItemFormViewModelProvider = ConsentItemFormViewModelFamily();

/// See also [consentItemFormViewModel].
class ConsentItemFormViewModelFamily extends Family<ConsentItemFormViewModel> {
  /// See also [consentItemFormViewModel].
  const ConsentItemFormViewModelFamily();

  /// See also [consentItemFormViewModel].
  ConsentItemFormViewModelProvider call(ConsentItemFormRouteArgs args) {
    return ConsentItemFormViewModelProvider(args);
  }

  @override
  ConsentItemFormViewModelProvider getProviderOverride(
    covariant ConsentItemFormViewModelProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'consentItemFormViewModelProvider';
}

/// See also [consentItemFormViewModel].
class ConsentItemFormViewModelProvider
    extends AutoDisposeProvider<ConsentItemFormViewModel> {
  /// See also [consentItemFormViewModel].
  ConsentItemFormViewModelProvider(ConsentItemFormRouteArgs args)
    : this._internal(
        (ref) =>
            consentItemFormViewModel(ref as ConsentItemFormViewModelRef, args),
        from: consentItemFormViewModelProvider,
        name: r'consentItemFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$consentItemFormViewModelHash,
        dependencies: ConsentItemFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            ConsentItemFormViewModelFamily._allTransitiveDependencies,
        args: args,
      );

  ConsentItemFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final ConsentItemFormRouteArgs args;

  @override
  Override overrideWith(
    ConsentItemFormViewModel Function(ConsentItemFormViewModelRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConsentItemFormViewModelProvider._internal(
        (ref) => create(ref as ConsentItemFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<ConsentItemFormViewModel> createElement() {
    return _ConsentItemFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConsentItemFormViewModelProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConsentItemFormViewModelRef
    on AutoDisposeProviderRef<ConsentItemFormViewModel> {
  /// The parameter `args` of this provider.
  ConsentItemFormRouteArgs get args;
}

class _ConsentItemFormViewModelProviderElement
    extends AutoDisposeProviderElement<ConsentItemFormViewModel>
    with ConsentItemFormViewModelRef {
  _ConsentItemFormViewModelProviderElement(super.provider);

  @override
  ConsentItemFormRouteArgs get args =>
      (origin as ConsentItemFormViewModelProvider).args;
}

String _$interventionsFormViewModelHash() =>
    r'80540b6ba2fe8d2987460f212564504a470d0836';

/// See also [interventionsFormViewModel].
@ProviderFor(interventionsFormViewModel)
const interventionsFormViewModelProvider = InterventionsFormViewModelFamily();

/// See also [interventionsFormViewModel].
class InterventionsFormViewModelFamily
    extends Family<MP23InterventionsFormViewModel> {
  /// See also [interventionsFormViewModel].
  const InterventionsFormViewModelFamily();

  /// See also [interventionsFormViewModel].
  InterventionsFormViewModelProvider call(String studyId) {
    return InterventionsFormViewModelProvider(studyId);
  }

  @override
  InterventionsFormViewModelProvider getProviderOverride(
    covariant InterventionsFormViewModelProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'interventionsFormViewModelProvider';
}

/// See also [interventionsFormViewModel].
class InterventionsFormViewModelProvider
    extends AutoDisposeProvider<MP23InterventionsFormViewModel> {
  /// See also [interventionsFormViewModel].
  InterventionsFormViewModelProvider(String studyId)
    : this._internal(
        (ref) => interventionsFormViewModel(
          ref as InterventionsFormViewModelRef,
          studyId,
        ),
        from: interventionsFormViewModelProvider,
        name: r'interventionsFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$interventionsFormViewModelHash,
        dependencies: InterventionsFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            InterventionsFormViewModelFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  InterventionsFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  Override overrideWith(
    MP23InterventionsFormViewModel Function(
      InterventionsFormViewModelRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InterventionsFormViewModelProvider._internal(
        (ref) => create(ref as InterventionsFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MP23InterventionsFormViewModel> createElement() {
    return _InterventionsFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InterventionsFormViewModelProvider &&
        other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InterventionsFormViewModelRef
    on AutoDisposeProviderRef<MP23InterventionsFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _InterventionsFormViewModelProviderElement
    extends AutoDisposeProviderElement<MP23InterventionsFormViewModel>
    with InterventionsFormViewModelRef {
  _InterventionsFormViewModelProviderElement(super.provider);

  @override
  String get studyId => (origin as InterventionsFormViewModelProvider).studyId;
}

String _$interventionFormViewModelHash() =>
    r'1f661e24b1bfeee6e51a68cb156789bbd0b6fc9c';

/// See also [interventionFormViewModel].
@ProviderFor(interventionFormViewModel)
const interventionFormViewModelProvider = InterventionFormViewModelFamily();

/// See also [interventionFormViewModel].
class InterventionFormViewModelFamily
    extends Family<InterventionFormViewModel> {
  /// See also [interventionFormViewModel].
  const InterventionFormViewModelFamily();

  /// See also [interventionFormViewModel].
  InterventionFormViewModelProvider call(InterventionFormRouteArgs args) {
    return InterventionFormViewModelProvider(args);
  }

  @override
  InterventionFormViewModelProvider getProviderOverride(
    covariant InterventionFormViewModelProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'interventionFormViewModelProvider';
}

/// See also [interventionFormViewModel].
class InterventionFormViewModelProvider
    extends AutoDisposeProvider<InterventionFormViewModel> {
  /// See also [interventionFormViewModel].
  InterventionFormViewModelProvider(InterventionFormRouteArgs args)
    : this._internal(
        (ref) => interventionFormViewModel(
          ref as InterventionFormViewModelRef,
          args,
        ),
        from: interventionFormViewModelProvider,
        name: r'interventionFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$interventionFormViewModelHash,
        dependencies: InterventionFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            InterventionFormViewModelFamily._allTransitiveDependencies,
        args: args,
      );

  InterventionFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final InterventionFormRouteArgs args;

  @override
  Override overrideWith(
    InterventionFormViewModel Function(InterventionFormViewModelRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InterventionFormViewModelProvider._internal(
        (ref) => create(ref as InterventionFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<InterventionFormViewModel> createElement() {
    return _InterventionFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InterventionFormViewModelProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InterventionFormViewModelRef
    on AutoDisposeProviderRef<InterventionFormViewModel> {
  /// The parameter `args` of this provider.
  InterventionFormRouteArgs get args;
}

class _InterventionFormViewModelProviderElement
    extends AutoDisposeProviderElement<InterventionFormViewModel>
    with InterventionFormViewModelRef {
  _InterventionFormViewModelProviderElement(super.provider);

  @override
  InterventionFormRouteArgs get args =>
      (origin as InterventionFormViewModelProvider).args;
}

String _$interventionTaskFormViewModelHash() =>
    r'1b6cdb9b40dcb77121ec70113867a8f4ab2628a8';

/// See also [interventionTaskFormViewModel].
@ProviderFor(interventionTaskFormViewModel)
const interventionTaskFormViewModelProvider =
    InterventionTaskFormViewModelFamily();

/// See also [interventionTaskFormViewModel].
class InterventionTaskFormViewModelFamily
    extends Family<InterventionTaskFormViewModel> {
  /// See also [interventionTaskFormViewModel].
  const InterventionTaskFormViewModelFamily();

  /// See also [interventionTaskFormViewModel].
  InterventionTaskFormViewModelProvider call(
    InterventionTaskFormRouteArgs args,
  ) {
    return InterventionTaskFormViewModelProvider(args);
  }

  @override
  InterventionTaskFormViewModelProvider getProviderOverride(
    covariant InterventionTaskFormViewModelProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'interventionTaskFormViewModelProvider';
}

/// See also [interventionTaskFormViewModel].
class InterventionTaskFormViewModelProvider
    extends AutoDisposeProvider<InterventionTaskFormViewModel> {
  /// See also [interventionTaskFormViewModel].
  InterventionTaskFormViewModelProvider(InterventionTaskFormRouteArgs args)
    : this._internal(
        (ref) => interventionTaskFormViewModel(
          ref as InterventionTaskFormViewModelRef,
          args,
        ),
        from: interventionTaskFormViewModelProvider,
        name: r'interventionTaskFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$interventionTaskFormViewModelHash,
        dependencies: InterventionTaskFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            InterventionTaskFormViewModelFamily._allTransitiveDependencies,
        args: args,
      );

  InterventionTaskFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final InterventionTaskFormRouteArgs args;

  @override
  Override overrideWith(
    InterventionTaskFormViewModel Function(
      InterventionTaskFormViewModelRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InterventionTaskFormViewModelProvider._internal(
        (ref) => create(ref as InterventionTaskFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<InterventionTaskFormViewModel> createElement() {
    return _InterventionTaskFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InterventionTaskFormViewModelProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InterventionTaskFormViewModelRef
    on AutoDisposeProviderRef<InterventionTaskFormViewModel> {
  /// The parameter `args` of this provider.
  InterventionTaskFormRouteArgs get args;
}

class _InterventionTaskFormViewModelProviderElement
    extends AutoDisposeProviderElement<InterventionTaskFormViewModel>
    with InterventionTaskFormViewModelRef {
  _InterventionTaskFormViewModelProviderElement(super.provider);

  @override
  InterventionTaskFormRouteArgs get args =>
      (origin as InterventionTaskFormViewModelProvider).args;
}

String _$measurementsFormViewModelHash() =>
    r'a92c30b523d67c47db86b09bee1d176d8fccc2a5';

/// See also [measurementsFormViewModel].
@ProviderFor(measurementsFormViewModel)
const measurementsFormViewModelProvider = MeasurementsFormViewModelFamily();

/// See also [measurementsFormViewModel].
class MeasurementsFormViewModelFamily
    extends Family<MeasurementsFormViewModel> {
  /// See also [measurementsFormViewModel].
  const MeasurementsFormViewModelFamily();

  /// See also [measurementsFormViewModel].
  MeasurementsFormViewModelProvider call(String studyId) {
    return MeasurementsFormViewModelProvider(studyId);
  }

  @override
  MeasurementsFormViewModelProvider getProviderOverride(
    covariant MeasurementsFormViewModelProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'measurementsFormViewModelProvider';
}

/// See also [measurementsFormViewModel].
class MeasurementsFormViewModelProvider
    extends AutoDisposeProvider<MeasurementsFormViewModel> {
  /// See also [measurementsFormViewModel].
  MeasurementsFormViewModelProvider(String studyId)
    : this._internal(
        (ref) => measurementsFormViewModel(
          ref as MeasurementsFormViewModelRef,
          studyId,
        ),
        from: measurementsFormViewModelProvider,
        name: r'measurementsFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$measurementsFormViewModelHash,
        dependencies: MeasurementsFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            MeasurementsFormViewModelFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  MeasurementsFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  Override overrideWith(
    MeasurementsFormViewModel Function(MeasurementsFormViewModelRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MeasurementsFormViewModelProvider._internal(
        (ref) => create(ref as MeasurementsFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MeasurementsFormViewModel> createElement() {
    return _MeasurementsFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MeasurementsFormViewModelProvider &&
        other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MeasurementsFormViewModelRef
    on AutoDisposeProviderRef<MeasurementsFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _MeasurementsFormViewModelProviderElement
    extends AutoDisposeProviderElement<MeasurementsFormViewModel>
    with MeasurementsFormViewModelRef {
  _MeasurementsFormViewModelProviderElement(super.provider);

  @override
  String get studyId => (origin as MeasurementsFormViewModelProvider).studyId;
}

String _$surveyFormViewModelHash() =>
    r'2cc4aef41c732ff379675a5ce4d5969a04c737ad';

/// See also [surveyFormViewModel].
@ProviderFor(surveyFormViewModel)
const surveyFormViewModelProvider = SurveyFormViewModelFamily();

/// See also [surveyFormViewModel].
class SurveyFormViewModelFamily extends Family<MeasurementSurveyFormViewModel> {
  /// See also [surveyFormViewModel].
  const SurveyFormViewModelFamily();

  /// See also [surveyFormViewModel].
  SurveyFormViewModelProvider call(MeasurementFormRouteArgs args) {
    return SurveyFormViewModelProvider(args);
  }

  @override
  SurveyFormViewModelProvider getProviderOverride(
    covariant SurveyFormViewModelProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'surveyFormViewModelProvider';
}

/// See also [surveyFormViewModel].
class SurveyFormViewModelProvider
    extends AutoDisposeProvider<MeasurementSurveyFormViewModel> {
  /// See also [surveyFormViewModel].
  SurveyFormViewModelProvider(MeasurementFormRouteArgs args)
    : this._internal(
        (ref) => surveyFormViewModel(ref as SurveyFormViewModelRef, args),
        from: surveyFormViewModelProvider,
        name: r'surveyFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$surveyFormViewModelHash,
        dependencies: SurveyFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            SurveyFormViewModelFamily._allTransitiveDependencies,
        args: args,
      );

  SurveyFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final MeasurementFormRouteArgs args;

  @override
  Override overrideWith(
    MeasurementSurveyFormViewModel Function(SurveyFormViewModelRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SurveyFormViewModelProvider._internal(
        (ref) => create(ref as SurveyFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MeasurementSurveyFormViewModel> createElement() {
    return _SurveyFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SurveyFormViewModelProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SurveyFormViewModelRef
    on AutoDisposeProviderRef<MeasurementSurveyFormViewModel> {
  /// The parameter `args` of this provider.
  MeasurementFormRouteArgs get args;
}

class _SurveyFormViewModelProviderElement
    extends AutoDisposeProviderElement<MeasurementSurveyFormViewModel>
    with SurveyFormViewModelRef {
  _SurveyFormViewModelProviderElement(super.provider);

  @override
  MeasurementFormRouteArgs get args =>
      (origin as SurveyFormViewModelProvider).args;
}

String _$surveyQuestionFormViewModelHash() =>
    r'd2b779f1b025110501edde497b421a479b1e059d';

/// See also [surveyQuestionFormViewModel].
@ProviderFor(surveyQuestionFormViewModel)
const surveyQuestionFormViewModelProvider = SurveyQuestionFormViewModelFamily();

/// See also [surveyQuestionFormViewModel].
class SurveyQuestionFormViewModelFamily extends Family<QuestionFormViewModel> {
  /// See also [surveyQuestionFormViewModel].
  const SurveyQuestionFormViewModelFamily();

  /// See also [surveyQuestionFormViewModel].
  SurveyQuestionFormViewModelProvider call(SurveyQuestionFormRouteArgs args) {
    return SurveyQuestionFormViewModelProvider(args);
  }

  @override
  SurveyQuestionFormViewModelProvider getProviderOverride(
    covariant SurveyQuestionFormViewModelProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'surveyQuestionFormViewModelProvider';
}

/// See also [surveyQuestionFormViewModel].
class SurveyQuestionFormViewModelProvider
    extends AutoDisposeProvider<QuestionFormViewModel> {
  /// See also [surveyQuestionFormViewModel].
  SurveyQuestionFormViewModelProvider(SurveyQuestionFormRouteArgs args)
    : this._internal(
        (ref) => surveyQuestionFormViewModel(
          ref as SurveyQuestionFormViewModelRef,
          args,
        ),
        from: surveyQuestionFormViewModelProvider,
        name: r'surveyQuestionFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$surveyQuestionFormViewModelHash,
        dependencies: SurveyQuestionFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            SurveyQuestionFormViewModelFamily._allTransitiveDependencies,
        args: args,
      );

  SurveyQuestionFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final SurveyQuestionFormRouteArgs args;

  @override
  Override overrideWith(
    QuestionFormViewModel Function(SurveyQuestionFormViewModelRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SurveyQuestionFormViewModelProvider._internal(
        (ref) => create(ref as SurveyQuestionFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<QuestionFormViewModel> createElement() {
    return _SurveyQuestionFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SurveyQuestionFormViewModelProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SurveyQuestionFormViewModelRef
    on AutoDisposeProviderRef<QuestionFormViewModel> {
  /// The parameter `args` of this provider.
  SurveyQuestionFormRouteArgs get args;
}

class _SurveyQuestionFormViewModelProviderElement
    extends AutoDisposeProviderElement<QuestionFormViewModel>
    with SurveyQuestionFormViewModelRef {
  _SurveyQuestionFormViewModelProviderElement(super.provider);

  @override
  SurveyQuestionFormRouteArgs get args =>
      (origin as SurveyQuestionFormViewModelProvider).args;
}

String _$reportsFormViewModelHash() =>
    r'570680561e1f2f5cc5c740b221ef2a0d8405bc6f';

/// See also [reportsFormViewModel].
@ProviderFor(reportsFormViewModel)
const reportsFormViewModelProvider = ReportsFormViewModelFamily();

/// See also [reportsFormViewModel].
class ReportsFormViewModelFamily extends Family<ReportsFormViewModel> {
  /// See also [reportsFormViewModel].
  const ReportsFormViewModelFamily();

  /// See also [reportsFormViewModel].
  ReportsFormViewModelProvider call(String studyId) {
    return ReportsFormViewModelProvider(studyId);
  }

  @override
  ReportsFormViewModelProvider getProviderOverride(
    covariant ReportsFormViewModelProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reportsFormViewModelProvider';
}

/// See also [reportsFormViewModel].
class ReportsFormViewModelProvider
    extends AutoDisposeProvider<ReportsFormViewModel> {
  /// See also [reportsFormViewModel].
  ReportsFormViewModelProvider(String studyId)
    : this._internal(
        (ref) => reportsFormViewModel(ref as ReportsFormViewModelRef, studyId),
        from: reportsFormViewModelProvider,
        name: r'reportsFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reportsFormViewModelHash,
        dependencies: ReportsFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            ReportsFormViewModelFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  ReportsFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  Override overrideWith(
    ReportsFormViewModel Function(ReportsFormViewModelRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportsFormViewModelProvider._internal(
        (ref) => create(ref as ReportsFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<ReportsFormViewModel> createElement() {
    return _ReportsFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsFormViewModelProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportsFormViewModelRef on AutoDisposeProviderRef<ReportsFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _ReportsFormViewModelProviderElement
    extends AutoDisposeProviderElement<ReportsFormViewModel>
    with ReportsFormViewModelRef {
  _ReportsFormViewModelProviderElement(super.provider);

  @override
  String get studyId => (origin as ReportsFormViewModelProvider).studyId;
}

String _$reportItemFormViewModelHash() =>
    r'34aad4103b63c267100cf7465127254feef5b90f';

/// See also [reportItemFormViewModel].
@ProviderFor(reportItemFormViewModel)
const reportItemFormViewModelProvider = ReportItemFormViewModelFamily();

/// See also [reportItemFormViewModel].
class ReportItemFormViewModelFamily extends Family<ReportItemFormViewModel> {
  /// See also [reportItemFormViewModel].
  const ReportItemFormViewModelFamily();

  /// See also [reportItemFormViewModel].
  ReportItemFormViewModelProvider call(ReportItemFormRouteArgs args) {
    return ReportItemFormViewModelProvider(args);
  }

  @override
  ReportItemFormViewModelProvider getProviderOverride(
    covariant ReportItemFormViewModelProvider provider,
  ) {
    return call(provider.args);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reportItemFormViewModelProvider';
}

/// See also [reportItemFormViewModel].
class ReportItemFormViewModelProvider
    extends AutoDisposeProvider<ReportItemFormViewModel> {
  /// See also [reportItemFormViewModel].
  ReportItemFormViewModelProvider(ReportItemFormRouteArgs args)
    : this._internal(
        (ref) =>
            reportItemFormViewModel(ref as ReportItemFormViewModelRef, args),
        from: reportItemFormViewModelProvider,
        name: r'reportItemFormViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reportItemFormViewModelHash,
        dependencies: ReportItemFormViewModelFamily._dependencies,
        allTransitiveDependencies:
            ReportItemFormViewModelFamily._allTransitiveDependencies,
        args: args,
      );

  ReportItemFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.args,
  }) : super.internal();

  final ReportItemFormRouteArgs args;

  @override
  Override overrideWith(
    ReportItemFormViewModel Function(ReportItemFormViewModelRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportItemFormViewModelProvider._internal(
        (ref) => create(ref as ReportItemFormViewModelRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        args: args,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<ReportItemFormViewModel> createElement() {
    return _ReportItemFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportItemFormViewModelProvider && other.args == args;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, args.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportItemFormViewModelRef
    on AutoDisposeProviderRef<ReportItemFormViewModel> {
  /// The parameter `args` of this provider.
  ReportItemFormRouteArgs get args;
}

class _ReportItemFormViewModelProviderElement
    extends AutoDisposeProviderElement<ReportItemFormViewModel>
    with ReportItemFormViewModelRef {
  _ReportItemFormViewModelProviderElement(super.provider);

  @override
  ReportItemFormRouteArgs get args =>
      (origin as ReportItemFormViewModelProvider).args;
}

String _$studyPublishValidatorHash() =>
    r'cfbd3f755d6648cc5c1bd08882377aa143120c1f';

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]
///
/// Copied from [studyPublishValidator].
@ProviderFor(studyPublishValidator)
const studyPublishValidatorProvider = StudyPublishValidatorFamily();

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]
///
/// Copied from [studyPublishValidator].
class StudyPublishValidatorFamily extends Family<StudyFormViewModel> {
  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.publish]
  ///
  /// Copied from [studyPublishValidator].
  const StudyPublishValidatorFamily();

  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.publish]
  ///
  /// Copied from [studyPublishValidator].
  StudyPublishValidatorProvider call(String studyId) {
    return StudyPublishValidatorProvider(studyId);
  }

  @override
  StudyPublishValidatorProvider getProviderOverride(
    covariant StudyPublishValidatorProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studyPublishValidatorProvider';
}

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.publish]
///
/// Copied from [studyPublishValidator].
class StudyPublishValidatorProvider
    extends AutoDisposeProvider<StudyFormViewModel> {
  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.publish]
  ///
  /// Copied from [studyPublishValidator].
  StudyPublishValidatorProvider(String studyId)
    : this._internal(
        (ref) =>
            studyPublishValidator(ref as StudyPublishValidatorRef, studyId),
        from: studyPublishValidatorProvider,
        name: r'studyPublishValidatorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studyPublishValidatorHash,
        dependencies: StudyPublishValidatorFamily._dependencies,
        allTransitiveDependencies:
            StudyPublishValidatorFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  StudyPublishValidatorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  Override overrideWith(
    StudyFormViewModel Function(StudyPublishValidatorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudyPublishValidatorProvider._internal(
        (ref) => create(ref as StudyPublishValidatorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<StudyFormViewModel> createElement() {
    return _StudyPublishValidatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyPublishValidatorProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudyPublishValidatorRef on AutoDisposeProviderRef<StudyFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyPublishValidatorProviderElement
    extends AutoDisposeProviderElement<StudyFormViewModel>
    with StudyPublishValidatorRef {
  _StudyPublishValidatorProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyPublishValidatorProvider).studyId;
}

String _$studyTestValidatorHash() =>
    r'208c3b6e26d0c566909efd11b9870dd0a10fb8b1';

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]
///
/// Copied from [studyTestValidator].
@ProviderFor(studyTestValidator)
const studyTestValidatorProvider = StudyTestValidatorFamily();

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]
///
/// Copied from [studyTestValidator].
class StudyTestValidatorFamily extends Family<StudyFormViewModel> {
  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.test]
  ///
  /// Copied from [studyTestValidator].
  const StudyTestValidatorFamily();

  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.test]
  ///
  /// Copied from [studyTestValidator].
  StudyTestValidatorProvider call(String studyId) {
    return StudyTestValidatorProvider(studyId);
  }

  @override
  StudyTestValidatorProvider getProviderOverride(
    covariant StudyTestValidatorProvider provider,
  ) {
    return call(provider.studyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studyTestValidatorProvider';
}

/// Provides the [StudyFormViewModel] for validation purposes with
/// a [StudyFormValidationSet.test]
///
/// Copied from [studyTestValidator].
class StudyTestValidatorProvider
    extends AutoDisposeProvider<StudyFormViewModel> {
  /// Provides the [StudyFormViewModel] for validation purposes with
  /// a [StudyFormValidationSet.test]
  ///
  /// Copied from [studyTestValidator].
  StudyTestValidatorProvider(String studyId)
    : this._internal(
        (ref) => studyTestValidator(ref as StudyTestValidatorRef, studyId),
        from: studyTestValidatorProvider,
        name: r'studyTestValidatorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studyTestValidatorHash,
        dependencies: StudyTestValidatorFamily._dependencies,
        allTransitiveDependencies:
            StudyTestValidatorFamily._allTransitiveDependencies,
        studyId: studyId,
      );

  StudyTestValidatorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyId,
  }) : super.internal();

  final String studyId;

  @override
  Override overrideWith(
    StudyFormViewModel Function(StudyTestValidatorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudyTestValidatorProvider._internal(
        (ref) => create(ref as StudyTestValidatorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studyId: studyId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<StudyFormViewModel> createElement() {
    return _StudyTestValidatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyTestValidatorProvider && other.studyId == studyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudyTestValidatorRef on AutoDisposeProviderRef<StudyFormViewModel> {
  /// The parameter `studyId` of this provider.
  String get studyId;
}

class _StudyTestValidatorProviderElement
    extends AutoDisposeProviderElement<StudyFormViewModel>
    with StudyTestValidatorRef {
  _StudyTestValidatorProviderElement(super.provider);

  @override
  String get studyId => (origin as StudyTestValidatorProvider).studyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
