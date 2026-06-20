// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marketplace_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DecksListState {
  List<DeckSummary> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  Failure? get loadMoreFailure => throw _privateConstructorUsedError;

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
      {List<DeckSummary> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      bool isRefreshing,
      Failure? loadMoreFailure});

  $FailureCopyWith<$Res>? get loadMoreFailure;
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
    Object? isRefreshing = null,
    Object? loadMoreFailure = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DeckSummary>,
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
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      loadMoreFailure: freezed == loadMoreFailure
          ? _value.loadMoreFailure
          : loadMoreFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ) as $Val);
  }

  /// Create a copy of DecksListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res>? get loadMoreFailure {
    if (_value.loadMoreFailure == null) {
      return null;
    }

    return $FailureCopyWith<$Res>(_value.loadMoreFailure!, (value) {
      return _then(_value.copyWith(loadMoreFailure: value) as $Val);
    });
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
      {List<DeckSummary> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      bool isRefreshing,
      Failure? loadMoreFailure});

  @override
  $FailureCopyWith<$Res>? get loadMoreFailure;
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
    Object? isRefreshing = null,
    Object? loadMoreFailure = freezed,
  }) {
    return _then(_$DecksListStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DeckSummary>,
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
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      loadMoreFailure: freezed == loadMoreFailure
          ? _value.loadMoreFailure
          : loadMoreFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ));
  }
}

/// @nodoc

class _$DecksListStateImpl extends _DecksListState {
  const _$DecksListStateImpl(
      {required final List<DeckSummary> items,
      this.currentPage = 1,
      this.totalPages = 1,
      this.isLoadingMore = false,
      this.isRefreshing = false,
      this.loadMoreFailure})
      : _items = items,
        super._();

  final List<DeckSummary> _items;
  @override
  List<DeckSummary> get items {
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
  final bool isRefreshing;
  @override
  final Failure? loadMoreFailure;

  @override
  String toString() {
    return 'DecksListState(items: $items, currentPage: $currentPage, totalPages: $totalPages, isLoadingMore: $isLoadingMore, isRefreshing: $isRefreshing, loadMoreFailure: $loadMoreFailure)';
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
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.loadMoreFailure, loadMoreFailure) ||
                other.loadMoreFailure == loadMoreFailure));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isLoadingMore,
      isRefreshing,
      loadMoreFailure);

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
      {required final List<DeckSummary> items,
      final int currentPage,
      final int totalPages,
      final bool isLoadingMore,
      final bool isRefreshing,
      final Failure? loadMoreFailure}) = _$DecksListStateImpl;
  const _DecksListState._() : super._();

  @override
  List<DeckSummary> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoadingMore;
  @override
  bool get isRefreshing;
  @override
  Failure? get loadMoreFailure;

  /// Create a copy of DecksListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DecksListStateImplCopyWith<_$DecksListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CollectionsListState {
  List<Collection> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  Failure? get loadMoreFailure => throw _privateConstructorUsedError;

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
      {List<Collection> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      Failure? loadMoreFailure});

  $FailureCopyWith<$Res>? get loadMoreFailure;
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
    Object? loadMoreFailure = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Collection>,
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
      loadMoreFailure: freezed == loadMoreFailure
          ? _value.loadMoreFailure
          : loadMoreFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ) as $Val);
  }

  /// Create a copy of CollectionsListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res>? get loadMoreFailure {
    if (_value.loadMoreFailure == null) {
      return null;
    }

    return $FailureCopyWith<$Res>(_value.loadMoreFailure!, (value) {
      return _then(_value.copyWith(loadMoreFailure: value) as $Val);
    });
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
      {List<Collection> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      Failure? loadMoreFailure});

  @override
  $FailureCopyWith<$Res>? get loadMoreFailure;
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
    Object? loadMoreFailure = freezed,
  }) {
    return _then(_$CollectionsListStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Collection>,
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
      loadMoreFailure: freezed == loadMoreFailure
          ? _value.loadMoreFailure
          : loadMoreFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ));
  }
}

/// @nodoc

class _$CollectionsListStateImpl extends _CollectionsListState {
  const _$CollectionsListStateImpl(
      {required final List<Collection> items,
      this.currentPage = 1,
      this.totalPages = 1,
      this.isLoadingMore = false,
      this.loadMoreFailure})
      : _items = items,
        super._();

