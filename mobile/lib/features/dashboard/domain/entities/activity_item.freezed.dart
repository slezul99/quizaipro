// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StudyCardReviewDetail {
  String get cardId => throw _privateConstructorUsedError;
  String get front => throw _privateConstructorUsedError;
  String get back => throw _privateConstructorUsedError;
  String? get explanation => throw _privateConstructorUsedError;
  int get grade => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;

  /// Create a copy of StudyCardReviewDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyCardReviewDetailCopyWith<StudyCardReviewDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyCardReviewDetailCopyWith<$Res> {
  factory $StudyCardReviewDetailCopyWith(StudyCardReviewDetail value,
          $Res Function(StudyCardReviewDetail) then) =
      _$StudyCardReviewDetailCopyWithImpl<$Res, StudyCardReviewDetail>;
  @useResult
  $Res call(
      {String cardId,
      String front,
      String back,
      String? explanation,
      int grade,
      int xpEarned});
}

/// @nodoc
class _$StudyCardReviewDetailCopyWithImpl<$Res,
        $Val extends StudyCardReviewDetail>
    implements $StudyCardReviewDetailCopyWith<$Res> {
  _$StudyCardReviewDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyCardReviewDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? front = null,
    Object? back = null,
    Object? explanation = freezed,
    Object? grade = null,
    Object? xpEarned = null,
  }) {
    return _then(_value.copyWith(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyCardReviewDetailImplCopyWith<$Res>
    implements $StudyCardReviewDetailCopyWith<$Res> {
  factory _$$StudyCardReviewDetailImplCopyWith(
          _$StudyCardReviewDetailImpl value,
          $Res Function(_$StudyCardReviewDetailImpl) then) =
      __$$StudyCardReviewDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String cardId,
      String front,
      String back,
      String? explanation,
      int grade,
      int xpEarned});
}

/// @nodoc
class __$$StudyCardReviewDetailImplCopyWithImpl<$Res>
    extends _$StudyCardReviewDetailCopyWithImpl<$Res,
        _$StudyCardReviewDetailImpl>
    implements _$$StudyCardReviewDetailImplCopyWith<$Res> {
  __$$StudyCardReviewDetailImplCopyWithImpl(_$StudyCardReviewDetailImpl _value,
      $Res Function(_$StudyCardReviewDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyCardReviewDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? front = null,
    Object? back = null,
    Object? explanation = freezed,
    Object? grade = null,
    Object? xpEarned = null,
  }) {
    return _then(_$StudyCardReviewDetailImpl(
      cardId: null == cardId
          ? _value.cardId
          : cardId // ignore: cast_nullable_to_non_nullable
              as String,
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      back: null == back
          ? _value.back
          : back // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
      grade: null == grade
          ? _value.grade
          : grade // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$StudyCardReviewDetailImpl implements _StudyCardReviewDetail {
  const _$StudyCardReviewDetailImpl(
      {required this.cardId,
      required this.front,
      required this.back,
      this.explanation,
      required this.grade,
      required this.xpEarned});

  @override
  final String cardId;
  @override
  final String front;
  @override
  final String back;
  @override
  final String? explanation;
  @override
  final int grade;
  @override
  final int xpEarned;

  @override
  String toString() {
    return 'StudyCardReviewDetail(cardId: $cardId, front: $front, back: $back, explanation: $explanation, grade: $grade, xpEarned: $xpEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyCardReviewDetailImpl &&
            (identical(other.cardId, cardId) || other.cardId == cardId) &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.grade, grade) || other.grade == grade) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, cardId, front, back, explanation, grade, xpEarned);

  /// Create a copy of StudyCardReviewDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyCardReviewDetailImplCopyWith<_$StudyCardReviewDetailImpl>
      get copyWith => __$$StudyCardReviewDetailImplCopyWithImpl<
          _$StudyCardReviewDetailImpl>(this, _$identity);
}

abstract class _StudyCardReviewDetail implements StudyCardReviewDetail {
  const factory _StudyCardReviewDetail(
      {required final String cardId,
      required final String front,
      required final String back,
      final String? explanation,
      required final int grade,
      required final int xpEarned}) = _$StudyCardReviewDetailImpl;

  @override
  String get cardId;
  @override
  String get front;
  @override
  String get back;
  @override
  String? get explanation;
  @override
  int get grade;
  @override
  int get xpEarned;

  /// Create a copy of StudyCardReviewDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyCardReviewDetailImplCopyWith<_$StudyCardReviewDetailImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TestQuestionAttemptDetail {
  String get front => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;
  String get correctAnswer => throw _privateConstructorUsedError;
  String? get selectedAnswer => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;

  /// Create a copy of TestQuestionAttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TestQuestionAttemptDetailCopyWith<TestQuestionAttemptDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestQuestionAttemptDetailCopyWith<$Res> {
  factory $TestQuestionAttemptDetailCopyWith(TestQuestionAttemptDetail value,
          $Res Function(TestQuestionAttemptDetail) then) =
      _$TestQuestionAttemptDetailCopyWithImpl<$Res, TestQuestionAttemptDetail>;
  @useResult
  $Res call(
      {String front,
      bool isCorrect,
      String correctAnswer,
      String? selectedAnswer,
      int xpEarned});
}

/// @nodoc
class _$TestQuestionAttemptDetailCopyWithImpl<$Res,
        $Val extends TestQuestionAttemptDetail>
    implements $TestQuestionAttemptDetailCopyWith<$Res> {
  _$TestQuestionAttemptDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TestQuestionAttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? front = null,
    Object? isCorrect = null,
    Object? correctAnswer = null,
    Object? selectedAnswer = freezed,
    Object? xpEarned = null,
  }) {
    return _then(_value.copyWith(
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      selectedAnswer: freezed == selectedAnswer
          ? _value.selectedAnswer
          : selectedAnswer // ignore: cast_nullable_to_non_nullable
              as String?,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TestQuestionAttemptDetailImplCopyWith<$Res>
    implements $TestQuestionAttemptDetailCopyWith<$Res> {
  factory _$$TestQuestionAttemptDetailImplCopyWith(
          _$TestQuestionAttemptDetailImpl value,
          $Res Function(_$TestQuestionAttemptDetailImpl) then) =
      __$$TestQuestionAttemptDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String front,
      bool isCorrect,
      String correctAnswer,
      String? selectedAnswer,
      int xpEarned});
}

/// @nodoc
class __$$TestQuestionAttemptDetailImplCopyWithImpl<$Res>
    extends _$TestQuestionAttemptDetailCopyWithImpl<$Res,
        _$TestQuestionAttemptDetailImpl>
    implements _$$TestQuestionAttemptDetailImplCopyWith<$Res> {
  __$$TestQuestionAttemptDetailImplCopyWithImpl(
      _$TestQuestionAttemptDetailImpl _value,
      $Res Function(_$TestQuestionAttemptDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of TestQuestionAttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? front = null,
    Object? isCorrect = null,
    Object? correctAnswer = null,
    Object? selectedAnswer = freezed,
    Object? xpEarned = null,
  }) {
    return _then(_$TestQuestionAttemptDetailImpl(
      front: null == front
          ? _value.front
          : front // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      correctAnswer: null == correctAnswer
          ? _value.correctAnswer
          : correctAnswer // ignore: cast_nullable_to_non_nullable
              as String,
      selectedAnswer: freezed == selectedAnswer
          ? _value.selectedAnswer
          : selectedAnswer // ignore: cast_nullable_to_non_nullable
              as String?,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TestQuestionAttemptDetailImpl implements _TestQuestionAttemptDetail {
  const _$TestQuestionAttemptDetailImpl(
      {required this.front,
      required this.isCorrect,
      required this.correctAnswer,
      this.selectedAnswer,
      required this.xpEarned});

  @override
  final String front;
  @override
  final bool isCorrect;
  @override
  final String correctAnswer;
  @override
  final String? selectedAnswer;
  @override
  final int xpEarned;

  @override
  String toString() {
    return 'TestQuestionAttemptDetail(front: $front, isCorrect: $isCorrect, correctAnswer: $correctAnswer, selectedAnswer: $selectedAnswer, xpEarned: $xpEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestQuestionAttemptDetailImpl &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.correctAnswer, correctAnswer) ||
                other.correctAnswer == correctAnswer) &&
            (identical(other.selectedAnswer, selectedAnswer) ||
                other.selectedAnswer == selectedAnswer) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, front, isCorrect, correctAnswer, selectedAnswer, xpEarned);

  /// Create a copy of TestQuestionAttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestQuestionAttemptDetailImplCopyWith<_$TestQuestionAttemptDetailImpl>
      get copyWith => __$$TestQuestionAttemptDetailImplCopyWithImpl<
          _$TestQuestionAttemptDetailImpl>(this, _$identity);
}

abstract class _TestQuestionAttemptDetail implements TestQuestionAttemptDetail {
  const factory _TestQuestionAttemptDetail(
      {required final String front,
      required final bool isCorrect,
      required final String correctAnswer,
      final String? selectedAnswer,
      required final int xpEarned}) = _$TestQuestionAttemptDetailImpl;

  @override
  String get front;
  @override
  bool get isCorrect;
  @override
  String get correctAnswer;
  @override
  String? get selectedAnswer;
  @override
  int get xpEarned;

  /// Create a copy of TestQuestionAttemptDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestQuestionAttemptDetailImplCopyWith<_$TestQuestionAttemptDetailImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ActivityItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  List<Object> get details => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String title,
            int cardsReviewed,
            int xpEarned,
            DateTime timestamp,
            List<StudyCardReviewDetail> details)
        study,
    required TResult Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)
        test,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String title, int cardsReviewed, int xpEarned,
            DateTime timestamp, List<StudyCardReviewDetail> details)?
        study,
    TResult? Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)?
        test,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String title, int cardsReviewed, int xpEarned,
            DateTime timestamp, List<StudyCardReviewDetail> details)?
        study,
    TResult Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)?
        test,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudySessionActivity value) study,
    required TResult Function(TestSessionActivity value) test,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudySessionActivity value)? study,
    TResult? Function(TestSessionActivity value)? test,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudySessionActivity value)? study,
    TResult Function(TestSessionActivity value)? test,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityItemCopyWith<ActivityItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityItemCopyWith<$Res> {
  factory $ActivityItemCopyWith(
          ActivityItem value, $Res Function(ActivityItem) then) =
      _$ActivityItemCopyWithImpl<$Res, ActivityItem>;
  @useResult
  $Res call({String id, String title, int xpEarned, DateTime timestamp});
}

