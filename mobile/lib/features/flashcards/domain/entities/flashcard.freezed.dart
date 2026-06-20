// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Flashcard {
  String get id => throw _privateConstructorUsedError;
  String get deckId => throw _privateConstructorUsedError;
  String get front => throw _privateConstructorUsedError;
  String get back => throw _privateConstructorUsedError;
  String? get hint => throw _privateConstructorUsedError;
  double get easeFactor => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  int get repetitions => throw _privateConstructorUsedError;
  double? get stability => throw _privateConstructorUsedError;
  double? get difficulty => throw _privateConstructorUsedError;
  DateTime? get nextReviewAt => throw _privateConstructorUsedError;
  DateTime? get lastStudiedAt => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  bool get isDifficult => throw _privateConstructorUsedError;
  int get againCount => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of Flashcard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardCopyWith<Flashcard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardCopyWith<$Res> {
  factory $FlashcardCopyWith(Flashcard value, $Res Function(Flashcard) then) =
      _$FlashcardCopyWithImpl<$Res, Flashcard>;
  @useResult
  $Res call(
      {String id,
      String deckId,
      String front,
      String back,
      String? hint,
      double easeFactor,
      int interval,
      int repetitions,
      double? stability,
      double? difficulty,
      DateTime? nextReviewAt,
      DateTime? lastStudiedAt,
      bool isFavorite,
      bool isDifficult,
      int againCount,
      DateTime updatedAt});
}

/// @nodoc
class _$FlashcardCopyWithImpl<$Res, $Val extends Flashcard>
    implements $FlashcardCopyWith<$Res> {
  _$FlashcardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Flashcard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? front = null,
    Object? back = null,
    Object? hint = freezed,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetitions = null,
    Object? stability = freezed,
    Object? difficulty = freezed,
    Object? nextReviewAt = freezed,
    Object? lastStudiedAt = freezed,
    Object? isFavorite = null,
    Object? isDifficult = null,
    Object? againCount = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      hint: freezed == hint
          ? _value.hint
          : hint // ignore: cast_nullable_to_non_nullable
              as String?,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      stability: freezed == stability
          ? _value.stability
          : stability // ignore: cast_nullable_to_non_nullable
              as double?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double?,
      nextReviewAt: freezed == nextReviewAt
          ? _value.nextReviewAt
          : nextReviewAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isDifficult: null == isDifficult
          ? _value.isDifficult
          : isDifficult // ignore: cast_nullable_to_non_nullable
              as bool,
      againCount: null == againCount
          ? _value.againCount
          : againCount // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FlashcardImplCopyWith<$Res>
    implements $FlashcardCopyWith<$Res> {
  factory _$$FlashcardImplCopyWith(
          _$FlashcardImpl value, $Res Function(_$FlashcardImpl) then) =
      __$$FlashcardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deckId,
      String front,
      String back,
      String? hint,
      double easeFactor,
      int interval,
      int repetitions,
      double? stability,
      double? difficulty,
      DateTime? nextReviewAt,
      DateTime? lastStudiedAt,
      bool isFavorite,
      bool isDifficult,
      int againCount,
      DateTime updatedAt});
}

