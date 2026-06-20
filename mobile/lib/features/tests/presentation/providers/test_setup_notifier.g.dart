// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_setup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$testSetupNotifierHash() => r'dbd75a667134d27800e4871f7f20a24572e9fd91';

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

abstract class _$TestSetupNotifier
    extends BuildlessAutoDisposeNotifier<TestSetupState> {
  late final String deckId;
  late final String deckTitle;

  TestSetupState build({
    required String deckId,
    required String deckTitle,
  });
}

/// See also [TestSetupNotifier].
@ProviderFor(TestSetupNotifier)
const testSetupNotifierProvider = TestSetupNotifierFamily();

/// See also [TestSetupNotifier].
class TestSetupNotifierFamily extends Family<TestSetupState> {
  /// See also [TestSetupNotifier].
  const TestSetupNotifierFamily();

  /// See also [TestSetupNotifier].
  TestSetupNotifierProvider call({
    required String deckId,
    required String deckTitle,
  }) {
    return TestSetupNotifierProvider(
      deckId: deckId,
      deckTitle: deckTitle,
    );
  }

  @override
  TestSetupNotifierProvider getProviderOverride(
    covariant TestSetupNotifierProvider provider,
  ) {
    return call(
      deckId: provider.deckId,
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
  String? get name => r'testSetupNotifierProvider';
}

/// See also [TestSetupNotifier].
class TestSetupNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TestSetupNotifier, TestSetupState> {
  /// See also [TestSetupNotifier].
  TestSetupNotifierProvider({
    required String deckId,
    required String deckTitle,
  }) : this._internal(
          () => TestSetupNotifier()
            ..deckId = deckId
            ..deckTitle = deckTitle,
          from: testSetupNotifierProvider,
          name: r'testSetupNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$testSetupNotifierHash,
          dependencies: TestSetupNotifierFamily._dependencies,
          allTransitiveDependencies:
              TestSetupNotifierFamily._allTransitiveDependencies,
          deckId: deckId,
          deckTitle: deckTitle,
        );

  TestSetupNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deckId,
    required this.deckTitle,
  }) : super.internal();

  final String deckId;
  final String deckTitle;

  @override
  TestSetupState runNotifierBuild(
    covariant TestSetupNotifier notifier,
  ) {
    return notifier.build(
      deckId: deckId,
      deckTitle: deckTitle,
    );
  }

  @override
  Override overrideWith(TestSetupNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TestSetupNotifierProvider._internal(
        () => create()
          ..deckId = deckId
          ..deckTitle = deckTitle,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deckId: deckId,
        deckTitle: deckTitle,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TestSetupNotifier, TestSetupState>
      createElement() {
    return _TestSetupNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TestSetupNotifierProvider &&
        other.deckId == deckId &&
        other.deckTitle == deckTitle;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);
    hash = _SystemHash.combine(hash, deckTitle.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TestSetupNotifierRef on AutoDisposeNotifierProviderRef<TestSetupState> {
  /// The parameter `deckId` of this provider.
  String get deckId;

  /// The parameter `deckTitle` of this provider.
  String get deckTitle;
}

class _TestSetupNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TestSetupNotifier,
        TestSetupState> with TestSetupNotifierRef {
  _TestSetupNotifierProviderElement(super.provider);

  @override
  String get deckId => (origin as TestSetupNotifierProvider).deckId;
  @override
  String get deckTitle => (origin as TestSetupNotifierProvider).deckTitle;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
