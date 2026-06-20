// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_answer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestAnswer {
  String get questionId => throw _privateConstructorUsedError;
  String? get selectedOptionId => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  DateTime get answeredAt => throw _privateConstructorUsedError;

  /// Create a copy of TestAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestAnswerCopyWith<TestAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestAnswerCopyWith<$Res> {
  factory $TestAnswerCopyWith(
          TestAnswer value, $Res Function(TestAnswer) then) =
      _$TestAnswerCopyWithImpl<$Res, TestAnswer>;
  @useResult
  $Res call(
      {String questionId,
      String? selectedOptionId,
      bool isCorrect,
      DateTime answeredAt});
}

/// @nodoc
class _$TestAnswerCopyWithImpl<$Res, $Val extends TestAnswer>
    implements $TestAnswerCopyWith<$Res> {
  _$TestAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? selectedOptionId = freezed,
    Object? isCorrect = null,
    Object? answeredAt = null,
  }) {
    return _then(_value.copyWith(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedOptionId: freezed == selectedOptionId
          ? _value.selectedOptionId
          : selectedOptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      answeredAt: null == answeredAt
          ? _value.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestAnswerImplCopyWith<$Res>
    implements $TestAnswerCopyWith<$Res> {
  factory _$$TestAnswerImplCopyWith(
          _$TestAnswerImpl value, $Res Function(_$TestAnswerImpl) then) =
      __$$TestAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String questionId,
      String? selectedOptionId,
      bool isCorrect,
      DateTime answeredAt});
}

/// @nodoc
class __$$TestAnswerImplCopyWithImpl<$Res>
    extends _$TestAnswerCopyWithImpl<$Res, _$TestAnswerImpl>
    implements _$$TestAnswerImplCopyWith<$Res> {
  __$$TestAnswerImplCopyWithImpl(
      _$TestAnswerImpl _value, $Res Function(_$TestAnswerImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? selectedOptionId = freezed,
    Object? isCorrect = null,
    Object? answeredAt = null,
  }) {
    return _then(_$TestAnswerImpl(
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedOptionId: freezed == selectedOptionId
          ? _value.selectedOptionId
          : selectedOptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      answeredAt: null == answeredAt
          ? _value.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$TestAnswerImpl implements _TestAnswer {
  const _$TestAnswerImpl(
      {required this.questionId,
      required this.selectedOptionId,
      required this.isCorrect,
      required this.answeredAt});

  @override
  final String questionId;
  @override
  final String? selectedOptionId;
  @override
  final bool isCorrect;
  @override
  final DateTime answeredAt;

  @override
  String toString() {
    return 'TestAnswer(questionId: $questionId, selectedOptionId: $selectedOptionId, isCorrect: $isCorrect, answeredAt: $answeredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestAnswerImpl &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.selectedOptionId, selectedOptionId) ||
                other.selectedOptionId == selectedOptionId) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, questionId, selectedOptionId, isCorrect, answeredAt);

  /// Create a copy of TestAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestAnswerImplCopyWith<_$TestAnswerImpl> get copyWith =>
      __$$TestAnswerImplCopyWithImpl<_$TestAnswerImpl>(this, _$identity);
}

abstract class _TestAnswer implements TestAnswer {
  const factory _TestAnswer(
      {required final String questionId,
      required final String? selectedOptionId,
      required final bool isCorrect,
      required final DateTime answeredAt}) = _$TestAnswerImpl;

  @override
  String get questionId;
  @override
  String? get selectedOptionId;
  @override
  bool get isCorrect;
  @override
  DateTime get answeredAt;

  /// Create a copy of TestAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestAnswerImplCopyWith<_$TestAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
