// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakSummary _$StreakSummaryFromJson(Map<String, dynamic> json) {
  return _StreakSummary.fromJson(json);
}

/// @nodoc
mixin _$StreakSummary {
  @JsonKey(name: 'current_streak')
  int get currentStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_streak')
  int get maxStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'today_completed')
  bool get todayCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_activity_date')
  DateTime? get lastActivityDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_stage')
  StreakStageInfo? get currentStage => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_stage')
  StreakStageInfo? get nextStage => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_ratio')
  double? get progressRatio => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_remaining')
  int? get daysRemaining => throw _privateConstructorUsedError;

  /// Serializes this StreakSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakSummaryCopyWith<StreakSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakSummaryCopyWith<$Res> {
  factory $StreakSummaryCopyWith(
          StreakSummary value, $Res Function(StreakSummary) then) =
      _$StreakSummaryCopyWithImpl<$Res, StreakSummary>;
  @useResult
  $Res call(
      {@JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'max_streak') int maxStreak,
      @JsonKey(name: 'today_completed') bool todayCompleted,
      @JsonKey(name: 'last_activity_date') DateTime? lastActivityDate,
      @JsonKey(name: 'current_stage') StreakStageInfo? currentStage,
      @JsonKey(name: 'next_stage') StreakStageInfo? nextStage,
      @JsonKey(name: 'progress_ratio') double? progressRatio,
      @JsonKey(name: 'days_remaining') int? daysRemaining});

  $StreakStageInfoCopyWith<$Res>? get currentStage;
  $StreakStageInfoCopyWith<$Res>? get nextStage;
}

