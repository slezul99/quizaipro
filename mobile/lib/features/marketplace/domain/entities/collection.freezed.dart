// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Collection {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get coverUrl => throw _privateConstructorUsedError;
  String get coverColorHex => throw _privateConstructorUsedError;
  int get deckCount => throw _privateConstructorUsedError;
  String? get subjectId => throw _privateConstructorUsedError;
  String get curatorName => throw _privateConstructorUsedError;

  /// Create a copy of Collection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionCopyWith<Collection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionCopyWith<$Res> {
  factory $CollectionCopyWith(
          Collection value, $Res Function(Collection) then) =
      _$CollectionCopyWithImpl<$Res, Collection>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String? coverUrl,
      String coverColorHex,
      int deckCount,
      String? subjectId,
      String curatorName});
}

/// @nodoc
class _$CollectionCopyWithImpl<$Res, $Val extends Collection>
    implements $CollectionCopyWith<$Res> {
  _$CollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Collection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? coverUrl = freezed,
    Object? coverColorHex = null,
    Object? deckCount = null,
    Object? subjectId = freezed,
    Object? curatorName = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
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
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      curatorName: null == curatorName
          ? _value.curatorName
          : curatorName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectionImplCopyWith<$Res>
    implements $CollectionCopyWith<$Res> {
  factory _$$CollectionImplCopyWith(
          _$CollectionImpl value, $Res Function(_$CollectionImpl) then) =
      __$$CollectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String? coverUrl,
      String coverColorHex,
      int deckCount,
      String? subjectId,
      String curatorName});
}

/// @nodoc
class __$$CollectionImplCopyWithImpl<$Res>
    extends _$CollectionCopyWithImpl<$Res, _$CollectionImpl>
    implements _$$CollectionImplCopyWith<$Res> {
  __$$CollectionImplCopyWithImpl(
      _$CollectionImpl _value, $Res Function(_$CollectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Collection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? coverUrl = freezed,
    Object? coverColorHex = null,
    Object? deckCount = null,
    Object? subjectId = freezed,
    Object? curatorName = null,
  }) {
    return _then(_$CollectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
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
      subjectId: freezed == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String?,
      curatorName: null == curatorName
          ? _value.curatorName
          : curatorName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CollectionImpl implements _Collection {
  const _$CollectionImpl(
      {required this.id,
      required this.name,
      required this.description,
      this.coverUrl,
      required this.coverColorHex,
      required this.deckCount,
      this.subjectId,
      required this.curatorName});

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String? coverUrl;
  @override
  final String coverColorHex;
  @override
  final int deckCount;
  @override
  final String? subjectId;
  @override
  final String curatorName;

  @override
  String toString() {
    return 'Collection(id: $id, name: $name, description: $description, coverUrl: $coverUrl, coverColorHex: $coverColorHex, deckCount: $deckCount, subjectId: $subjectId, curatorName: $curatorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.coverColorHex, coverColorHex) ||
                other.coverColorHex == coverColorHex) &&
            (identical(other.deckCount, deckCount) ||
                other.deckCount == deckCount) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.curatorName, curatorName) ||
                other.curatorName == curatorName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, coverUrl,
      coverColorHex, deckCount, subjectId, curatorName);

  /// Create a copy of Collection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionImplCopyWith<_$CollectionImpl> get copyWith =>
      __$$CollectionImplCopyWithImpl<_$CollectionImpl>(this, _$identity);
}

abstract class _Collection implements Collection {
  const factory _Collection(
      {required final String id,
      required final String name,
      required final String description,
      final String? coverUrl,
      required final String coverColorHex,
      required final int deckCount,
      final String? subjectId,
      required final String curatorName}) = _$CollectionImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String? get coverUrl;
  @override
  String get coverColorHex;
  @override
  int get deckCount;
  @override
  String? get subjectId;
  @override
  String get curatorName;

  /// Create a copy of Collection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionImplCopyWith<_$CollectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
