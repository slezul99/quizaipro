// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_setup_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestSetupState {
  String get deckId => throw _privateConstructorUsedError;
  String get deckTitle => throw _privateConstructorUsedError;
  int get questionCount => throw _privateConstructorUsedError;
  bool get shuffle => throw _privateConstructorUsedError;
  bool get timedMode => throw _privateConstructorUsedError;
  int get secondsPerQuestion => throw _privateConstructorUsedError;
  bool get isStarting => throw _privateConstructorUsedError;

  /// Create a copy of TestSetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestSetupStateCopyWith<TestSetupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestSetupStateCopyWith<$Res> {
  factory $TestSetupStateCopyWith(
          TestSetupState value, $Res Function(TestSetupState) then) =
      _$TestSetupStateCopyWithImpl<$Res, TestSetupState>;
  @useResult
  $Res call(
      {String deckId,
      String deckTitle,
      int questionCount,
      bool shuffle,
      bool timedMode,
      int secondsPerQuestion,
      bool isStarting});
}

/// @nodoc
class _$TestSetupStateCopyWithImpl<$Res, $Val extends TestSetupState>
    implements $TestSetupStateCopyWith<$Res> {
  _$TestSetupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestSetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? deckTitle = null,
    Object? questionCount = null,
    Object? shuffle = null,
    Object? timedMode = null,
    Object? secondsPerQuestion = null,
    Object? isStarting = null,
  }) {
    return _then(_value.copyWith(
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
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
      isStarting: null == isStarting
          ? _value.isStarting
          : isStarting // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestSetupStateImplCopyWith<$Res>
    implements $TestSetupStateCopyWith<$Res> {
  factory _$$TestSetupStateImplCopyWith(_$TestSetupStateImpl value,
          $Res Function(_$TestSetupStateImpl) then) =
      __$$TestSetupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String deckId,
      String deckTitle,
      int questionCount,
      bool shuffle,
      bool timedMode,
      int secondsPerQuestion,
      bool isStarting});
}

/// @nodoc
class __$$TestSetupStateImplCopyWithImpl<$Res>
    extends _$TestSetupStateCopyWithImpl<$Res, _$TestSetupStateImpl>
    implements _$$TestSetupStateImplCopyWith<$Res> {
  __$$TestSetupStateImplCopyWithImpl(
      _$TestSetupStateImpl _value, $Res Function(_$TestSetupStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestSetupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deckId = null,
    Object? deckTitle = null,
    Object? questionCount = null,
    Object? shuffle = null,
    Object? timedMode = null,
    Object? secondsPerQuestion = null,
    Object? isStarting = null,
  }) {
    return _then(_$TestSetupStateImpl(
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
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
      isStarting: null == isStarting
          ? _value.isStarting
          : isStarting // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TestSetupStateImpl extends _TestSetupState {
  const _$TestSetupStateImpl(
      {required this.deckId,
      required this.deckTitle,
      this.questionCount = AppConstants.testDefaultQuestionCount,
      this.shuffle = true,
      this.timedMode = false,
      this.secondsPerQuestion = AppConstants.testDefaultSecondsPerQuestion,
      this.isStarting = false})
      : super._();

  @override
  final String deckId;
  @override
  final String deckTitle;
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
  @JsonKey()
  final bool isStarting;

  @override
  String toString() {
    return 'TestSetupState(deckId: $deckId, deckTitle: $deckTitle, questionCount: $questionCount, shuffle: $shuffle, timedMode: $timedMode, secondsPerQuestion: $secondsPerQuestion, isStarting: $isStarting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestSetupStateImpl &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.deckTitle, deckTitle) ||
                other.deckTitle == deckTitle) &&
            (identical(other.questionCount, questionCount) ||
                other.questionCount == questionCount) &&
            (identical(other.shuffle, shuffle) || other.shuffle == shuffle) &&
            (identical(other.timedMode, timedMode) ||
                other.timedMode == timedMode) &&
            (identical(other.secondsPerQuestion, secondsPerQuestion) ||
                other.secondsPerQuestion == secondsPerQuestion) &&
            (identical(other.isStarting, isStarting) ||
                other.isStarting == isStarting));
  }

  @override
  int get hashCode => Object.hash(runtimeType, deckId, deckTitle, questionCount,
      shuffle, timedMode, secondsPerQuestion, isStarting);

  /// Create a copy of TestSetupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestSetupStateImplCopyWith<_$TestSetupStateImpl> get copyWith =>
      __$$TestSetupStateImplCopyWithImpl<_$TestSetupStateImpl>(
          this, _$identity);
}

abstract class _TestSetupState extends TestSetupState {
  const factory _TestSetupState(
      {required final String deckId,
      required final String deckTitle,
      final int questionCount,
      final bool shuffle,
      final bool timedMode,
      final int secondsPerQuestion,
      final bool isStarting}) = _$TestSetupStateImpl;
  const _TestSetupState._() : super._();

  @override
  String get deckId;
  @override
  String get deckTitle;
  @override
  int get questionCount;
  @override
  bool get shuffle;
  @override
  bool get timedMode;
  @override
  int get secondsPerQuestion;
  @override
  bool get isStarting;

  /// Create a copy of TestSetupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestSetupStateImplCopyWith<_$TestSetupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
