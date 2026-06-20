// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_goal_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DailyGoalProgress {
  int get targetCards => throw _privateConstructorUsedError;
  int get completedCards => throw _privateConstructorUsedError;

  /// Create a copy of DailyGoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyGoalProgressCopyWith<DailyGoalProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyGoalProgressCopyWith<$Res> {
  factory $DailyGoalProgressCopyWith(
          DailyGoalProgress value, $Res Function(DailyGoalProgress) then) =
      _$DailyGoalProgressCopyWithImpl<$Res, DailyGoalProgress>;
  @useResult
  $Res call({int targetCards, int completedCards});
}

/// @nodoc
class _$DailyGoalProgressCopyWithImpl<$Res, $Val extends DailyGoalProgress>
    implements $DailyGoalProgressCopyWith<$Res> {
  _$DailyGoalProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyGoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetCards = null,
    Object? completedCards = null,
  }) {
    return _then(_value.copyWith(
      targetCards: null == targetCards
          ? _value.targetCards
          : targetCards // ignore: cast_nullable_to_non_nullable
              as int,
      completedCards: null == completedCards
          ? _value.completedCards
          : completedCards // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyGoalProgressImplCopyWith<$Res>
    implements $DailyGoalProgressCopyWith<$Res> {
  factory _$$DailyGoalProgressImplCopyWith(_$DailyGoalProgressImpl value,
          $Res Function(_$DailyGoalProgressImpl) then) =
      __$$DailyGoalProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int targetCards, int completedCards});
}

/// @nodoc
class __$$DailyGoalProgressImplCopyWithImpl<$Res>
    extends _$DailyGoalProgressCopyWithImpl<$Res, _$DailyGoalProgressImpl>
    implements _$$DailyGoalProgressImplCopyWith<$Res> {
  __$$DailyGoalProgressImplCopyWithImpl(_$DailyGoalProgressImpl _value,
      $Res Function(_$DailyGoalProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyGoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? targetCards = null,
    Object? completedCards = null,
  }) {
    return _then(_$DailyGoalProgressImpl(
      targetCards: null == targetCards
          ? _value.targetCards
          : targetCards // ignore: cast_nullable_to_non_nullable
              as int,
      completedCards: null == completedCards
          ? _value.completedCards
          : completedCards // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DailyGoalProgressImpl extends _DailyGoalProgress {
  const _$DailyGoalProgressImpl(
      {required this.targetCards, required this.completedCards})
      : super._();

  @override
  final int targetCards;
  @override
  final int completedCards;

  @override
  String toString() {
    return 'DailyGoalProgress(targetCards: $targetCards, completedCards: $completedCards)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyGoalProgressImpl &&
            (identical(other.targetCards, targetCards) ||
                other.targetCards == targetCards) &&
            (identical(other.completedCards, completedCards) ||
                other.completedCards == completedCards));
  }

  @override
  int get hashCode => Object.hash(runtimeType, targetCards, completedCards);

  /// Create a copy of DailyGoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyGoalProgressImplCopyWith<_$DailyGoalProgressImpl> get copyWith =>
      __$$DailyGoalProgressImplCopyWithImpl<_$DailyGoalProgressImpl>(
          this, _$identity);
}

abstract class _DailyGoalProgress extends DailyGoalProgress {
  const factory _DailyGoalProgress(
      {required final int targetCards,
      required final int completedCards}) = _$DailyGoalProgressImpl;
  const _DailyGoalProgress._() : super._();

  @override
  int get targetCards;
  @override
  int get completedCards;

  /// Create a copy of DailyGoalProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyGoalProgressImplCopyWith<_$DailyGoalProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
