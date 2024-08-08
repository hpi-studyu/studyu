// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_form_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studyInfoFormViewModelHash() =>
    r'491b4f5a18e4a203bb5f157e7a43c63a22e7e172';

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
  StudyInfoFormViewModelProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyInfoFormViewModelProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyInfoFormViewModelProvider getProviderOverride(
    covariant StudyInfoFormViewModelProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
    );
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
  StudyInfoFormViewModelProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => studyInfoFormViewModel(
            ref as StudyInfoFormViewModelRef,
            studyCreationArgs,
          ),
          from: studyInfoFormViewModelProvider,
          name: r'studyInfoFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyInfoFormViewModelHash,
          dependencies: StudyInfoFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              StudyInfoFormViewModelFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyInfoFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

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
        studyCreationArgs: studyCreationArgs,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<StudyInfoFormViewModel> createElement() {
    return _StudyInfoFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyInfoFormViewModelProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyInfoFormViewModelRef
    on AutoDisposeProviderRef<StudyInfoFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyInfoFormViewModelProviderElement
    extends AutoDisposeProviderElement<StudyInfoFormViewModel>
    with StudyInfoFormViewModelRef {
  _StudyInfoFormViewModelProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyInfoFormViewModelProvider).studyCreationArgs;
}

String _$enrollmentFormViewModelHash() =>
    r'79fd02063c01ee084bb6fafd42187731b4492adf';

/// See also [enrollmentFormViewModel].
@ProviderFor(enrollmentFormViewModel)
const enrollmentFormViewModelProvider = EnrollmentFormViewModelFamily();

/// See also [enrollmentFormViewModel].
class EnrollmentFormViewModelFamily extends Family<EnrollmentFormViewModel> {
  /// See also [enrollmentFormViewModel].
  const EnrollmentFormViewModelFamily();

  /// See also [enrollmentFormViewModel].
  EnrollmentFormViewModelProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return EnrollmentFormViewModelProvider(
      studyCreationArgs,
    );
  }

  @override
  EnrollmentFormViewModelProvider getProviderOverride(
    covariant EnrollmentFormViewModelProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
    );
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
  EnrollmentFormViewModelProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => enrollmentFormViewModel(
            ref as EnrollmentFormViewModelRef,
            studyCreationArgs,
          ),
          from: enrollmentFormViewModelProvider,
          name: r'enrollmentFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$enrollmentFormViewModelHash,
          dependencies: EnrollmentFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              EnrollmentFormViewModelFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  EnrollmentFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

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
        studyCreationArgs: studyCreationArgs,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<EnrollmentFormViewModel> createElement() {
    return _EnrollmentFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnrollmentFormViewModelProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EnrollmentFormViewModelRef
    on AutoDisposeProviderRef<EnrollmentFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _EnrollmentFormViewModelProviderElement
    extends AutoDisposeProviderElement<EnrollmentFormViewModel>
    with EnrollmentFormViewModelRef {
  _EnrollmentFormViewModelProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as EnrollmentFormViewModelProvider).studyCreationArgs;
}

