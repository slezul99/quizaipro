// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_detail_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckDetailNotifierHash() =>
    r'1da6f6b94489e6b40c50327851920e2248865433';

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

abstract class _$DeckDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<DeckDetailState> {
  late final String deckId;

  FutureOr<DeckDetailState> build(
    String deckId,
  );
}

/// See also [DeckDetailNotifier].
@ProviderFor(DeckDetailNotifier)
const deckDetailNotifierProvider = DeckDetailNotifierFamily();

/// See also [DeckDetailNotifier].
class DeckDetailNotifierFamily extends Family<AsyncValue<DeckDetailState>> {
  /// See also [DeckDetailNotifier].
  const DeckDetailNotifierFamily();

  /// See also [DeckDetailNotifier].
  DeckDetailNotifierProvider call(
    String deckId,
  ) {
    return DeckDetailNotifierProvider(
      deckId,
    );
  }

  @override
  DeckDetailNotifierProvider getProviderOverride(
    covariant DeckDetailNotifierProvider provider,
  ) {
    return call(
      provider.deckId,
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
  String? get name => r'deckDetailNotifierProvider';
}

/// See also [DeckDetailNotifier].
class DeckDetailNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DeckDetailNotifier, DeckDetailState> {
  /// See also [DeckDetailNotifier].
  DeckDetailNotifierProvider(
    String deckId,
  ) : this._internal(
          () => DeckDetailNotifier()..deckId = deckId,
          from: deckDetailNotifierProvider,
          name: r'deckDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckDetailNotifierHash,
          dependencies: DeckDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              DeckDetailNotifierFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
  }) : super.internal();

  final String deckId;

  @override
  FutureOr<DeckDetailState> runNotifierBuild(
    covariant DeckDetailNotifier notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(DeckDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeckDetailNotifierProvider._internal(
        () => create()..deckId = deckId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DeckDetailNotifier, DeckDetailState>
      createElement() {
    return _DeckDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckDetailNotifierProvider && other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeckDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<DeckDetailState> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckDetailNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DeckDetailNotifier,
        DeckDetailState> with DeckDetailNotifierRef {
  _DeckDetailNotifierProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckDetailNotifierProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
