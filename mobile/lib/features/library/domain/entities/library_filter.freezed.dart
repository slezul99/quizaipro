// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LibraryFilter {
  LibrarySortBy get sortBy => throw _privateConstructorUsedError;
  LibraryDifficulty? get difficulty => throw _privateConstructorUsedError;
  bool get showArchived => throw _privateConstructorUsedError;
  bool get hasDueOnly => throw _privateConstructorUsedError;

  /// Create a copy of LibraryFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LibraryFilterCopyWith<LibraryFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LibraryFilterCopyWith<$Res> {
  factory $LibraryFilterCopyWith(
          LibraryFilter value, $Res Function(LibraryFilter) then) =
      _$LibraryFilterCopyWithImpl<$Res, LibraryFilter>;
  @useResult
  $Res call(
      {LibrarySortBy sortBy,
      LibraryDifficulty? difficulty,
      bool showArchived,
      bool hasDueOnly});
}

/// @nodoc
class _$LibraryFilterCopyWithImpl<$Res, $Val extends LibraryFilter>
    implements $LibraryFilterCopyWith<$Res> {
  _$LibraryFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LibraryFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sortBy = null,
    Object? difficulty = freezed,
    Object? showArchived = null,
    Object? hasDueOnly = null,
  }) {
    return _then(_value.copyWith(
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as LibrarySortBy,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as LibraryDifficulty?,
      showArchived: null == showArchived
          ? _value.showArchived
          : showArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      hasDueOnly: null == hasDueOnly
          ? _value.hasDueOnly
          : hasDueOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LibraryFilterImplCopyWith<$Res>
    implements $LibraryFilterCopyWith<$Res> {
  factory _$$LibraryFilterImplCopyWith(
          _$LibraryFilterImpl value, $Res Function(_$LibraryFilterImpl) then) =
      __$$LibraryFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LibrarySortBy sortBy,
      LibraryDifficulty? difficulty,
      bool showArchived,
      bool hasDueOnly});
}

/// @nodoc
class __$$LibraryFilterImplCopyWithImpl<$Res>
    extends _$LibraryFilterCopyWithImpl<$Res, _$LibraryFilterImpl>
    implements _$$LibraryFilterImplCopyWith<$Res> {
  __$$LibraryFilterImplCopyWithImpl(
      _$LibraryFilterImpl _value, $Res Function(_$LibraryFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of LibraryFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sortBy = null,
    Object? difficulty = freezed,
    Object? showArchived = null,
    Object? hasDueOnly = null,
  }) {
    return _then(_$LibraryFilterImpl(
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as LibrarySortBy,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as LibraryDifficulty?,
      showArchived: null == showArchived
          ? _value.showArchived
          : showArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      hasDueOnly: null == hasDueOnly
          ? _value.hasDueOnly
          : hasDueOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$LibraryFilterImpl extends _LibraryFilter {
  const _$LibraryFilterImpl(
      {this.sortBy = LibrarySortBy.createdAt,
      this.difficulty,
      this.showArchived = false,
      this.hasDueOnly = false})
      : super._();

  @override
  @JsonKey()
  final LibrarySortBy sortBy;
  @override
  final LibraryDifficulty? difficulty;
  @override
  @JsonKey()
  final bool showArchived;
  @override
  @JsonKey()
  final bool hasDueOnly;

  @override
  String toString() {
    return 'LibraryFilter(sortBy: $sortBy, difficulty: $difficulty, showArchived: $showArchived, hasDueOnly: $hasDueOnly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LibraryFilterImpl &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.showArchived, showArchived) ||
                other.showArchived == showArchived) &&
            (identical(other.hasDueOnly, hasDueOnly) ||
                other.hasDueOnly == hasDueOnly));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, sortBy, difficulty, showArchived, hasDueOnly);

  /// Create a copy of LibraryFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LibraryFilterImplCopyWith<_$LibraryFilterImpl> get copyWith =>
      __$$LibraryFilterImplCopyWithImpl<_$LibraryFilterImpl>(this, _$identity);
}

abstract class _LibraryFilter extends LibraryFilter {
  const factory _LibraryFilter(
      {final LibrarySortBy sortBy,
      final LibraryDifficulty? difficulty,
      final bool showArchived,
      final bool hasDueOnly}) = _$LibraryFilterImpl;
  const _LibraryFilter._() : super._();

  @override
  LibrarySortBy get sortBy;
  @override
  LibraryDifficulty? get difficulty;
  @override
  bool get showArchived;
  @override
  bool get hasDueOnly;

  /// Create a copy of LibraryFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LibraryFilterImplCopyWith<_$LibraryFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
