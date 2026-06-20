// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_path.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LearningPath {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get coverUrl => throw _privateConstructorUsedError;
  String get coverColorHex => throw _privateConstructorUsedError;
  int get deckCount => throw _privateConstructorUsedError;
  int get estimatedHours => throw _privateConstructorUsedError;
  PathDifficulty get difficulty => throw _privateConstructorUsedError;
  int get enrolledCount => throw _privateConstructorUsedError;

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningPathCopyWith<LearningPath> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningPathCopyWith<$Res> {
  factory $LearningPathCopyWith(
          LearningPath value, $Res Function(LearningPath) then) =
      _$LearningPathCopyWithImpl<$Res, LearningPath>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? coverUrl,
      String coverColorHex,
      int deckCount,
      int estimatedHours,
      PathDifficulty difficulty,
      int enrolledCount});
}

/// @nodoc
class _$LearningPathCopyWithImpl<$Res, $Val extends LearningPath>
    implements $LearningPathCopyWith<$Res> {
  _$LearningPathCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? coverUrl = freezed,
    Object? coverColorHex = null,
    Object? deckCount = null,
    Object? estimatedHours = null,
    Object? difficulty = null,
    Object? enrolledCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverUrl: freezed == coverUrl
          ? _value.coverUrl
          : coverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverColorHex: null == coverColorHex
          ? _value.coverColorHex
          : coverColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      deckCount: null == deckCount
          ? _value.deckCount
          : deckCount // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedHours: null == estimatedHours
          ? _value.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as PathDifficulty,
      enrolledCount: null == enrolledCount
          ? _value.enrolledCount
          : enrolledCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LearningPathImplCopyWith<$Res>
    implements $LearningPathCopyWith<$Res> {
  factory _$$LearningPathImplCopyWith(
          _$LearningPathImpl value, $Res Function(_$LearningPathImpl) then) =
      __$$LearningPathImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? coverUrl,
      String coverColorHex,
      int deckCount,
      int estimatedHours,
      PathDifficulty difficulty,
      int enrolledCount});
}

/// @nodoc
class __$$LearningPathImplCopyWithImpl<$Res>
    extends _$LearningPathCopyWithImpl<$Res, _$LearningPathImpl>
    implements _$$LearningPathImplCopyWith<$Res> {
  __$$LearningPathImplCopyWithImpl(
      _$LearningPathImpl _value, $Res Function(_$LearningPathImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? coverUrl = freezed,
    Object? coverColorHex = null,
    Object? deckCount = null,
    Object? estimatedHours = null,
    Object? difficulty = null,
    Object? enrolledCount = null,
  }) {
    return _then(_$LearningPathImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverUrl: freezed == coverUrl
          ? _value.coverUrl
          : coverUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      coverColorHex: null == coverColorHex
          ? _value.coverColorHex
          : coverColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      deckCount: null == deckCount
          ? _value.deckCount
          : deckCount // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedHours: null == estimatedHours
          ? _value.estimatedHours
          : estimatedHours // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as PathDifficulty,
      enrolledCount: null == enrolledCount
          ? _value.enrolledCount
          : enrolledCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$LearningPathImpl implements _LearningPath {
  const _$LearningPathImpl(
      {required this.id,
      required this.title,
      required this.description,
      this.coverUrl,
      required this.coverColorHex,
      required this.deckCount,
      required this.estimatedHours,
      required this.difficulty,
      required this.enrolledCount});

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? coverUrl;
  @override
  final String coverColorHex;
  @override
  final int deckCount;
  @override
  final int estimatedHours;
  @override
  final PathDifficulty difficulty;
  @override
  final int enrolledCount;

  @override
  String toString() {
    return 'LearningPath(id: $id, title: $title, description: $description, coverUrl: $coverUrl, coverColorHex: $coverColorHex, deckCount: $deckCount, estimatedHours: $estimatedHours, difficulty: $difficulty, enrolledCount: $enrolledCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningPathImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.coverColorHex, coverColorHex) ||
                other.coverColorHex == coverColorHex) &&
            (identical(other.deckCount, deckCount) ||
                other.deckCount == deckCount) &&
            (identical(other.estimatedHours, estimatedHours) ||
                other.estimatedHours == estimatedHours) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.enrolledCount, enrolledCount) ||
                other.enrolledCount == enrolledCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, coverUrl,
      coverColorHex, deckCount, estimatedHours, difficulty, enrolledCount);

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningPathImplCopyWith<_$LearningPathImpl> get copyWith =>
      __$$LearningPathImplCopyWithImpl<_$LearningPathImpl>(this, _$identity);
}

abstract class _LearningPath implements LearningPath {
  const factory _LearningPath(
      {required final String id,
      required final String title,
      required final String description,
      final String? coverUrl,
      required final String coverColorHex,
      required final int deckCount,
      required final int estimatedHours,
      required final PathDifficulty difficulty,
      required final int enrolledCount}) = _$LearningPathImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get coverUrl;
  @override
  String get coverColorHex;
  @override
  int get deckCount;
  @override
  int get estimatedHours;
  @override
  PathDifficulty get difficulty;
  @override
  int get enrolledCount;

  /// Create a copy of LearningPath
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningPathImplCopyWith<_$LearningPathImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
