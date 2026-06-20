// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Failure {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(_$NetworkFailureImpl value,
          $Res Function(_$NetworkFailureImpl) then) =
      __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, bool retryable});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
      _$NetworkFailureImpl _value, $Res Function(_$NetworkFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? retryable = null,
  }) {
    return _then(_$NetworkFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      retryable: null == retryable
          ? _value.retryable
          : retryable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl({required this.message, this.retryable = true});

  @override
  final String message;
  @override
  @JsonKey()
  final bool retryable;

  @override
  String toString() {
    return 'Failure.network(message: $message, retryable: $retryable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.retryable, retryable) ||
                other.retryable == retryable));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, retryable);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return network(message, retryable);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return network?.call(message, retryable);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, retryable);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure(
      {required final String message,
      final bool retryable}) = _$NetworkFailureImpl;

  @override
  String get message;
  bool get retryable;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
          _$ServerFailureImpl value, $Res Function(_$ServerFailureImpl) then) =
      __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      String message,
      bool retryable,
      Map<String, List<String>>? fields});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
      _$ServerFailureImpl _value, $Res Function(_$ServerFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? retryable = null,
    Object? fields = freezed,
  }) {
    return _then(_$ServerFailureImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      retryable: null == retryable
          ? _value.retryable
          : retryable // ignore: cast_nullable_to_non_nullable
              as bool,
      fields: freezed == fields
          ? _value._fields
          : fields // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
    ));
  }
}

/// @nodoc

class _$ServerFailureImpl implements ServerFailure {
  const _$ServerFailureImpl(
      {required this.code,
      required this.message,
      this.retryable = false,
      final Map<String, List<String>>? fields})
      : _fields = fields;

  @override
  final String code;
  @override
  final String message;
  @override
  @JsonKey()
  final bool retryable;
  final Map<String, List<String>>? _fields;
  @override
  Map<String, List<String>>? get fields {
    final value = _fields;
    if (value == null) return null;
    if (_fields is EqualUnmodifiableMapView) return _fields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Failure.server(code: $code, message: $message, retryable: $retryable, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.retryable, retryable) ||
                other.retryable == retryable) &&
            const DeepCollectionEquality().equals(other._fields, _fields));
  }

  @override
  int get hashCode => Object.hash(runtimeType, code, message, retryable,
      const DeepCollectionEquality().hash(_fields));

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return server(code, message, retryable, fields);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return server?.call(code, message, retryable, fields);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(code, message, retryable, fields);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerFailure implements Failure {
  const factory ServerFailure(
      {required final String code,
      required final String message,
      final bool retryable,
      final Map<String, List<String>>? fields}) = _$ServerFailureImpl;

  String get code;
  @override
  String get message;
  bool get retryable;
  Map<String, List<String>>? get fields;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnauthorizedFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnauthorizedFailureImplCopyWith(_$UnauthorizedFailureImpl value,
          $Res Function(_$UnauthorizedFailureImpl) then) =
      __$$UnauthorizedFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnauthorizedFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnauthorizedFailureImpl>
    implements _$$UnauthorizedFailureImplCopyWith<$Res> {
  __$$UnauthorizedFailureImplCopyWithImpl(_$UnauthorizedFailureImpl _value,
      $Res Function(_$UnauthorizedFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UnauthorizedFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UnauthorizedFailureImpl implements UnauthorizedFailure {
  const _$UnauthorizedFailureImpl(
      {this.message = 'Session expired. Please log in again.'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'Failure.unauthorized(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnauthorizedFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnauthorizedFailureImplCopyWith<_$UnauthorizedFailureImpl> get copyWith =>
      __$$UnauthorizedFailureImplCopyWithImpl<_$UnauthorizedFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return unauthorized(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return unauthorized?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unauthorized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unauthorized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unauthorized != null) {
      return unauthorized(this);
    }
    return orElse();
  }
}

abstract class UnauthorizedFailure implements Failure {
  const factory UnauthorizedFailure({final String message}) =
      _$UnauthorizedFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnauthorizedFailureImplCopyWith<_$UnauthorizedFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(_$ValidationFailureImpl value,
          $Res Function(_$ValidationFailureImpl) then) =
      __$$ValidationFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Map<String, List<String>>? fields});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(_$ValidationFailureImpl _value,
      $Res Function(_$ValidationFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? fields = freezed,
  }) {
    return _then(_$ValidationFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      fields: freezed == fields
          ? _value._fields
          : fields // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
    ));
  }
}

/// @nodoc

class _$ValidationFailureImpl implements ValidationFailure {
  const _$ValidationFailureImpl(
      {required this.message, final Map<String, List<String>>? fields})
      : _fields = fields;

  @override
  final String message;
  final Map<String, List<String>>? _fields;
  @override
  Map<String, List<String>>? get fields {
    final value = _fields;
    if (value == null) return null;
    if (_fields is EqualUnmodifiableMapView) return _fields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Failure.validation(message: $message, fields: $fields)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._fields, _fields));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, message, const DeepCollectionEquality().hash(_fields));

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return validation(message, fields);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return validation?.call(message, fields);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, fields);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure implements Failure {
  const factory ValidationFailure(
      {required final String message,
      final Map<String, List<String>>? fields}) = _$ValidationFailureImpl;

  @override
  String get message;
  Map<String, List<String>>? get fields;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RateLimitedFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$RateLimitedFailureImplCopyWith(_$RateLimitedFailureImpl value,
          $Res Function(_$RateLimitedFailureImpl) then) =
      __$$RateLimitedFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? retryAfterSeconds});
}

