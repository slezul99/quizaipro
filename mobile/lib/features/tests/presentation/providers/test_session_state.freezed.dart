// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestSessionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)
        inProgress,
    required TResult Function(TestResult result) completed,
    required TResult Function(String message) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult? Function(TestResult result)? completed,
    TResult? Function(String message)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult Function(TestResult result)? completed,
    TResult Function(String message)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TestSessionStateIdle value) idle,
    required TResult Function(TestSessionStateLoading value) loading,
    required TResult Function(TestSessionStateInProgress value) inProgress,
    required TResult Function(TestSessionStateCompleted value) completed,
    required TResult Function(TestSessionStateFailed value) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TestSessionStateIdle value)? idle,
    TResult? Function(TestSessionStateLoading value)? loading,
    TResult? Function(TestSessionStateInProgress value)? inProgress,
    TResult? Function(TestSessionStateCompleted value)? completed,
    TResult? Function(TestSessionStateFailed value)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TestSessionStateIdle value)? idle,
    TResult Function(TestSessionStateLoading value)? loading,
    TResult Function(TestSessionStateInProgress value)? inProgress,
    TResult Function(TestSessionStateCompleted value)? completed,
    TResult Function(TestSessionStateFailed value)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestSessionStateCopyWith<$Res> {
  factory $TestSessionStateCopyWith(
          TestSessionState value, $Res Function(TestSessionState) then) =
      _$TestSessionStateCopyWithImpl<$Res, TestSessionState>;
}

