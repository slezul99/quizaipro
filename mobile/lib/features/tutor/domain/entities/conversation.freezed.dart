// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Conversation {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get deckId => throw _privateConstructorUsedError;
  String? get deckTitle => throw _privateConstructorUsedError;
  bool get isPinned => throw _privateConstructorUsedError;
  int get messageCount => throw _privateConstructorUsedError;
  String? get lastMessagePreview => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? deckId,
      String? deckTitle,
      bool isPinned,
      int messageCount,
      String? lastMessagePreview,
      DateTime createdAt,
      DateTime updatedAt,
      bool synced});
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? deckId = freezed,
    Object? deckTitle = freezed,
    Object? isPinned = null,
    Object? messageCount = null,
    Object? lastMessagePreview = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? synced = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: freezed == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String?,
      deckTitle: freezed == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessagePreview: freezed == lastMessagePreview
          ? _value.lastMessagePreview
          : lastMessagePreview // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? deckId,
      String? deckTitle,
      bool isPinned,
      int messageCount,
      String? lastMessagePreview,
      DateTime createdAt,
      DateTime updatedAt,
      bool synced});
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? deckId = freezed,
    Object? deckTitle = freezed,
    Object? isPinned = null,
    Object? messageCount = null,
    Object? lastMessagePreview = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? synced = null,
  }) {
    return _then(_$ConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: freezed == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String?,
      deckTitle: freezed == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      messageCount: null == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastMessagePreview: freezed == lastMessagePreview
          ? _value.lastMessagePreview
          : lastMessagePreview // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl(
      {required this.id,
      required this.title,
      this.deckId,
      this.deckTitle,
      this.isPinned = false,
      this.messageCount = 0,
      this.lastMessagePreview,
      required this.createdAt,
      required this.updatedAt,
      this.synced = false});

  @override
  final String id;
  @override
  final String title;
  @override
  final String? deckId;
  @override
  final String? deckTitle;
  @override
  @JsonKey()
  final bool isPinned;
  @override
  @JsonKey()
  final int messageCount;
  @override
  final String? lastMessagePreview;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool synced;

  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, deckId: $deckId, deckTitle: $deckTitle, isPinned: $isPinned, messageCount: $messageCount, lastMessagePreview: $lastMessagePreview, createdAt: $createdAt, updatedAt: $updatedAt, synced: $synced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.deckTitle, deckTitle) ||
                other.deckTitle == deckTitle) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            (identical(other.lastMessagePreview, lastMessagePreview) ||
                other.lastMessagePreview == lastMessagePreview) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.synced, synced) || other.synced == synced));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, deckId, deckTitle,
      isPinned, messageCount, lastMessagePreview, createdAt, updatedAt, synced);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);
}

abstract class _Conversation implements Conversation {
  const factory _Conversation(
      {required final String id,
      required final String title,
      final String? deckId,
      final String? deckTitle,
      final bool isPinned,
      final int messageCount,
      final String? lastMessagePreview,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final bool synced}) = _$ConversationImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get deckId;
  @override
  String? get deckTitle;
  @override
  bool get isPinned;
  @override
  int get messageCount;
  @override
  String? get lastMessagePreview;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get synced;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
