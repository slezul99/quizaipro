// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'find_answers_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FindAnswersResult _$FindAnswersResultFromJson(Map<String, dynamic> json) {
  return _FindAnswersResult.fromJson(json);
}

/// @nodoc
mixin _$FindAnswersResult {
  String get question => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  List<String> get keyPoints => throw _privateConstructorUsedError;

  /// Serializes this FindAnswersResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FindAnswersResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FindAnswersResultCopyWith<FindAnswersResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FindAnswersResultCopyWith<$Res> {
  factory $FindAnswersResultCopyWith(
          FindAnswersResult value, $Res Function(FindAnswersResult) then) =
      _$FindAnswersResultCopyWithImpl<$Res, FindAnswersResult>;
  @useResult
  $Res call({String question, String explanation, List<String> keyPoints});
}

/// @nodoc
class _$FindAnswersResultCopyWithImpl<$Res, $Val extends FindAnswersResult>
    implements $FindAnswersResultCopyWith<$Res> {
  _$FindAnswersResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FindAnswersResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? explanation = null,
    Object? keyPoints = null,
  }) {
    return _then(_value.copyWith(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      keyPoints: null == keyPoints
          ? _value.keyPoints
          : keyPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FindAnswersResultImplCopyWith<$Res>
    implements $FindAnswersResultCopyWith<$Res> {
  factory _$$FindAnswersResultImplCopyWith(_$FindAnswersResultImpl value,
          $Res Function(_$FindAnswersResultImpl) then) =
      __$$FindAnswersResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String question, String explanation, List<String> keyPoints});
}

/// @nodoc
class __$$FindAnswersResultImplCopyWithImpl<$Res>
    extends _$FindAnswersResultCopyWithImpl<$Res, _$FindAnswersResultImpl>
    implements _$$FindAnswersResultImplCopyWith<$Res> {
  __$$FindAnswersResultImplCopyWithImpl(_$FindAnswersResultImpl _value,
      $Res Function(_$FindAnswersResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of FindAnswersResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? explanation = null,
    Object? keyPoints = null,
  }) {
    return _then(_$FindAnswersResultImpl(
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      keyPoints: null == keyPoints
          ? _value._keyPoints
          : keyPoints // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FindAnswersResultImpl implements _FindAnswersResult {
  const _$FindAnswersResultImpl(
      {required this.question,
      required this.explanation,
      final List<String> keyPoints = const []})
      : _keyPoints = keyPoints;

  factory _$FindAnswersResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FindAnswersResultImplFromJson(json);

  @override
  final String question;
  @override
  final String explanation;
  final List<String> _keyPoints;
  @override
  @JsonKey()
  List<String> get keyPoints {
    if (_keyPoints is EqualUnmodifiableListView) return _keyPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyPoints);
  }

  @override
  String toString() {
    return 'FindAnswersResult(question: $question, explanation: $explanation, keyPoints: $keyPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FindAnswersResultImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            const DeepCollectionEquality()
                .equals(other._keyPoints, _keyPoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, question, explanation,
      const DeepCollectionEquality().hash(_keyPoints));

  /// Create a copy of FindAnswersResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FindAnswersResultImplCopyWith<_$FindAnswersResultImpl> get copyWith =>
      __$$FindAnswersResultImplCopyWithImpl<_$FindAnswersResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FindAnswersResultImplToJson(
      this,
    );
  }
}

abstract class _FindAnswersResult implements FindAnswersResult {
  const factory _FindAnswersResult(
      {required final String question,
      required final String explanation,
      final List<String> keyPoints}) = _$FindAnswersResultImpl;

  factory _FindAnswersResult.fromJson(Map<String, dynamic> json) =
      _$FindAnswersResultImpl.fromJson;

  @override
  String get question;
  @override
  String get explanation;
  @override
  List<String> get keyPoints;

  /// Create a copy of FindAnswersResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FindAnswersResultImplCopyWith<_$FindAnswersResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
