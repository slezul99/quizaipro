// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck_card_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeckCardPreview {
  String get id => throw _privateConstructorUsedError;
  String get front => throw _privateConstructorUsedError;
  String get back => throw _privateConstructorUsedError;
  String? get hint => throw _privateConstructorUsedError;

  /// Create a copy of DeckCardPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeckCardPreviewCopyWith<DeckCardPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeckCardPreviewCopyWith<$Res> {
  factory $DeckCardPreviewCopyWith(
          DeckCardPreview value, $Res Function(DeckCardPreview) then) =
      _$DeckCardPreviewCopyWithImpl<$Res, DeckCardPreview>;
  @useResult
  $Res call({String id, String front, String back, String? hint});
}

/// @nodoc
class _$DeckCardPreviewCopyWithImpl<$Res, $Val extends DeckCardPreview>
    implements $DeckCardPreviewCopyWith<$Res> {
  _$DeckCardPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeckCardPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? front = null,
    Object? back = null,
    Object? hint = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeckCardPreviewImplCopyWith<$Res>
    implements $DeckCardPreviewCopyWith<$Res> {
  factory _$$DeckCardPreviewImplCopyWith(_$DeckCardPreviewImpl value,
          $Res Function(_$DeckCardPreviewImpl) then) =
      __$$DeckCardPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String front, String back, String? hint});
}

/// @nodoc
class __$$DeckCardPreviewImplCopyWithImpl<$Res>
    extends _$DeckCardPreviewCopyWithImpl<$Res, _$DeckCardPreviewImpl>
    implements _$$DeckCardPreviewImplCopyWith<$Res> {
  __$$DeckCardPreviewImplCopyWithImpl(
      _$DeckCardPreviewImpl _value, $Res Function(_$DeckCardPreviewImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeckCardPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? front = null,
    Object? back = null,
    Object? hint = freezed,
  }) {
    return _then(_$DeckCardPreviewImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc

class _$DeckCardPreviewImpl implements _DeckCardPreview {
  const _$DeckCardPreviewImpl(
      {required this.id, required this.front, required this.back, this.hint});

  @override
  final String id;
  @override
  final String front;
  @override
  final String back;
  @override
  final String? hint;

  @override
  String toString() {
    return 'DeckCardPreview(id: $id, front: $front, back: $back, hint: $hint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeckCardPreviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back) &&
            (identical(other.hint, hint) || other.hint == hint));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, front, back, hint);

  /// Create a copy of DeckCardPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeckCardPreviewImplCopyWith<_$DeckCardPreviewImpl> get copyWith =>
      __$$DeckCardPreviewImplCopyWithImpl<_$DeckCardPreviewImpl>(
          this, _$identity);
}

abstract class _DeckCardPreview implements DeckCardPreview {
  const factory _DeckCardPreview(
      {required final String id,
      required final String front,
      required final String back,
      final String? hint}) = _$DeckCardPreviewImpl;

  @override
  String get id;
  @override
  String get front;
  @override
  String get back;
  @override
  String? get hint;

  /// Create a copy of DeckCardPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeckCardPreviewImplCopyWith<_$DeckCardPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
