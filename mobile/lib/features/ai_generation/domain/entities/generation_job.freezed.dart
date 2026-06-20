// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GenerationJob {
  String get id => throw _privateConstructorUsedError;
  GenerationSource get source => throw _privateConstructorUsedError;
  GenerationStatus get status => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  String? get topic => throw _privateConstructorUsedError;
  String? get inputText => throw _privateConstructorUsedError;
  String? get pdfFileName => throw _privateConstructorUsedError;
  QualityMode get qualityMode => throw _privateConstructorUsedError;
  int get requestedCardCount => throw _privateConstructorUsedError;
  List<GeneratedCard> get cards => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenerationJobCopyWith<GenerationJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationJobCopyWith<$Res> {
  factory $GenerationJobCopyWith(
          GenerationJob value, $Res Function(GenerationJob) then) =
      _$GenerationJobCopyWithImpl<$Res, GenerationJob>;
  @useResult
  $Res call(
      {String id,
      GenerationSource source,
      GenerationStatus status,
      int progress,
      String? topic,
      String? inputText,
      String? pdfFileName,
      QualityMode qualityMode,
      int requestedCardCount,
      List<GeneratedCard> cards,
      String? errorMessage,
      DateTime createdAt,
      DateTime? completedAt});
}

/// @nodoc
class _$GenerationJobCopyWithImpl<$Res, $Val extends GenerationJob>
    implements $GenerationJobCopyWith<$Res> {
  _$GenerationJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? status = null,
    Object? progress = null,
    Object? topic = freezed,
    Object? inputText = freezed,
    Object? pdfFileName = freezed,
    Object? qualityMode = null,
    Object? requestedCardCount = null,
    Object? cards = null,
    Object? errorMessage = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as GenerationSource,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GenerationStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      inputText: freezed == inputText
          ? _value.inputText
          : inputText // ignore: cast_nullable_to_non_nullable
              as String?,
      pdfFileName: freezed == pdfFileName
          ? _value.pdfFileName
          : pdfFileName // ignore: cast_nullable_to_non_nullable
              as String?,
      qualityMode: null == qualityMode
          ? _value.qualityMode
          : qualityMode // ignore: cast_nullable_to_non_nullable
              as QualityMode,
      requestedCardCount: null == requestedCardCount
          ? _value.requestedCardCount
          : requestedCardCount // ignore: cast_nullable_to_non_nullable
              as int,
      cards: null == cards
          ? _value.cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<GeneratedCard>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GenerationJobImplCopyWith<$Res>
    implements $GenerationJobCopyWith<$Res> {
  factory _$$GenerationJobImplCopyWith(
          _$GenerationJobImpl value, $Res Function(_$GenerationJobImpl) then) =
      __$$GenerationJobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      GenerationSource source,
      GenerationStatus status,
      int progress,
      String? topic,
      String? inputText,
      String? pdfFileName,
      QualityMode qualityMode,
      int requestedCardCount,
      List<GeneratedCard> cards,
      String? errorMessage,
      DateTime createdAt,
      DateTime? completedAt});
}

