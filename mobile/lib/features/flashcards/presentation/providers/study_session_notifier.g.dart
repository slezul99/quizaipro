// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studySessionNotifierHash() =>
    r'796077138f2e0dc879eef008724ce541d5409091';

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

abstract class _$StudySessionNotifier
    extends BuildlessAutoDisposeAsyncNotifier<StudySessionState> {
  late final String deckId;
  late final StudyMode mode;
  late final String deckTitle;

  FutureOr<StudySessionState> build({
    required String deckId,
    required StudyMode mode,
    required String deckTitle,
  });
}

/// See also [StudySessionNotifier].
@ProviderFor(StudySessionNotifier)
const studySessionNotifierProvider = StudySessionNotifierFamily();

/// See also [StudySessionNotifier].
class StudySessionNotifierFamily extends Family<AsyncValue<StudySessionState>> {
  /// See also [StudySessionNotifier].
  const StudySessionNotifierFamily();

  /// See also [StudySessionNotifier].
  StudySessionNotifierProvider call({
    required String deckId,
    required StudyMode mode,
    required String deckTitle,
  }) {
    return StudySessionNotifierProvider(
      deckId: deckId,
      mode: mode,
      deckTitle: deckTitle,
    );
  }

  @override
  StudySessionNotifierProvider getProviderOverride(
    covariant StudySessionNotifierProvider provider,
  ) {
    return call(
      deckId: provider.deckId,
      mode: provider.mode,
      deckTitle: provider.deckTitle,
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
  String? get name => r'studySessionNotifierProvider';
}

/// See also [StudySessionNotifier].
class StudySessionNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    StudySessionNotifier, StudySessionState> {
  /// See also [StudySessionNotifier].
  StudySessionNotifierProvider({
    required String deckId,
    required StudyMode mode,
    required String deckTitle,
  }) : this._internal(
          () => StudySessionNotifier()
            ..deckId = deckId
            ..mode = mode
            ..deckTitle = deckTitle,
          from: studySessionNotifierProvider,
          name: r'studySessionNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$studySessionNotifierHash,
          dependencies: StudySessionNotifierFamily._dependencies,
          allTransitiveDependencies:
              StudySessionNotifierFamily._allTransitiveDependencies,
          deckId: deckId,
          mode: mode,
          deckTitle: deckTitle,
        );

  StudySessionNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
    required this.mode,
    required this.deckTitle,
  }) : super.internal();

  final String deckId;
  final StudyMode mode;
  final String deckTitle;

  @override
  FutureOr<StudySessionState> runNotifierBuild(
    covariant StudySessionNotifier notifier,
  ) {
    return notifier.build(
      deckId: deckId,
      mode: mode,
      deckTitle: deckTitle,
    );
  }

  @override
  Override overrideWith(StudySessionNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: StudySessionNotifierProvider._internal(
        () => create()
          ..deckId = deckId
          ..mode = mode
          ..deckTitle = deckTitle,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
        mode: mode,
        deckTitle: deckTitle,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<StudySessionNotifier,
      StudySessionState> createElement() {
    return _StudySessionNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudySessionNotifierProvider &&
        other.deckId == deckId &&
        other.mode == mode &&
        other.deckTitle == deckTitle;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);
    hash = _SystemHash.combine(hash, deckTitle.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudySessionNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<StudySessionState> {
  /// The parameter `deckId` of this provider.
  String get deckId;

  /// The parameter `mode` of this provider.
  StudyMode get mode;

  /// The parameter `deckTitle` of this provider.
  String get deckTitle;
}

class _StudySessionNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<StudySessionNotifier,
        StudySessionState> with StudySessionNotifierRef {
  _StudySessionNotifierProviderElement(super.provider);

  @override
  String get deckId => (origin as StudySessionNotifierProvider).deckId;
  @override
  StudyMode get mode => (origin as StudySessionNotifierProvider).mode;
  @override
  String get deckTitle => (origin as StudySessionNotifierProvider).deckTitle;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
