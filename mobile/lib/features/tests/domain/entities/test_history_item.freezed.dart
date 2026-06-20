// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_history_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TestHistoryItem {
  String get id => throw _privateConstructorUsedError;
  String get deckId => throw _privateConstructorUsedError;
  String get deckTitle => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;

  /// Create a copy of TestHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestHistoryItemCopyWith<TestHistoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestHistoryItemCopyWith<$Res> {
  factory $TestHistoryItemCopyWith(
          TestHistoryItem value, $Res Function(TestHistoryItem) then) =
      _$TestHistoryItemCopyWithImpl<$Res, TestHistoryItem>;
  @useResult
  $Res call(
      {String id,
      String deckId,
      String deckTitle,
      int totalQuestions,
      int correctCount,
      int durationSeconds,
      DateTime completedAt});
}

/// @nodoc
class _$TestHistoryItemCopyWithImpl<$Res, $Val extends TestHistoryItem>
    implements $TestHistoryItemCopyWith<$Res> {
  _$TestHistoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? deckTitle = null,
    Object? totalQuestions = null,
    Object? correctCount = null,
    Object? durationSeconds = null,
    Object? completedAt = null,
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
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestHistoryItemImplCopyWith<$Res>
    implements $TestHistoryItemCopyWith<$Res> {
  factory _$$TestHistoryItemImplCopyWith(_$TestHistoryItemImpl value,
          $Res Function(_$TestHistoryItemImpl) then) =
      __$$TestHistoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deckId,
      String deckTitle,
      int totalQuestions,
      int correctCount,
      int durationSeconds,
      DateTime completedAt});
}

/// @nodoc
class __$$TestHistoryItemImplCopyWithImpl<$Res>
    extends _$TestHistoryItemCopyWithImpl<$Res, _$TestHistoryItemImpl>
    implements _$$TestHistoryItemImplCopyWith<$Res> {
  __$$TestHistoryItemImplCopyWithImpl(
      _$TestHistoryItemImpl _value, $Res Function(_$TestHistoryItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deckId = null,
    Object? deckTitle = null,
    Object? totalQuestions = null,
    Object? correctCount = null,
    Object? durationSeconds = null,
    Object? completedAt = null,
  }) {
    return _then(_$TestHistoryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deckId: null == deckId
          ? _value.deckId
          : deckId // ignore: cast_nullable_to_non_nullable
              as String,
      deckTitle: null == deckTitle
          ? _value.deckTitle
          : deckTitle // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$TestHistoryItemImpl extends _TestHistoryItem {
  const _$TestHistoryItemImpl(
      {required this.id,
      required this.deckId,
      required this.deckTitle,
      required this.totalQuestions,
      required this.correctCount,
      required this.durationSeconds,
      required this.completedAt})
      : super._();

  @override
  final String id;
  @override
  final String deckId;
  @override
  final String deckTitle;
  @override
  final int totalQuestions;
  @override
  final int correctCount;
  @override
  final int durationSeconds;
  @override
  final DateTime completedAt;

  @override
  String toString() {
    return 'TestHistoryItem(id: $id, deckId: $deckId, deckTitle: $deckTitle, totalQuestions: $totalQuestions, correctCount: $correctCount, durationSeconds: $durationSeconds, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestHistoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deckId, deckId) || other.deckId == deckId) &&
            (identical(other.deckTitle, deckTitle) ||
                other.deckTitle == deckTitle) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, deckId, deckTitle,
      totalQuestions, correctCount, durationSeconds, completedAt);

  /// Create a copy of TestHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestHistoryItemImplCopyWith<_$TestHistoryItemImpl> get copyWith =>
      __$$TestHistoryItemImplCopyWithImpl<_$TestHistoryItemImpl>(
          this, _$identity);
}

abstract class _TestHistoryItem extends TestHistoryItem {
  const factory _TestHistoryItem(
      {required final String id,
      required final String deckId,
      required final String deckTitle,
      required final int totalQuestions,
      required final int correctCount,
      required final int durationSeconds,
      required final DateTime completedAt}) = _$TestHistoryItemImpl;
  const _TestHistoryItem._() : super._();

  @override
  String get id;
  @override
  String get deckId;
  @override
  String get deckTitle;
  @override
  int get totalQuestions;
  @override
  int get correctCount;
  @override
  int get durationSeconds;
  @override
  DateTime get completedAt;

  /// Create a copy of TestHistoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestHistoryItemImplCopyWith<_$TestHistoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
