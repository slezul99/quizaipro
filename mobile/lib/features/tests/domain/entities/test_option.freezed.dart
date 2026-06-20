// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestOption {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;

  /// Create a copy of TestOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestOptionCopyWith<TestOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestOptionCopyWith<$Res> {
  factory $TestOptionCopyWith(
          TestOption value, $Res Function(TestOption) then) =
      _$TestOptionCopyWithImpl<$Res, TestOption>;
  @useResult
  $Res call({String id, String text, bool isCorrect});
}

/// @nodoc
class _$TestOptionCopyWithImpl<$Res, $Val extends TestOption>
    implements $TestOptionCopyWith<$Res> {
  _$TestOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isCorrect = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestOptionImplCopyWith<$Res>
    implements $TestOptionCopyWith<$Res> {
  factory _$$TestOptionImplCopyWith(
          _$TestOptionImpl value, $Res Function(_$TestOptionImpl) then) =
      __$$TestOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String text, bool isCorrect});
}

/// @nodoc
class __$$TestOptionImplCopyWithImpl<$Res>
    extends _$TestOptionCopyWithImpl<$Res, _$TestOptionImpl>
    implements _$$TestOptionImplCopyWith<$Res> {
  __$$TestOptionImplCopyWithImpl(
      _$TestOptionImpl _value, $Res Function(_$TestOptionImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? isCorrect = null,
  }) {
    return _then(_$TestOptionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TestOptionImpl implements _TestOption {
  const _$TestOptionImpl(
      {required this.id, required this.text, required this.isCorrect});

  @override
  final String id;
  @override
  final String text;
  @override
  final bool isCorrect;

  @override
  String toString() {
    return 'TestOption(id: $id, text: $text, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, text, isCorrect);

  /// Create a copy of TestOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestOptionImplCopyWith<_$TestOptionImpl> get copyWith =>
      __$$TestOptionImplCopyWithImpl<_$TestOptionImpl>(this, _$identity);
}

abstract class _TestOption implements TestOption {
  const factory _TestOption(
      {required final String id,
      required final String text,
      required final bool isCorrect}) = _$TestOptionImpl;

  @override
  String get id;
  @override
  String get text;
  @override
  bool get isCorrect;

  /// Create a copy of TestOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestOptionImplCopyWith<_$TestOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
