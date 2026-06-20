// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_history_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$testHistoryHash() => r'2fde5599ae7232e3425dfe6e7376902bb3ce134b';

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

/// See also [testHistory].
@ProviderFor(testHistory)
const testHistoryProvider = TestHistoryFamily();

/// See also [testHistory].
class TestHistoryFamily extends Family<AsyncValue<List<TestHistoryItem>>> {
  /// See also [testHistory].
  const TestHistoryFamily();

  /// See also [testHistory].
  TestHistoryProvider call({
    required String deckId,
  }) {
    return TestHistoryProvider(
      deckId: deckId,
    );
  }

  @override
  TestHistoryProvider getProviderOverride(
    covariant TestHistoryProvider provider,
  ) {
    return call(
      deckId: provider.deckId,
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
  String? get name => r'testHistoryProvider';
}

/// See also [testHistory].
class TestHistoryProvider
    extends AutoDisposeFutureProvider<List<TestHistoryItem>> {
  /// See also [testHistory].
  TestHistoryProvider({
    required String deckId,
  }) : this._internal(
          (ref) => testHistory(
            ref as TestHistoryRef,
            deckId: deckId,
          ),
          from: testHistoryProvider,
          name: r'testHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$testHistoryHash,
          dependencies: TestHistoryFamily._dependencies,
          allTransitiveDependencies:
              TestHistoryFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  TestHistoryProvider._internal(
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
  Override overrideWith(
    FutureOr<List<TestHistoryItem>> Function(TestHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TestHistoryProvider._internal(
        (ref) => create(ref as TestHistoryRef),
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
  AutoDisposeFutureProviderElement<List<TestHistoryItem>> createElement() {
    return _TestHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TestHistoryProvider && other.deckId == deckId;
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
mixin TestHistoryRef on AutoDisposeFutureProviderRef<List<TestHistoryItem>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _TestHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<TestHistoryItem>>
    with TestHistoryRef {
  _TestHistoryProviderElement(super.provider);

  @override
  String get deckId => (origin as TestHistoryProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
