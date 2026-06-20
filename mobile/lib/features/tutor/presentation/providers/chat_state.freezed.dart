// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChatState {
  String get conversationId => throw _privateConstructorUsedError;
  String get conversationTitle => throw _privateConstructorUsedError;
  String? get deckId => throw _privateConstructorUsedError;
  List<TutorMessage> get messages => throw _privateConstructorUsedError;
  bool get isLoadingHistory => throw _privateConstructorUsedError;
  bool get isStreaming => throw _privateConstructorUsedError;
  String get streamingBuffer => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatStateCopyWith<ChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) then) =
      _$ChatStateCopyWithImpl<$Res, ChatState>;
  @useResult
  $Res call(
      {String conversationId,
      String conversationTitle,
      String? deckId,
      List<TutorMessage> messages,
      bool isLoadingHistory,
      bool isStreaming,
      String streamingBuffer,
      String? errorMessage});
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res, $Val extends ChatState>
    implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? conversationTitle = null,
    Object? deckId = freezed,
    Object? messages = null,
    Object? isLoadingHistory = null,
    Object? isStreaming = null,
    Object? streamingBuffer = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationTitle: null == conversationTitle
          ? _value.conversationTitle
          : conversationTitle // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: freezed == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String?,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<TutorMessage>,
      isLoadingHistory: null == isLoadingHistory
          ? _value.isLoadingHistory
          : isLoadingHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      streamingBuffer: null == streamingBuffer
          ? _value.streamingBuffer
          : streamingBuffer // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatStateImplCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$$ChatStateImplCopyWith(
          _$ChatStateImpl value, $Res Function(_$ChatStateImpl) then) =
      __$$ChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String conversationId,
      String conversationTitle,
      String? deckId,
      List<TutorMessage> messages,
      bool isLoadingHistory,
      bool isStreaming,
      String streamingBuffer,
      String? errorMessage});
}

/// @nodoc
class __$$ChatStateImplCopyWithImpl<$Res>
    extends _$ChatStateCopyWithImpl<$Res, _$ChatStateImpl>
    implements _$$ChatStateImplCopyWith<$Res> {
  __$$ChatStateImplCopyWithImpl(
      _$ChatStateImpl _value, $Res Function(_$ChatStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = null,
    Object? conversationTitle = null,
    Object? deckId = freezed,
    Object? messages = null,
    Object? isLoadingHistory = null,
    Object? isStreaming = null,
    Object? streamingBuffer = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$ChatStateImpl(
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationTitle: null == conversationTitle
          ? _value.conversationTitle
          : conversationTitle // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: freezed == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String?,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<TutorMessage>,
      isLoadingHistory: null == isLoadingHistory
          ? _value.isLoadingHistory
          : isLoadingHistory // ignore: cast_nullable_to_non_nullable
              as bool,
      isStreaming: null == isStreaming
          ? _value.isStreaming
          : isStreaming // ignore: cast_nullable_to_non_nullable
              as bool,
      streamingBuffer: null == streamingBuffer
          ? _value.streamingBuffer
          : streamingBuffer // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ChatStateImpl extends _ChatState {
  const _$ChatStateImpl(
      {required this.conversationId,
      required this.conversationTitle,
      this.deckId,
      final List<TutorMessage> messages = const [],
      this.isLoadingHistory = false,
      this.isStreaming = false,
      this.streamingBuffer = '',
      this.errorMessage})
      : _messages = messages,
        super._();

  @override
  final String conversationId;
  @override
  final String conversationTitle;
  @override
  final String? deckId;
  final List<TutorMessage> _messages;
  @override
  @JsonKey()
  List<TutorMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool isLoadingHistory;
  @override
  @JsonKey()
  final bool isStreaming;
  @override
  @JsonKey()
  final String streamingBuffer;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ChatState(conversationId: $conversationId, conversationTitle: $conversationTitle, deckId: $deckId, messages: $messages, isLoadingHistory: $isLoadingHistory, isStreaming: $isStreaming, streamingBuffer: $streamingBuffer, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatStateImpl &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.conversationTitle, conversationTitle) ||
                other.conversationTitle == conversationTitle) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.isLoadingHistory, isLoadingHistory) ||
                other.isLoadingHistory == isLoadingHistory) &&
            (identical(other.isStreaming, isStreaming) ||
                other.isStreaming == isStreaming) &&
            (identical(other.streamingBuffer, streamingBuffer) ||
                other.streamingBuffer == streamingBuffer) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      conversationId,
      conversationTitle,
      deckId,
      const DeepCollectionEquality().hash(_messages),
      isLoadingHistory,
      isStreaming,
      streamingBuffer,
      errorMessage);

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      __$$ChatStateImplCopyWithImpl<_$ChatStateImpl>(this, _$identity);
}

abstract class _ChatState extends ChatState {
  const factory _ChatState(
      {required final String conversationId,
      required final String conversationTitle,
      final String? deckId,
      final List<TutorMessage> messages,
      final bool isLoadingHistory,
      final bool isStreaming,
      final String streamingBuffer,
      final String? errorMessage}) = _$ChatStateImpl;
  const _ChatState._() : super._();

  @override
  String get conversationId;
  @override
  String get conversationTitle;
  @override
  String? get deckId;
  @override
  List<TutorMessage> get messages;
  @override
  bool get isLoadingHistory;
  @override
  bool get isStreaming;
  @override
  String get streamingBuffer;
  @override
  String? get errorMessage;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatStateImplCopyWith<_$ChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
