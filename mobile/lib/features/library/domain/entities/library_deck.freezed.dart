// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_deck.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LibraryDeck {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get cardCount => throw _privateConstructorUsedError;
  int get dueCount => throw _privateConstructorUsedError;
  bool get hasTests => throw _privateConstructorUsedError;
  bool get hasFlashcards => throw _privateConstructorUsedError;
  String get coverColorHex => throw _privateConstructorUsedError;
  bool get isPro => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  LibraryDifficulty? get difficulty => throw _privateConstructorUsedError;
  DateTime? get lastStudiedAt => throw _privateConstructorUsedError;
  String? get subjectName => throw _privateConstructorUsedError;

  /// Create a copy of LibraryDeck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LibraryDeckCopyWith<LibraryDeck> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LibraryDeckCopyWith<$Res> {
  factory $LibraryDeckCopyWith(
          LibraryDeck value, $Res Function(LibraryDeck) then) =
      _$LibraryDeckCopyWithImpl<$Res, LibraryDeck>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int cardCount,
      int dueCount,
      bool hasTests,
      bool hasFlashcards,
      String coverColorHex,
      bool isPro,
      bool isPublic,
      bool isFavorite,
      bool isArchived,
      List<String> tags,
      DateTime createdAt,
      DateTime updatedAt,
      LibraryDifficulty? difficulty,
      DateTime? lastStudiedAt,
      String? subjectName});
}

/// @nodoc
class _$LibraryDeckCopyWithImpl<$Res, $Val extends LibraryDeck>
    implements $LibraryDeckCopyWith<$Res> {
  _$LibraryDeckCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LibraryDeck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? cardCount = null,
    Object? dueCount = null,
    Object? hasTests = null,
    Object? hasFlashcards = null,
    Object? coverColorHex = null,
    Object? isPro = null,
    Object? isPublic = null,
    Object? isFavorite = null,
    Object? isArchived = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? difficulty = freezed,
    Object? lastStudiedAt = freezed,
    Object? subjectName = freezed,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cardCount: null == cardCount
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      dueCount: null == dueCount
          ? _value.dueCount
          : dueCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasTests: null == hasTests
          ? _value.hasTests
          : hasTests // ignore: cast_nullable_to_non_nullable
              as bool,
      hasFlashcards: null == hasFlashcards
          ? _value.hasFlashcards
          : hasFlashcards // ignore: cast_nullable_to_non_nullable
              as bool,
      coverColorHex: null == coverColorHex
          ? _value.coverColorHex
          : coverColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      isPro: null == isPro
          ? _value.isPro
          : isPro // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as LibraryDifficulty?,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subjectName: freezed == subjectName
          ? _value.subjectName
          : subjectName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LibraryDeckImplCopyWith<$Res>
    implements $LibraryDeckCopyWith<$Res> {
  factory _$$LibraryDeckImplCopyWith(
          _$LibraryDeckImpl value, $Res Function(_$LibraryDeckImpl) then) =
      __$$LibraryDeckImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int cardCount,
      int dueCount,
      bool hasTests,
      bool hasFlashcards,
      String coverColorHex,
      bool isPro,
      bool isPublic,
      bool isFavorite,
      bool isArchived,
      List<String> tags,
      DateTime createdAt,
      DateTime updatedAt,
      LibraryDifficulty? difficulty,
      DateTime? lastStudiedAt,
      String? subjectName});
}

