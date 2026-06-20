// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'due_reviews_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DueReviewsSummary {
  int get totalDue => throw _privateConstructorUsedError;
  int get overdue => throw _privateConstructorUsedError;
  int get dueToday => throw _privateConstructorUsedError;

  /// Create a copy of DueReviewsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DueReviewsSummaryCopyWith<DueReviewsSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DueReviewsSummaryCopyWith<$Res> {
  factory $DueReviewsSummaryCopyWith(
          DueReviewsSummary value, $Res Function(DueReviewsSummary) then) =
      _$DueReviewsSummaryCopyWithImpl<$Res, DueReviewsSummary>;
  @useResult
  $Res call({int totalDue, int overdue, int dueToday});
}

/// @nodoc
class _$DueReviewsSummaryCopyWithImpl<$Res, $Val extends DueReviewsSummary>
    implements $DueReviewsSummaryCopyWith<$Res> {
  _$DueReviewsSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DueReviewsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDue = null,
    Object? overdue = null,
    Object? dueToday = null,
  }) {
    return _then(_value.copyWith(
      totalDue: null == totalDue
          ? _value.totalDue
          : totalDue // ignore: cast_nullable_to_non_nullable
              as int,
      overdue: null == overdue
          ? _value.overdue
          : overdue // ignore: cast_nullable_to_non_nullable
              as int,
      dueToday: null == dueToday
          ? _value.dueToday
          : dueToday // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DueReviewsSummaryImplCopyWith<$Res>
    implements $DueReviewsSummaryCopyWith<$Res> {
  factory _$$DueReviewsSummaryImplCopyWith(_$DueReviewsSummaryImpl value,
          $Res Function(_$DueReviewsSummaryImpl) then) =
      __$$DueReviewsSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalDue, int overdue, int dueToday});
}

/// @nodoc
class __$$DueReviewsSummaryImplCopyWithImpl<$Res>
    extends _$DueReviewsSummaryCopyWithImpl<$Res, _$DueReviewsSummaryImpl>
    implements _$$DueReviewsSummaryImplCopyWith<$Res> {
  __$$DueReviewsSummaryImplCopyWithImpl(_$DueReviewsSummaryImpl _value,
      $Res Function(_$DueReviewsSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DueReviewsSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDue = null,
    Object? overdue = null,
    Object? dueToday = null,
  }) {
    return _then(_$DueReviewsSummaryImpl(
      totalDue: null == totalDue
          ? _value.totalDue
          : totalDue // ignore: cast_nullable_to_non_nullable
              as int,
      overdue: null == overdue
          ? _value.overdue
          : overdue // ignore: cast_nullable_to_non_nullable
              as int,
      dueToday: null == dueToday
          ? _value.dueToday
          : dueToday // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DueReviewsSummaryImpl extends _DueReviewsSummary {
  const _$DueReviewsSummaryImpl(
      {required this.totalDue, required this.overdue, required this.dueToday})
      : super._();

  @override
  final int totalDue;
  @override
  final int overdue;
  @override
  final int dueToday;

  @override
  String toString() {
    return 'DueReviewsSummary(totalDue: $totalDue, overdue: $overdue, dueToday: $dueToday)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DueReviewsSummaryImpl &&
            (identical(other.totalDue, totalDue) ||
                other.totalDue == totalDue) &&
            (identical(other.overdue, overdue) || other.overdue == overdue) &&
            (identical(other.dueToday, dueToday) ||
                other.dueToday == dueToday));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalDue, overdue, dueToday);

  /// Create a copy of DueReviewsSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DueReviewsSummaryImplCopyWith<_$DueReviewsSummaryImpl> get copyWith =>
      __$$DueReviewsSummaryImplCopyWithImpl<_$DueReviewsSummaryImpl>(
          this, _$identity);
}

abstract class _DueReviewsSummary extends DueReviewsSummary {
  const factory _DueReviewsSummary(
      {required final int totalDue,
      required final int overdue,
      required final int dueToday}) = _$DueReviewsSummaryImpl;
  const _DueReviewsSummary._() : super._();

  @override
  int get totalDue;
  @override
  int get overdue;
  @override
  int get dueToday;

  /// Create a copy of DueReviewsSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DueReviewsSummaryImplCopyWith<_$DueReviewsSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