/// @nodoc
class __$$FlashcardImplCopyWithImpl<$Res>
    extends _$FlashcardCopyWithImpl<$Res, _$FlashcardImpl>
    implements _$$FlashcardImplCopyWith<$Res> {
  __$$FlashcardImplCopyWithImpl(
      _$FlashcardImpl _value, $Res Function(_$FlashcardImpl) _then)
      : super(_value, _then);

  /// Create a copy of Flashcard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? front = null,
    Object? back = null,
    Object? hint = freezed,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetitions = null,
    Object? stability = freezed,
    Object? difficulty = freezed,
    Object? nextReviewAt = freezed,
    Object? lastStudiedAt = freezed,
    Object? isFavorite = null,
    Object? isDifficult = null,
    Object? againCount = null,
    Object? updatedAt = null,
  }) {
    return _then(_$FlashcardImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      hint: freezed == hint
          ? _value.hint
          : hint // ignore: cast_nullable_to_non_nullable
              as String?,
      easeFactor: null == easeFactor
          ? _value.easeFactor
          : easeFactor // ignore: cast_nullable_to_non_nullable
              as double,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      repetitions: null == repetitions
          ? _value.repetitions
          : repetitions // ignore: cast_nullable_to_non_nullable
              as int,
      stability: freezed == stability
          ? _value.stability
          : stability // ignore: cast_nullable_to_non_nullable
              as double?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as double?,
      nextReviewAt: freezed == nextReviewAt
          ? _value.nextReviewAt
          : nextReviewAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isDifficult: null == isDifficult
          ? _value.isDifficult
          : isDifficult // ignore: cast_nullable_to_non_nullable
              as bool,
      againCount: null == againCount
          ? _value.againCount
          : againCount // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$FlashcardImpl extends _Flashcard {
  const _$FlashcardImpl(
      {required this.id,
      required this.deckId,
      required this.front,
      required this.back,
      this.hint,
      required this.easeFactor,
      required this.interval,
      required this.repetitions,
      this.stability,
      this.difficulty,
      this.nextReviewAt,
      this.lastStudiedAt,
      required this.isFavorite,
      required this.isDifficult,
      required this.againCount,
      required this.updatedAt})
      : super._();

  @override
  final String id;
  @override
  final String deckId;
  @override
  final String front;
  @override
  final String back;
  @override
  final String? hint;
  @override
  final double easeFactor;
  @override
  final int interval;
  @override
  final int repetitions;
  @override
  final double? stability;
  @override
  final double? difficulty;
  @override
  final DateTime? nextReviewAt;
  @override
  final DateTime? lastStudiedAt;
  @override
  final bool isFavorite;
  @override
  final bool isDifficult;
  @override
  final int againCount;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Flashcard(id: $id, deckId: $deckId, front: $front, back: $back, hint: $hint, easeFactor: $easeFactor, interval: $interval, repetitions: $repetitions, stability: $stability, difficulty: $difficulty, nextReviewAt: $nextReviewAt, lastStudiedAt: $lastStudiedAt, isFavorite: $isFavorite, isDifficult: $isDifficult, againCount: $againCount, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back) &&
            (identical(other.hint, hint) || other.hint == hint) &&
            (identical(other.easeFactor, easeFactor) ||
                other.easeFactor == easeFactor) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.stability, stability) ||
                other.stability == stability) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.nextReviewAt, nextReviewAt) ||
                other.nextReviewAt == nextReviewAt) &&
            (identical(other.lastStudiedAt, lastStudiedAt) ||
                other.lastStudiedAt == lastStudiedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isDifficult, isDifficult) ||
                other.isDifficult == isDifficult) &&
            (identical(other.againCount, againCount) ||
                other.againCount == againCount) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      deckId,
      front,
      back,
      hint,
      easeFactor,
      interval,
      repetitions,
      stability,
      difficulty,
      nextReviewAt,
      lastStudiedAt,
      isFavorite,
      isDifficult,
      againCount,
      updatedAt);

  /// Create a copy of Flashcard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardImplCopyWith<_$FlashcardImpl> get copyWith =>
      __$$FlashcardImplCopyWithImpl<_$FlashcardImpl>(this, _$identity);
}

abstract class _Flashcard extends Flashcard {
  const factory _Flashcard(
      {required final String id,
      required final String deckId,
      required final String front,
      required final String back,
      final String? hint,
      required final double easeFactor,
      required final int interval,
      required final int repetitions,
      final double? stability,
      final double? difficulty,
      final DateTime? nextReviewAt,
      final DateTime? lastStudiedAt,
      required final bool isFavorite,
      required final bool isDifficult,
      required final int againCount,
      required final DateTime updatedAt}) = _$FlashcardImpl;
  const _Flashcard._() : super._();

  @override
  String get id;
  @override
  String get deckId;
  @override
  String get front;
  @override
  String get back;
  @override
  String? get hint;
  @override
  double get easeFactor;
  @override
  int get interval;
  @override
  int get repetitions;
  @override
  double? get stability;
  @override
  double? get difficulty;
  @override
  DateTime? get nextReviewAt;
  @override
  DateTime? get lastStudiedAt;
  @override
  bool get isFavorite;
  @override
  bool get isDifficult;
  @override
  int get againCount;
  @override
  DateTime get updatedAt;

  /// Create a copy of Flashcard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardImplCopyWith<_$FlashcardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
