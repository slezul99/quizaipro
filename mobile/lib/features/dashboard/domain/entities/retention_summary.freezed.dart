// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'retention_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RetentionSummary {
  int? get now => throw _privateConstructorUsedError;
  int? get forecast => throw _privateConstructorUsedError;
  int get fading => throw _privateConstructorUsedError;
  int get studied => throw _privateConstructorUsedError;

  /// Create a copy of RetentionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RetentionSummaryCopyWith<RetentionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetentionSummaryCopyWith<$Res> {
  factory $RetentionSummaryCopyWith(
          RetentionSummary value, $Res Function(RetentionSummary) then) =
      _$RetentionSummaryCopyWithImpl<$Res, RetentionSummary>;
  @useResult
  $Res call({int? now, int? forecast, int fading, int studied});
}

/// @nodoc
class _$RetentionSummaryCopyWithImpl<$Res, $Val extends RetentionSummary>
    implements $RetentionSummaryCopyWith<$Res> {
  _$RetentionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RetentionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? now = freezed,
    Object? forecast = freezed,
    Object? fading = null,
    Object? studied = null,
  }) {
    return _then(_value.copyWith(
      now: freezed == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as int?,
      forecast: freezed == forecast
          ? _value.forecast
          : forecast // ignore: cast_nullable_to_non_nullable
              as int?,
      fading: null == fading
          ? _value.fading
          : fading // ignore: cast_nullable_to_non_nullable
              as int,
      studied: null == studied
          ? _value.studied
          : studied // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RetentionSummaryImplCopyWith<$Res>
    implements $RetentionSummaryCopyWith<$Res> {
  factory _$$RetentionSummaryImplCopyWith(_$RetentionSummaryImpl value,
          $Res Function(_$RetentionSummaryImpl) then) =
      __$$RetentionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? now, int? forecast, int fading, int studied});
}

/// @nodoc
class __$$RetentionSummaryImplCopyWithImpl<$Res>
    extends _$RetentionSummaryCopyWithImpl<$Res, _$RetentionSummaryImpl>
    implements _$$RetentionSummaryImplCopyWith<$Res> {
  __$$RetentionSummaryImplCopyWithImpl(_$RetentionSummaryImpl _value,
      $Res Function(_$RetentionSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of RetentionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? now = freezed,
    Object? forecast = freezed,
    Object? fading = null,
    Object? studied = null,
  }) {
    return _then(_$RetentionSummaryImpl(
      now: freezed == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as int?,
      forecast: freezed == forecast
          ? _value.forecast
          : forecast // ignore: cast_nullable_to_non_nullable
              as int?,
      fading: null == fading
          ? _value.fading
          : fading // ignore: cast_nullable_to_non_nullable
              as int,
      studied: null == studied
          ? _value.studied
          : studied // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$RetentionSummaryImpl extends _RetentionSummary {
  const _$RetentionSummaryImpl(
      {this.now, this.forecast, this.fading = 0, this.studied = 0})
      : super._();

  @override
  final int? now;
  @override
  final int? forecast;
  @override
  @JsonKey()
  final int fading;
  @override
  @JsonKey()
  final int studied;

  @override
  String toString() {
    return 'RetentionSummary(now: $now, forecast: $forecast, fading: $fading, studied: $studied)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RetentionSummaryImpl &&
            (identical(other.now, now) || other.now == now) &&
            (identical(other.forecast, forecast) ||
                other.forecast == forecast) &&
            (identical(other.fading, fading) || other.fading == fading) &&
            (identical(other.studied, studied) || other.studied == studied));
  }

  @override
  int get hashCode => Object.hash(runtimeType, now, forecast, fading, studied);

  /// Create a copy of RetentionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RetentionSummaryImplCopyWith<_$RetentionSummaryImpl> get copyWith =>
      __$$RetentionSummaryImplCopyWithImpl<_$RetentionSummaryImpl>(
          this, _$identity);
}

abstract class _RetentionSummary extends RetentionSummary {
  const factory _RetentionSummary(
      {final int? now,
      final int? forecast,
      final int fading,
      final int studied}) = _$RetentionSummaryImpl;
  const _RetentionSummary._() : super._();

  @override
  int? get now;
  @override
  int? get forecast;
  @override
  int get fading;
  @override
  int get studied;

  /// Create a copy of RetentionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RetentionSummaryImplCopyWith<_$RetentionSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