/// @nodoc
class __$$LibraryDeckImplCopyWithImpl<$Res>
    extends _$LibraryDeckCopyWithImpl<$Res, _$LibraryDeckImpl>
    implements _$$LibraryDeckImplCopyWith<$Res> {
  __$$LibraryDeckImplCopyWithImpl(
      _$LibraryDeckImpl _value, $Res Function(_$LibraryDeckImpl) _then)
      : super(_value, _then);

  /// Create a copy of LibraryDeck
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? cardCount = null,
    Object? dueCount = null,
    Object? hasTests = null,
    Object? hasFlashcards = null,
    Object? coverColorHex = null,
    Object? isPro = null,
    Object? isPublic = null,
    Object? isFavorite = null,
    Object? isArchived = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? difficulty = freezed,
    Object? lastStudiedAt = freezed,
    Object? subjectName = freezed,
  }) {
    return _then(_$LibraryDeckImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      cardCount: null == cardCount
          ? _value.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      dueCount: null == dueCount
          ? _value.dueCount
          : dueCount // ignore: cast_nullable_to_non_nullable
              as int,
      hasTests: null == hasTests
          ? _value.hasTests
          : hasTests // ignore: cast_nullable_to_non_nullable
              as bool,
      hasFlashcards: null == hasFlashcards
          ? _value.hasFlashcards
          : hasFlashcards // ignore: cast_nullable_to_non_nullable
              as bool,
      coverColorHex: null == coverColorHex
          ? _value.coverColorHex
          : coverColorHex // ignore: cast_nullable_to_non_nullable
              as String,
      isPro: null == isPro
          ? _value.isPro
          : isPro // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as LibraryDifficulty?,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subjectName: freezed == subjectName
          ? _value.subjectName
          : subjectName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LibraryDeckImpl implements _LibraryDeck {
  const _$LibraryDeckImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.cardCount,
      required this.dueCount,
      required this.hasTests,
      required this.hasFlashcards,
      required this.coverColorHex,
      required this.isPro,
      required this.isPublic,
      required this.isFavorite,
      required this.isArchived,
      required final List<String> tags,
      required this.createdAt,
      required this.updatedAt,
      this.difficulty,
      this.lastStudiedAt,
      this.subjectName})
      : _tags = tags;

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final int cardCount;
  @override
  final int dueCount;
  @override
  final bool hasTests;
  @override
  final bool hasFlashcards;
  @override
  final String coverColorHex;
  @override
  final bool isPro;
  @override
  final bool isPublic;
  @override
  final bool isFavorite;
  @override
  final bool isArchived;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final LibraryDifficulty? difficulty;
  @override
  final DateTime? lastStudiedAt;
  @override
  final String? subjectName;

  @override
  String toString() {
    return 'LibraryDeck(id: $id, title: $title, description: $description, cardCount: $cardCount, dueCount: $dueCount, hasTests: $hasTests, hasFlashcards: $hasFlashcards, coverColorHex: $coverColorHex, isPro: $isPro, isPublic: $isPublic, isFavorite: $isFavorite, isArchived: $isArchived, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt, difficulty: $difficulty, lastStudiedAt: $lastStudiedAt, subjectName: $subjectName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LibraryDeckImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cardCount, cardCount) ||
                other.cardCount == cardCount) &&
            (identical(other.dueCount, dueCount) ||
                other.dueCount == dueCount) &&
            (identical(other.hasTests, hasTests) ||
                other.hasTests == hasTests) &&
            (identical(other.hasFlashcards, hasFlashcards) ||
                other.hasFlashcards == hasFlashcards) &&
            (identical(other.coverColorHex, coverColorHex) ||
                other.coverColorHex == coverColorHex) &&
            (identical(other.isPro, isPro) || other.isPro == isPro) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.lastStudiedAt, lastStudiedAt) ||
                other.lastStudiedAt == lastStudiedAt) &&
            (identical(other.subjectName, subjectName) ||
                other.subjectName == subjectName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      cardCount,
      dueCount,
      hasTests,
      hasFlashcards,
      coverColorHex,
      isPro,
      isPublic,
      isFavorite,
      isArchived,
      const DeepCollectionEquality().hash(_tags),
      createdAt,
      updatedAt,
      difficulty,
      lastStudiedAt,
      subjectName);

  /// Create a copy of LibraryDeck
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LibraryDeckImplCopyWith<_$LibraryDeckImpl> get copyWith =>
      __$$LibraryDeckImplCopyWithImpl<_$LibraryDeckImpl>(this, _$identity);
}

abstract class _LibraryDeck implements LibraryDeck {
  const factory _LibraryDeck(
      {required final String id,
      required final String title,
      required final String description,
      required final int cardCount,
      required final int dueCount,
      required final bool hasTests,
      required final bool hasFlashcards,
      required final String coverColorHex,
      required final bool isPro,
      required final bool isPublic,
      required final bool isFavorite,
      required final bool isArchived,
      required final List<String> tags,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final LibraryDifficulty? difficulty,
      final DateTime? lastStudiedAt,
      final String? subjectName}) = _$LibraryDeckImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  int get cardCount;
  @override
  int get dueCount;
  @override
  bool get hasTests;
  @override
  bool get hasFlashcards;
  @override
  String get coverColorHex;
  @override
  bool get isPro;
  @override
  bool get isPublic;
  @override
  bool get isFavorite;
  @override
  bool get isArchived;
  @override
  List<String> get tags;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  LibraryDifficulty? get difficulty;
  @override
  DateTime? get lastStudiedAt;
  @override
  String? get subjectName;

  /// Create a copy of LibraryDeck
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LibraryDeckImplCopyWith<_$LibraryDeckImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