/// @nodoc
class _$StreakSummaryCopyWithImpl<$Res, $Val extends StreakSummary>
    implements $StreakSummaryCopyWith<$Res> {
  _$StreakSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? todayCompleted = null,
    Object? lastActivityDate = freezed,
    Object? currentStage = freezed,
    Object? nextStage = freezed,
    Object? progressRatio = freezed,
    Object? daysRemaining = freezed,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      todayCompleted: null == todayCompleted
          ? _value.todayCompleted
          : todayCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActivityDate: freezed == lastActivityDate
          ? _value.lastActivityDate
          : lastActivityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentStage: freezed == currentStage
          ? _value.currentStage
          : currentStage // ignore: cast_nullable_to_non_nullable
              as StreakStageInfo?,
      nextStage: freezed == nextStage
          ? _value.nextStage
          : nextStage // ignore: cast_nullable_to_non_nullable
              as StreakStageInfo?,
      progressRatio: freezed == progressRatio
          ? _value.progressRatio
          : progressRatio // ignore: cast_nullable_to_non_nullable
              as double?,
      daysRemaining: freezed == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  /// Create a copy of StreakSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreakStageInfoCopyWith<$Res>? get currentStage {
    if (_value.currentStage == null) {
      return null;
    }

    return $StreakStageInfoCopyWith<$Res>(_value.currentStage!, (value) {
      return _then(_value.copyWith(currentStage: value) as $Val);
    });
  }

  /// Create a copy of StreakSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreakStageInfoCopyWith<$Res>? get nextStage {
    if (_value.nextStage == null) {
      return null;
    }

    return $StreakStageInfoCopyWith<$Res>(_value.nextStage!, (value) {
      return _then(_value.copyWith(nextStage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StreakSummaryImplCopyWith<$Res>
    implements $StreakSummaryCopyWith<$Res> {
  factory _$$StreakSummaryImplCopyWith(
          _$StreakSummaryImpl value, $Res Function(_$StreakSummaryImpl) then) =
      __$$StreakSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'max_streak') int maxStreak,
      @JsonKey(name: 'today_completed') bool todayCompleted,
      @JsonKey(name: 'last_activity_date') DateTime? lastActivityDate,
      @JsonKey(name: 'current_stage') StreakStageInfo? currentStage,
      @JsonKey(name: 'next_stage') StreakStageInfo? nextStage,
      @JsonKey(name: 'progress_ratio') double? progressRatio,
      @JsonKey(name: 'days_remaining') int? daysRemaining});

  @override
  $StreakStageInfoCopyWith<$Res>? get currentStage;
  @override
  $StreakStageInfoCopyWith<$Res>? get nextStage;
}

/// @nodoc
class __$$StreakSummaryImplCopyWithImpl<$Res>
    extends _$StreakSummaryCopyWithImpl<$Res, _$StreakSummaryImpl>
    implements _$$StreakSummaryImplCopyWith<$Res> {
  __$$StreakSummaryImplCopyWithImpl(
      _$StreakSummaryImpl _value, $Res Function(_$StreakSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? todayCompleted = null,
    Object? lastActivityDate = freezed,
    Object? currentStage = freezed,
    Object? nextStage = freezed,
    Object? progressRatio = freezed,
    Object? daysRemaining = freezed,
  }) {
    return _then(_$StreakSummaryImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      todayCompleted: null == todayCompleted
          ? _value.todayCompleted
          : todayCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActivityDate: freezed == lastActivityDate
          ? _value.lastActivityDate
          : lastActivityDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentStage: freezed == currentStage
          ? _value.currentStage
          : currentStage // ignore: cast_nullable_to_non_nullable
              as StreakStageInfo?,
      nextStage: freezed == nextStage
          ? _value.nextStage
          : nextStage // ignore: cast_nullable_to_non_nullable
              as StreakStageInfo?,
      progressRatio: freezed == progressRatio
          ? _value.progressRatio
          : progressRatio // ignore: cast_nullable_to_non_nullable
              as double?,
      daysRemaining: freezed == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakSummaryImpl extends _StreakSummary {
  const _$StreakSummaryImpl(
      {@JsonKey(name: 'current_streak') required this.currentStreak,
      @JsonKey(name: 'max_streak') required this.maxStreak,
      @JsonKey(name: 'today_completed') required this.todayCompleted,
      @JsonKey(name: 'last_activity_date') this.lastActivityDate,
      @JsonKey(name: 'current_stage') required this.currentStage,
      @JsonKey(name: 'next_stage') required this.nextStage,
      @JsonKey(name: 'progress_ratio') required this.progressRatio,
      @JsonKey(name: 'days_remaining') required this.daysRemaining})
      : super._();

  factory _$StreakSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'current_streak')
  final int currentStreak;
  @override
  @JsonKey(name: 'max_streak')
  final int maxStreak;
  @override
  @JsonKey(name: 'today_completed')
  final bool todayCompleted;
  @override
  @JsonKey(name: 'last_activity_date')
  final DateTime? lastActivityDate;
  @override
  @JsonKey(name: 'current_stage')
  final StreakStageInfo? currentStage;
  @override
  @JsonKey(name: 'next_stage')
  final StreakStageInfo? nextStage;
  @override
  @JsonKey(name: 'progress_ratio')
  final double? progressRatio;
  @override
  @JsonKey(name: 'days_remaining')
  final int? daysRemaining;

  @override
  String toString() {
    return 'StreakSummary(currentStreak: $currentStreak, maxStreak: $maxStreak, todayCompleted: $todayCompleted, lastActivityDate: $lastActivityDate, currentStage: $currentStage, nextStage: $nextStage, progressRatio: $progressRatio, daysRemaining: $daysRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakSummaryImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.maxStreak, maxStreak) ||
                other.maxStreak == maxStreak) &&
            (identical(other.todayCompleted, todayCompleted) ||
                other.todayCompleted == todayCompleted) &&
            (identical(other.lastActivityDate, lastActivityDate) ||
                other.lastActivityDate == lastActivityDate) &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.nextStage, nextStage) ||
                other.nextStage == nextStage) &&
            (identical(other.progressRatio, progressRatio) ||
                other.progressRatio == progressRatio) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStreak,
      maxStreak,
      todayCompleted,
      lastActivityDate,
      currentStage,
      nextStage,
      progressRatio,
      daysRemaining);

  /// Create a copy of StreakSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakSummaryImplCopyWith<_$StreakSummaryImpl> get copyWith =>
      __$$StreakSummaryImplCopyWithImpl<_$StreakSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakSummaryImplToJson(
      this,
    );
  }
}

abstract class _StreakSummary extends StreakSummary {
  const factory _StreakSummary(
      {@JsonKey(name: 'current_streak') required final int currentStreak,
      @JsonKey(name: 'max_streak') required final int maxStreak,
      @JsonKey(name: 'today_completed') required final bool todayCompleted,
      @JsonKey(name: 'last_activity_date') final DateTime? lastActivityDate,
      @JsonKey(name: 'current_stage')
      required final StreakStageInfo? currentStage,
      @JsonKey(name: 'next_stage') required final StreakStageInfo? nextStage,
      @JsonKey(name: 'progress_ratio') required final double? progressRatio,
      @JsonKey(name: 'days_remaining')
      required final int? daysRemaining}) = _$StreakSummaryImpl;
  const _StreakSummary._() : super._();

  factory _StreakSummary.fromJson(Map<String, dynamic> json) =
      _$StreakSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'current_streak')
  int get currentStreak;
  @override
  @JsonKey(name: 'max_streak')
  int get maxStreak;
  @override
  @JsonKey(name: 'today_completed')
  bool get todayCompleted;
  @override
  @JsonKey(name: 'last_activity_date')
  DateTime? get lastActivityDate;
  @override
  @JsonKey(name: 'current_stage')
  StreakStageInfo? get currentStage;
  @override
  @JsonKey(name: 'next_stage')
  StreakStageInfo? get nextStage;
  @override
  @JsonKey(name: 'progress_ratio')
  double? get progressRatio;
  @override
  @JsonKey(name: 'days_remaining')
  int? get daysRemaining;

  /// Create a copy of StreakSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakSummaryImplCopyWith<_$StreakSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StreakStageInfo _$StreakStageInfoFromJson(Map<String, dynamic> json) {
  return _StreakStageInfo.fromJson(json);
}