/// @nodoc
class _$TestSessionStateCopyWithImpl<$Res, $Val extends TestSessionState>
    implements $TestSessionStateCopyWith<$Res> {
  _$TestSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TestSessionStateIdleImplCopyWith<$Res> {
  factory _$$TestSessionStateIdleImplCopyWith(_$TestSessionStateIdleImpl value,
          $Res Function(_$TestSessionStateIdleImpl) then) =
      __$$TestSessionStateIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TestSessionStateIdleImplCopyWithImpl<$Res>
    extends _$TestSessionStateCopyWithImpl<$Res, _$TestSessionStateIdleImpl>
    implements _$$TestSessionStateIdleImplCopyWith<$Res> {
  __$$TestSessionStateIdleImplCopyWithImpl(_$TestSessionStateIdleImpl _value,
      $Res Function(_$TestSessionStateIdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TestSessionStateIdleImpl implements TestSessionStateIdle {
  const _$TestSessionStateIdleImpl();

  @override
  String toString() {
    return 'TestSessionState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestSessionStateIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)
        inProgress,
    required TResult Function(TestResult result) completed,
    required TResult Function(String message) failed,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult? Function(TestResult result)? completed,
    TResult? Function(String message)? failed,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult Function(TestResult result)? completed,
    TResult Function(String message)? failed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TestSessionStateIdle value) idle,
    required TResult Function(TestSessionStateLoading value) loading,
    required TResult Function(TestSessionStateInProgress value) inProgress,
    required TResult Function(TestSessionStateCompleted value) completed,
    required TResult Function(TestSessionStateFailed value) failed,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TestSessionStateIdle value)? idle,
    TResult? Function(TestSessionStateLoading value)? loading,
    TResult? Function(TestSessionStateInProgress value)? inProgress,
    TResult? Function(TestSessionStateCompleted value)? completed,
    TResult? Function(TestSessionStateFailed value)? failed,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TestSessionStateIdle value)? idle,
    TResult Function(TestSessionStateLoading value)? loading,
    TResult Function(TestSessionStateInProgress value)? inProgress,
    TResult Function(TestSessionStateCompleted value)? completed,
    TResult Function(TestSessionStateFailed value)? failed,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class TestSessionStateIdle implements TestSessionState {
  const factory TestSessionStateIdle() = _$TestSessionStateIdleImpl;
}

/// @nodoc
abstract class _$$TestSessionStateLoadingImplCopyWith<$Res> {
  factory _$$TestSessionStateLoadingImplCopyWith(
          _$TestSessionStateLoadingImpl value,
          $Res Function(_$TestSessionStateLoadingImpl) then) =
      __$$TestSessionStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TestSessionStateLoadingImplCopyWithImpl<$Res>
    extends _$TestSessionStateCopyWithImpl<$Res, _$TestSessionStateLoadingImpl>
    implements _$$TestSessionStateLoadingImplCopyWith<$Res> {
  __$$TestSessionStateLoadingImplCopyWithImpl(
      _$TestSessionStateLoadingImpl _value,
      $Res Function(_$TestSessionStateLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TestSessionStateLoadingImpl implements TestSessionStateLoading {
  const _$TestSessionStateLoadingImpl();

  @override
  String toString() {
    return 'TestSessionState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestSessionStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)
        inProgress,
    required TResult Function(TestResult result) completed,
    required TResult Function(String message) failed,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult? Function(TestResult result)? completed,
    TResult? Function(String message)? failed,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult Function(TestResult result)? completed,
    TResult Function(String message)? failed,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TestSessionStateIdle value) idle,
    required TResult Function(TestSessionStateLoading value) loading,
    required TResult Function(TestSessionStateInProgress value) inProgress,
    required TResult Function(TestSessionStateCompleted value) completed,
    required TResult Function(TestSessionStateFailed value) failed,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TestSessionStateIdle value)? idle,
    TResult? Function(TestSessionStateLoading value)? loading,
    TResult? Function(TestSessionStateInProgress value)? inProgress,
    TResult? Function(TestSessionStateCompleted value)? completed,
    TResult? Function(TestSessionStateFailed value)? failed,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TestSessionStateIdle value)? idle,
    TResult Function(TestSessionStateLoading value)? loading,
    TResult Function(TestSessionStateInProgress value)? inProgress,
    TResult Function(TestSessionStateCompleted value)? completed,
    TResult Function(TestSessionStateFailed value)? failed,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TestSessionStateLoading implements TestSessionState {
  const factory TestSessionStateLoading() = _$TestSessionStateLoadingImpl;
}

/// @nodoc
abstract class _$$TestSessionStateInProgressImplCopyWith<$Res> {
  factory _$$TestSessionStateInProgressImplCopyWith(
          _$TestSessionStateInProgressImpl value,
          $Res Function(_$TestSessionStateInProgressImpl) then) =
      __$$TestSessionStateInProgressImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<TestQuestion> questions,
      int currentIndex,
      Map<String, String> answers,
      TestConfig config,
      DateTime startedAt,
      String deckId,
      String deckTitle,
      int? remainingSeconds});

  $TestConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$TestSessionStateInProgressImplCopyWithImpl<$Res>
    extends _$TestSessionStateCopyWithImpl<$Res,
        _$TestSessionStateInProgressImpl>
    implements _$$TestSessionStateInProgressImplCopyWith<$Res> {
  __$$TestSessionStateInProgressImplCopyWithImpl(
      _$TestSessionStateInProgressImpl _value,
      $Res Function(_$TestSessionStateInProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? currentIndex = null,
    Object? answers = null,
    Object? config = null,
    Object? startedAt = null,
    Object? deckId = null,
    Object? deckTitle = null,
    Object? remainingSeconds = freezed,
  }) {
    return _then(_$TestSessionStateInProgressImpl(
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<TestQuestion>,
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as TestConfig,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
      remainingSeconds: freezed == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TestConfigCopyWith<$Res> get config {
    return $TestConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value));
    });
  }
}

/// @nodoc

class _$TestSessionStateInProgressImpl implements TestSessionStateInProgress {
  const _$TestSessionStateInProgressImpl(
      {required final List<TestQuestion> questions,
      required this.currentIndex,
      final Map<String, String> answers = const {},
      required this.config,
      required this.startedAt,
      required this.deckId,
      required this.deckTitle,
      this.remainingSeconds})
      : _questions = questions,
        _answers = answers;

  final List<TestQuestion> _questions;
  @override
  List<TestQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  final int currentIndex;
  final Map<String, String> _answers;
  @override
  @JsonKey()
  Map<String, String> get answers {
    if (_answers is EqualUnmodifiableMapView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_answers);
  }

  @override
  final TestConfig config;
  @override
  final DateTime startedAt;
  @override
  final String deckId;
  @override
  final String deckTitle;
  @override
  final int? remainingSeconds;

  @override
  String toString() {
    return 'TestSessionState.inProgress(questions: $questions, currentIndex: $currentIndex, answers: $answers, config: $config, startedAt: $startedAt, deckId: $deckId, deckTitle: $deckTitle, remainingSeconds: $remainingSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestSessionStateInProgressImpl &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.deckTitle, deckTitle) ||
                other.deckTitle == deckTitle) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_questions),
      currentIndex,
      const DeepCollectionEquality().hash(_answers),
      config,
      startedAt,
      deckId,
      deckTitle,
      remainingSeconds);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestSessionStateInProgressImplCopyWith<_$TestSessionStateInProgressImpl>
      get copyWith => __$$TestSessionStateInProgressImplCopyWithImpl<
          _$TestSessionStateInProgressImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)
        inProgress,
    required TResult Function(TestResult result) completed,
    required TResult Function(String message) failed,
  }) {
    return inProgress(questions, currentIndex, answers, config, startedAt,
        deckId, deckTitle, remainingSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult? Function(TestResult result)? completed,
    TResult? Function(String message)? failed,
  }) {
    return inProgress?.call(questions, currentIndex, answers, config, startedAt,
        deckId, deckTitle, remainingSeconds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult Function(TestResult result)? completed,
    TResult Function(String message)? failed,
    required TResult orElse(),
  }) {
    if (inProgress != null) {
      return inProgress(questions, currentIndex, answers, config, startedAt,
          deckId, deckTitle, remainingSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TestSessionStateIdle value) idle,
    required TResult Function(TestSessionStateLoading value) loading,
    required TResult Function(TestSessionStateInProgress value) inProgress,
    required TResult Function(TestSessionStateCompleted value) completed,
    required TResult Function(TestSessionStateFailed value) failed,
  }) {
    return inProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TestSessionStateIdle value)? idle,
    TResult? Function(TestSessionStateLoading value)? loading,
    TResult? Function(TestSessionStateInProgress value)? inProgress,
    TResult? Function(TestSessionStateCompleted value)? completed,
    TResult? Function(TestSessionStateFailed value)? failed,
  }) {
    return inProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TestSessionStateIdle value)? idle,
    TResult Function(TestSessionStateLoading value)? loading,
    TResult Function(TestSessionStateInProgress value)? inProgress,
    TResult Function(TestSessionStateCompleted value)? completed,
    TResult Function(TestSessionStateFailed value)? failed,
    required TResult orElse(),
  }) {
    if (inProgress != null) {
      return inProgress(this);
    }
    return orElse();
  }
}

