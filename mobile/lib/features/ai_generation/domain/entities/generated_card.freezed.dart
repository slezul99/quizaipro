// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GeneratedCard _$GeneratedCardFromJson(Map<String, dynamic> json) {
  return _GeneratedCard.fromJson(json);
}

/// @nodoc
mixin _$GeneratedCard {
  String get question => throw _privateConstructorUsedError;
  String get answer => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;

  /// Serializes this GeneratedCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeneratedCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeneratedCardCopyWith<GeneratedCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeneratedCardCopyWith<$Res> {
  factory $GeneratedCardCopyWith(
          GeneratedCard value, $Res Function(GeneratedCard) then) =
      _$GeneratedCardCopyWithImpl<$Res, GeneratedCard>;
  @useResult
  $Res call({String question, String answer, String topic, String difficulty});
}

/// @nodoc
class _$GeneratedCardCopyWithImpl<$Res, $Val extends GeneratedCard>
    implements $GeneratedCardCopyWith<$Res> {
  _$GeneratedCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeneratedCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? answer = null,
    Object? topic = null,
    Object? difficulty = null,
  }) {
    return _then(_value.copyWith(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeneratedCardImplCopyWith<$Res>
    implements $GeneratedCardCopyWith<$Res> {
  factory _$$GeneratedCardImplCopyWith(
          _$GeneratedCardImpl value, $Res Function(_$GeneratedCardImpl) then) =
      __$$GeneratedCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String question, String answer, String topic, String difficulty});
}

/// @nodoc
class __$$GeneratedCardImplCopyWithImpl<$Res>
    extends _$GeneratedCardCopyWithImpl<$Res, _$GeneratedCardImpl>
    implements _$$GeneratedCardImplCopyWith<$Res> {
  __$$GeneratedCardImplCopyWithImpl(
      _$GeneratedCardImpl _value, $Res Function(_$GeneratedCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeneratedCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? answer = null,
    Object? topic = null,
    Object? difficulty = null,
  }) {
    return _then(_$GeneratedCardImpl(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeneratedCardImpl implements _GeneratedCard {
  const _$GeneratedCardImpl(
      {required this.question,
      required this.answer,
      this.topic = '',
      this.difficulty = 'medium'});

  factory _$GeneratedCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeneratedCardImplFromJson(json);

  @override
  final String question;
  @override
  final String answer;
  @override
  @JsonKey()
  final String topic;
  @override
  @JsonKey()
  final String difficulty;

  @override
  String toString() {
    return 'GeneratedCard(question: $question, answer: $answer, topic: $topic, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeneratedCardImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, question, answer, topic, difficulty);

  /// Create a copy of GeneratedCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeneratedCardImplCopyWith<_$GeneratedCardImpl> get copyWith =>
      __$$GeneratedCardImplCopyWithImpl<_$GeneratedCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeneratedCardImplToJson(
      this,
    );
  }
}

abstract class _GeneratedCard implements GeneratedCard {
  const factory _GeneratedCard(
      {required final String question,
      required final String answer,
      final String topic,
      final String difficulty}) = _$GeneratedCardImpl;

  factory _GeneratedCard.fromJson(Map<String, dynamic> json) =
      _$GeneratedCardImpl.fromJson;

  @override
  String get question;
  @override
  String get answer;
  @override
  String get topic;
  @override
  String get difficulty;

  /// Create a copy of GeneratedCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeneratedCardImplCopyWith<_$GeneratedCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
