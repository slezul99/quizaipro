// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestQuestion {
  String get id => throw _privateConstructorUsedError;
  String get deckId => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;
  List<TestOption> get options => throw _privateConstructorUsedError;
  String? get topic => throw _privateConstructorUsedError;

  /// Create a copy of TestQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestQuestionCopyWith<TestQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestQuestionCopyWith<$Res> {
  factory $TestQuestionCopyWith(
          TestQuestion value, $Res Function(TestQuestion) then) =
      _$TestQuestionCopyWithImpl<$Res, TestQuestion>;
  @useResult
  $Res call(
      {String id,
      String deckId,
      String question,
      String correctAnswer,
      List<TestOption> options,
      String? topic});
}

/// @nodoc
class _$TestQuestionCopyWithImpl<$Res, $Val extends TestQuestion>
    implements $TestQuestionCopyWith<$Res> {
  _$TestQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? question = null,
    Object? correctAnswer = null,
    Object? options = null,
    Object? topic = freezed,
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
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<TestOption>,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestQuestionImplCopyWith<$Res>
    implements $TestQuestionCopyWith<$Res> {
  factory _$$TestQuestionImplCopyWith(
          _$TestQuestionImpl value, $Res Function(_$TestQuestionImpl) then) =
      __$$TestQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deckId,
      String question,
      String correctAnswer,
      List<TestOption> options,
      String? topic});
}

/// @nodoc
class __$$TestQuestionImplCopyWithImpl<$Res>
    extends _$TestQuestionCopyWithImpl<$Res, _$TestQuestionImpl>
    implements _$$TestQuestionImplCopyWith<$Res> {
  __$$TestQuestionImplCopyWithImpl(
      _$TestQuestionImpl _value, $Res Function(_$TestQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? question = null,
    Object? correctAnswer = null,
    Object? options = null,
    Object? topic = freezed,
  }) {
    return _then(_$TestQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<TestOption>,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TestQuestionImpl extends _TestQuestion {
  const _$TestQuestionImpl(
      {required this.id,
      required this.deckId,
      required this.question,
      required this.correctAnswer,
      required final List<TestOption> options,
      this.topic})
      : _options = options,
        super._();

  @override
  final String id;
  @override
  final String deckId;
  @override
  final String question;
  @override
  final String correctAnswer;
  final List<TestOption> _options;
  @override
  List<TestOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final String? topic;

  @override
  String toString() {
    return 'TestQuestion(id: $id, deckId: $deckId, question: $question, correctAnswer: $correctAnswer, options: $options, topic: $topic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.topic, topic) || other.topic == topic));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, deckId, question,
      correctAnswer, const DeepCollectionEquality().hash(_options), topic);

  /// Create a copy of TestQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestQuestionImplCopyWith<_$TestQuestionImpl> get copyWith =>
      __$$TestQuestionImplCopyWithImpl<_$TestQuestionImpl>(this, _$identity);
}

abstract class _TestQuestion extends TestQuestion {
  const factory _TestQuestion(
      {required final String id,
      required final String deckId,
      required final String question,
      required final String correctAnswer,
      required final List<TestOption> options,
      final String? topic}) = _$TestQuestionImpl;
  const _TestQuestion._() : super._();

  @override
  String get id;
  @override
  String get deckId;
  @override
  String get question;
  @override
  String get correctAnswer;
  @override
  List<TestOption> get options;
  @override
  String? get topic;

  /// Create a copy of TestQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestQuestionImplCopyWith<_$TestQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
