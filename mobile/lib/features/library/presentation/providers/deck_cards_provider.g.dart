// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_cards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deckCardsHash() => r'c797a17ead7a471f9e715cf56484f4ce4a99b5c8';

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

/// All flashcards belonging to a deck the user owns, for the "Cards"
/// section on the library deck detail screen. Local-first via
/// [FlashcardRepository.getCardsForDeck] (same source the study session
/// uses), so it works offline once a deck has been opened before.
///
/// Copied from [deckCards].
@ProviderFor(deckCards)
const deckCardsProvider = DeckCardsFamily();

/// All flashcards belonging to a deck the user owns, for the "Cards"
/// section on the library deck detail screen. Local-first via
/// [FlashcardRepository.getCardsForDeck] (same source the study session
/// uses), so it works offline once a deck has been opened before.
///
/// Copied from [deckCards].
class DeckCardsFamily extends Family<AsyncValue<List<Flashcard>>> {
  /// All flashcards belonging to a deck the user owns, for the "Cards"
  /// section on the library deck detail screen. Local-first via
  /// [FlashcardRepository.getCardsForDeck] (same source the study session
  /// uses), so it works offline once a deck has been opened before.
  ///
  /// Copied from [deckCards].
  const DeckCardsFamily();

  /// All flashcards belonging to a deck the user owns, for the "Cards"
  /// section on the library deck detail screen. Local-first via
  /// [FlashcardRepository.getCardsForDeck] (same source the study session
  /// uses), so it works offline once a deck has been opened before.
  ///
  /// Copied from [deckCards].
  DeckCardsProvider call(
    String deckId,
  ) {
    return DeckCardsProvider(
      deckId,
    );
  }

  @override
  DeckCardsProvider getProviderOverride(
    covariant DeckCardsProvider provider,
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
  String? get name => r'deckCardsProvider';
}

/// All flashcards belonging to a deck the user owns, for the "Cards"
/// section on the library deck detail screen. Local-first via
/// [FlashcardRepository.getCardsForDeck] (same source the study session
/// uses), so it works offline once a deck has been opened before.
///
/// Copied from [deckCards].
class DeckCardsProvider extends AutoDisposeFutureProvider<List<Flashcard>> {
  /// All flashcards belonging to a deck the user owns, for the "Cards"
  /// section on the library deck detail screen. Local-first via
  /// [FlashcardRepository.getCardsForDeck] (same source the study session
  /// uses), so it works offline once a deck has been opened before.
  ///
  /// Copied from [deckCards].
  DeckCardsProvider(
    String deckId,
  ) : this._internal(
          (ref) => deckCards(
            ref as DeckCardsRef,
            deckId,
          ),
          from: deckCardsProvider,
          name: r'deckCardsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deckCardsHash,
          dependencies: DeckCardsFamily._dependencies,
          allTransitiveDependencies: DeckCardsFamily._allTransitiveDependencies,
          deckId: deckId,
        );

  DeckCardsProvider._internal(
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
    FutureOr<List<Flashcard>> Function(DeckCardsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeckCardsProvider._internal(
        (ref) => create(ref as DeckCardsRef),
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
  AutoDisposeFutureProviderElement<List<Flashcard>> createElement() {
    return _DeckCardsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeckCardsProvider && other.deckId == deckId;
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
mixin DeckCardsRef on AutoDisposeFutureProviderRef<List<Flashcard>> {
  /// The parameter `deckId` of this provider.
  String get deckId;
}

class _DeckCardsProviderElement
    extends AutoDisposeFutureProviderElement<List<Flashcard>>
    with DeckCardsRef {
  _DeckCardsProviderElement(super.provider);

  @override
  String get deckId => (origin as DeckCardsProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