  final List<Collection> _items;
  @override
  List<Collection> get items {
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
  final Failure? loadMoreFailure;

  @override
  String toString() {
    return 'CollectionsListState(items: $items, currentPage: $currentPage, totalPages: $totalPages, isLoadingMore: $isLoadingMore, loadMoreFailure: $loadMoreFailure)';
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
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.loadMoreFailure, loadMoreFailure) ||
                other.loadMoreFailure == loadMoreFailure));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isLoadingMore,
      loadMoreFailure);

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
      {required final List<Collection> items,
      final int currentPage,
      final int totalPages,
      final bool isLoadingMore,
      final Failure? loadMoreFailure}) = _$CollectionsListStateImpl;
  const _CollectionsListState._() : super._();

  @override
  List<Collection> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoadingMore;
  @override
  Failure? get loadMoreFailure;

  /// Create a copy of CollectionsListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionsListStateImplCopyWith<_$CollectionsListStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LearningPathsListState {
  List<LearningPath> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  Failure? get loadMoreFailure => throw _privateConstructorUsedError;

  /// Create a copy of LearningPathsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningPathsListStateCopyWith<LearningPathsListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningPathsListStateCopyWith<$Res> {
  factory $LearningPathsListStateCopyWith(LearningPathsListState value,
          $Res Function(LearningPathsListState) then) =
      _$LearningPathsListStateCopyWithImpl<$Res, LearningPathsListState>;
  @useResult
  $Res call(
      {List<LearningPath> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      Failure? loadMoreFailure});

  $FailureCopyWith<$Res>? get loadMoreFailure;
}

/// @nodoc
class _$LearningPathsListStateCopyWithImpl<$Res,
        $Val extends LearningPathsListState>
    implements $LearningPathsListStateCopyWith<$Res> {
  _$LearningPathsListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningPathsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
    Object? loadMoreFailure = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LearningPath>,
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
      loadMoreFailure: freezed == loadMoreFailure
          ? _value.loadMoreFailure
          : loadMoreFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ) as $Val);
  }

  /// Create a copy of LearningPathsListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res>? get loadMoreFailure {
    if (_value.loadMoreFailure == null) {
      return null;
    }

    return $FailureCopyWith<$Res>(_value.loadMoreFailure!, (value) {
      return _then(_value.copyWith(loadMoreFailure: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LearningPathsListStateImplCopyWith<$Res>
    implements $LearningPathsListStateCopyWith<$Res> {
  factory _$$LearningPathsListStateImplCopyWith(
          _$LearningPathsListStateImpl value,
          $Res Function(_$LearningPathsListStateImpl) then) =
      __$$LearningPathsListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<LearningPath> items,
      int currentPage,
      int totalPages,
      bool isLoadingMore,
      Failure? loadMoreFailure});

  @override
  $FailureCopyWith<$Res>? get loadMoreFailure;
}

/// @nodoc
class __$$LearningPathsListStateImplCopyWithImpl<$Res>
    extends _$LearningPathsListStateCopyWithImpl<$Res,
        _$LearningPathsListStateImpl>
    implements _$$LearningPathsListStateImplCopyWith<$Res> {
  __$$LearningPathsListStateImplCopyWithImpl(
      _$LearningPathsListStateImpl _value,
      $Res Function(_$LearningPathsListStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LearningPathsListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoadingMore = null,
    Object? loadMoreFailure = freezed,
  }) {
    return _then(_$LearningPathsListStateImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<LearningPath>,
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
      loadMoreFailure: freezed == loadMoreFailure
          ? _value.loadMoreFailure
          : loadMoreFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ));
  }
}

/// @nodoc

class _$LearningPathsListStateImpl extends _LearningPathsListState {
  const _$LearningPathsListStateImpl(
      {required final List<LearningPath> items,
      this.currentPage = 1,
      this.totalPages = 1,
      this.isLoadingMore = false,
      this.loadMoreFailure})
      : _items = items,
        super._();

  final List<LearningPath> _items;
  @override
  List<LearningPath> get items {
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
  final Failure? loadMoreFailure;

  @override
  String toString() {
    return 'LearningPathsListState(items: $items, currentPage: $currentPage, totalPages: $totalPages, isLoadingMore: $isLoadingMore, loadMoreFailure: $loadMoreFailure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningPathsListStateImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.loadMoreFailure, loadMoreFailure) ||
                other.loadMoreFailure == loadMoreFailure));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isLoadingMore,
      loadMoreFailure);

  /// Create a copy of LearningPathsListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningPathsListStateImplCopyWith<_$LearningPathsListStateImpl>
      get copyWith => __$$LearningPathsListStateImplCopyWithImpl<
          _$LearningPathsListStateImpl>(this, _$identity);
}