String _$screenerQuestionFormViewModelHash() =>
    r'7d735fa1ad80e5e86b76877b02984a9e180eb5b9';

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
    return ScreenerQuestionFormViewModelProvider(
      args,
    );
  }

  @override
  ScreenerQuestionFormViewModelProvider getProviderOverride(
    covariant ScreenerQuestionFormViewModelProvider provider,
  ) {
    return call(
      provider.args,
    );
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
  ScreenerQuestionFormViewModelProvider(
    ScreenerQuestionFormRouteArgs args,
  ) : this._internal(
          (ref) => screenerQuestionFormViewModel(
            ref as ScreenerQuestionFormViewModelRef,
            args,
          ),
          from: screenerQuestionFormViewModelProvider,
          name: r'screenerQuestionFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
            ScreenerQuestionFormViewModelRef provider)
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
    r'1b1bb1dd213a2f4b07eb84e51155b02e9454cdbe';

/// See also [consentItemFormViewModel].
@ProviderFor(consentItemFormViewModel)
const consentItemFormViewModelProvider = ConsentItemFormViewModelFamily();

/// See also [consentItemFormViewModel].
class ConsentItemFormViewModelFamily extends Family<ConsentItemFormViewModel> {
  /// See also [consentItemFormViewModel].
  const ConsentItemFormViewModelFamily();

  /// See also [consentItemFormViewModel].
  ConsentItemFormViewModelProvider call(
    ConsentItemFormRouteArgs args,
  ) {
    return ConsentItemFormViewModelProvider(
      args,
    );
  }

  @override
  ConsentItemFormViewModelProvider getProviderOverride(
    covariant ConsentItemFormViewModelProvider provider,
  ) {
    return call(
      provider.args,
    );
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
  ConsentItemFormViewModelProvider(
    ConsentItemFormRouteArgs args,
  ) : this._internal(
          (ref) => consentItemFormViewModel(
            ref as ConsentItemFormViewModelRef,
            args,
          ),
          from: consentItemFormViewModelProvider,
          name: r'consentItemFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
    r'466e384be9d5834ffbb76c075cd191849ea6191f';

/// See also [interventionsFormViewModel].
@ProviderFor(interventionsFormViewModel)
const interventionsFormViewModelProvider = InterventionsFormViewModelFamily();

/// See also [interventionsFormViewModel].
class InterventionsFormViewModelFamily
    extends Family<InterventionsFormViewModel> {
  /// See also [interventionsFormViewModel].
  const InterventionsFormViewModelFamily();

  /// See also [interventionsFormViewModel].
  InterventionsFormViewModelProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return InterventionsFormViewModelProvider(
      studyCreationArgs,
    );
  }

  @override
  InterventionsFormViewModelProvider getProviderOverride(
    covariant InterventionsFormViewModelProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
    );
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
    extends AutoDisposeProvider<InterventionsFormViewModel> {
  /// See also [interventionsFormViewModel].
  InterventionsFormViewModelProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => interventionsFormViewModel(
            ref as InterventionsFormViewModelRef,
            studyCreationArgs,
          ),
          from: interventionsFormViewModelProvider,
          name: r'interventionsFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$interventionsFormViewModelHash,
          dependencies: InterventionsFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              InterventionsFormViewModelFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  InterventionsFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

  @override
  Override overrideWith(
    InterventionsFormViewModel Function(InterventionsFormViewModelRef provider)
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
        studyCreationArgs: studyCreationArgs,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<InterventionsFormViewModel> createElement() {
    return _InterventionsFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InterventionsFormViewModelProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin InterventionsFormViewModelRef
    on AutoDisposeProviderRef<InterventionsFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _InterventionsFormViewModelProviderElement
    extends AutoDisposeProviderElement<InterventionsFormViewModel>
    with InterventionsFormViewModelRef {
  _InterventionsFormViewModelProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as InterventionsFormViewModelProvider).studyCreationArgs;
}

String _$interventionFormViewModelHash() =>
    r'977d104a10f56c4f609d5e08cdef7aa1b5d8aaab';

/// See also [interventionFormViewModel].
@ProviderFor(interventionFormViewModel)
const interventionFormViewModelProvider = InterventionFormViewModelFamily();

/// See also [interventionFormViewModel].
class InterventionFormViewModelFamily
    extends Family<InterventionFormViewModel> {
  /// See also [interventionFormViewModel].
  const InterventionFormViewModelFamily();

  /// See also [interventionFormViewModel].
  InterventionFormViewModelProvider call(
    InterventionFormRouteArgs args,
  ) {
    return InterventionFormViewModelProvider(
      args,
    );
  }

  @override
  InterventionFormViewModelProvider getProviderOverride(
    covariant InterventionFormViewModelProvider provider,
  ) {
    return call(
      provider.args,
    );
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
  InterventionFormViewModelProvider(
    InterventionFormRouteArgs args,
  ) : this._internal(
          (ref) => interventionFormViewModel(
            ref as InterventionFormViewModelRef,
            args,
          ),
          from: interventionFormViewModelProvider,
          name: r'interventionFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
    r'58c02adfdf31d7529b49bed1b884d3042f032db0';

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
    return InterventionTaskFormViewModelProvider(
      args,
    );
  }

  @override
  InterventionTaskFormViewModelProvider getProviderOverride(
    covariant InterventionTaskFormViewModelProvider provider,
  ) {
    return call(
      provider.args,
    );
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
  InterventionTaskFormViewModelProvider(
    InterventionTaskFormRouteArgs args,
  ) : this._internal(
          (ref) => interventionTaskFormViewModel(
            ref as InterventionTaskFormViewModelRef,
            args,
          ),
          from: interventionTaskFormViewModelProvider,
          name: r'interventionTaskFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
            InterventionTaskFormViewModelRef provider)
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
    r'57b9b16939dce5249f419fc1b54a2760bde80662';

/// See also [measurementsFormViewModel].
@ProviderFor(measurementsFormViewModel)
const measurementsFormViewModelProvider = MeasurementsFormViewModelFamily();

/// See also [measurementsFormViewModel].
class MeasurementsFormViewModelFamily
    extends Family<MeasurementsFormViewModel> {
  /// See also [measurementsFormViewModel].
  const MeasurementsFormViewModelFamily();

  /// See also [measurementsFormViewModel].
  MeasurementsFormViewModelProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return MeasurementsFormViewModelProvider(
      studyCreationArgs,
    );
  }

  @override
  MeasurementsFormViewModelProvider getProviderOverride(
    covariant MeasurementsFormViewModelProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
    );
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
  MeasurementsFormViewModelProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => measurementsFormViewModel(
            ref as MeasurementsFormViewModelRef,
            studyCreationArgs,
          ),
          from: measurementsFormViewModelProvider,
          name: r'measurementsFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$measurementsFormViewModelHash,
          dependencies: MeasurementsFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              MeasurementsFormViewModelFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  MeasurementsFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

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
        studyCreationArgs: studyCreationArgs,
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
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MeasurementsFormViewModelRef
    on AutoDisposeProviderRef<MeasurementsFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _MeasurementsFormViewModelProviderElement
    extends AutoDisposeProviderElement<MeasurementsFormViewModel>
    with MeasurementsFormViewModelRef {
  _MeasurementsFormViewModelProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as MeasurementsFormViewModelProvider).studyCreationArgs;
}

String _$surveyFormViewModelHash() =>
    r'5b3cc0f61f754cde8800ca166fbfb6a25bc3632a';

/// See also [surveyFormViewModel].
@ProviderFor(surveyFormViewModel)
const surveyFormViewModelProvider = SurveyFormViewModelFamily();

/// See also [surveyFormViewModel].
class SurveyFormViewModelFamily extends Family<MeasurementSurveyFormViewModel> {
  /// See also [surveyFormViewModel].
  const SurveyFormViewModelFamily();

  /// See also [surveyFormViewModel].
  SurveyFormViewModelProvider call(
    MeasurementFormRouteArgs args,
  ) {
    return SurveyFormViewModelProvider(
      args,
    );
  }

  @override
  SurveyFormViewModelProvider getProviderOverride(
    covariant SurveyFormViewModelProvider provider,
  ) {
    return call(
      provider.args,
    );
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
  SurveyFormViewModelProvider(
    MeasurementFormRouteArgs args,
  ) : this._internal(
          (ref) => surveyFormViewModel(
            ref as SurveyFormViewModelRef,
            args,
          ),
          from: surveyFormViewModelProvider,
          name: r'surveyFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
    r'8359acab6df34eec28b3523b6e0c22cbfa001b66';

/// See also [surveyQuestionFormViewModel].
@ProviderFor(surveyQuestionFormViewModel)
const surveyQuestionFormViewModelProvider = SurveyQuestionFormViewModelFamily();

/// See also [surveyQuestionFormViewModel].
class SurveyQuestionFormViewModelFamily extends Family<QuestionFormViewModel> {
  /// See also [surveyQuestionFormViewModel].
  const SurveyQuestionFormViewModelFamily();

  /// See also [surveyQuestionFormViewModel].
  SurveyQuestionFormViewModelProvider call(
    SurveyQuestionFormRouteArgs args,
  ) {
    return SurveyQuestionFormViewModelProvider(
      args,
    );
  }

  @override
  SurveyQuestionFormViewModelProvider getProviderOverride(
    covariant SurveyQuestionFormViewModelProvider provider,
  ) {
    return call(
      provider.args,
    );
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
  SurveyQuestionFormViewModelProvider(
    SurveyQuestionFormRouteArgs args,
  ) : this._internal(
          (ref) => surveyQuestionFormViewModel(
            ref as SurveyQuestionFormViewModelRef,
            args,
          ),
          from: surveyQuestionFormViewModelProvider,
          name: r'surveyQuestionFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
    r'd959f254f4aa1b139ba72a22193176fd316ebd40';

/// See also [reportsFormViewModel].
@ProviderFor(reportsFormViewModel)
const reportsFormViewModelProvider = ReportsFormViewModelFamily();

/// See also [reportsFormViewModel].
class ReportsFormViewModelFamily extends Family<ReportsFormViewModel> {
  /// See also [reportsFormViewModel].
  const ReportsFormViewModelFamily();

  /// See also [reportsFormViewModel].
  ReportsFormViewModelProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return ReportsFormViewModelProvider(
      studyCreationArgs,
    );
  }

  @override
  ReportsFormViewModelProvider getProviderOverride(
    covariant ReportsFormViewModelProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
    );
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
  ReportsFormViewModelProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => reportsFormViewModel(
            ref as ReportsFormViewModelRef,
            studyCreationArgs,
          ),
          from: reportsFormViewModelProvider,
          name: r'reportsFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportsFormViewModelHash,
          dependencies: ReportsFormViewModelFamily._dependencies,
          allTransitiveDependencies:
              ReportsFormViewModelFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  ReportsFormViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

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
        studyCreationArgs: studyCreationArgs,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<ReportsFormViewModel> createElement() {
    return _ReportsFormViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportsFormViewModelProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReportsFormViewModelRef on AutoDisposeProviderRef<ReportsFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _ReportsFormViewModelProviderElement
    extends AutoDisposeProviderElement<ReportsFormViewModel>
    with ReportsFormViewModelRef {
  _ReportsFormViewModelProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as ReportsFormViewModelProvider).studyCreationArgs;
}

String _$reportItemFormViewModelHash() =>
    r'80f9f4f57288fa4f24c7ed6f98545f5d5f5bbf9f';

/// See also [reportItemFormViewModel].
@ProviderFor(reportItemFormViewModel)
const reportItemFormViewModelProvider = ReportItemFormViewModelFamily();

/// See also [reportItemFormViewModel].
class ReportItemFormViewModelFamily extends Family<ReportItemFormViewModel> {
  /// See also [reportItemFormViewModel].
  const ReportItemFormViewModelFamily();

  /// See also [reportItemFormViewModel].
  ReportItemFormViewModelProvider call(
    ReportItemFormRouteArgs args,
  ) {
    return ReportItemFormViewModelProvider(
      args,
    );
  }

  @override
  ReportItemFormViewModelProvider getProviderOverride(
    covariant ReportItemFormViewModelProvider provider,
  ) {
    return call(
      provider.args,
    );
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
  ReportItemFormViewModelProvider(
    ReportItemFormRouteArgs args,
  ) : this._internal(
          (ref) => reportItemFormViewModel(
            ref as ReportItemFormViewModelRef,
            args,
          ),
          from: reportItemFormViewModelProvider,
          name: r'reportItemFormViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
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
    r'c5b3ce0f03a611b437ba726bab479d6de27577b1';

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
  StudyPublishValidatorProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyPublishValidatorProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyPublishValidatorProvider getProviderOverride(
    covariant StudyPublishValidatorProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
    );
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
  StudyPublishValidatorProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => studyPublishValidator(
            ref as StudyPublishValidatorRef,
            studyCreationArgs,
          ),
          from: studyPublishValidatorProvider,
          name: r'studyPublishValidatorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyPublishValidatorHash,
          dependencies: StudyPublishValidatorFamily._dependencies,
          allTransitiveDependencies:
              StudyPublishValidatorFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyPublishValidatorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

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
        studyCreationArgs: studyCreationArgs,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<StudyFormViewModel> createElement() {
    return _StudyPublishValidatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyPublishValidatorProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyPublishValidatorRef on AutoDisposeProviderRef<StudyFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyPublishValidatorProviderElement
    extends AutoDisposeProviderElement<StudyFormViewModel>
    with StudyPublishValidatorRef {
  _StudyPublishValidatorProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyPublishValidatorProvider).studyCreationArgs;
}

String _$studyTestValidatorHash() =>
    r'69986be5facc3c1e88ea111694fd90939fd03c8d';

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
  StudyTestValidatorProvider call(
    StudyCreationArgs studyCreationArgs,
  ) {
    return StudyTestValidatorProvider(
      studyCreationArgs,
    );
  }

  @override
  StudyTestValidatorProvider getProviderOverride(
    covariant StudyTestValidatorProvider provider,
  ) {
    return call(
      provider.studyCreationArgs,
    );
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
  StudyTestValidatorProvider(
    StudyCreationArgs studyCreationArgs,
  ) : this._internal(
          (ref) => studyTestValidator(
            ref as StudyTestValidatorRef,
            studyCreationArgs,
          ),
          from: studyTestValidatorProvider,
          name: r'studyTestValidatorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studyTestValidatorHash,
          dependencies: StudyTestValidatorFamily._dependencies,
          allTransitiveDependencies:
              StudyTestValidatorFamily._allTransitiveDependencies,
          studyCreationArgs: studyCreationArgs,
        );

  StudyTestValidatorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studyCreationArgs,
  }) : super.internal();

  final StudyCreationArgs studyCreationArgs;

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
        studyCreationArgs: studyCreationArgs,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<StudyFormViewModel> createElement() {
    return _StudyTestValidatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudyTestValidatorProvider &&
        other.studyCreationArgs == studyCreationArgs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studyCreationArgs.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StudyTestValidatorRef on AutoDisposeProviderRef<StudyFormViewModel> {
  /// The parameter `studyCreationArgs` of this provider.
  StudyCreationArgs get studyCreationArgs;
}

class _StudyTestValidatorProviderElement
    extends AutoDisposeProviderElement<StudyFormViewModel>
    with StudyTestValidatorRef {
  _StudyTestValidatorProviderElement(super.provider);

  @override
  StudyCreationArgs get studyCreationArgs =>
      (origin as StudyTestValidatorProvider).studyCreationArgs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