/// @nodoc
class _$ActivityItemCopyWithImpl<$Res, $Val extends ActivityItem>
    implements $ActivityItemCopyWith<$Res> {
  _$ActivityItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? xpEarned = null,
    Object? timestamp = null,
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
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudySessionActivityImplCopyWith<$Res>
    implements $ActivityItemCopyWith<$Res> {
  factory _$$StudySessionActivityImplCopyWith(_$StudySessionActivityImpl value,
          $Res Function(_$StudySessionActivityImpl) then) =
      __$$StudySessionActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      int cardsReviewed,
      int xpEarned,
      DateTime timestamp,
      List<StudyCardReviewDetail> details});
}

/// @nodoc
class __$$StudySessionActivityImplCopyWithImpl<$Res>
    extends _$ActivityItemCopyWithImpl<$Res, _$StudySessionActivityImpl>
    implements _$$StudySessionActivityImplCopyWith<$Res> {
  __$$StudySessionActivityImplCopyWithImpl(_$StudySessionActivityImpl _value,
      $Res Function(_$StudySessionActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? cardsReviewed = null,
    Object? xpEarned = null,
    Object? timestamp = null,
    Object? details = null,
  }) {
    return _then(_$StudySessionActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      cardsReviewed: null == cardsReviewed
          ? _value.cardsReviewed
          : cardsReviewed // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      details: null == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as List<StudyCardReviewDetail>,
    ));
  }
}

