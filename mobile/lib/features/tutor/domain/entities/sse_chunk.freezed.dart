// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sse_chunk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SseChunk {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) delta,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? delta,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? delta,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SseChunkDelta value) delta,
    required TResult Function(SseChunkDone value) done,
    required TResult Function(SseChunkError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SseChunkDelta value)? delta,
    TResult? Function(SseChunkDone value)? done,
    TResult? Function(SseChunkError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SseChunkDelta value)? delta,
    TResult Function(SseChunkDone value)? done,
    TResult Function(SseChunkError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SseChunkCopyWith<$Res> {
  factory $SseChunkCopyWith(SseChunk value, $Res Function(SseChunk) then) =
      _$SseChunkCopyWithImpl<$Res, SseChunk>;
}

/// @nodoc
class _$SseChunkCopyWithImpl<$Res, $Val extends SseChunk>
    implements $SseChunkCopyWith<$Res> {
  _$SseChunkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SseChunkDeltaImplCopyWith<$Res> {
  factory _$$SseChunkDeltaImplCopyWith(
          _$SseChunkDeltaImpl value, $Res Function(_$SseChunkDeltaImpl) then) =
      __$$SseChunkDeltaImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$SseChunkDeltaImplCopyWithImpl<$Res>
    extends _$SseChunkCopyWithImpl<$Res, _$SseChunkDeltaImpl>
    implements _$$SseChunkDeltaImplCopyWith<$Res> {
  __$$SseChunkDeltaImplCopyWithImpl(
      _$SseChunkDeltaImpl _value, $Res Function(_$SseChunkDeltaImpl) _then)
      : super(_value, _then);

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
  }) {
    return _then(_$SseChunkDeltaImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SseChunkDeltaImpl implements SseChunkDelta {
  const _$SseChunkDeltaImpl({required this.text});

  @override
  final String text;

  @override
  String toString() {
    return 'SseChunk.delta(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SseChunkDeltaImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SseChunkDeltaImplCopyWith<_$SseChunkDeltaImpl> get copyWith =>
      __$$SseChunkDeltaImplCopyWithImpl<_$SseChunkDeltaImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) delta,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return delta(text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? delta,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return delta?.call(text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? delta,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (delta != null) {
      return delta(text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SseChunkDelta value) delta,
    required TResult Function(SseChunkDone value) done,
    required TResult Function(SseChunkError value) error,
  }) {
    return delta(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SseChunkDelta value)? delta,
    TResult? Function(SseChunkDone value)? done,
    TResult? Function(SseChunkError value)? error,
  }) {
    return delta?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SseChunkDelta value)? delta,
    TResult Function(SseChunkDone value)? done,
    TResult Function(SseChunkError value)? error,
    required TResult orElse(),
  }) {
    if (delta != null) {
      return delta(this);
    }
    return orElse();
  }
}

abstract class SseChunkDelta implements SseChunk {
  const factory SseChunkDelta({required final String text}) =
      _$SseChunkDeltaImpl;

  String get text;

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SseChunkDeltaImplCopyWith<_$SseChunkDeltaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SseChunkDoneImplCopyWith<$Res> {
  factory _$$SseChunkDoneImplCopyWith(
          _$SseChunkDoneImpl value, $Res Function(_$SseChunkDoneImpl) then) =
      __$$SseChunkDoneImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SseChunkDoneImplCopyWithImpl<$Res>
    extends _$SseChunkCopyWithImpl<$Res, _$SseChunkDoneImpl>
    implements _$$SseChunkDoneImplCopyWith<$Res> {
  __$$SseChunkDoneImplCopyWithImpl(
      _$SseChunkDoneImpl _value, $Res Function(_$SseChunkDoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SseChunkDoneImpl implements SseChunkDone {
  const _$SseChunkDoneImpl();

  @override
  String toString() {
    return 'SseChunk.done()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SseChunkDoneImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) delta,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return done();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? delta,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return done?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? delta,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SseChunkDelta value) delta,
    required TResult Function(SseChunkDone value) done,
    required TResult Function(SseChunkError value) error,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SseChunkDelta value)? delta,
    TResult? Function(SseChunkDone value)? done,
    TResult? Function(SseChunkError value)? error,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SseChunkDelta value)? delta,
    TResult Function(SseChunkDone value)? done,
    TResult Function(SseChunkError value)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }
}

abstract class SseChunkDone implements SseChunk {
  const factory SseChunkDone() = _$SseChunkDoneImpl;
}

/// @nodoc
abstract class _$$SseChunkErrorImplCopyWith<$Res> {
  factory _$$SseChunkErrorImplCopyWith(
          _$SseChunkErrorImpl value, $Res Function(_$SseChunkErrorImpl) then) =
      __$$SseChunkErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SseChunkErrorImplCopyWithImpl<$Res>
    extends _$SseChunkCopyWithImpl<$Res, _$SseChunkErrorImpl>
    implements _$$SseChunkErrorImplCopyWith<$Res> {
  __$$SseChunkErrorImplCopyWithImpl(
      _$SseChunkErrorImpl _value, $Res Function(_$SseChunkErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$SseChunkErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SseChunkErrorImpl implements SseChunkError {
  const _$SseChunkErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'SseChunk.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SseChunkErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SseChunkErrorImplCopyWith<_$SseChunkErrorImpl> get copyWith =>
      __$$SseChunkErrorImplCopyWithImpl<_$SseChunkErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String text) delta,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String text)? delta,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String text)? delta,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SseChunkDelta value) delta,
    required TResult Function(SseChunkDone value) done,
    required TResult Function(SseChunkError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SseChunkDelta value)? delta,
    TResult? Function(SseChunkDone value)? done,
    TResult? Function(SseChunkError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SseChunkDelta value)? delta,
    TResult Function(SseChunkDone value)? done,
    TResult Function(SseChunkError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class SseChunkError implements SseChunk {
  const factory SseChunkError({required final String message}) =
      _$SseChunkErrorImpl;

  String get message;

  /// Create a copy of SseChunk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SseChunkErrorImplCopyWith<_$SseChunkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
