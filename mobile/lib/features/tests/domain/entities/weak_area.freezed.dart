// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weak_area.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WeakArea {
  String get topic => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get correctAnswers => throw _privateConstructorUsedError;

  /// Create a copy of WeakArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeakAreaCopyWith<WeakArea> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeakAreaCopyWith<$Res> {
  factory $WeakAreaCopyWith(WeakArea value, $Res Function(WeakArea) then) =
      _$WeakAreaCopyWithImpl<$Res, WeakArea>;
  @useResult
  $Res call({String topic, int totalQuestions, int correctAnswers});
}

/// @nodoc
class _$WeakAreaCopyWithImpl<$Res, $Val extends WeakArea>
    implements $WeakAreaCopyWith<$Res> {
  _$WeakAreaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeakArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topic = null,
    Object? totalQuestions = null,
    Object? correctAnswers = null,
  }) {
    return _then(_value.copyWith(
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswers: null == correctAnswers
          ? _value.correctAnswers
          : correctAnswers // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeakAreaImplCopyWith<$Res>
    implements $WeakAreaCopyWith<$Res> {
  factory _$$WeakAreaImplCopyWith(
          _$WeakAreaImpl value, $Res Function(_$WeakAreaImpl) then) =
      __$$WeakAreaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String topic, int totalQuestions, int correctAnswers});
}

/// @nodoc
class __$$WeakAreaImplCopyWithImpl<$Res>
    extends _$WeakAreaCopyWithImpl<$Res, _$WeakAreaImpl>
    implements _$$WeakAreaImplCopyWith<$Res> {
  __$$WeakAreaImplCopyWithImpl(
      _$WeakAreaImpl _value, $Res Function(_$WeakAreaImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeakArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topic = null,
    Object? totalQuestions = null,
    Object? correctAnswers = null,
  }) {
    return _then(_$WeakAreaImpl(
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      correctAnswers: null == correctAnswers
          ? _value.correctAnswers
          : correctAnswers // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$WeakAreaImpl extends _WeakArea {
  const _$WeakAreaImpl(
      {required this.topic,
      required this.totalQuestions,
      required this.correctAnswers})
      : super._();

  @override
  final String topic;
  @override
  final int totalQuestions;
  @override
  final int correctAnswers;

  @override
  String toString() {
    return 'WeakArea(topic: $topic, totalQuestions: $totalQuestions, correctAnswers: $correctAnswers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeakAreaImpl &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.correctAnswers, correctAnswers) ||
                other.correctAnswers == correctAnswers));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, topic, totalQuestions, correctAnswers);

  /// Create a copy of WeakArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeakAreaImplCopyWith<_$WeakAreaImpl> get copyWith =>
      __$$WeakAreaImplCopyWithImpl<_$WeakAreaImpl>(this, _$identity);
}

abstract class _WeakArea extends WeakArea {
  const factory _WeakArea(
      {required final String topic,
      required final int totalQuestions,
      required final int correctAnswers}) = _$WeakAreaImpl;
  const _WeakArea._() : super._();

  @override
  String get topic;
  @override
  int get totalQuestions;
  @override
  int get correctAnswers;

  /// Create a copy of WeakArea
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeakAreaImplCopyWith<_$WeakAreaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
