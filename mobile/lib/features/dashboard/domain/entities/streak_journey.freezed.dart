// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_journey.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakJourney _$StreakJourneyFromJson(Map<String, dynamic> json) {
  return _StreakJourney.fromJson(json);
}

/// @nodoc
mixin _$StreakJourney {
  StreakSummary get streak => throw _privateConstructorUsedError;
  List<StreakMilestone> get milestones => throw _privateConstructorUsedError;
  List<ClaimedReward> get rewardsHistory => throw _privateConstructorUsedError;
  StreakCalendar get calendar => throw _privateConstructorUsedError;

  /// Serializes this StreakJourney to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakJourney
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakJourneyCopyWith<StreakJourney> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakJourneyCopyWith<$Res> {
  factory $StreakJourneyCopyWith(
          StreakJourney value, $Res Function(StreakJourney) then) =
      _$StreakJourneyCopyWithImpl<$Res, StreakJourney>;
  @useResult
  $Res call(
      {StreakSummary streak,
      List<StreakMilestone> milestones,
      List<ClaimedReward> rewardsHistory,
      StreakCalendar calendar});

  $StreakSummaryCopyWith<$Res> get streak;
  $StreakCalendarCopyWith<$Res> get calendar;
}

/// @nodoc
class _$StreakJourneyCopyWithImpl<$Res, $Val extends StreakJourney>
    implements $StreakJourneyCopyWith<$Res> {
  _$StreakJourneyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakJourney
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streak = null,
    Object? milestones = null,
    Object? rewardsHistory = null,
    Object? calendar = null,
  }) {
    return _then(_value.copyWith(
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as StreakSummary,
      milestones: null == milestones
          ? _value.milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<StreakMilestone>,
      rewardsHistory: null == rewardsHistory
          ? _value.rewardsHistory
          : rewardsHistory // ignore: cast_nullable_to_non_nullable
              as List<ClaimedReward>,
      calendar: null == calendar
          ? _value.calendar
          : calendar // ignore: cast_nullable_to_non_nullable
              as StreakCalendar,
    ) as $Val);
  }

  /// Create a copy of StreakJourney
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreakSummaryCopyWith<$Res> get streak {
    return $StreakSummaryCopyWith<$Res>(_value.streak, (value) {
      return _then(_value.copyWith(streak: value) as $Val);
    });
  }

  /// Create a copy of StreakJourney
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreakCalendarCopyWith<$Res> get calendar {
    return $StreakCalendarCopyWith<$Res>(_value.calendar, (value) {
      return _then(_value.copyWith(calendar: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StreakJourneyImplCopyWith<$Res>
    implements $StreakJourneyCopyWith<$Res> {
  factory _$$StreakJourneyImplCopyWith(
          _$StreakJourneyImpl value, $Res Function(_$StreakJourneyImpl) then) =
      __$$StreakJourneyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {StreakSummary streak,
      List<StreakMilestone> milestones,
      List<ClaimedReward> rewardsHistory,
      StreakCalendar calendar});

  @override
  $StreakSummaryCopyWith<$Res> get streak;
  @override
  $StreakCalendarCopyWith<$Res> get calendar;
}

/// @nodoc
class __$$StreakJourneyImplCopyWithImpl<$Res>
    extends _$StreakJourneyCopyWithImpl<$Res, _$StreakJourneyImpl>
    implements _$$StreakJourneyImplCopyWith<$Res> {
  __$$StreakJourneyImplCopyWithImpl(
      _$StreakJourneyImpl _value, $Res Function(_$StreakJourneyImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakJourney
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streak = null,
    Object? milestones = null,
    Object? rewardsHistory = null,
    Object? calendar = null,
  }) {
    return _then(_$StreakJourneyImpl(
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as StreakSummary,
      milestones: null == milestones
          ? _value._milestones
          : milestones // ignore: cast_nullable_to_non_nullable
              as List<StreakMilestone>,
      rewardsHistory: null == rewardsHistory
          ? _value._rewardsHistory
          : rewardsHistory // ignore: cast_nullable_to_non_nullable
              as List<ClaimedReward>,
      calendar: null == calendar
          ? _value.calendar
          : calendar // ignore: cast_nullable_to_non_nullable
              as StreakCalendar,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakJourneyImpl implements _StreakJourney {
  const _$StreakJourneyImpl(
      {required this.streak,
      required final List<StreakMilestone> milestones,
      required final List<ClaimedReward> rewardsHistory,
      required this.calendar})
      : _milestones = milestones,
        _rewardsHistory = rewardsHistory;

  factory _$StreakJourneyImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakJourneyImplFromJson(json);

  @override
  final StreakSummary streak;
  final List<StreakMilestone> _milestones;
  @override
  List<StreakMilestone> get milestones {
    if (_milestones is EqualUnmodifiableListView) return _milestones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_milestones);
  }

  final List<ClaimedReward> _rewardsHistory;
  @override
  List<ClaimedReward> get rewardsHistory {
    if (_rewardsHistory is EqualUnmodifiableListView) return _rewardsHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rewardsHistory);
  }

  @override
  final StreakCalendar calendar;

  @override
  String toString() {
    return 'StreakJourney(streak: $streak, milestones: $milestones, rewardsHistory: $rewardsHistory, calendar: $calendar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakJourneyImpl &&
            (identical(other.streak, streak) || other.streak == streak) &&
            const DeepCollectionEquality()
                .equals(other._milestones, _milestones) &&
            const DeepCollectionEquality()
                .equals(other._rewardsHistory, _rewardsHistory) &&
            (identical(other.calendar, calendar) ||
                other.calendar == calendar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      streak,
      const DeepCollectionEquality().hash(_milestones),
      const DeepCollectionEquality().hash(_rewardsHistory),
      calendar);

  /// Create a copy of StreakJourney
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakJourneyImplCopyWith<_$StreakJourneyImpl> get copyWith =>
      __$$StreakJourneyImplCopyWithImpl<_$StreakJourneyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakJourneyImplToJson(
      this,
    );
  }
}

abstract class _StreakJourney implements StreakJourney {
  const factory _StreakJourney(
      {required final StreakSummary streak,
      required final List<StreakMilestone> milestones,
      required final List<ClaimedReward> rewardsHistory,
      required final StreakCalendar calendar}) = _$StreakJourneyImpl;

  factory _StreakJourney.fromJson(Map<String, dynamic> json) =
      _$StreakJourneyImpl.fromJson;

  @override
  StreakSummary get streak;
  @override
  List<StreakMilestone> get milestones;
  @override
  List<ClaimedReward> get rewardsHistory;
  @override
  StreakCalendar get calendar;

  /// Create a copy of StreakJourney
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakJourneyImplCopyWith<_$StreakJourneyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StreakMilestone _$StreakMilestoneFromJson(Map<String, dynamic> json) {
  return _StreakMilestone.fromJson(json);
}

/// @nodoc
mixin _$StreakMilestone {
  String get key => throw _privateConstructorUsedError;
  int get days => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get desc => throw _privateConstructorUsedError;
  bool get unlocked => throw _privateConstructorUsedError;
  String? get unlockedAt => throw _privateConstructorUsedError;

  /// Serializes this StreakMilestone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakMilestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakMilestoneCopyWith<StreakMilestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakMilestoneCopyWith<$Res> {
  factory $StreakMilestoneCopyWith(
          StreakMilestone value, $Res Function(StreakMilestone) then) =
      _$StreakMilestoneCopyWithImpl<$Res, StreakMilestone>;
  @useResult
  $Res call(
      {String key,
      int days,
      int xp,
      String name,
      String desc,
      bool unlocked,
      String? unlockedAt});
}

/// @nodoc
class _$StreakMilestoneCopyWithImpl<$Res, $Val extends StreakMilestone>
    implements $StreakMilestoneCopyWith<$Res> {
  _$StreakMilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakMilestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? days = null,
    Object? xp = null,
    Object? name = null,
    Object? desc = null,
    Object? unlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      unlocked: null == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakMilestoneImplCopyWith<$Res>
    implements $StreakMilestoneCopyWith<$Res> {
  factory _$$StreakMilestoneImplCopyWith(_$StreakMilestoneImpl value,
          $Res Function(_$StreakMilestoneImpl) then) =
      __$$StreakMilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key,
      int days,
      int xp,
      String name,
      String desc,
      bool unlocked,
      String? unlockedAt});
}

/// @nodoc
class __$$StreakMilestoneImplCopyWithImpl<$Res>
    extends _$StreakMilestoneCopyWithImpl<$Res, _$StreakMilestoneImpl>
    implements _$$StreakMilestoneImplCopyWith<$Res> {
  __$$StreakMilestoneImplCopyWithImpl(
      _$StreakMilestoneImpl _value, $Res Function(_$StreakMilestoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakMilestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? days = null,
    Object? xp = null,
    Object? name = null,
    Object? desc = null,
    Object? unlocked = null,
    Object? unlockedAt = freezed,
  }) {
    return _then(_$StreakMilestoneImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      days: null == days
          ? _value.days
          : days // ignore: cast_nullable_to_non_nullable
              as int,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _value.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      unlocked: null == unlocked
          ? _value.unlocked
          : unlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakMilestoneImpl implements _StreakMilestone {
  const _$StreakMilestoneImpl(
      {required this.key,
      required this.days,
      required this.xp,
      required this.name,
      required this.desc,
      required this.unlocked,
      required this.unlockedAt});

  factory _$StreakMilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakMilestoneImplFromJson(json);

  @override
  final String key;
  @override
  final int days;
  @override
  final int xp;
  @override
  final String name;
  @override
  final String desc;
  @override
  final bool unlocked;
  @override
  final String? unlockedAt;

  @override
  String toString() {
    return 'StreakMilestone(key: $key, days: $days, xp: $xp, name: $name, desc: $desc, unlocked: $unlocked, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakMilestoneImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.days, days) || other.days == days) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            (identical(other.unlocked, unlocked) ||
                other.unlocked == unlocked) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, key, days, xp, name, desc, unlocked, unlockedAt);

  /// Create a copy of StreakMilestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakMilestoneImplCopyWith<_$StreakMilestoneImpl> get copyWith =>
      __$$StreakMilestoneImplCopyWithImpl<_$StreakMilestoneImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakMilestoneImplToJson(
      this,
    );
  }
}

abstract class _StreakMilestone implements StreakMilestone {
  const factory _StreakMilestone(
      {required final String key,
      required final int days,
      required final int xp,
      required final String name,
      required final String desc,
      required final bool unlocked,
      required final String? unlockedAt}) = _$StreakMilestoneImpl;

  factory _StreakMilestone.fromJson(Map<String, dynamic> json) =
      _$StreakMilestoneImpl.fromJson;

  @override
  String get key;
  @override
  int get days;
  @override
  int get xp;
  @override
  String get name;
  @override
  String get desc;
  @override
  bool get unlocked;
  @override
  String? get unlockedAt;

  /// Create a copy of StreakMilestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakMilestoneImplCopyWith<_$StreakMilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClaimedReward _$ClaimedRewardFromJson(Map<String, dynamic> json) {
  return _ClaimedReward.fromJson(json);
}

/// @nodoc
mixin _$ClaimedReward {
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  String get unlockedAt => throw _privateConstructorUsedError;

  /// Serializes this ClaimedReward to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClaimedReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClaimedRewardCopyWith<ClaimedReward> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClaimedRewardCopyWith<$Res> {
  factory $ClaimedRewardCopyWith(
          ClaimedReward value, $Res Function(ClaimedReward) then) =
      _$ClaimedRewardCopyWithImpl<$Res, ClaimedReward>;
  @useResult
  $Res call({String key, String name, int xp, String unlockedAt});
}

/// @nodoc
class _$ClaimedRewardCopyWithImpl<$Res, $Val extends ClaimedReward>
    implements $ClaimedRewardCopyWith<$Res> {
  _$ClaimedRewardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClaimedReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? xp = null,
    Object? unlockedAt = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedAt: null == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClaimedRewardImplCopyWith<$Res>
    implements $ClaimedRewardCopyWith<$Res> {
  factory _$$ClaimedRewardImplCopyWith(
          _$ClaimedRewardImpl value, $Res Function(_$ClaimedRewardImpl) then) =
      __$$ClaimedRewardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key, String name, int xp, String unlockedAt});
}

/// @nodoc
class __$$ClaimedRewardImplCopyWithImpl<$Res>
    extends _$ClaimedRewardCopyWithImpl<$Res, _$ClaimedRewardImpl>
    implements _$$ClaimedRewardImplCopyWith<$Res> {
  __$$ClaimedRewardImplCopyWithImpl(
      _$ClaimedRewardImpl _value, $Res Function(_$ClaimedRewardImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClaimedReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? name = null,
    Object? xp = null,
    Object? unlockedAt = null,
  }) {
    return _then(_$ClaimedRewardImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedAt: null == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClaimedRewardImpl implements _ClaimedReward {
  const _$ClaimedRewardImpl(
      {required this.key,
      required this.name,
      required this.xp,
      required this.unlockedAt});

  factory _$ClaimedRewardImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClaimedRewardImplFromJson(json);

  @override
  final String key;
  @override
  final String name;
  @override
  final int xp;
  @override
  final String unlockedAt;

  @override
  String toString() {
    return 'ClaimedReward(key: $key, name: $name, xp: $xp, unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClaimedRewardImpl &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key, name, xp, unlockedAt);

  /// Create a copy of ClaimedReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClaimedRewardImplCopyWith<_$ClaimedRewardImpl> get copyWith =>
      __$$ClaimedRewardImplCopyWithImpl<_$ClaimedRewardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClaimedRewardImplToJson(
      this,
    );
  }
}

abstract class _ClaimedReward implements ClaimedReward {
  const factory _ClaimedReward(
      {required final String key,
      required final String name,
      required final int xp,
      required final String unlockedAt}) = _$ClaimedRewardImpl;

  factory _ClaimedReward.fromJson(Map<String, dynamic> json) =
      _$ClaimedRewardImpl.fromJson;

  @override
  String get key;
  @override
  String get name;
  @override
  int get xp;
  @override
  String get unlockedAt;

  /// Create a copy of ClaimedReward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClaimedRewardImplCopyWith<_$ClaimedRewardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StreakCalendar _$StreakCalendarFromJson(Map<String, dynamic> json) {
  return _StreakCalendar.fromJson(json);
}

/// @nodoc
mixin _$StreakCalendar {
  String get startDate => throw _privateConstructorUsedError;
  String get endDate => throw _privateConstructorUsedError;
  List<String> get activeDates => throw _privateConstructorUsedError;

  /// Serializes this StreakCalendar to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakCalendar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakCalendarCopyWith<StreakCalendar> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakCalendarCopyWith<$Res> {
  factory $StreakCalendarCopyWith(
          StreakCalendar value, $Res Function(StreakCalendar) then) =
      _$StreakCalendarCopyWithImpl<$Res, StreakCalendar>;
  @useResult
  $Res call({String startDate, String endDate, List<String> activeDates});
}

/// @nodoc
class _$StreakCalendarCopyWithImpl<$Res, $Val extends StreakCalendar>
    implements $StreakCalendarCopyWith<$Res> {
  _$StreakCalendarCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakCalendar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? activeDates = null,
  }) {
    return _then(_value.copyWith(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      activeDates: null == activeDates
          ? _value.activeDates
          : activeDates // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakCalendarImplCopyWith<$Res>
    implements $StreakCalendarCopyWith<$Res> {
  factory _$$StreakCalendarImplCopyWith(_$StreakCalendarImpl value,
          $Res Function(_$StreakCalendarImpl) then) =
      __$$StreakCalendarImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String startDate, String endDate, List<String> activeDates});
}

/// @nodoc
class __$$StreakCalendarImplCopyWithImpl<$Res>
    extends _$StreakCalendarCopyWithImpl<$Res, _$StreakCalendarImpl>
    implements _$$StreakCalendarImplCopyWith<$Res> {
  __$$StreakCalendarImplCopyWithImpl(
      _$StreakCalendarImpl _value, $Res Function(_$StreakCalendarImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakCalendar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? activeDates = null,
  }) {
    return _then(_$StreakCalendarImpl(
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      activeDates: null == activeDates
          ? _value._activeDates
          : activeDates // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakCalendarImpl implements _StreakCalendar {
  const _$StreakCalendarImpl(
      {required this.startDate,
      required this.endDate,
      required final List<String> activeDates})
      : _activeDates = activeDates;

  factory _$StreakCalendarImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakCalendarImplFromJson(json);

  @override
  final String startDate;
  @override
  final String endDate;
  final List<String> _activeDates;
  @override
  List<String> get activeDates {
    if (_activeDates is EqualUnmodifiableListView) return _activeDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeDates);
  }

  @override
  String toString() {
    return 'StreakCalendar(startDate: $startDate, endDate: $endDate, activeDates: $activeDates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakCalendarImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality()
                .equals(other._activeDates, _activeDates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate,
      const DeepCollectionEquality().hash(_activeDates));

  /// Create a copy of StreakCalendar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakCalendarImplCopyWith<_$StreakCalendarImpl> get copyWith =>
      __$$StreakCalendarImplCopyWithImpl<_$StreakCalendarImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakCalendarImplToJson(
      this,
    );
  }
}

abstract class _StreakCalendar implements StreakCalendar {
  const factory _StreakCalendar(
      {required final String startDate,
      required final String endDate,
      required final List<String> activeDates}) = _$StreakCalendarImpl;

  factory _StreakCalendar.fromJson(Map<String, dynamic> json) =
      _$StreakCalendarImpl.fromJson;

  @override
  String get startDate;
  @override
  String get endDate;
  @override
  List<String> get activeDates;

  /// Create a copy of StreakCalendar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakCalendarImplCopyWith<_$StreakCalendarImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