/// @nodoc

class _$StudySessionActivityImpl implements StudySessionActivity {
  const _$StudySessionActivityImpl(
      {required this.id,
      required this.title,
      required this.cardsReviewed,
      required this.xpEarned,
      required this.timestamp,
      required final List<StudyCardReviewDetail> details})
      : _details = details;

  @override
  final String id;
  @override
  final String title;
  @override
  final int cardsReviewed;
  @override
  final int xpEarned;
  @override
  final DateTime timestamp;
  final List<StudyCardReviewDetail> _details;
  @override
  List<StudyCardReviewDetail> get details {
    if (_details is EqualUnmodifiableListView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_details);
  }

  @override
  String toString() {
    return 'ActivityItem.study(id: $id, title: $title, cardsReviewed: $cardsReviewed, xpEarned: $xpEarned, timestamp: $timestamp, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudySessionActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.cardsReviewed, cardsReviewed) ||
                other.cardsReviewed == cardsReviewed) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, cardsReviewed,
      xpEarned, timestamp, const DeepCollectionEquality().hash(_details));

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudySessionActivityImplCopyWith<_$StudySessionActivityImpl>
      get copyWith =>
          __$$StudySessionActivityImplCopyWithImpl<_$StudySessionActivityImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String title,
            int cardsReviewed,
            int xpEarned,
            DateTime timestamp,
            List<StudyCardReviewDetail> details)
        study,
    required TResult Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)
        test,
  }) {
    return study(id, title, cardsReviewed, xpEarned, timestamp, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String title, int cardsReviewed, int xpEarned,
            DateTime timestamp, List<StudyCardReviewDetail> details)?
        study,
    TResult? Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)?
        test,
  }) {
    return study?.call(id, title, cardsReviewed, xpEarned, timestamp, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String title, int cardsReviewed, int xpEarned,
            DateTime timestamp, List<StudyCardReviewDetail> details)?
        study,
    TResult Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)?
        test,
    required TResult orElse(),
  }) {
    if (study != null) {
      return study(id, title, cardsReviewed, xpEarned, timestamp, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudySessionActivity value) study,
    required TResult Function(TestSessionActivity value) test,
  }) {
    return study(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudySessionActivity value)? study,
    TResult? Function(TestSessionActivity value)? test,
  }) {
    return study?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudySessionActivity value)? study,
    TResult Function(TestSessionActivity value)? test,
    required TResult orElse(),
  }) {
    if (study != null) {
      return study(this);
    }
    return orElse();
  }
}

