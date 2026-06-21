// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_reviews_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckReviewsNotifierHash() =>
    r'3a73a1c8e7f70df03a0eefe0ac07f76413c093b5';

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

abstract class _$DeckReviewsNotifier
    extends BuildlessAutoDisposeAsyncNotifier<DeckReviewsResult> {
  late final String deckId;

  FutureOr<DeckReviewsResult> build(
    String deckId,
  );
}

/// Loads and mutates the reviews for one marketplace deck. Each mutation
/// re-fetches so the aggregate (rating/count) and the list stay consistent.
///
/// Copied from [DeckReviewsNotifier].
@ProviderFor(DeckReviewsNotifier)
const deckReviewsNotifierProvider = DeckReviewsNotifierFamily();

/// Loads and mutates the reviews for one marketplace deck. Each mutation
/// re-fetches so the aggregate (rating/count) and the list stay consistent.
///
/// Copied from [DeckReviewsNotifier].
class DeckReviewsNotifierFamily extends Family<AsyncValue<DeckReviewsResult>> {
  /// Loads and mutates the reviews for one marketplace deck. Each mutation
  /// re-fetches so the aggregate (rating/count) and the list stay consistent.
  ///
  /// Copied from [DeckReviewsNotifier].
  const DeckReviewsNotifierFamily();

  /// Loads and mutates the reviews for one marketplace deck. Each mutation
  /// re-fetches so the aggregate (rating/count) and the list stay consistent.
  ///
  /// Copied from [DeckReviewsNotifier].
  DeckReviewsNotifierProvider call(
    String deckId,
  ) {
    return DeckReviewsNotifierProvider(
      deckId,
    );
  }

  @override
  DeckReviewsNotifierProvider getProviderOverride(
    covariant DeckReviewsNotifierProvider provider,
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
  String? get name => r'deckReviewsNotifierProvider';
}

/// Loads and mutates the reviews for one marketplace deck. Each mutation
/// re-fetches so the aggregate (rating/count) and the list stay consistent.
///
/// Copied from [DeckReviewsNotifier].
class DeckReviewsNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DeckReviewsNotifier, DeckReviewsResult> {
  /// Loads and mutates the reviews for one marketplace deck. Each mutation
  /// re-fetches so the aggregate (rating/count) and the list stay consistent.
  ///
  /// Copied from [DeckReviewsNotifier].
  DeckReviewsNotifierProvider(
    String deckId,
  ) : this._internal(
          () => DeckReviewsNotifier()..deckId = deckId,
          from: deckReviewsNotifierProvider,
          name: r'deckReviewsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckReviewsNotifierHash,
          dependencies: DeckReviewsNotifierFamily._dependencies,
          allTransitiveDependencies:
              DeckReviewsNotifierFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckReviewsNotifierProvider._internal(
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
  FutureOr<DeckReviewsResult> runNotifierBuild(
    covariant DeckReviewsNotifier notifier,
  ) {
    return notifier.build(
      deckId,
    );
  }

  @override
  Override overrideWith(DeckReviewsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeckReviewsNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<DeckReviewsNotifier,
      DeckReviewsResult> createElement() {
    return _DeckReviewsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckReviewsNotifierProvider && other.deckId == deckId;
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
mixin DeckReviewsNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<DeckReviewsResult> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckReviewsNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DeckReviewsNotifier,
        DeckReviewsResult> with DeckReviewsNotifierRef {
  _DeckReviewsNotifierProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckReviewsNotifierProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