abstract class _LearningPathsListState extends LearningPathsListState {
  const factory _LearningPathsListState(
      {required final List<LearningPath> items,
      final int currentPage,
      final int totalPages,
      final bool isLoadingMore,
      final Failure? loadMoreFailure}) = _$LearningPathsListStateImpl;
  const _LearningPathsListState._() : super._();

  @override
  List<LearningPath> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoadingMore;
  @override
  Failure? get loadMoreFailure;

  /// Create a copy of LearningPathsListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningPathsListStateImplCopyWith<_$LearningPathsListStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchState {
  String get query => throw _privateConstructorUsedError;
  MarketplaceFilter get filter => throw _privateConstructorUsedError;
  List<DeckSummary> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  Failure? get searchFailure => throw _privateConstructorUsedError;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call(
      {String query,
      MarketplaceFilter filter,
      List<DeckSummary> items,
      int currentPage,
      int totalPages,
      bool isSearching,
      bool isLoadingMore,
      Failure? searchFailure});

  $MarketplaceFilterCopyWith<$Res> get filter;
  $FailureCopyWith<$Res>? get searchFailure;
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? filter = null,
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isSearching = null,
    Object? isLoadingMore = null,
    Object? searchFailure = freezed,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MarketplaceFilter,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DeckSummary>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      searchFailure: freezed == searchFailure
          ? _value.searchFailure
          : searchFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ) as $Val);
  }

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MarketplaceFilterCopyWith<$Res> get filter {
    return $MarketplaceFilterCopyWith<$Res>(_value.filter, (value) {
      return _then(_value.copyWith(filter: value) as $Val);
    });
  }

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res>? get searchFailure {
    if (_value.searchFailure == null) {
      return null;
    }

    return $FailureCopyWith<$Res>(_value.searchFailure!, (value) {
      return _then(_value.copyWith(searchFailure: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
          _$SearchStateImpl value, $Res Function(_$SearchStateImpl) then) =
      __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      MarketplaceFilter filter,
      List<DeckSummary> items,
      int currentPage,
      int totalPages,
      bool isSearching,
      bool isLoadingMore,
      Failure? searchFailure});

  @override
  $MarketplaceFilterCopyWith<$Res> get filter;
  @override
  $FailureCopyWith<$Res>? get searchFailure;
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
      _$SearchStateImpl _value, $Res Function(_$SearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? filter = null,
    Object? items = null,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isSearching = null,
    Object? isLoadingMore = null,
    Object? searchFailure = freezed,
  }) {
    return _then(_$SearchStateImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as MarketplaceFilter,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<DeckSummary>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      searchFailure: freezed == searchFailure
          ? _value.searchFailure
          : searchFailure // ignore: cast_nullable_to_non_nullable
              as Failure?,
    ));
  }
}

/// @nodoc

class _$SearchStateImpl extends _SearchState {
  const _$SearchStateImpl(
      {this.query = '',
      this.filter = const MarketplaceFilter(),
      final List<DeckSummary> items = const [],
      this.currentPage = 1,
      this.totalPages = 1,
      this.isSearching = false,
      this.isLoadingMore = false,
      this.searchFailure})
      : _items = items,
        super._();

  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final MarketplaceFilter filter;
  final List<DeckSummary> _items;
  @override
  @JsonKey()
  List<DeckSummary> get items {
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
  final bool isSearching;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  final Failure? searchFailure;

  @override
  String toString() {
    return 'SearchState(query: $query, filter: $filter, items: $items, currentPage: $currentPage, totalPages: $totalPages, isSearching: $isSearching, isLoadingMore: $isLoadingMore, searchFailure: $searchFailure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.searchFailure, searchFailure) ||
                other.searchFailure == searchFailure));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      filter,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      totalPages,
      isSearching,
      isLoadingMore,
      searchFailure);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState extends SearchState {
  const factory _SearchState(
      {final String query,
      final MarketplaceFilter filter,
      final List<DeckSummary> items,
      final int currentPage,
      final int totalPages,
      final bool isSearching,
      final bool isLoadingMore,
      final Failure? searchFailure}) = _$SearchStateImpl;
  const _SearchState._() : super._();

  @override
  String get query;
  @override
  MarketplaceFilter get filter;
  @override
  List<DeckSummary> get items;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isSearching;
  @override
  bool get isLoadingMore;
  @override
  Failure? get searchFailure;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
