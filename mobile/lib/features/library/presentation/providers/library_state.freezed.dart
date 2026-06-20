// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'library_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DecksListState {
  List<LibraryDeck> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Create a copy of DecksListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DecksListStateCopyWith<DecksListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DecksListStateCopyWith<$Res> {
  factory $DecksListStateCopyWith(
          DecksListState value, $Res Function(DecksListState) then) =
      _$DecksListStateCopyWithImpl<$Res, DecksListState>;
  @useResult
  $Res call(
      {List<LibraryDeck> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore});
}

/// @nodoc
class _$DecksListStateCopyWithImpl<$Res, $Val extends DecksListState>
    implements $DecksListStateCopyWith<$Res> {
  _$DecksListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DecksListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryDeck>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DecksListStateImplCopyWith<$Res>
    implements $DecksListStateCopyWith<$Res> {
  factory _$$DecksListStateImplCopyWith(_$DecksListStateImpl value,
          $Res Function(_$DecksListStateImpl) then) =
      __$$DecksListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LibraryDeck> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore});
}

/// @nodoc
class __$$DecksListStateImplCopyWithImpl<$Res>
    extends _$DecksListStateCopyWithImpl<$Res, _$DecksListStateImpl>
    implements _$$DecksListStateImplCopyWith<$Res> {
  __$$DecksListStateImplCopyWithImpl(
      _$DecksListStateImpl _value, $Res Function(_$DecksListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DecksListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_$DecksListStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryDeck>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$DecksListStateImpl extends _DecksListState {
  const _$DecksListStateImpl(
      {final List<LibraryDeck> items = const [],
      this.currentPage = 1,
      this.totalPages = 1,
      this.isLoadingMore = false})
      : _items = items,
        super._();

  final List<LibraryDeck> _items;
  @override
  @JsonKey()
  List<LibraryDeck> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'DecksListState(items: $items, currentPage: $currentPage, totalPages: $totalPages, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DecksListStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isLoadingMore);

  /// Create a copy of DecksListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DecksListStateImplCopyWith<_$DecksListStateImpl> get copyWith =>
      __$$DecksListStateImplCopyWithImpl<_$DecksListStateImpl>(
          this, _$identity);
}

abstract class _DecksListState extends DecksListState {
  const factory _DecksListState(
      {final List<LibraryDeck> items,
      final int currentPage,
      final int totalPages,
      final bool isLoadingMore}) = _$DecksListStateImpl;
  const _DecksListState._() : super._();

  @override
  List<LibraryDeck> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoadingMore;

  /// Create a copy of DecksListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DecksListStateImplCopyWith<_$DecksListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CollectionsListState {
  List<LibraryCollection> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Create a copy of CollectionsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionsListStateCopyWith<CollectionsListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionsListStateCopyWith<$Res> {
  factory $CollectionsListStateCopyWith(CollectionsListState value,
          $Res Function(CollectionsListState) then) =
      _$CollectionsListStateCopyWithImpl<$Res, CollectionsListState>;
  @useResult
  $Res call(
      {List<LibraryCollection> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore});
}

/// @nodoc
class _$CollectionsListStateCopyWithImpl<$Res,
        $Val extends CollectionsListState>
    implements $CollectionsListStateCopyWith<$Res> {
  _$CollectionsListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryCollection>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectionsListStateImplCopyWith<$Res>
    implements $CollectionsListStateCopyWith<$Res> {
  factory _$$CollectionsListStateImplCopyWith(_$CollectionsListStateImpl value,
          $Res Function(_$CollectionsListStateImpl) then) =
      __$$CollectionsListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LibraryCollection> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore});
}

/// @nodoc
class __$$CollectionsListStateImplCopyWithImpl<$Res>
    extends _$CollectionsListStateCopyWithImpl<$Res, _$CollectionsListStateImpl>
    implements _$$CollectionsListStateImplCopyWith<$Res> {
  __$$CollectionsListStateImplCopyWithImpl(_$CollectionsListStateImpl _value,
      $Res Function(_$CollectionsListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollectionsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_$CollectionsListStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryCollection>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CollectionsListStateImpl extends _CollectionsListState {
  const _$CollectionsListStateImpl(
      {final List<LibraryCollection> items = const [],
      this.currentPage = 1,
      this.totalPages = 1,
      this.isLoadingMore = false})
      : _items = items,
        super._();

  final List<LibraryCollection> _items;
  @override
  @JsonKey()
  List<LibraryCollection> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'CollectionsListState(items: $items, currentPage: $currentPage, totalPages: $totalPages, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionsListStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isLoadingMore);

  /// Create a copy of CollectionsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionsListStateImplCopyWith<_$CollectionsListStateImpl>
      get copyWith =>
          __$$CollectionsListStateImplCopyWithImpl<_$CollectionsListStateImpl>(
              this, _$identity);
}

abstract class _CollectionsListState extends CollectionsListState {
  const factory _CollectionsListState(
      {final List<LibraryCollection> items,
      final int currentPage,
      final int totalPages,
      final bool isLoadingMore}) = _$CollectionsListStateImpl;
  const _CollectionsListState._() : super._();

  @override
  List<LibraryCollection> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoadingMore;

  /// Create a copy of CollectionsListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionsListStateImplCopyWith<_$CollectionsListStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FavoritesListState {
  List<LibraryDeck> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Create a copy of FavoritesListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoritesListStateCopyWith<FavoritesListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoritesListStateCopyWith<$Res> {
  factory $FavoritesListStateCopyWith(
          FavoritesListState value, $Res Function(FavoritesListState) then) =
      _$FavoritesListStateCopyWithImpl<$Res, FavoritesListState>;
  @useResult
  $Res call(
      {List<LibraryDeck> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore});
}

/// @nodoc
class _$FavoritesListStateCopyWithImpl<$Res, $Val extends FavoritesListState>
    implements $FavoritesListStateCopyWith<$Res> {
  _$FavoritesListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoritesListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryDeck>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FavoritesListStateImplCopyWith<$Res>
    implements $FavoritesListStateCopyWith<$Res> {
  factory _$$FavoritesListStateImplCopyWith(_$FavoritesListStateImpl value,
          $Res Function(_$FavoritesListStateImpl) then) =
      __$$FavoritesListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LibraryDeck> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore});
}

/// @nodoc
class __$$FavoritesListStateImplCopyWithImpl<$Res>
    extends _$FavoritesListStateCopyWithImpl<$Res, _$FavoritesListStateImpl>
    implements _$$FavoritesListStateImplCopyWith<$Res> {
  __$$FavoritesListStateImplCopyWithImpl(_$FavoritesListStateImpl _value,
      $Res Function(_$FavoritesListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FavoritesListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_$FavoritesListStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryDeck>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$FavoritesListStateImpl extends _FavoritesListState {
  const _$FavoritesListStateImpl(
      {final List<LibraryDeck> items = const [],
      this.currentPage = 1,
      this.totalPages = 1,
      this.isLoadingMore = false})
      : _items = items,
        super._();

  final List<LibraryDeck> _items;
  @override
  @JsonKey()
  List<LibraryDeck> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'FavoritesListState(items: $items, currentPage: $currentPage, totalPages: $totalPages, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoritesListStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isLoadingMore);

  /// Create a copy of FavoritesListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoritesListStateImplCopyWith<_$FavoritesListStateImpl> get copyWith =>
      __$$FavoritesListStateImplCopyWithImpl<_$FavoritesListStateImpl>(
          this, _$identity);
}

abstract class _FavoritesListState extends FavoritesListState {
  const factory _FavoritesListState(
      {final List<LibraryDeck> items,
      final int currentPage,
      final int totalPages,
      final bool isLoadingMore}) = _$FavoritesListStateImpl;
  const _FavoritesListState._() : super._();

  @override
  List<LibraryDeck> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoadingMore;

  /// Create a copy of FavoritesListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoritesListStateImplCopyWith<_$FavoritesListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchLibraryState {
  List<LibraryDeck> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get isIdle => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;

  /// Create a copy of SearchLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchLibraryStateCopyWith<SearchLibraryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchLibraryStateCopyWith<$Res> {
  factory $SearchLibraryStateCopyWith(
          SearchLibraryState value, $Res Function(SearchLibraryState) then) =
      _$SearchLibraryStateCopyWithImpl<$Res, SearchLibraryState>;
  @useResult
  $Res call(
      {List<LibraryDeck> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      bool isIdle,
      String query});
}

/// @nodoc
class _$SearchLibraryStateCopyWithImpl<$Res, $Val extends SearchLibraryState>
    implements $SearchLibraryStateCopyWith<$Res> {
  _$SearchLibraryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
    Object? isIdle = null,
    Object? query = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryDeck>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isIdle: null == isIdle
          ? _value.isIdle
          : isIdle // ignore: cast_nullable_to_non_nullable
              as bool,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchLibraryStateImplCopyWith<$Res>
    implements $SearchLibraryStateCopyWith<$Res> {
  factory _$$SearchLibraryStateImplCopyWith(_$SearchLibraryStateImpl value,
          $Res Function(_$SearchLibraryStateImpl) then) =
      __$$SearchLibraryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LibraryDeck> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      bool isIdle,
      String query});
}

/// @nodoc
class __$$SearchLibraryStateImplCopyWithImpl<$Res>
    extends _$SearchLibraryStateCopyWithImpl<$Res, _$SearchLibraryStateImpl>
    implements _$$SearchLibraryStateImplCopyWith<$Res> {
  __$$SearchLibraryStateImplCopyWithImpl(_$SearchLibraryStateImpl _value,
      $Res Function(_$SearchLibraryStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
    Object? isIdle = null,
    Object? query = null,
  }) {
    return _then(_$SearchLibraryStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LibraryDeck>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isIdle: null == isIdle
          ? _value.isIdle
          : isIdle // ignore: cast_nullable_to_non_nullable
              as bool,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SearchLibraryStateImpl extends _SearchLibraryState {
  const _$SearchLibraryStateImpl(
      {final List<LibraryDeck> items = const [],
      this.currentPage = 1,
      this.totalPages = 1,
      this.isLoadingMore = false,
      this.isIdle = true,
      this.query = ''})
      : _items = items,
        super._();

  final List<LibraryDeck> _items;
  @override
  @JsonKey()
  List<LibraryDeck> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool isIdle;
  @override
  @JsonKey()
  final String query;

  @override
  String toString() {
    return 'SearchLibraryState(items: $items, currentPage: $currentPage, totalPages: $totalPages, isLoadingMore: $isLoadingMore, isIdle: $isIdle, query: $query)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchLibraryStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.isIdle, isIdle) || other.isIdle == isIdle) &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isLoadingMore,
      isIdle,
      query);

  /// Create a copy of SearchLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchLibraryStateImplCopyWith<_$SearchLibraryStateImpl> get copyWith =>
      __$$SearchLibraryStateImplCopyWithImpl<_$SearchLibraryStateImpl>(
          this, _$identity);
}

abstract class _SearchLibraryState extends SearchLibraryState {
  const factory _SearchLibraryState(
      {final List<LibraryDeck> items,
      final int currentPage,
      final int totalPages,
      final bool isLoadingMore,
      final bool isIdle,
      final String query}) = _$SearchLibraryStateImpl;
  const _SearchLibraryState._() : super._();

  @override
  List<LibraryDeck> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoadingMore;
  @override
  bool get isIdle;
  @override
  String get query;

  /// Create a copy of SearchLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchLibraryStateImplCopyWith<_$SearchLibraryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
