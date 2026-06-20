// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StudySessionState {
  List<StudyCard> get queue => throw _privateConstructorUsedError;
  int get currentIndex => throw _privateConstructorUsedError;
  bool get isCardFlipped => throw _privateConstructorUsedError;
  SessionStats get stats => throw _privateConstructorUsedError;
  StudyMode get mode => throw _privateConstructorUsedError;
  String get deckId => throw _privateConstructorUsedError;
  String get deckTitle => throw _privateConstructorUsedError;
  bool get isComplete => throw _privateConstructorUsedError;
  bool get isSavingSession => throw _privateConstructorUsedError;
  String? get saveError => throw _privateConstructorUsedError;

  /// Create a copy of StudySessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudySessionStateCopyWith<StudySessionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudySessionStateCopyWith<$Res> {
  factory $StudySessionStateCopyWith(
          StudySessionState value, $Res Function(StudySessionState) then) =
      _$StudySessionStateCopyWithImpl<$Res, StudySessionState>;
  @useResult
  $Res call(
      {List<StudyCard> queue,
      int currentIndex,
      bool isCardFlipped,
      SessionStats stats,
      StudyMode mode,
      String deckId,
      String deckTitle,
      bool isComplete,
      bool isSavingSession,
      String? saveError});

  $SessionStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$StudySessionStateCopyWithImpl<$Res, $Val extends StudySessionState>
    implements $StudySessionStateCopyWith<$Res> {
  _$StudySessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudySessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queue = null,
    Object? currentIndex = null,
    Object? isCardFlipped = null,
    Object? stats = null,
    Object? mode = null,
    Object? deckId = null,
    Object? deckTitle = null,
    Object? isComplete = null,
    Object? isSavingSession = null,
    Object? saveError = freezed,
  }) {
    return _then(_value.copyWith(
      queue: null == queue
          ? _value.queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<StudyCard>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isCardFlipped: null == isCardFlipped
          ? _value.isCardFlipped
          : isCardFlipped // ignore: cast_nullable_to_non_nullable
              as bool,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as SessionStats,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as StudyMode,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isSavingSession: null == isSavingSession
          ? _value.isSavingSession
          : isSavingSession // ignore: cast_nullable_to_non_nullable
              as bool,
      saveError: freezed == saveError
          ? _value.saveError
          : saveError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of StudySessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SessionStatsCopyWith<$Res> get stats {
    return $SessionStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudySessionStateImplCopyWith<$Res>
    implements $StudySessionStateCopyWith<$Res> {
  factory _$$StudySessionStateImplCopyWith(_$StudySessionStateImpl value,
          $Res Function(_$StudySessionStateImpl) then) =
      __$$StudySessionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<StudyCard> queue,
      int currentIndex,
      bool isCardFlipped,
      SessionStats stats,
      StudyMode mode,
      String deckId,
      String deckTitle,
      bool isComplete,
      bool isSavingSession,
      String? saveError});

  @override
  $SessionStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$StudySessionStateImplCopyWithImpl<$Res>
    extends _$StudySessionStateCopyWithImpl<$Res, _$StudySessionStateImpl>
    implements _$$StudySessionStateImplCopyWith<$Res> {
  __$$StudySessionStateImplCopyWithImpl(_$StudySessionStateImpl _value,
      $Res Function(_$StudySessionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudySessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? queue = null,
    Object? currentIndex = null,
    Object? isCardFlipped = null,
    Object? stats = null,
    Object? mode = null,
    Object? deckId = null,
    Object? deckTitle = null,
    Object? isComplete = null,
    Object? isSavingSession = null,
    Object? saveError = freezed,
  }) {
    return _then(_$StudySessionStateImpl(
      queue: null == queue
          ? _value._queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<StudyCard>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isCardFlipped: null == isCardFlipped
          ? _value.isCardFlipped
          : isCardFlipped // ignore: cast_nullable_to_non_nullable
              as bool,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as SessionStats,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as StudyMode,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
      isComplete: null == isComplete
          ? _value.isComplete
          : isComplete // ignore: cast_nullable_to_non_nullable
              as bool,
      isSavingSession: null == isSavingSession
          ? _value.isSavingSession
          : isSavingSession // ignore: cast_nullable_to_non_nullable
              as bool,
      saveError: freezed == saveError
          ? _value.saveError
          : saveError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$StudySessionStateImpl extends _StudySessionState {
  const _$StudySessionStateImpl(
      {required final List<StudyCard> queue,
      required this.currentIndex,
      required this.isCardFlipped,
      required this.stats,
      required this.mode,
      required this.deckId,
      required this.deckTitle,
      this.isComplete = false,
      this.isSavingSession = false,
      this.saveError})
      : _queue = queue,
        super._();

  final List<StudyCard> _queue;
  @override
  List<StudyCard> get queue {
    if (_queue is EqualUnmodifiableListView) return _queue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queue);
  }

  @override
  final int currentIndex;
  @override
  final bool isCardFlipped;
  @override
  final SessionStats stats;
  @override
  final StudyMode mode;
  @override
  final String deckId;
  @override
  final String deckTitle;
  @override
  @JsonKey()
  final bool isComplete;
  @override
  @JsonKey()
  final bool isSavingSession;
  @override
  final String? saveError;

  @override
  String toString() {
    return 'StudySessionState(queue: $queue, currentIndex: $currentIndex, isCardFlipped: $isCardFlipped, stats: $stats, mode: $mode, deckId: $deckId, deckTitle: $deckTitle, isComplete: $isComplete, isSavingSession: $isSavingSession, saveError: $saveError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudySessionStateImpl &&
            const DeepCollectionEquality().equals(other._queue, _queue) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.isCardFlipped, isCardFlipped) ||
                other.isCardFlipped == isCardFlipped) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.deckTitle, deckTitle) ||
                other.deckTitle == deckTitle) &&
            (identical(other.isComplete, isComplete) ||
                other.isComplete == isComplete) &&
            (identical(other.isSavingSession, isSavingSession) ||
                other.isSavingSession == isSavingSession) &&
            (identical(other.saveError, saveError) ||
                other.saveError == saveError));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_queue),
      currentIndex,
      isCardFlipped,
      stats,
      mode,
      deckId,
      deckTitle,
      isComplete,
      isSavingSession,
      saveError);

  /// Create a copy of StudySessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudySessionStateImplCopyWith<_$StudySessionStateImpl> get copyWith =>
      __$$StudySessionStateImplCopyWithImpl<_$StudySessionStateImpl>(
          this, _$identity);
}

abstract class _StudySessionState extends StudySessionState {
  const factory _StudySessionState(
      {required final List<StudyCard> queue,
      required final int currentIndex,
      required final bool isCardFlipped,
      required final SessionStats stats,
      required final StudyMode mode,
      required final String deckId,
      required final String deckTitle,
      final bool isComplete,
      final bool isSavingSession,
      final String? saveError}) = _$StudySessionStateImpl;
  const _StudySessionState._() : super._();

  @override
  List<StudyCard> get queue;
  @override
  int get currentIndex;
  @override
  bool get isCardFlipped;
  @override
  SessionStats get stats;
  @override
  StudyMode get mode;
  @override
  String get deckId;
  @override
  String get deckTitle;
  @override
  bool get isComplete;
  @override
  bool get isSavingSession;
  @override
  String? get saveError;

  /// Create a copy of StudySessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudySessionStateImplCopyWith<_$StudySessionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
