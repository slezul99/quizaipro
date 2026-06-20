// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestConfig {
  int get questionCount => throw _privateConstructorUsedError;
  bool get shuffle => throw _privateConstructorUsedError;
  bool get timedMode => throw _privateConstructorUsedError;
  int get secondsPerQuestion => throw _privateConstructorUsedError;

  /// Create a copy of TestConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestConfigCopyWith<TestConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestConfigCopyWith<$Res> {
  factory $TestConfigCopyWith(
          TestConfig value, $Res Function(TestConfig) then) =
      _$TestConfigCopyWithImpl<$Res, TestConfig>;
  @useResult
  $Res call(
      {int questionCount,
      bool shuffle,
      bool timedMode,
      int secondsPerQuestion});
}

/// @nodoc
class _$TestConfigCopyWithImpl<$Res, $Val extends TestConfig>
    implements $TestConfigCopyWith<$Res> {
  _$TestConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionCount = null,
    Object? shuffle = null,
    Object? timedMode = null,
    Object? secondsPerQuestion = null,
  }) {
    return _then(_value.copyWith(
      questionCount: null == questionCount
          ? _value.questionCount
          : questionCount // ignore: cast_nullable_to_non_nullable
              as int,
      shuffle: null == shuffle
          ? _value.shuffle
          : shuffle // ignore: cast_nullable_to_non_nullable
              as bool,
      timedMode: null == timedMode
          ? _value.timedMode
          : timedMode // ignore: cast_nullable_to_non_nullable
              as bool,
      secondsPerQuestion: null == secondsPerQuestion
          ? _value.secondsPerQuestion
          : secondsPerQuestion // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestConfigImplCopyWith<$Res>
    implements $TestConfigCopyWith<$Res> {
  factory _$$TestConfigImplCopyWith(
          _$TestConfigImpl value, $Res Function(_$TestConfigImpl) then) =
      __$$TestConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int questionCount,
      bool shuffle,
      bool timedMode,
      int secondsPerQuestion});
}

/// @nodoc
class __$$TestConfigImplCopyWithImpl<$Res>
    extends _$TestConfigCopyWithImpl<$Res, _$TestConfigImpl>
    implements _$$TestConfigImplCopyWith<$Res> {
  __$$TestConfigImplCopyWithImpl(
      _$TestConfigImpl _value, $Res Function(_$TestConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionCount = null,
    Object? shuffle = null,
    Object? timedMode = null,
    Object? secondsPerQuestion = null,
  }) {
    return _then(_$TestConfigImpl(
      questionCount: null == questionCount
          ? _value.questionCount
          : questionCount // ignore: cast_nullable_to_non_nullable
              as int,
      shuffle: null == shuffle
          ? _value.shuffle
          : shuffle // ignore: cast_nullable_to_non_nullable
              as bool,
      timedMode: null == timedMode
          ? _value.timedMode
          : timedMode // ignore: cast_nullable_to_non_nullable
              as bool,
      secondsPerQuestion: null == secondsPerQuestion
          ? _value.secondsPerQuestion
          : secondsPerQuestion // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TestConfigImpl extends _TestConfig {
  const _$TestConfigImpl(
      {this.questionCount = AppConstants.testDefaultQuestionCount,
      this.shuffle = true,
      this.timedMode = false,
      this.secondsPerQuestion = AppConstants.testDefaultSecondsPerQuestion})
      : super._();

  @override
  @JsonKey()
  final int questionCount;
  @override
  @JsonKey()
  final bool shuffle;
  @override
  @JsonKey()
  final bool timedMode;
  @override
  @JsonKey()
  final int secondsPerQuestion;

  @override
  String toString() {
    return 'TestConfig(questionCount: $questionCount, shuffle: $shuffle, timedMode: $timedMode, secondsPerQuestion: $secondsPerQuestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestConfigImpl &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.shuffle, shuffle) || other.shuffle == shuffle) &&
            (identical(other.timedMode, timedMode) ||
                other.timedMode == timedMode) &&
            (identical(other.secondsPerQuestion, secondsPerQuestion) ||
                other.secondsPerQuestion == secondsPerQuestion));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, questionCount, shuffle, timedMode, secondsPerQuestion);

  /// Create a copy of TestConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestConfigImplCopyWith<_$TestConfigImpl> get copyWith =>
      __$$TestConfigImplCopyWithImpl<_$TestConfigImpl>(this, _$identity);
}

abstract class _TestConfig extends TestConfig {
  const factory _TestConfig(
      {final int questionCount,
      final bool shuffle,
      final bool timedMode,
      final int secondsPerQuestion}) = _$TestConfigImpl;
  const _TestConfig._() : super._();

  @override
  int get questionCount;
  @override
  bool get shuffle;
  @override
  bool get timedMode;
  @override
  int get secondsPerQuestion;

  /// Create a copy of TestConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestConfigImplCopyWith<_$TestConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