abstract class StudySessionActivity implements ActivityItem {
  const factory StudySessionActivity(
          {required final String id,
          required final String title,
          required final int cardsReviewed,
          required final int xpEarned,
          required final DateTime timestamp,
          required final List<StudyCardReviewDetail> details}) =
      _$StudySessionActivityImpl;

  @override
  String get id;
  @override
  String get title;
  int get cardsReviewed;
  @override
  int get xpEarned;
  @override
  DateTime get timestamp;
  @override
  List<StudyCardReviewDetail> get details;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudySessionActivityImplCopyWith<_$StudySessionActivityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TestSessionActivityImplCopyWith<$Res>
    implements $ActivityItemCopyWith<$Res> {
  factory _$$TestSessionActivityImplCopyWith(_$TestSessionActivityImpl value,
          $Res Function(_$TestSessionActivityImpl) then) =
      __$$TestSessionActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      int totalQuestions,
      int correctCount,
      int xpEarned,
      DateTime timestamp,
      List<TestQuestionAttemptDetail> details});
}

/// @nodoc
class __$$TestSessionActivityImplCopyWithImpl<$Res>
    extends _$ActivityItemCopyWithImpl<$Res, _$TestSessionActivityImpl>
    implements _$$TestSessionActivityImplCopyWith<$Res> {
  __$$TestSessionActivityImplCopyWithImpl(_$TestSessionActivityImpl _value,
      $Res Function(_$TestSessionActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? totalQuestions = null,
    Object? correctCount = null,
    Object? xpEarned = null,
    Object? timestamp = null,
    Object? details = null,
  }) {
    return _then(_$TestSessionActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _value.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      details: null == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as List<TestQuestionAttemptDetail>,
    ));
  }
}

