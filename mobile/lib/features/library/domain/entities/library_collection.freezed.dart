// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LibraryCollection {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get coverColorHex => throw _privateConstructorUsedError;
  int get deckCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of LibraryCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LibraryCollectionCopyWith<LibraryCollection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LibraryCollectionCopyWith<$Res> {
  factory $LibraryCollectionCopyWith(
          LibraryCollection value, $Res Function(LibraryCollection) then) =
      _$LibraryCollectionCopyWithImpl<$Res, LibraryCollection>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String coverColorHex,
      int deckCount,
      DateTime createdAt});
}

/// @nodoc
class _$LibraryCollectionCopyWithImpl<$Res, $Val extends LibraryCollection>
    implements $LibraryCollectionCopyWith<$Res> {
  _$LibraryCollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LibraryCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? coverColorHex = null,
    Object? deckCount = null,
    Object? createdAt = null,
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
      coverColorHex: null == coverColorHex
          ? _value.coverColorHex
          : coverColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      deckCount: null == deckCount
          ? _value.deckCount
          : deckCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LibraryCollectionImplCopyWith<$Res>
    implements $LibraryCollectionCopyWith<$Res> {
  factory _$$LibraryCollectionImplCopyWith(_$LibraryCollectionImpl value,
          $Res Function(_$LibraryCollectionImpl) then) =
      __$$LibraryCollectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String coverColorHex,
      int deckCount,
      DateTime createdAt});
}

/// @nodoc
class __$$LibraryCollectionImplCopyWithImpl<$Res>
    extends _$LibraryCollectionCopyWithImpl<$Res, _$LibraryCollectionImpl>
    implements _$$LibraryCollectionImplCopyWith<$Res> {
  __$$LibraryCollectionImplCopyWithImpl(_$LibraryCollectionImpl _value,
      $Res Function(_$LibraryCollectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of LibraryCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? coverColorHex = null,
    Object? deckCount = null,
    Object? createdAt = null,
  }) {
    return _then(_$LibraryCollectionImpl(
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
      coverColorHex: null == coverColorHex
          ? _value.coverColorHex
          : coverColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      deckCount: null == deckCount
          ? _value.deckCount
          : deckCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$LibraryCollectionImpl implements _LibraryCollection {
  const _$LibraryCollectionImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.coverColorHex,
      required this.deckCount,
      required this.createdAt});

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String coverColorHex;
  @override
  final int deckCount;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LibraryCollection(id: $id, name: $name, description: $description, coverColorHex: $coverColorHex, deckCount: $deckCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LibraryCollectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverColorHex, coverColorHex) ||
                other.coverColorHex == coverColorHex) &&
            (identical(other.deckCount, deckCount) ||
                other.deckCount == deckCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, description, coverColorHex, deckCount, createdAt);

  /// Create a copy of LibraryCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LibraryCollectionImplCopyWith<_$LibraryCollectionImpl> get copyWith =>
      __$$LibraryCollectionImplCopyWithImpl<_$LibraryCollectionImpl>(
          this, _$identity);
}

abstract class _LibraryCollection implements LibraryCollection {
  const factory _LibraryCollection(
      {required final String id,
      required final String name,
      required final String description,
      required final String coverColorHex,
      required final int deckCount,
      required final DateTime createdAt}) = _$LibraryCollectionImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get coverColorHex;
  @override
  int get deckCount;
  @override
  DateTime get createdAt;

  /// Create a copy of LibraryCollection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LibraryCollectionImplCopyWith<_$LibraryCollectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
