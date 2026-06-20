// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestResult {
  String get id => throw _privateConstructorUsedError;
  String get deckId => throw _privateConstructorUsedError;
  String get deckTitle => throw _privateConstructorUsedError;
  TestConfig get config => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  List<TestAnswer> get answers => throw _privateConstructorUsedError;
  List<TestQuestion> get questions => throw _privateConstructorUsedError;
  List<WeakArea> get weakAreas => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;

  /// Create a copy of TestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestResultCopyWith<TestResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestResultCopyWith<$Res> {
  factory $TestResultCopyWith(
          TestResult value, $Res Function(TestResult) then) =
      _$TestResultCopyWithImpl<$Res, TestResult>;
  @useResult
  $Res call(
      {String id,
      String deckId,
      String deckTitle,
      TestConfig config,
      int totalQuestions,
      int correctCount,
      int durationSeconds,
      List<TestAnswer> answers,
      List<TestQuestion> questions,
      List<WeakArea> weakAreas,
      DateTime completedAt});

  $TestConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$TestResultCopyWithImpl<$Res, $Val extends TestResult>
    implements $TestResultCopyWith<$Res> {
  _$TestResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? deckTitle = null,
    Object? config = null,
    Object? totalQuestions = null,
    Object? correctCount = null,
    Object? durationSeconds = null,
    Object? answers = null,
    Object? questions = null,
    Object? weakAreas = null,
    Object? completedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as TestConfig,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<TestAnswer>,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<TestQuestion>,
      weakAreas: null == weakAreas
          ? _value.weakAreas
          : weakAreas // ignore: cast_nullable_to_non_nullable
              as List<WeakArea>,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of TestResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TestConfigCopyWith<$Res> get config {
    return $TestConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TestResultImplCopyWith<$Res>
    implements $TestResultCopyWith<$Res> {
  factory _$$TestResultImplCopyWith(
          _$TestResultImpl value, $Res Function(_$TestResultImpl) then) =
      __$$TestResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deckId,
      String deckTitle,
      TestConfig config,
      int totalQuestions,
      int correctCount,
      int durationSeconds,
      List<TestAnswer> answers,
      List<TestQuestion> questions,
      List<WeakArea> weakAreas,
      DateTime completedAt});

  @override
  $TestConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$TestResultImplCopyWithImpl<$Res>
    extends _$TestResultCopyWithImpl<$Res, _$TestResultImpl>
    implements _$$TestResultImplCopyWith<$Res> {
  __$$TestResultImplCopyWithImpl(
      _$TestResultImpl _value, $Res Function(_$TestResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? deckTitle = null,
    Object? config = null,
    Object? totalQuestions = null,
    Object? correctCount = null,
    Object? durationSeconds = null,
    Object? answers = null,
    Object? questions = null,
    Object? weakAreas = null,
    Object? completedAt = null,
  }) {
    return _then(_$TestResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as TestConfig,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<TestAnswer>,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<TestQuestion>,
      weakAreas: null == weakAreas
          ? _value._weakAreas
          : weakAreas // ignore: cast_nullable_to_non_nullable
              as List<WeakArea>,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$TestResultImpl extends _TestResult {
  const _$TestResultImpl(
      {required this.id,
      required this.deckId,
      required this.deckTitle,
      required this.config,
      required this.totalQuestions,
      required this.correctCount,
      required this.durationSeconds,
      required final List<TestAnswer> answers,
      required final List<TestQuestion> questions,
      final List<WeakArea> weakAreas = const [],
      required this.completedAt})
      : _answers = answers,
        _questions = questions,
        _weakAreas = weakAreas,
        super._();

  @override
  final String id;
  @override
  final String deckId;
  @override
  final String deckTitle;
  @override
  final TestConfig config;
  @override
  final int totalQuestions;
  @override
  final int correctCount;
  @override
  final int durationSeconds;
  final List<TestAnswer> _answers;
  @override
  List<TestAnswer> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  final List<TestQuestion> _questions;
  @override
  List<TestQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  final List<WeakArea> _weakAreas;
  @override
  @JsonKey()
  List<WeakArea> get weakAreas {
    if (_weakAreas is EqualUnmodifiableListView) return _weakAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weakAreas);
  }

  @override
  final DateTime completedAt;

  @override
  String toString() {
    return 'TestResult(id: $id, deckId: $deckId, deckTitle: $deckTitle, config: $config, totalQuestions: $totalQuestions, correctCount: $correctCount, durationSeconds: $durationSeconds, answers: $answers, questions: $questions, weakAreas: $weakAreas, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.deckTitle, deckTitle) ||
                other.deckTitle == deckTitle) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            const DeepCollectionEquality()
                .equals(other._weakAreas, _weakAreas) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      deckId,
      deckTitle,
      config,
      totalQuestions,
      correctCount,
      durationSeconds,
      const DeepCollectionEquality().hash(_answers),
      const DeepCollectionEquality().hash(_questions),
      const DeepCollectionEquality().hash(_weakAreas),
      completedAt);

  /// Create a copy of TestResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestResultImplCopyWith<_$TestResultImpl> get copyWith =>
      __$$TestResultImplCopyWithImpl<_$TestResultImpl>(this, _$identity);
}

abstract class _TestResult extends TestResult {
  const factory _TestResult(
      {required final String id,
      required final String deckId,
      required final String deckTitle,
      required final TestConfig config,
      required final int totalQuestions,
      required final int correctCount,
      required final int durationSeconds,
      required final List<TestAnswer> answers,
      required final List<TestQuestion> questions,
      final List<WeakArea> weakAreas,
      required final DateTime completedAt}) = _$TestResultImpl;
  const _TestResult._() : super._();

  @override
  String get id;
  @override
  String get deckId;
  @override
  String get deckTitle;
  @override
  TestConfig get config;
  @override
  int get totalQuestions;
  @override
  int get correctCount;
  @override
  int get durationSeconds;
  @override
  List<TestAnswer> get answers;
  @override
  List<TestQuestion> get questions;
  @override
  List<WeakArea> get weakAreas;
  @override
  DateTime get completedAt;

  /// Create a copy of TestResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestResultImplCopyWith<_$TestResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