/// @nodoc

class _$TestSessionActivityImpl implements TestSessionActivity {
  const _$TestSessionActivityImpl(
      {required this.id,
      required this.title,
      required this.totalQuestions,
      required this.correctCount,
      required this.xpEarned,
      required this.timestamp,
      required final List<TestQuestionAttemptDetail> details})
      : _details = details;

  @override
  final String id;
  @override
  final String title;
  @override
  final int totalQuestions;
  @override
  final int correctCount;
  @override
  final int xpEarned;
  @override
  final DateTime timestamp;
  final List<TestQuestionAttemptDetail> _details;
  @override
  List<TestQuestionAttemptDetail> get details {
    if (_details is EqualUnmodifiableListView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_details);
  }

  @override
  String toString() {
    return 'ActivityItem.test(id: $id, title: $title, totalQuestions: $totalQuestions, correctCount: $correctCount, xpEarned: $xpEarned, timestamp: $timestamp, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TestSessionActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      totalQuestions,
      correctCount,
      xpEarned,
      timestamp,
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TestSessionActivityImplCopyWith<_$TestSessionActivityImpl> get copyWith =>
      __$$TestSessionActivityImplCopyWithImpl<_$TestSessionActivityImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String id,
            String title,
            int cardsReviewed,
            int xpEarned,
            DateTime timestamp,
            List<StudyCardReviewDetail> details)
        study,
    required TResult Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)
        test,
  }) {
    return test(
        id, title, totalQuestions, correctCount, xpEarned, timestamp, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String id, String title, int cardsReviewed, int xpEarned,
            DateTime timestamp, List<StudyCardReviewDetail> details)?
        study,
    TResult? Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)?
        test,
  }) {
    return test?.call(
        id, title, totalQuestions, correctCount, xpEarned, timestamp, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String id, String title, int cardsReviewed, int xpEarned,
            DateTime timestamp, List<StudyCardReviewDetail> details)?
        study,
    TResult Function(
            String id,
            String title,
            int totalQuestions,
            int correctCount,
            int xpEarned,
            DateTime timestamp,
            List<TestQuestionAttemptDetail> details)?
        test,
    required TResult orElse(),
  }) {
    if (test != null) {
      return test(id, title, totalQuestions, correctCount, xpEarned, timestamp,
          details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StudySessionActivity value) study,
    required TResult Function(TestSessionActivity value) test,
  }) {
    return test(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(StudySessionActivity value)? study,
    TResult? Function(TestSessionActivity value)? test,
  }) {
    return test?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StudySessionActivity value)? study,
    TResult Function(TestSessionActivity value)? test,
    required TResult orElse(),
  }) {
    if (test != null) {
      return test(this);
    }
    return orElse();
  }
}

abstract class TestSessionActivity implements ActivityItem {
  const factory TestSessionActivity(
          {required final String id,
          required final String title,
          required final int totalQuestions,
          required final int correctCount,
          required final int xpEarned,
          required final DateTime timestamp,
          required final List<TestQuestionAttemptDetail> details}) =
      _$TestSessionActivityImpl;

  @override
  String get id;
  @override
  String get title;
  int get totalQuestions;
  int get correctCount;
  @override
  int get xpEarned;
  @override
  DateTime get timestamp;
  @override
  List<TestQuestionAttemptDetail> get details;

  /// Create a copy of ActivityItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TestSessionActivityImplCopyWith<_$TestSessionActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