/// @nodoc
mixin _$StreakStageInfo {
  String get key => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_days')
  int get startDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_stage_days')
  int? get nextStageDays => throw _privateConstructorUsedError;

  /// Serializes this StreakStageInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakStageInfoCopyWith<StreakStageInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakStageInfoCopyWith<$Res> {
  factory $StreakStageInfoCopyWith(
          StreakStageInfo value, $Res Function(StreakStageInfo) then) =
      _$StreakStageInfoCopyWithImpl<$Res, StreakStageInfo>;
  @useResult
  $Res call(
      {String key,
      @JsonKey(name: 'start_days') int startDays,
      @JsonKey(name: 'next_stage_days') int? nextStageDays});
}

/// @nodoc
class _$StreakStageInfoCopyWithImpl<$Res, $Val extends StreakStageInfo>
    implements $StreakStageInfoCopyWith<$Res> {
  _$StreakStageInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? startDays = null,
    Object? nextStageDays = freezed,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      startDays: null == startDays
          ? _value.startDays
          : startDays // ignore: cast_nullable_to_non_nullable
              as int,
      nextStageDays: freezed == nextStageDays
          ? _value.nextStageDays
          : nextStageDays // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakStageInfoImplCopyWith<$Res>
    implements $StreakStageInfoCopyWith<$Res> {
  factory _$$StreakStageInfoImplCopyWith(_$StreakStageInfoImpl value,
          $Res Function(_$StreakStageInfoImpl) then) =
      __$$StreakStageInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      @JsonKey(name: 'start_days') int startDays,
      @JsonKey(name: 'next_stage_days') int? nextStageDays});
}

/// @nodoc
class __$$StreakStageInfoImplCopyWithImpl<$Res>
    extends _$StreakStageInfoCopyWithImpl<$Res, _$StreakStageInfoImpl>
    implements _$$StreakStageInfoImplCopyWith<$Res> {
  __$$StreakStageInfoImplCopyWithImpl(
      _$StreakStageInfoImpl _value, $Res Function(_$StreakStageInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? startDays = null,
    Object? nextStageDays = freezed,
  }) {
    return _then(_$StreakStageInfoImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      startDays: null == startDays
          ? _value.startDays
          : startDays // ignore: cast_nullable_to_non_nullable
              as int,
      nextStageDays: freezed == nextStageDays
          ? _value.nextStageDays
          : nextStageDays // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakStageInfoImpl implements _StreakStageInfo {
  const _$StreakStageInfoImpl(
      {required this.key,
      @JsonKey(name: 'start_days') required this.startDays,
      @JsonKey(name: 'next_stage_days') this.nextStageDays});

  factory _$StreakStageInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakStageInfoImplFromJson(json);

  @override
  final String key;
  @override
  @JsonKey(name: 'start_days')
  final int startDays;
  @override
  @JsonKey(name: 'next_stage_days')
  final int? nextStageDays;

  @override
  String toString() {
    return 'StreakStageInfo(key: $key, startDays: $startDays, nextStageDays: $nextStageDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakStageInfoImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.startDays, startDays) ||
                other.startDays == startDays) &&
            (identical(other.nextStageDays, nextStageDays) ||
                other.nextStageDays == nextStageDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, startDays, nextStageDays);

  /// Create a copy of StreakStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakStageInfoImplCopyWith<_$StreakStageInfoImpl> get copyWith =>
      __$$StreakStageInfoImplCopyWithImpl<_$StreakStageInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakStageInfoImplToJson(
      this,
    );
  }
}

abstract class _StreakStageInfo implements StreakStageInfo {
  const factory _StreakStageInfo(
          {required final String key,
          @JsonKey(name: 'start_days') required final int startDays,
          @JsonKey(name: 'next_stage_days') final int? nextStageDays}) =
      _$StreakStageInfoImpl;

  factory _StreakStageInfo.fromJson(Map<String, dynamic> json) =
      _$StreakStageInfoImpl.fromJson;

  @override
  String get key;
  @override
  @JsonKey(name: 'start_days')
  int get startDays;
  @override
  @JsonKey(name: 'next_stage_days')
  int? get nextStageDays;

  /// Create a copy of StreakStageInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakStageInfoImplCopyWith<_$StreakStageInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
