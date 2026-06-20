// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tutor_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TutorMessage {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError;

  /// Create a copy of TutorMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TutorMessageCopyWith<TutorMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TutorMessageCopyWith<$Res> {
  factory $TutorMessageCopyWith(
          TutorMessage value, $Res Function(TutorMessage) then) =
      _$TutorMessageCopyWithImpl<$Res, TutorMessage>;
  @useResult
  $Res call(
      {String id,
      String conversationId,
      MessageRole role,
      String content,
      DateTime createdAt,
      bool isStreaming,
      bool synced});
}

/// @nodoc
class _$TutorMessageCopyWithImpl<$Res, $Val extends TutorMessage>
    implements $TutorMessageCopyWith<$Res> {
  _$TutorMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TutorMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isStreaming = null,
    Object? synced = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TutorMessageImplCopyWith<$Res>
    implements $TutorMessageCopyWith<$Res> {
  factory _$$TutorMessageImplCopyWith(
          _$TutorMessageImpl value, $Res Function(_$TutorMessageImpl) then) =
      __$$TutorMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String conversationId,
      MessageRole role,
      String content,
      DateTime createdAt,
      bool isStreaming,
      bool synced});
}

/// @nodoc
class __$$TutorMessageImplCopyWithImpl<$Res>
    extends _$TutorMessageCopyWithImpl<$Res, _$TutorMessageImpl>
    implements _$$TutorMessageImplCopyWith<$Res> {
  __$$TutorMessageImplCopyWithImpl(
      _$TutorMessageImpl _value, $Res Function(_$TutorMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of TutorMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? role = null,
    Object? content = null,
    Object? createdAt = null,
    Object? isStreaming = null,
    Object? synced = null,
  }) {
    return _then(_$TutorMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as MessageRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      synced: null == synced
          ? _value.synced
          : synced // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TutorMessageImpl extends _TutorMessage {
  const _$TutorMessageImpl(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      required this.createdAt,
      this.isStreaming = false,
      this.synced = false})
      : super._();

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final MessageRole role;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final bool synced;

  @override
  String toString() {
    return 'TutorMessage(id: $id, conversationId: $conversationId, role: $role, content: $content, createdAt: $createdAt, isStreaming: $isStreaming, synced: $synced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TutorMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.synced, synced) || other.synced == synced));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, conversationId, role,
      content, createdAt, isStreaming, synced);

  /// Create a copy of TutorMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TutorMessageImplCopyWith<_$TutorMessageImpl> get copyWith =>
      __$$TutorMessageImplCopyWithImpl<_$TutorMessageImpl>(this, _$identity);
}

abstract class _TutorMessage extends TutorMessage {
  const factory _TutorMessage(
      {required final String id,
      required final String conversationId,
      required final MessageRole role,
      required final String content,
      required final DateTime createdAt,
      final bool isStreaming,
      final bool synced}) = _$TutorMessageImpl;
  const _TutorMessage._() : super._();

  @override
  String get id;
  @override
  String get conversationId;
  @override
  MessageRole get role;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  bool get isStreaming;
  @override
  bool get synced;

  /// Create a copy of TutorMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TutorMessageImplCopyWith<_$TutorMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
