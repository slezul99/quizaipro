// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeckSummary {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get cardCount => throw _privateConstructorUsedError;

  /// Create a copy of DeckSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeckSummaryCopyWith<DeckSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeckSummaryCopyWith<$Res> {
  factory $DeckSummaryCopyWith(
          DeckSummary value, $Res Function(DeckSummary) then) =
      _$DeckSummaryCopyWithImpl<$Res, DeckSummary>;
  @useResult
  $Res call({String id, String title, int cardCount});
}

/// @nodoc
class _$DeckSummaryCopyWithImpl<$Res, $Val extends DeckSummary>
    implements $DeckSummaryCopyWith<$Res> {
  _$DeckSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeckSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? cardCount = null,
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
      cardCount: null == cardCount
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeckSummaryImplCopyWith<$Res>
    implements $DeckSummaryCopyWith<$Res> {
  factory _$$DeckSummaryImplCopyWith(
          _$DeckSummaryImpl value, $Res Function(_$DeckSummaryImpl) then) =
      __$$DeckSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, int cardCount});
}

/// @nodoc
class __$$DeckSummaryImplCopyWithImpl<$Res>
    extends _$DeckSummaryCopyWithImpl<$Res, _$DeckSummaryImpl>
    implements _$$DeckSummaryImplCopyWith<$Res> {
  __$$DeckSummaryImplCopyWithImpl(
      _$DeckSummaryImpl _value, $Res Function(_$DeckSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeckSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? cardCount = null,
  }) {
    return _then(_$DeckSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      cardCount: null == cardCount
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DeckSummaryImpl implements _DeckSummary {
  const _$DeckSummaryImpl(
      {required this.id, required this.title, this.cardCount = 0});

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final int cardCount;

  @override
  String toString() {
    return 'DeckSummary(id: $id, title: $title, cardCount: $cardCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeckSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.cardCount, cardCount) ||
                other.cardCount == cardCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, cardCount);

  /// Create a copy of DeckSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeckSummaryImplCopyWith<_$DeckSummaryImpl> get copyWith =>
      __$$DeckSummaryImplCopyWithImpl<_$DeckSummaryImpl>(this, _$identity);
}

abstract class _DeckSummary implements DeckSummary {
  const factory _DeckSummary(
      {required final String id,
      required final String title,
      final int cardCount}) = _$DeckSummaryImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  int get cardCount;

  /// Create a copy of DeckSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeckSummaryImplCopyWith<_$DeckSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
