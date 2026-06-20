// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explain_card_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$explainCardNotifierHash() =>
    r'fe89fd5ff91221070ee621940a2982d759b7d3c8';

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

abstract class _$ExplainCardNotifier
    extends BuildlessAutoDisposeNotifier<AsyncValue<String>> {
  late final String question;
  late final String answer;
  late final String? deckId;

  AsyncValue<String> build({
    required String question,
    required String answer,
    String? deckId,
  });
}

/// See also [ExplainCardNotifier].
@ProviderFor(ExplainCardNotifier)
const explainCardNotifierProvider = ExplainCardNotifierFamily();

/// See also [ExplainCardNotifier].
class ExplainCardNotifierFamily extends Family<AsyncValue<String>> {
  /// See also [ExplainCardNotifier].
  const ExplainCardNotifierFamily();

  /// See also [ExplainCardNotifier].
  ExplainCardNotifierProvider call({
    required String question,
    required String answer,
    String? deckId,
  }) {
    return ExplainCardNotifierProvider(
      question: question,
      answer: answer,
      deckId: deckId,
    );
  }

  @override
  ExplainCardNotifierProvider getProviderOverride(
    covariant ExplainCardNotifierProvider provider,
  ) {
    return call(
      question: provider.question,
      answer: provider.answer,
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
  String? get name => r'explainCardNotifierProvider';
}

/// See also [ExplainCardNotifier].
class ExplainCardNotifierProvider extends AutoDisposeNotifierProviderImpl<
    ExplainCardNotifier, AsyncValue<String>> {
  /// See also [ExplainCardNotifier].
  ExplainCardNotifierProvider({
    required String question,
    required String answer,
    String? deckId,
  }) : this._internal(
          () => ExplainCardNotifier()
            ..question = question
            ..answer = answer
            ..deckId = deckId,
          from: explainCardNotifierProvider,
          name: r'explainCardNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$explainCardNotifierHash,
          dependencies: ExplainCardNotifierFamily._dependencies,
          allTransitiveDependencies:
              ExplainCardNotifierFamily._allTransitiveDependencies,
          question: question,
          answer: answer,
          deckId: deckId,
        );

  ExplainCardNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.question,
    required this.answer,
    required this.deckId,
  }) : super.internal();

  final String question;
  final String answer;
  final String? deckId;

  @override
  AsyncValue<String> runNotifierBuild(
    covariant ExplainCardNotifier notifier,
  ) {
    return notifier.build(
      question: question,
      answer: answer,
      deckId: deckId,
    );
  }

  @override
  Override overrideWith(ExplainCardNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ExplainCardNotifierProvider._internal(
        () => create()
          ..question = question
          ..answer = answer
          ..deckId = deckId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        question: question,
        answer: answer,
        deckId: deckId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ExplainCardNotifier, AsyncValue<String>>
      createElement() {
    return _ExplainCardNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExplainCardNotifierProvider &&
        other.question == question &&
        other.answer == answer &&
        other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, question.hashCode);
    hash = _SystemHash.combine(hash, answer.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExplainCardNotifierRef
    on AutoDisposeNotifierProviderRef<AsyncValue<String>> {
  /// The parameter `question` of this provider.
  String get question;

  /// The parameter `answer` of this provider.
  String get answer;

  /// The parameter `deckId` of this provider.
  String? get deckId;
}

class _ExplainCardNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<ExplainCardNotifier,
        AsyncValue<String>> with ExplainCardNotifierRef {
  _ExplainCardNotifierProviderElement(super.provider);

  @override
  String get question => (origin as ExplainCardNotifierProvider).question;
  @override
  String get answer => (origin as ExplainCardNotifierProvider).answer;
  @override
  String? get deckId => (origin as ExplainCardNotifierProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
