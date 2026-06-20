// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_job_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$generationJobNotifierHash() =>
    r'b3b9cfc7040839b375b04458a367222273ca11f0';

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

abstract class _$GenerationJobNotifier
    extends BuildlessNotifier<AsyncValue<GenerationJob>> {
  late final String jobId;

  AsyncValue<GenerationJob> build({
    required String jobId,
  });
}

/// See also [GenerationJobNotifier].
@ProviderFor(GenerationJobNotifier)
const generationJobNotifierProvider = GenerationJobNotifierFamily();

/// See also [GenerationJobNotifier].
class GenerationJobNotifierFamily extends Family<AsyncValue<GenerationJob>> {
  /// See also [GenerationJobNotifier].
  const GenerationJobNotifierFamily();

  /// See also [GenerationJobNotifier].
  GenerationJobNotifierProvider call({
    required String jobId,
  }) {
    return GenerationJobNotifierProvider(
      jobId: jobId,
    );
  }

  @override
  GenerationJobNotifierProvider getProviderOverride(
    covariant GenerationJobNotifierProvider provider,
  ) {
    return call(
      jobId: provider.jobId,
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
  String? get name => r'generationJobNotifierProvider';
}

/// See also [GenerationJobNotifier].
class GenerationJobNotifierProvider extends NotifierProviderImpl<
    GenerationJobNotifier, AsyncValue<GenerationJob>> {
  /// See also [GenerationJobNotifier].
  GenerationJobNotifierProvider({
    required String jobId,
  }) : this._internal(
          () => GenerationJobNotifier()..jobId = jobId,
          from: generationJobNotifierProvider,
          name: r'generationJobNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$generationJobNotifierHash,
          dependencies: GenerationJobNotifierFamily._dependencies,
          allTransitiveDependencies:
              GenerationJobNotifierFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  GenerationJobNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  AsyncValue<GenerationJob> runNotifierBuild(
    covariant GenerationJobNotifier notifier,
  ) {
    return notifier.build(
      jobId: jobId,
    );
  }

  @override
  Override overrideWith(GenerationJobNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GenerationJobNotifierProvider._internal(
        () => create()..jobId = jobId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  NotifierProviderElement<GenerationJobNotifier, AsyncValue<GenerationJob>>
      createElement() {
    return _GenerationJobNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GenerationJobNotifierProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GenerationJobNotifierRef
    on NotifierProviderRef<AsyncValue<GenerationJob>> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _GenerationJobNotifierProviderElement extends NotifierProviderElement<
    GenerationJobNotifier,
    AsyncValue<GenerationJob>> with GenerationJobNotifierRef {
  _GenerationJobNotifierProviderElement(super.provider);

  @override
  String get jobId => (origin as GenerationJobNotifierProvider).jobId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
