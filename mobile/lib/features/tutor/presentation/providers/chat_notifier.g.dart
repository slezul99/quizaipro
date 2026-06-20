// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatNotifierHash() => r'd3298921cc74d236e34ee95449e4c7f79780098f';

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

abstract class _$ChatNotifier extends BuildlessNotifier<ChatState> {
  late final String conversationId;
  late final String conversationTitle;
  late final String? deckId;

  ChatState build({
    required String conversationId,
    required String conversationTitle,
    String? deckId,
  });
}

/// See also [ChatNotifier].
@ProviderFor(ChatNotifier)
const chatNotifierProvider = ChatNotifierFamily();

/// See also [ChatNotifier].
class ChatNotifierFamily extends Family<ChatState> {
  /// See also [ChatNotifier].
  const ChatNotifierFamily();

  /// See also [ChatNotifier].
  ChatNotifierProvider call({
    required String conversationId,
    required String conversationTitle,
    String? deckId,
  }) {
    return ChatNotifierProvider(
      conversationId: conversationId,
      conversationTitle: conversationTitle,
      deckId: deckId,
    );
  }

  @override
  ChatNotifierProvider getProviderOverride(
    covariant ChatNotifierProvider provider,
  ) {
    return call(
      conversationId: provider.conversationId,
      conversationTitle: provider.conversationTitle,
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
  String? get name => r'chatNotifierProvider';
}

/// See also [ChatNotifier].
class ChatNotifierProvider
    extends NotifierProviderImpl<ChatNotifier, ChatState> {
  /// See also [ChatNotifier].
  ChatNotifierProvider({
    required String conversationId,
    required String conversationTitle,
    String? deckId,
  }) : this._internal(
          () => ChatNotifier()
            ..conversationId = conversationId
            ..conversationTitle = conversationTitle
            ..deckId = deckId,
          from: chatNotifierProvider,
          name: r'chatNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatNotifierHash,
          dependencies: ChatNotifierFamily._dependencies,
          allTransitiveDependencies:
              ChatNotifierFamily._allTransitiveDependencies,
          conversationId: conversationId,
          conversationTitle: conversationTitle,
          deckId: deckId,
        );

  ChatNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
    required this.conversationTitle,
    required this.deckId,
  }) : super.internal();

  final String conversationId;
  final String conversationTitle;
  final String? deckId;

  @override
  ChatState runNotifierBuild(
    covariant ChatNotifier notifier,
  ) {
    return notifier.build(
      conversationId: conversationId,
      conversationTitle: conversationTitle,
      deckId: deckId,
    );
  }

  @override
  Override overrideWith(ChatNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatNotifierProvider._internal(
        () => create()
          ..conversationId = conversationId
          ..conversationTitle = conversationTitle
          ..deckId = deckId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
        conversationTitle: conversationTitle,
        deckId: deckId,
      ),
    );
  }

  @override
  NotifierProviderElement<ChatNotifier, ChatState> createElement() {
    return _ChatNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatNotifierProvider &&
        other.conversationId == conversationId &&
        other.conversationTitle == conversationTitle &&
        other.deckId == deckId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);
    hash = _SystemHash.combine(hash, conversationTitle.hashCode);
    hash = _SystemHash.combine(hash, deckId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatNotifierRef on NotifierProviderRef<ChatState> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;

  /// The parameter `conversationTitle` of this provider.
  String get conversationTitle;

  /// The parameter `deckId` of this provider.
  String? get deckId;
}

class _ChatNotifierProviderElement
    extends NotifierProviderElement<ChatNotifier, ChatState>
    with ChatNotifierRef {
  _ChatNotifierProviderElement(super.provider);

  @override
  String get conversationId => (origin as ChatNotifierProvider).conversationId;
  @override
  String get conversationTitle =>
      (origin as ChatNotifierProvider).conversationTitle;
  @override
  String? get deckId => (origin as ChatNotifierProvider).deckId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
