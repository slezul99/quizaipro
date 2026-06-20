// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MarketplaceFilter {
  String? get subjectId => throw _privateConstructorUsedError;
  String? get collectionId => throw _privateConstructorUsedError;
  MarketplaceSortBy get sortBy => throw _privateConstructorUsedError;
  DeckDifficulty? get difficulty => throw _privateConstructorUsedError;
  bool get proOnly => throw _privateConstructorUsedError;

  /// Create a copy of MarketplaceFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarketplaceFilterCopyWith<MarketplaceFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarketplaceFilterCopyWith<$Res> {
  factory $MarketplaceFilterCopyWith(
          MarketplaceFilter value, $Res Function(MarketplaceFilter) then) =
      _$MarketplaceFilterCopyWithImpl<$Res, MarketplaceFilter>;
  @useResult
  $Res call(
      {String? subjectId,
      String? collectionId,
      MarketplaceSortBy sortBy,
      DeckDifficulty? difficulty,
      bool proOnly});
}

/// @nodoc
class _$MarketplaceFilterCopyWithImpl<$Res, $Val extends MarketplaceFilter>
    implements $MarketplaceFilterCopyWith<$Res> {
  _$MarketplaceFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MarketplaceFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectId = freezed,
    Object? collectionId = freezed,
    Object? sortBy = null,
    Object? difficulty = freezed,
    Object? proOnly = null,
  }) {
    return _then(_value.copyWith(
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionId: freezed == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as MarketplaceSortBy,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as DeckDifficulty?,
      proOnly: null == proOnly
          ? _value.proOnly
          : proOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MarketplaceFilterImplCopyWith<$Res>
    implements $MarketplaceFilterCopyWith<$Res> {
  factory _$$MarketplaceFilterImplCopyWith(_$MarketplaceFilterImpl value,
          $Res Function(_$MarketplaceFilterImpl) then) =
      __$$MarketplaceFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? subjectId,
      String? collectionId,
      MarketplaceSortBy sortBy,
      DeckDifficulty? difficulty,
      bool proOnly});
}

/// @nodoc
class __$$MarketplaceFilterImplCopyWithImpl<$Res>
    extends _$MarketplaceFilterCopyWithImpl<$Res, _$MarketplaceFilterImpl>
    implements _$$MarketplaceFilterImplCopyWith<$Res> {
  __$$MarketplaceFilterImplCopyWithImpl(_$MarketplaceFilterImpl _value,
      $Res Function(_$MarketplaceFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of MarketplaceFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subjectId = freezed,
    Object? collectionId = freezed,
    Object? sortBy = null,
    Object? difficulty = freezed,
    Object? proOnly = null,
  }) {
    return _then(_$MarketplaceFilterImpl(
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionId: freezed == collectionId
          ? _value.collectionId
          : collectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as MarketplaceSortBy,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as DeckDifficulty?,
      proOnly: null == proOnly
          ? _value.proOnly
          : proOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MarketplaceFilterImpl extends _MarketplaceFilter {
  const _$MarketplaceFilterImpl(
      {this.subjectId,
      this.collectionId,
      this.sortBy = MarketplaceSortBy.popular,
      this.difficulty,
      this.proOnly = false})
      : super._();

  @override
  final String? subjectId;
  @override
  final String? collectionId;
  @override
  @JsonKey()
  final MarketplaceSortBy sortBy;
  @override
  final DeckDifficulty? difficulty;
  @override
  @JsonKey()
  final bool proOnly;

  @override
  String toString() {
    return 'MarketplaceFilter(subjectId: $subjectId, collectionId: $collectionId, sortBy: $sortBy, difficulty: $difficulty, proOnly: $proOnly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarketplaceFilterImpl &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.collectionId, collectionId) ||
                other.collectionId == collectionId) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.proOnly, proOnly) || other.proOnly == proOnly));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, subjectId, collectionId, sortBy, difficulty, proOnly);

  /// Create a copy of MarketplaceFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarketplaceFilterImplCopyWith<_$MarketplaceFilterImpl> get copyWith =>
      __$$MarketplaceFilterImplCopyWithImpl<_$MarketplaceFilterImpl>(
          this, _$identity);
}

abstract class _MarketplaceFilter extends MarketplaceFilter {
  const factory _MarketplaceFilter(
      {final String? subjectId,
      final String? collectionId,
      final MarketplaceSortBy sortBy,
      final DeckDifficulty? difficulty,
      final bool proOnly}) = _$MarketplaceFilterImpl;
  const _MarketplaceFilter._() : super._();

  @override
  String? get subjectId;
  @override
  String? get collectionId;
  @override
  MarketplaceSortBy get sortBy;
  @override
  DeckDifficulty? get difficulty;
  @override
  bool get proOnly;

  /// Create a copy of MarketplaceFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarketplaceFilterImplCopyWith<_$MarketplaceFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
