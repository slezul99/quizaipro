// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'find_answers_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FindAnswersState {
  String get query => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;
  FindAnswersResult? get result => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of FindAnswersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FindAnswersStateCopyWith<FindAnswersState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FindAnswersStateCopyWith<$Res> {
  factory $FindAnswersStateCopyWith(
          FindAnswersState value, $Res Function(FindAnswersState) then) =
      _$FindAnswersStateCopyWithImpl<$Res, FindAnswersState>;
  @useResult
  $Res call(
      {String query,
      bool isSearching,
      FindAnswersResult? result,
      String? errorMessage});

  $FindAnswersResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$FindAnswersStateCopyWithImpl<$Res, $Val extends FindAnswersState>
    implements $FindAnswersStateCopyWith<$Res> {
  _$FindAnswersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FindAnswersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? isSearching = null,
    Object? result = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as FindAnswersResult?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of FindAnswersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FindAnswersResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $FindAnswersResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FindAnswersStateImplCopyWith<$Res>
    implements $FindAnswersStateCopyWith<$Res> {
  factory _$$FindAnswersStateImplCopyWith(_$FindAnswersStateImpl value,
          $Res Function(_$FindAnswersStateImpl) then) =
      __$$FindAnswersStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      bool isSearching,
      FindAnswersResult? result,
      String? errorMessage});

  @override
  $FindAnswersResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$FindAnswersStateImplCopyWithImpl<$Res>
    extends _$FindAnswersStateCopyWithImpl<$Res, _$FindAnswersStateImpl>
    implements _$$FindAnswersStateImplCopyWith<$Res> {
  __$$FindAnswersStateImplCopyWithImpl(_$FindAnswersStateImpl _value,
      $Res Function(_$FindAnswersStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FindAnswersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? isSearching = null,
    Object? result = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$FindAnswersStateImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as FindAnswersResult?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$FindAnswersStateImpl implements _FindAnswersState {
  const _$FindAnswersStateImpl(
      {this.query = '',
      this.isSearching = false,
      this.result,
      this.errorMessage});

  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final bool isSearching;
  @override
  final FindAnswersResult? result;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'FindAnswersState(query: $query, isSearching: $isSearching, result: $result, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FindAnswersStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, query, isSearching, result, errorMessage);

  /// Create a copy of FindAnswersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FindAnswersStateImplCopyWith<_$FindAnswersStateImpl> get copyWith =>
      __$$FindAnswersStateImplCopyWithImpl<_$FindAnswersStateImpl>(
          this, _$identity);
}

abstract class _FindAnswersState implements FindAnswersState {
  const factory _FindAnswersState(
      {final String query,
      final bool isSearching,
      final FindAnswersResult? result,
      final String? errorMessage}) = _$FindAnswersStateImpl;

  @override
  String get query;
  @override
  bool get isSearching;
  @override
  FindAnswersResult? get result;
  @override
  String? get errorMessage;

  /// Create a copy of FindAnswersState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FindAnswersStateImplCopyWith<_$FindAnswersStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
