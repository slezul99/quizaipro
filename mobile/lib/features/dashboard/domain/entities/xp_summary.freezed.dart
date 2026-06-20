// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'xp_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$XpSummary {
  int get currentXp => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get xpInCurrentLevel => throw _privateConstructorUsedError;
  int get xpForNextLevel => throw _privateConstructorUsedError;

  /// Create a copy of XpSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $XpSummaryCopyWith<XpSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $XpSummaryCopyWith<$Res> {
  factory $XpSummaryCopyWith(XpSummary value, $Res Function(XpSummary) then) =
      _$XpSummaryCopyWithImpl<$Res, XpSummary>;
  @useResult
  $Res call(
      {int currentXp, int level, int xpInCurrentLevel, int xpForNextLevel});
}

/// @nodoc
class _$XpSummaryCopyWithImpl<$Res, $Val extends XpSummary>
    implements $XpSummaryCopyWith<$Res> {
  _$XpSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of XpSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentXp = null,
    Object? level = null,
    Object? xpInCurrentLevel = null,
    Object? xpForNextLevel = null,
  }) {
    return _then(_value.copyWith(
      currentXp: null == currentXp
          ? _value.currentXp
          : currentXp // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xpInCurrentLevel: null == xpInCurrentLevel
          ? _value.xpInCurrentLevel
          : xpInCurrentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      xpForNextLevel: null == xpForNextLevel
          ? _value.xpForNextLevel
          : xpForNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$XpSummaryImplCopyWith<$Res>
    implements $XpSummaryCopyWith<$Res> {
  factory _$$XpSummaryImplCopyWith(
          _$XpSummaryImpl value, $Res Function(_$XpSummaryImpl) then) =
      __$$XpSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentXp, int level, int xpInCurrentLevel, int xpForNextLevel});
}

/// @nodoc
class __$$XpSummaryImplCopyWithImpl<$Res>
    extends _$XpSummaryCopyWithImpl<$Res, _$XpSummaryImpl>
    implements _$$XpSummaryImplCopyWith<$Res> {
  __$$XpSummaryImplCopyWithImpl(
      _$XpSummaryImpl _value, $Res Function(_$XpSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of XpSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentXp = null,
    Object? level = null,
    Object? xpInCurrentLevel = null,
    Object? xpForNextLevel = null,
  }) {
    return _then(_$XpSummaryImpl(
      currentXp: null == currentXp
          ? _value.currentXp
          : currentXp // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xpInCurrentLevel: null == xpInCurrentLevel
          ? _value.xpInCurrentLevel
          : xpInCurrentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      xpForNextLevel: null == xpForNextLevel
          ? _value.xpForNextLevel
          : xpForNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$XpSummaryImpl extends _XpSummary {
  const _$XpSummaryImpl(
      {required this.currentXp,
      required this.level,
      required this.xpInCurrentLevel,
      required this.xpForNextLevel})
      : super._();

  @override
  final int currentXp;
  @override
  final int level;
  @override
  final int xpInCurrentLevel;
  @override
  final int xpForNextLevel;

  @override
  String toString() {
    return 'XpSummary(currentXp: $currentXp, level: $level, xpInCurrentLevel: $xpInCurrentLevel, xpForNextLevel: $xpForNextLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$XpSummaryImpl &&
            (identical(other.currentXp, currentXp) ||
                other.currentXp == currentXp) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.xpInCurrentLevel, xpInCurrentLevel) ||
                other.xpInCurrentLevel == xpInCurrentLevel) &&
            (identical(other.xpForNextLevel, xpForNextLevel) ||
                other.xpForNextLevel == xpForNextLevel));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, currentXp, level, xpInCurrentLevel, xpForNextLevel);

  /// Create a copy of XpSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$XpSummaryImplCopyWith<_$XpSummaryImpl> get copyWith =>
      __$$XpSummaryImplCopyWithImpl<_$XpSummaryImpl>(this, _$identity);
}

abstract class _XpSummary extends XpSummary {
  const factory _XpSummary(
      {required final int currentXp,
      required final int level,
      required final int xpInCurrentLevel,
      required final int xpForNextLevel}) = _$XpSummaryImpl;
  const _XpSummary._() : super._();

  @override
  int get currentXp;
  @override
  int get level;
  @override
  int get xpInCurrentLevel;
  @override
  int get xpForNextLevel;

  /// Create a copy of XpSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$XpSummaryImplCopyWith<_$XpSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