/// @nodoc
class __$$GenerationJobImplCopyWithImpl<$Res>
    extends _$GenerationJobCopyWithImpl<$Res, _$GenerationJobImpl>
    implements _$$GenerationJobImplCopyWith<$Res> {
  __$$GenerationJobImplCopyWithImpl(
      _$GenerationJobImpl _value, $Res Function(_$GenerationJobImpl) _then)
      : super(_value, _then);

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? status = null,
    Object? progress = null,
    Object? topic = freezed,
    Object? inputText = freezed,
    Object? pdfFileName = freezed,
    Object? qualityMode = null,
    Object? requestedCardCount = null,
    Object? cards = null,
    Object? errorMessage = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$GenerationJobImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as GenerationSource,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GenerationStatus,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      inputText: freezed == inputText
          ? _value.inputText
          : inputText // ignore: cast_nullable_to_non_nullable
              as String?,
      pdfFileName: freezed == pdfFileName
          ? _value.pdfFileName
          : pdfFileName // ignore: cast_nullable_to_non_nullable
              as String?,
      qualityMode: null == qualityMode
          ? _value.qualityMode
          : qualityMode // ignore: cast_nullable_to_non_nullable
              as QualityMode,
      requestedCardCount: null == requestedCardCount
          ? _value.requestedCardCount
          : requestedCardCount // ignore: cast_nullable_to_non_nullable
              as int,
      cards: null == cards
          ? _value._cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<GeneratedCard>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$GenerationJobImpl extends _GenerationJob {
  const _$GenerationJobImpl(
      {required this.id,
      required this.source,
      required this.status,
      this.progress = 0,
      this.topic,
      this.inputText,
      this.pdfFileName,
      required this.qualityMode,
      required this.requestedCardCount,
      final List<GeneratedCard> cards = const [],
      this.errorMessage,
      required this.createdAt,
      this.completedAt})
      : _cards = cards,
        super._();

  @override
  final String id;
  @override
  final GenerationSource source;
  @override
  final GenerationStatus status;
  @override
  @JsonKey()
  final int progress;
  @override
  final String? topic;
  @override
  final String? inputText;
  @override
  final String? pdfFileName;
  @override
  final QualityMode qualityMode;
  @override
  final int requestedCardCount;
  final List<GeneratedCard> _cards;
  @override
  @JsonKey()
  List<GeneratedCard> get cards {
    if (_cards is EqualUnmodifiableListView) return _cards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cards);
  }

  @override
  final String? errorMessage;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'GenerationJob(id: $id, source: $source, status: $status, progress: $progress, topic: $topic, inputText: $inputText, pdfFileName: $pdfFileName, qualityMode: $qualityMode, requestedCardCount: $requestedCardCount, cards: $cards, errorMessage: $errorMessage, createdAt: $createdAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationJobImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.inputText, inputText) ||
                other.inputText == inputText) &&
            (identical(other.pdfFileName, pdfFileName) ||
                other.pdfFileName == pdfFileName) &&
            (identical(other.qualityMode, qualityMode) ||
                other.qualityMode == qualityMode) &&
            (identical(other.requestedCardCount, requestedCardCount) ||
                other.requestedCardCount == requestedCardCount) &&
            const DeepCollectionEquality().equals(other._cards, _cards) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      source,
      status,
      progress,
      topic,
      inputText,
      pdfFileName,
      qualityMode,
      requestedCardCount,
      const DeepCollectionEquality().hash(_cards),
      errorMessage,
      createdAt,
      completedAt);

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationJobImplCopyWith<_$GenerationJobImpl> get copyWith =>
      __$$GenerationJobImplCopyWithImpl<_$GenerationJobImpl>(this, _$identity);
}

abstract class _GenerationJob extends GenerationJob {
  const factory _GenerationJob(
      {required final String id,
      required final GenerationSource source,
      required final GenerationStatus status,
      final int progress,
      final String? topic,
      final String? inputText,
      final String? pdfFileName,
      required final QualityMode qualityMode,
      required final int requestedCardCount,
      final List<GeneratedCard> cards,
      final String? errorMessage,
      required final DateTime createdAt,
      final DateTime? completedAt}) = _$GenerationJobImpl;
  const _GenerationJob._() : super._();

  @override
  String get id;
  @override
  GenerationSource get source;
  @override
  GenerationStatus get status;
  @override
  int get progress;
  @override
  String? get topic;
  @override
  String? get inputText;
  @override
  String? get pdfFileName;
  @override
  QualityMode get qualityMode;
  @override
  int get requestedCardCount;
  @override
  List<GeneratedCard> get cards;
  @override
  String? get errorMessage;
  @override
  DateTime get createdAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of GenerationJob
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationJobImplCopyWith<_$GenerationJobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