abstract class TestSessionStateInProgress implements TestSessionState {
  const factory TestSessionStateInProgress(
      {required final List<TestQuestion> questions,
      required final int currentIndex,
      final Map<String, String> answers,
      required final TestConfig config,
      required final DateTime startedAt,
      required final String deckId,
      required final String deckTitle,
      final int? remainingSeconds}) = _$TestSessionStateInProgressImpl;

  List<TestQuestion> get questions;
  int get currentIndex;
  Map<String, String> get answers;
  TestConfig get config;
  DateTime get startedAt;
  String get deckId;
  String get deckTitle;
  int? get remainingSeconds;

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestSessionStateInProgressImplCopyWith<_$TestSessionStateInProgressImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TestSessionStateCompletedImplCopyWith<$Res> {
  factory _$$TestSessionStateCompletedImplCopyWith(
          _$TestSessionStateCompletedImpl value,
          $Res Function(_$TestSessionStateCompletedImpl) then) =
      __$$TestSessionStateCompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TestResult result});

  $TestResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$TestSessionStateCompletedImplCopyWithImpl<$Res>
    extends _$TestSessionStateCopyWithImpl<$Res,
        _$TestSessionStateCompletedImpl>
    implements _$$TestSessionStateCompletedImplCopyWith<$Res> {
  __$$TestSessionStateCompletedImplCopyWithImpl(
      _$TestSessionStateCompletedImpl _value,
      $Res Function(_$TestSessionStateCompletedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
  }) {
    return _then(_$TestSessionStateCompletedImpl(
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as TestResult,
    ));
  }

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TestResultCopyWith<$Res> get result {
    return $TestResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value));
    });
  }
}

/// @nodoc

class _$TestSessionStateCompletedImpl implements TestSessionStateCompleted {
  const _$TestSessionStateCompletedImpl({required this.result});

  @override
  final TestResult result;