/// @nodoc
class __$$RateLimitedFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$RateLimitedFailureImpl>
    implements _$$RateLimitedFailureImplCopyWith<$Res> {
  __$$RateLimitedFailureImplCopyWithImpl(_$RateLimitedFailureImpl _value,
      $Res Function(_$RateLimitedFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? retryAfterSeconds = freezed,
  }) {
    return _then(_$RateLimitedFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      retryAfterSeconds: freezed == retryAfterSeconds
          ? _value.retryAfterSeconds
          : retryAfterSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$RateLimitedFailureImpl implements RateLimitedFailure {
  const _$RateLimitedFailureImpl(
      {required this.message, this.retryAfterSeconds});

  @override
  final String message;
  @override
  final int? retryAfterSeconds;

  @override
  String toString() {
    return 'Failure.rateLimited(message: $message, retryAfterSeconds: $retryAfterSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitedFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.retryAfterSeconds, retryAfterSeconds) ||
                other.retryAfterSeconds == retryAfterSeconds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, retryAfterSeconds);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitedFailureImplCopyWith<_$RateLimitedFailureImpl> get copyWith =>
      __$$RateLimitedFailureImplCopyWithImpl<_$RateLimitedFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return rateLimited(message, retryAfterSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return rateLimited?.call(message, retryAfterSeconds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(message, retryAfterSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return rateLimited(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return rateLimited?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(this);
    }
    return orElse();
  }
}

abstract class RateLimitedFailure implements Failure {
  const factory RateLimitedFailure(
      {required final String message,
      final int? retryAfterSeconds}) = _$RateLimitedFailureImpl;

  @override
  String get message;
  int? get retryAfterSeconds;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitedFailureImplCopyWith<_$RateLimitedFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AiUnavailableFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$AiUnavailableFailureImplCopyWith(_$AiUnavailableFailureImpl value,
          $Res Function(_$AiUnavailableFailureImpl) then) =
      __$$AiUnavailableFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AiUnavailableFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$AiUnavailableFailureImpl>
    implements _$$AiUnavailableFailureImplCopyWith<$Res> {
  __$$AiUnavailableFailureImplCopyWithImpl(_$AiUnavailableFailureImpl _value,
      $Res Function(_$AiUnavailableFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AiUnavailableFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AiUnavailableFailureImpl implements AiUnavailableFailure {
  const _$AiUnavailableFailureImpl(
      {this.message = 'AI service is temporarily unavailable.'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'Failure.aiUnavailable(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiUnavailableFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiUnavailableFailureImplCopyWith<_$AiUnavailableFailureImpl>
      get copyWith =>
          __$$AiUnavailableFailureImplCopyWithImpl<_$AiUnavailableFailureImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return aiUnavailable(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return aiUnavailable?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (aiUnavailable != null) {
      return aiUnavailable(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return aiUnavailable(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return aiUnavailable?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (aiUnavailable != null) {
      return aiUnavailable(this);
    }
    return orElse();
  }
}

abstract class AiUnavailableFailure implements Failure {
  const factory AiUnavailableFailure({final String message}) =
      _$AiUnavailableFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiUnavailableFailureImplCopyWith<_$AiUnavailableFailureImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$CacheFailureImplCopyWith(
          _$CacheFailureImpl value, $Res Function(_$CacheFailureImpl) then) =
      __$$CacheFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$CacheFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$CacheFailureImpl>
    implements _$$CacheFailureImplCopyWith<$Res> {
  __$$CacheFailureImplCopyWithImpl(
      _$CacheFailureImpl _value, $Res Function(_$CacheFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$CacheFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CacheFailureImpl implements CacheFailure {
  const _$CacheFailureImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'Failure.cache(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      __$$CacheFailureImplCopyWithImpl<_$CacheFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return cache(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return cache?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return cache(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return cache?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(this);
    }
    return orElse();
  }
}

abstract class CacheFailure implements Failure {
  const factory CacheFailure({required final String message}) =
      _$CacheFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(_$UnknownFailureImpl value,
          $Res Function(_$UnknownFailureImpl) then) =
      __$$UnknownFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
      _$UnknownFailureImpl _value, $Res Function(_$UnknownFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UnknownFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl({this.message = 'An unexpected error occurred.'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'Failure.unknown(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, bool retryable) network,
    required TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)
        server,
    required TResult Function(String message) unauthorized,
    required TResult Function(String message, Map<String, List<String>>? fields)
        validation,
    required TResult Function(String message, int? retryAfterSeconds)
        rateLimited,
    required TResult Function(String message) aiUnavailable,
    required TResult Function(String message) cache,
    required TResult Function(String message) unknown,
  }) {
    return unknown(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, bool retryable)? network,
    TResult? Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult? Function(String message)? unauthorized,
    TResult? Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult? Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult? Function(String message)? aiUnavailable,
    TResult? Function(String message)? cache,
    TResult? Function(String message)? unknown,
  }) {
    return unknown?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, bool retryable)? network,
    TResult Function(String code, String message, bool retryable,
            Map<String, List<String>>? fields)?
        server,
    TResult Function(String message)? unauthorized,
    TResult Function(String message, Map<String, List<String>>? fields)?
        validation,
    TResult Function(String message, int? retryAfterSeconds)? rateLimited,
    TResult Function(String message)? aiUnavailable,
    TResult Function(String message)? cache,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(UnauthorizedFailure value) unauthorized,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(RateLimitedFailure value) rateLimited,
    required TResult Function(AiUnavailableFailure value) aiUnavailable,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(UnauthorizedFailure value)? unauthorized,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(RateLimitedFailure value)? rateLimited,
    TResult? Function(AiUnavailableFailure value)? aiUnavailable,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(UnauthorizedFailure value)? unauthorized,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(RateLimitedFailure value)? rateLimited,
    TResult Function(AiUnavailableFailure value)? aiUnavailable,
    TResult Function(CacheFailure value)? cache,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure({final String message}) = _$UnknownFailureImpl;

  @override
  String get message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
