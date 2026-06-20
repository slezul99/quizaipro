// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversations_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConversationsState {
  List<Conversation> get conversations => throw _privateConstructorUsedError;
  List<Conversation> get searchResults => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  bool get isSearching => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationsStateCopyWith<ConversationsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationsStateCopyWith<$Res> {
  factory $ConversationsStateCopyWith(
          ConversationsState value, $Res Function(ConversationsState) then) =
      _$ConversationsStateCopyWithImpl<$Res, ConversationsState>;
  @useResult
  $Res call(
      {List<Conversation> conversations,
      List<Conversation> searchResults,
      String searchQuery,
      bool isSearching,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$ConversationsStateCopyWithImpl<$Res, $Val extends ConversationsState>
    implements $ConversationsStateCopyWith<$Res> {
  _$ConversationsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? searchResults = null,
    Object? searchQuery = null,
    Object? isSearching = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      conversations: null == conversations
          ? _value.conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      searchResults: null == searchResults
          ? _value.searchResults
          : searchResults // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationsStateImplCopyWith<$Res>
    implements $ConversationsStateCopyWith<$Res> {
  factory _$$ConversationsStateImplCopyWith(_$ConversationsStateImpl value,
          $Res Function(_$ConversationsStateImpl) then) =
      __$$ConversationsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Conversation> conversations,
      List<Conversation> searchResults,
      String searchQuery,
      bool isSearching,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$ConversationsStateImplCopyWithImpl<$Res>
    extends _$ConversationsStateCopyWithImpl<$Res, _$ConversationsStateImpl>
    implements _$$ConversationsStateImplCopyWith<$Res> {
  __$$ConversationsStateImplCopyWithImpl(_$ConversationsStateImpl _value,
      $Res Function(_$ConversationsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversations = null,
    Object? searchResults = null,
    Object? searchQuery = null,
    Object? isSearching = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$ConversationsStateImpl(
      conversations: null == conversations
          ? _value._conversations
          : conversations // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      searchResults: null == searchResults
          ? _value._searchResults
          : searchResults // ignore: cast_nullable_to_non_nullable
              as List<Conversation>,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ConversationsStateImpl extends _ConversationsState {
  const _$ConversationsStateImpl(
      {final List<Conversation> conversations = const [],
      final List<Conversation> searchResults = const [],
      this.searchQuery = '',
      this.isSearching = false,
      this.isLoading = false,
      this.errorMessage})
      : _conversations = conversations,
        _searchResults = searchResults,
        super._();

  final List<Conversation> _conversations;
  @override
  @JsonKey()
  List<Conversation> get conversations {
    if (_conversations is EqualUnmodifiableListView) return _conversations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conversations);
  }

  final List<Conversation> _searchResults;
  @override
  @JsonKey()
  List<Conversation> get searchResults {
    if (_searchResults is EqualUnmodifiableListView) return _searchResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResults);
  }

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final bool isSearching;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ConversationsState(conversations: $conversations, searchResults: $searchResults, searchQuery: $searchQuery, isSearching: $isSearching, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._conversations, _conversations) &&
            const DeepCollectionEquality()
                .equals(other._searchResults, _searchResults) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_conversations),
      const DeepCollectionEquality().hash(_searchResults),
      searchQuery,
      isSearching,
      isLoading,
      errorMessage);

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationsStateImplCopyWith<_$ConversationsStateImpl> get copyWith =>
      __$$ConversationsStateImplCopyWithImpl<_$ConversationsStateImpl>(
          this, _$identity);
}

abstract class _ConversationsState extends ConversationsState {
  const factory _ConversationsState(
      {final List<Conversation> conversations,
      final List<Conversation> searchResults,
      final String searchQuery,
      final bool isSearching,
      final bool isLoading,
      final String? errorMessage}) = _$ConversationsStateImpl;
  const _ConversationsState._() : super._();

  @override
  List<Conversation> get conversations;
  @override
  List<Conversation> get searchResults;
  @override
  String get searchQuery;
  @override
  bool get isSearching;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of ConversationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationsStateImplCopyWith<_$ConversationsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