  @override
  String toString() {
    return 'TestSessionState.completed(result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestSessionStateCompletedImpl &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, result);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestSessionStateCompletedImplCopyWith<_$TestSessionStateCompletedImpl>
      get copyWith => __$$TestSessionStateCompletedImplCopyWithImpl<
          _$TestSessionStateCompletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)
        inProgress,
    required TResult Function(TestResult result) completed,
    required TResult Function(String message) failed,
  }) {
    return completed(result);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult? Function(TestResult result)? completed,
    TResult? Function(String message)? failed,
  }) {
    return completed?.call(result);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult Function(TestResult result)? completed,
    TResult Function(String message)? failed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(result);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TestSessionStateIdle value) idle,
    required TResult Function(TestSessionStateLoading value) loading,
    required TResult Function(TestSessionStateInProgress value) inProgress,
    required TResult Function(TestSessionStateCompleted value) completed,
    required TResult Function(TestSessionStateFailed value) failed,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TestSessionStateIdle value)? idle,
    TResult? Function(TestSessionStateLoading value)? loading,
    TResult? Function(TestSessionStateInProgress value)? inProgress,
    TResult? Function(TestSessionStateCompleted value)? completed,
    TResult? Function(TestSessionStateFailed value)? failed,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TestSessionStateIdle value)? idle,
    TResult Function(TestSessionStateLoading value)? loading,
    TResult Function(TestSessionStateInProgress value)? inProgress,
    TResult Function(TestSessionStateCompleted value)? completed,
    TResult Function(TestSessionStateFailed value)? failed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class TestSessionStateCompleted implements TestSessionState {
  const factory TestSessionStateCompleted({required final TestResult result}) =
      _$TestSessionStateCompletedImpl;

  TestResult get result;

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestSessionStateCompletedImplCopyWith<_$TestSessionStateCompletedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TestSessionStateFailedImplCopyWith<$Res> {
  factory _$$TestSessionStateFailedImplCopyWith(
          _$TestSessionStateFailedImpl value,
          $Res Function(_$TestSessionStateFailedImpl) then) =
      __$$TestSessionStateFailedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$TestSessionStateFailedImplCopyWithImpl<$Res>
    extends _$TestSessionStateCopyWithImpl<$Res, _$TestSessionStateFailedImpl>
    implements _$$TestSessionStateFailedImplCopyWith<$Res> {
  __$$TestSessionStateFailedImplCopyWithImpl(
      _$TestSessionStateFailedImpl _value,
      $Res Function(_$TestSessionStateFailedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$TestSessionStateFailedImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TestSessionStateFailedImpl implements TestSessionStateFailed {
  const _$TestSessionStateFailedImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'TestSessionState.failed(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestSessionStateFailedImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestSessionStateFailedImplCopyWith<_$TestSessionStateFailedImpl>
      get copyWith => __$$TestSessionStateFailedImplCopyWithImpl<
          _$TestSessionStateFailedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() loading,
    required TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)
        inProgress,
    required TResult Function(TestResult result) completed,
    required TResult Function(String message) failed,
  }) {
    return failed(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? loading,
    TResult? Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult? Function(TestResult result)? completed,
    TResult? Function(String message)? failed,
  }) {
    return failed?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? loading,
    TResult Function(
            List<TestQuestion> questions,
            int currentIndex,
            Map<String, String> answers,
            TestConfig config,
            DateTime startedAt,
            String deckId,
            String deckTitle,
            int? remainingSeconds)?
        inProgress,
    TResult Function(TestResult result)? completed,
    TResult Function(String message)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TestSessionStateIdle value) idle,
    required TResult Function(TestSessionStateLoading value) loading,
    required TResult Function(TestSessionStateInProgress value) inProgress,
    required TResult Function(TestSessionStateCompleted value) completed,
    required TResult Function(TestSessionStateFailed value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TestSessionStateIdle value)? idle,
    TResult? Function(TestSessionStateLoading value)? loading,
    TResult? Function(TestSessionStateInProgress value)? inProgress,
    TResult? Function(TestSessionStateCompleted value)? completed,
    TResult? Function(TestSessionStateFailed value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TestSessionStateIdle value)? idle,
    TResult Function(TestSessionStateLoading value)? loading,
    TResult Function(TestSessionStateInProgress value)? inProgress,
    TResult Function(TestSessionStateCompleted value)? completed,
    TResult Function(TestSessionStateFailed value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class TestSessionStateFailed implements TestSessionState {
  const factory TestSessionStateFailed({required final String message}) =
      _$TestSessionStateFailedImpl;

  String get message;

  /// Create a copy of TestSessionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestSessionStateFailedImplCopyWith<_$TestSessionStateFailedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
