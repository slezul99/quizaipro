// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FlashcardsLocalTableTable extends FlashcardsLocalTable
    with TableInfo<$FlashcardsLocalTableTable, FlashcardsLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
      'front', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
      'back', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
      'hint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _easeFactorMeta =
      const VerificationMeta('easeFactor');
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
      'ease_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stabilityMeta =
      const VerificationMeta('stability');
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
      'stability', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
      'difficulty', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _nextReviewAtMeta =
      const VerificationMeta('nextReviewAt');
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
      'next_review_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastStudiedAtMeta =
      const VerificationMeta('lastStudiedAt');
  @override
  late final GeneratedColumn<DateTime> lastStudiedAt =
      GeneratedColumn<DateTime>('last_studied_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDifficultMeta =
      const VerificationMeta('isDifficult');
  @override
  late final GeneratedColumn<bool> isDifficult = GeneratedColumn<bool>(
      'is_difficult', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_difficult" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _againCountMeta =
      const VerificationMeta('againCount');
  @override
  late final GeneratedColumn<int> againCount = GeneratedColumn<int>(
      'again_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deckId,
        front,
        back,
        hint,
        easeFactor,
        interval,
        repetitions,
        stability,
        difficulty,
        nextReviewAt,
        lastStudiedAt,
        isFavorite,
        isDifficult,
        againCount,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<FlashcardsLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
          _frontMeta, front.isAcceptableOrUnknown(data['front']!, _frontMeta));
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
          _backMeta, back.isAcceptableOrUnknown(data['back']!, _backMeta));
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
          _hintMeta, hint.isAcceptableOrUnknown(data['hint']!, _hintMeta));
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
          _easeFactorMeta,
          easeFactor.isAcceptableOrUnknown(
              data['ease_factor']!, _easeFactorMeta));
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    }
    if (data.containsKey('stability')) {
      context.handle(_stabilityMeta,
          stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
          _nextReviewAtMeta,
          nextReviewAt.isAcceptableOrUnknown(
              data['next_review_at']!, _nextReviewAtMeta));
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
          _lastStudiedAtMeta,
          lastStudiedAt.isAcceptableOrUnknown(
              data['last_studied_at']!, _lastStudiedAtMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_difficult')) {
      context.handle(
          _isDifficultMeta,
          isDifficult.isAcceptableOrUnknown(
              data['is_difficult']!, _isDifficultMeta));
    }
    if (data.containsKey('again_count')) {
      context.handle(
          _againCountMeta,
          againCount.isAcceptableOrUnknown(
              data['again_count']!, _againCountMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardsLocalTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardsLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id'])!,
      front: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front'])!,
      back: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back'])!,
      hint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hint']),
      easeFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ease_factor'])!,
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
      stability: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stability']),
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}difficulty']),
      nextReviewAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_at']),
      lastStudiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_studied_at']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isDifficult: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_difficult'])!,
      againCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}again_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FlashcardsLocalTableTable createAlias(String alias) {
    return $FlashcardsLocalTableTable(attachedDatabase, alias);
  }
}

class FlashcardsLocalTableData extends DataClass
    implements Insertable<FlashcardsLocalTableData> {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? hint;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final double? stability;
  final double? difficulty;
  final DateTime? nextReviewAt;
  final DateTime? lastStudiedAt;
  final bool isFavorite;
  final bool isDifficult;
  final int againCount;
  final DateTime updatedAt;
  const FlashcardsLocalTableData(
      {required this.id,
      required this.deckId,
      required this.front,
      required this.back,
      this.hint,
      required this.easeFactor,
      required this.interval,
      required this.repetitions,
      this.stability,
      this.difficulty,
      this.nextReviewAt,
      this.lastStudiedAt,
      required this.isFavorite,
      required this.isDifficult,
      required this.againCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval'] = Variable<int>(interval);
    map['repetitions'] = Variable<int>(repetitions);
    if (!nullToAbsent || stability != null) {
      map['stability'] = Variable<double>(stability);
    }
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<double>(difficulty);
    }
    if (!nullToAbsent || nextReviewAt != null) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    }
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_difficult'] = Variable<bool>(isDifficult);
    map['again_count'] = Variable<int>(againCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FlashcardsLocalTableCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsLocalTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
      easeFactor: Value(easeFactor),
      interval: Value(interval),
      repetitions: Value(repetitions),
      stability: stability == null && nullToAbsent
          ? const Value.absent()
          : Value(stability),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      nextReviewAt: nextReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewAt),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
      isFavorite: Value(isFavorite),
      isDifficult: Value(isDifficult),
      againCount: Value(againCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory FlashcardsLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardsLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      hint: serializer.fromJson<String?>(json['hint']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      interval: serializer.fromJson<int>(json['interval']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      stability: serializer.fromJson<double?>(json['stability']),
      difficulty: serializer.fromJson<double?>(json['difficulty']),
      nextReviewAt: serializer.fromJson<DateTime?>(json['nextReviewAt']),
      lastStudiedAt: serializer.fromJson<DateTime?>(json['lastStudiedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isDifficult: serializer.fromJson<bool>(json['isDifficult']),
      againCount: serializer.fromJson<int>(json['againCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'hint': serializer.toJson<String?>(hint),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'interval': serializer.toJson<int>(interval),
      'repetitions': serializer.toJson<int>(repetitions),
      'stability': serializer.toJson<double?>(stability),
      'difficulty': serializer.toJson<double?>(difficulty),
      'nextReviewAt': serializer.toJson<DateTime?>(nextReviewAt),
      'lastStudiedAt': serializer.toJson<DateTime?>(lastStudiedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isDifficult': serializer.toJson<bool>(isDifficult),
      'againCount': serializer.toJson<int>(againCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FlashcardsLocalTableData copyWith(
          {String? id,
          String? deckId,
          String? front,
          String? back,
          Value<String?> hint = const Value.absent(),
          double? easeFactor,
          int? interval,
          int? repetitions,
          Value<double?> stability = const Value.absent(),
          Value<double?> difficulty = const Value.absent(),
          Value<DateTime?> nextReviewAt = const Value.absent(),
          Value<DateTime?> lastStudiedAt = const Value.absent(),
          bool? isFavorite,
          bool? isDifficult,
          int? againCount,
          DateTime? updatedAt}) =>
      FlashcardsLocalTableData(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        front: front ?? this.front,
        back: back ?? this.back,
        hint: hint.present ? hint.value : this.hint,
        easeFactor: easeFactor ?? this.easeFactor,
        interval: interval ?? this.interval,
        repetitions: repetitions ?? this.repetitions,
        stability: stability.present ? stability.value : this.stability,
        difficulty: difficulty.present ? difficulty.value : this.difficulty,
        nextReviewAt:
            nextReviewAt.present ? nextReviewAt.value : this.nextReviewAt,
        lastStudiedAt:
            lastStudiedAt.present ? lastStudiedAt.value : this.lastStudiedAt,
        isFavorite: isFavorite ?? this.isFavorite,
        isDifficult: isDifficult ?? this.isDifficult,
        againCount: againCount ?? this.againCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FlashcardsLocalTableData copyWithCompanion(
      FlashcardsLocalTableCompanion data) {
    return FlashcardsLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      hint: data.hint.present ? data.hint.value : this.hint,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      interval: data.interval.present ? data.interval.value : this.interval,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isDifficult:
          data.isDifficult.present ? data.isDifficult.value : this.isDifficult,
      againCount:
          data.againCount.present ? data.againCount.value : this.againCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsLocalTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isDifficult: $isDifficult, ')
          ..write('againCount: $againCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deckId,
      front,
      back,
      hint,
      easeFactor,
      interval,
      repetitions,
      stability,
      difficulty,
      nextReviewAt,
      lastStudiedAt,
      isFavorite,
      isDifficult,
      againCount,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardsLocalTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.front == this.front &&
          other.back == this.back &&
          other.hint == this.hint &&
          other.easeFactor == this.easeFactor &&
          other.interval == this.interval &&
          other.repetitions == this.repetitions &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.nextReviewAt == this.nextReviewAt &&
          other.lastStudiedAt == this.lastStudiedAt &&
          other.isFavorite == this.isFavorite &&
          other.isDifficult == this.isDifficult &&
          other.againCount == this.againCount &&
          other.updatedAt == this.updatedAt);
}

class FlashcardsLocalTableCompanion
    extends UpdateCompanion<FlashcardsLocalTableData> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> hint;
  final Value<double> easeFactor;
  final Value<int> interval;
  final Value<int> repetitions;
  final Value<double?> stability;
  final Value<double?> difficulty;
  final Value<DateTime?> nextReviewAt;
  final Value<DateTime?> lastStudiedAt;
  final Value<bool> isFavorite;
  final Value<bool> isDifficult;
  final Value<int> againCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FlashcardsLocalTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.hint = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isDifficult = const Value.absent(),
    this.againCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardsLocalTableCompanion.insert({
    required String id,
    required String deckId,
    required String front,
    required String back,
    this.hint = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isDifficult = const Value.absent(),
    this.againCount = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deckId = Value(deckId),
        front = Value(front),
        back = Value(back),
        updatedAt = Value(updatedAt);
  static Insertable<FlashcardsLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? hint,
    Expression<double>? easeFactor,
    Expression<int>? interval,
    Expression<int>? repetitions,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? nextReviewAt,
    Expression<DateTime>? lastStudiedAt,
    Expression<bool>? isFavorite,
    Expression<bool>? isDifficult,
    Expression<int>? againCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (hint != null) 'hint': hint,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (interval != null) 'interval': interval,
      if (repetitions != null) 'repetitions': repetitions,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isDifficult != null) 'is_difficult': isDifficult,
      if (againCount != null) 'again_count': againCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardsLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deckId,
      Value<String>? front,
      Value<String>? back,
      Value<String?>? hint,
      Value<double>? easeFactor,
      Value<int>? interval,
      Value<int>? repetitions,
      Value<double?>? stability,
      Value<double?>? difficulty,
      Value<DateTime?>? nextReviewAt,
      Value<DateTime?>? lastStudiedAt,
      Value<bool>? isFavorite,
      Value<bool>? isDifficult,
      Value<int>? againCount,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FlashcardsLocalTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isDifficult: isDifficult ?? this.isDifficult,
      againCount: againCount ?? this.againCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isDifficult.present) {
      map['is_difficult'] = Variable<bool>(isDifficult.value);
    }
    if (againCount.present) {
      map['again_count'] = Variable<int>(againCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isDifficult: $isDifficult, ')
          ..write('againCount: $againCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingGradesTableTable extends PendingGradesTable
    with TableInfo<$PendingGradesTableTable, PendingGradesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingGradesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
      'grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newEaseFactorMeta =
      const VerificationMeta('newEaseFactor');
  @override
  late final GeneratedColumn<double> newEaseFactor = GeneratedColumn<double>(
      'new_ease_factor', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _newIntervalMeta =
      const VerificationMeta('newInterval');
  @override
  late final GeneratedColumn<int> newInterval = GeneratedColumn<int>(
      'new_interval', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newRepetitionsMeta =
      const VerificationMeta('newRepetitions');
  @override
  late final GeneratedColumn<int> newRepetitions = GeneratedColumn<int>(
      'new_repetitions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newStabilityMeta =
      const VerificationMeta('newStability');
  @override
  late final GeneratedColumn<double> newStability = GeneratedColumn<double>(
      'new_stability', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _newDifficultyMeta =
      const VerificationMeta('newDifficulty');
  @override
  late final GeneratedColumn<double> newDifficulty = GeneratedColumn<double>(
      'new_difficulty', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _nextReviewAtMeta =
      const VerificationMeta('nextReviewAt');
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
      'next_review_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _gradedAtMeta =
      const VerificationMeta('gradedAt');
  @override
  late final GeneratedColumn<DateTime> gradedAt = GeneratedColumn<DateTime>(
      'graded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardId,
        deckId,
        grade,
        newEaseFactor,
        newInterval,
        newRepetitions,
        newStability,
        newDifficulty,
        nextReviewAt,
        gradedAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_grades';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingGradesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('new_ease_factor')) {
      context.handle(
          _newEaseFactorMeta,
          newEaseFactor.isAcceptableOrUnknown(
              data['new_ease_factor']!, _newEaseFactorMeta));
    } else if (isInserting) {
      context.missing(_newEaseFactorMeta);
    }
    if (data.containsKey('new_interval')) {
      context.handle(
          _newIntervalMeta,
          newInterval.isAcceptableOrUnknown(
              data['new_interval']!, _newIntervalMeta));
    } else if (isInserting) {
      context.missing(_newIntervalMeta);
    }
    if (data.containsKey('new_repetitions')) {
      context.handle(
          _newRepetitionsMeta,
          newRepetitions.isAcceptableOrUnknown(
              data['new_repetitions']!, _newRepetitionsMeta));
    } else if (isInserting) {
      context.missing(_newRepetitionsMeta);
    }
    if (data.containsKey('new_stability')) {
      context.handle(
          _newStabilityMeta,
          newStability.isAcceptableOrUnknown(
              data['new_stability']!, _newStabilityMeta));
    }
    if (data.containsKey('new_difficulty')) {
      context.handle(
          _newDifficultyMeta,
          newDifficulty.isAcceptableOrUnknown(
              data['new_difficulty']!, _newDifficultyMeta));
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
          _nextReviewAtMeta,
          nextReviewAt.isAcceptableOrUnknown(
              data['next_review_at']!, _nextReviewAtMeta));
    } else if (isInserting) {
      context.missing(_nextReviewAtMeta);
    }
    if (data.containsKey('graded_at')) {
      context.handle(_gradedAtMeta,
          gradedAt.isAcceptableOrUnknown(data['graded_at']!, _gradedAtMeta));
    } else if (isInserting) {
      context.missing(_gradedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingGradesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingGradesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grade'])!,
      newEaseFactor: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}new_ease_factor'])!,
      newInterval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_interval'])!,
      newRepetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_repetitions'])!,
      newStability: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}new_stability']),
      newDifficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}new_difficulty']),
      nextReviewAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_at'])!,
      gradedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}graded_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $PendingGradesTableTable createAlias(String alias) {
    return $PendingGradesTableTable(attachedDatabase, alias);
  }
}

class PendingGradesTableData extends DataClass
    implements Insertable<PendingGradesTableData> {
  final int id;
  final String cardId;
  final String deckId;
  final int grade;
  final double newEaseFactor;
  final int newInterval;
  final int newRepetitions;
  final double? newStability;
  final double? newDifficulty;
  final DateTime nextReviewAt;
  final DateTime gradedAt;
  final bool synced;
  const PendingGradesTableData(
      {required this.id,
      required this.cardId,
      required this.deckId,
      required this.grade,
      required this.newEaseFactor,
      required this.newInterval,
      required this.newRepetitions,
      this.newStability,
      this.newDifficulty,
      required this.nextReviewAt,
      required this.gradedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['deck_id'] = Variable<String>(deckId);
    map['grade'] = Variable<int>(grade);
    map['new_ease_factor'] = Variable<double>(newEaseFactor);
    map['new_interval'] = Variable<int>(newInterval);
    map['new_repetitions'] = Variable<int>(newRepetitions);
    if (!nullToAbsent || newStability != null) {
      map['new_stability'] = Variable<double>(newStability);
    }
    if (!nullToAbsent || newDifficulty != null) {
      map['new_difficulty'] = Variable<double>(newDifficulty);
    }
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    map['graded_at'] = Variable<DateTime>(gradedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  PendingGradesTableCompanion toCompanion(bool nullToAbsent) {
    return PendingGradesTableCompanion(
      id: Value(id),
      cardId: Value(cardId),
      deckId: Value(deckId),
      grade: Value(grade),
      newEaseFactor: Value(newEaseFactor),
      newInterval: Value(newInterval),
      newRepetitions: Value(newRepetitions),
      newStability: newStability == null && nullToAbsent
          ? const Value.absent()
          : Value(newStability),
      newDifficulty: newDifficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(newDifficulty),
      nextReviewAt: Value(nextReviewAt),
      gradedAt: Value(gradedAt),
      synced: Value(synced),
    );
  }

  factory PendingGradesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingGradesTableData(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      deckId: serializer.fromJson<String>(json['deckId']),
      grade: serializer.fromJson<int>(json['grade']),
      newEaseFactor: serializer.fromJson<double>(json['newEaseFactor']),
      newInterval: serializer.fromJson<int>(json['newInterval']),
      newRepetitions: serializer.fromJson<int>(json['newRepetitions']),
      newStability: serializer.fromJson<double?>(json['newStability']),
      newDifficulty: serializer.fromJson<double?>(json['newDifficulty']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
      gradedAt: serializer.fromJson<DateTime>(json['gradedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'deckId': serializer.toJson<String>(deckId),
      'grade': serializer.toJson<int>(grade),
      'newEaseFactor': serializer.toJson<double>(newEaseFactor),
      'newInterval': serializer.toJson<int>(newInterval),
      'newRepetitions': serializer.toJson<int>(newRepetitions),
      'newStability': serializer.toJson<double?>(newStability),
      'newDifficulty': serializer.toJson<double?>(newDifficulty),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
      'gradedAt': serializer.toJson<DateTime>(gradedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  PendingGradesTableData copyWith(
          {int? id,
          String? cardId,
          String? deckId,
          int? grade,
          double? newEaseFactor,
          int? newInterval,
          int? newRepetitions,
          Value<double?> newStability = const Value.absent(),
          Value<double?> newDifficulty = const Value.absent(),
          DateTime? nextReviewAt,
          DateTime? gradedAt,
          bool? synced}) =>
      PendingGradesTableData(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        deckId: deckId ?? this.deckId,
        grade: grade ?? this.grade,
        newEaseFactor: newEaseFactor ?? this.newEaseFactor,
        newInterval: newInterval ?? this.newInterval,
        newRepetitions: newRepetitions ?? this.newRepetitions,
        newStability:
            newStability.present ? newStability.value : this.newStability,
        newDifficulty:
            newDifficulty.present ? newDifficulty.value : this.newDifficulty,
        nextReviewAt: nextReviewAt ?? this.nextReviewAt,
        gradedAt: gradedAt ?? this.gradedAt,
        synced: synced ?? this.synced,
      );
  PendingGradesTableData copyWithCompanion(PendingGradesTableCompanion data) {
    return PendingGradesTableData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      grade: data.grade.present ? data.grade.value : this.grade,
      newEaseFactor: data.newEaseFactor.present
          ? data.newEaseFactor.value
          : this.newEaseFactor,
      newInterval:
          data.newInterval.present ? data.newInterval.value : this.newInterval,
      newRepetitions: data.newRepetitions.present
          ? data.newRepetitions.value
          : this.newRepetitions,
      newStability: data.newStability.present
          ? data.newStability.value
          : this.newStability,
      newDifficulty: data.newDifficulty.present
          ? data.newDifficulty.value
          : this.newDifficulty,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      gradedAt: data.gradedAt.present ? data.gradedAt.value : this.gradedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingGradesTableData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('deckId: $deckId, ')
          ..write('grade: $grade, ')
          ..write('newEaseFactor: $newEaseFactor, ')
          ..write('newInterval: $newInterval, ')
          ..write('newRepetitions: $newRepetitions, ')
          ..write('newStability: $newStability, ')
          ..write('newDifficulty: $newDifficulty, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('gradedAt: $gradedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cardId,
      deckId,
      grade,
      newEaseFactor,
      newInterval,
      newRepetitions,
      newStability,
      newDifficulty,
      nextReviewAt,
      gradedAt,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingGradesTableData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.deckId == this.deckId &&
          other.grade == this.grade &&
          other.newEaseFactor == this.newEaseFactor &&
          other.newInterval == this.newInterval &&
          other.newRepetitions == this.newRepetitions &&
          other.newStability == this.newStability &&
          other.newDifficulty == this.newDifficulty &&
          other.nextReviewAt == this.nextReviewAt &&
          other.gradedAt == this.gradedAt &&
          other.synced == this.synced);
}

class PendingGradesTableCompanion
    extends UpdateCompanion<PendingGradesTableData> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<String> deckId;
  final Value<int> grade;
  final Value<double> newEaseFactor;
  final Value<int> newInterval;
  final Value<int> newRepetitions;
  final Value<double?> newStability;
  final Value<double?> newDifficulty;
  final Value<DateTime> nextReviewAt;
  final Value<DateTime> gradedAt;
  final Value<bool> synced;
  const PendingGradesTableCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.grade = const Value.absent(),
    this.newEaseFactor = const Value.absent(),
    this.newInterval = const Value.absent(),
    this.newRepetitions = const Value.absent(),
    this.newStability = const Value.absent(),
    this.newDifficulty = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.gradedAt = const Value.absent(),
    this.synced = const Value.absent(),
  });
  PendingGradesTableCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required String deckId,
    required int grade,
    required double newEaseFactor,
    required int newInterval,
    required int newRepetitions,
    this.newStability = const Value.absent(),
    this.newDifficulty = const Value.absent(),
    required DateTime nextReviewAt,
    required DateTime gradedAt,
    this.synced = const Value.absent(),
  })  : cardId = Value(cardId),
        deckId = Value(deckId),
        grade = Value(grade),
        newEaseFactor = Value(newEaseFactor),
        newInterval = Value(newInterval),
        newRepetitions = Value(newRepetitions),
        nextReviewAt = Value(nextReviewAt),
        gradedAt = Value(gradedAt);
  static Insertable<PendingGradesTableData> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<String>? deckId,
    Expression<int>? grade,
    Expression<double>? newEaseFactor,
    Expression<int>? newInterval,
    Expression<int>? newRepetitions,
    Expression<double>? newStability,
    Expression<double>? newDifficulty,
    Expression<DateTime>? nextReviewAt,
    Expression<DateTime>? gradedAt,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (deckId != null) 'deck_id': deckId,
      if (grade != null) 'grade': grade,
      if (newEaseFactor != null) 'new_ease_factor': newEaseFactor,
      if (newInterval != null) 'new_interval': newInterval,
      if (newRepetitions != null) 'new_repetitions': newRepetitions,
      if (newStability != null) 'new_stability': newStability,
      if (newDifficulty != null) 'new_difficulty': newDifficulty,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (gradedAt != null) 'graded_at': gradedAt,
      if (synced != null) 'synced': synced,
    });
  }

  PendingGradesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? cardId,
      Value<String>? deckId,
      Value<int>? grade,
      Value<double>? newEaseFactor,
      Value<int>? newInterval,
      Value<int>? newRepetitions,
      Value<double?>? newStability,
      Value<double?>? newDifficulty,
      Value<DateTime>? nextReviewAt,
      Value<DateTime>? gradedAt,
      Value<bool>? synced}) {
    return PendingGradesTableCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      deckId: deckId ?? this.deckId,
      grade: grade ?? this.grade,
      newEaseFactor: newEaseFactor ?? this.newEaseFactor,
      newInterval: newInterval ?? this.newInterval,
      newRepetitions: newRepetitions ?? this.newRepetitions,
      newStability: newStability ?? this.newStability,
      newDifficulty: newDifficulty ?? this.newDifficulty,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      gradedAt: gradedAt ?? this.gradedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (newEaseFactor.present) {
      map['new_ease_factor'] = Variable<double>(newEaseFactor.value);
    }
    if (newInterval.present) {
      map['new_interval'] = Variable<int>(newInterval.value);
    }
    if (newRepetitions.present) {
      map['new_repetitions'] = Variable<int>(newRepetitions.value);
    }
    if (newStability.present) {
      map['new_stability'] = Variable<double>(newStability.value);
    }
    if (newDifficulty.present) {
      map['new_difficulty'] = Variable<double>(newDifficulty.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (gradedAt.present) {
      map['graded_at'] = Variable<DateTime>(gradedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingGradesTableCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('deckId: $deckId, ')
          ..write('grade: $grade, ')
          ..write('newEaseFactor: $newEaseFactor, ')
          ..write('newInterval: $newInterval, ')
          ..write('newRepetitions: $newRepetitions, ')
          ..write('newStability: $newStability, ')
          ..write('newDifficulty: $newDifficulty, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('gradedAt: $gradedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsLocalTableTable extends StudySessionsLocalTable
    with TableInfo<$StudySessionsLocalTableTable, StudySessionsLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalCardsMeta =
      const VerificationMeta('totalCards');
  @override
  late final GeneratedColumn<int> totalCards = GeneratedColumn<int>(
      'total_cards', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _newCardsMeta =
      const VerificationMeta('newCards');
  @override
  late final GeneratedColumn<int> newCards = GeneratedColumn<int>(
      'new_cards', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reviewCardsMeta =
      const VerificationMeta('reviewCards');
  @override
  late final GeneratedColumn<int> reviewCards = GeneratedColumn<int>(
      'review_cards', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _againCountMeta =
      const VerificationMeta('againCount');
  @override
  late final GeneratedColumn<int> againCount = GeneratedColumn<int>(
      'again_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hardCountMeta =
      const VerificationMeta('hardCount');
  @override
  late final GeneratedColumn<int> hardCount = GeneratedColumn<int>(
      'hard_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _goodCountMeta =
      const VerificationMeta('goodCount');
  @override
  late final GeneratedColumn<int> goodCount = GeneratedColumn<int>(
      'good_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _easyCountMeta =
      const VerificationMeta('easyCount');
  @override
  late final GeneratedColumn<int> easyCount = GeneratedColumn<int>(
      'easy_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deckId,
        totalCards,
        newCards,
        reviewCards,
        againCount,
        hardCount,
        goodCount,
        easyCount,
        durationSeconds,
        completedAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<StudySessionsLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('total_cards')) {
      context.handle(
          _totalCardsMeta,
          totalCards.isAcceptableOrUnknown(
              data['total_cards']!, _totalCardsMeta));
    } else if (isInserting) {
      context.missing(_totalCardsMeta);
    }
    if (data.containsKey('new_cards')) {
      context.handle(_newCardsMeta,
          newCards.isAcceptableOrUnknown(data['new_cards']!, _newCardsMeta));
    } else if (isInserting) {
      context.missing(_newCardsMeta);
    }
    if (data.containsKey('review_cards')) {
      context.handle(
          _reviewCardsMeta,
          reviewCards.isAcceptableOrUnknown(
              data['review_cards']!, _reviewCardsMeta));
    } else if (isInserting) {
      context.missing(_reviewCardsMeta);
    }
    if (data.containsKey('again_count')) {
      context.handle(
          _againCountMeta,
          againCount.isAcceptableOrUnknown(
              data['again_count']!, _againCountMeta));
    } else if (isInserting) {
      context.missing(_againCountMeta);
    }
    if (data.containsKey('hard_count')) {
      context.handle(_hardCountMeta,
          hardCount.isAcceptableOrUnknown(data['hard_count']!, _hardCountMeta));
    } else if (isInserting) {
      context.missing(_hardCountMeta);
    }
    if (data.containsKey('good_count')) {
      context.handle(_goodCountMeta,
          goodCount.isAcceptableOrUnknown(data['good_count']!, _goodCountMeta));
    } else if (isInserting) {
      context.missing(_goodCountMeta);
    }
    if (data.containsKey('easy_count')) {
      context.handle(_easyCountMeta,
          easyCount.isAcceptableOrUnknown(data['easy_count']!, _easyCountMeta));
    } else if (isInserting) {
      context.missing(_easyCountMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySessionsLocalTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySessionsLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id'])!,
      totalCards: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_cards'])!,
      newCards: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_cards'])!,
      reviewCards: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}review_cards'])!,
      againCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}again_count'])!,
      hardCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hard_count'])!,
      goodCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}good_count'])!,
      easyCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}easy_count'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $StudySessionsLocalTableTable createAlias(String alias) {
    return $StudySessionsLocalTableTable(attachedDatabase, alias);
  }
}

class StudySessionsLocalTableData extends DataClass
    implements Insertable<StudySessionsLocalTableData> {
  final String id;
  final String deckId;
  final int totalCards;
  final int newCards;
  final int reviewCards;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final int durationSeconds;
  final DateTime completedAt;
  final bool synced;
  const StudySessionsLocalTableData(
      {required this.id,
      required this.deckId,
      required this.totalCards,
      required this.newCards,
      required this.reviewCards,
      required this.againCount,
      required this.hardCount,
      required this.goodCount,
      required this.easyCount,
      required this.durationSeconds,
      required this.completedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['total_cards'] = Variable<int>(totalCards);
    map['new_cards'] = Variable<int>(newCards);
    map['review_cards'] = Variable<int>(reviewCards);
    map['again_count'] = Variable<int>(againCount);
    map['hard_count'] = Variable<int>(hardCount);
    map['good_count'] = Variable<int>(goodCount);
    map['easy_count'] = Variable<int>(easyCount);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  StudySessionsLocalTableCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsLocalTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      totalCards: Value(totalCards),
      newCards: Value(newCards),
      reviewCards: Value(reviewCards),
      againCount: Value(againCount),
      hardCount: Value(hardCount),
      goodCount: Value(goodCount),
      easyCount: Value(easyCount),
      durationSeconds: Value(durationSeconds),
      completedAt: Value(completedAt),
      synced: Value(synced),
    );
  }

  factory StudySessionsLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySessionsLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      totalCards: serializer.fromJson<int>(json['totalCards']),
      newCards: serializer.fromJson<int>(json['newCards']),
      reviewCards: serializer.fromJson<int>(json['reviewCards']),
      againCount: serializer.fromJson<int>(json['againCount']),
      hardCount: serializer.fromJson<int>(json['hardCount']),
      goodCount: serializer.fromJson<int>(json['goodCount']),
      easyCount: serializer.fromJson<int>(json['easyCount']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'totalCards': serializer.toJson<int>(totalCards),
      'newCards': serializer.toJson<int>(newCards),
      'reviewCards': serializer.toJson<int>(reviewCards),
      'againCount': serializer.toJson<int>(againCount),
      'hardCount': serializer.toJson<int>(hardCount),
      'goodCount': serializer.toJson<int>(goodCount),
      'easyCount': serializer.toJson<int>(easyCount),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  StudySessionsLocalTableData copyWith(
          {String? id,
          String? deckId,
          int? totalCards,
          int? newCards,
          int? reviewCards,
          int? againCount,
          int? hardCount,
          int? goodCount,
          int? easyCount,
          int? durationSeconds,
          DateTime? completedAt,
          bool? synced}) =>
      StudySessionsLocalTableData(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        totalCards: totalCards ?? this.totalCards,
        newCards: newCards ?? this.newCards,
        reviewCards: reviewCards ?? this.reviewCards,
        againCount: againCount ?? this.againCount,
        hardCount: hardCount ?? this.hardCount,
        goodCount: goodCount ?? this.goodCount,
        easyCount: easyCount ?? this.easyCount,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        completedAt: completedAt ?? this.completedAt,
        synced: synced ?? this.synced,
      );
  StudySessionsLocalTableData copyWithCompanion(
      StudySessionsLocalTableCompanion data) {
    return StudySessionsLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      totalCards:
          data.totalCards.present ? data.totalCards.value : this.totalCards,
      newCards: data.newCards.present ? data.newCards.value : this.newCards,
      reviewCards:
          data.reviewCards.present ? data.reviewCards.value : this.reviewCards,
      againCount:
          data.againCount.present ? data.againCount.value : this.againCount,
      hardCount: data.hardCount.present ? data.hardCount.value : this.hardCount,
      goodCount: data.goodCount.present ? data.goodCount.value : this.goodCount,
      easyCount: data.easyCount.present ? data.easyCount.value : this.easyCount,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsLocalTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('totalCards: $totalCards, ')
          ..write('newCards: $newCards, ')
          ..write('reviewCards: $reviewCards, ')
          ..write('againCount: $againCount, ')
          ..write('hardCount: $hardCount, ')
          ..write('goodCount: $goodCount, ')
          ..write('easyCount: $easyCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deckId,
      totalCards,
      newCards,
      reviewCards,
      againCount,
      hardCount,
      goodCount,
      easyCount,
      durationSeconds,
      completedAt,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySessionsLocalTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.totalCards == this.totalCards &&
          other.newCards == this.newCards &&
          other.reviewCards == this.reviewCards &&
          other.againCount == this.againCount &&
          other.hardCount == this.hardCount &&
          other.goodCount == this.goodCount &&
          other.easyCount == this.easyCount &&
          other.durationSeconds == this.durationSeconds &&
          other.completedAt == this.completedAt &&
          other.synced == this.synced);
}

class StudySessionsLocalTableCompanion
    extends UpdateCompanion<StudySessionsLocalTableData> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<int> totalCards;
  final Value<int> newCards;
  final Value<int> reviewCards;
  final Value<int> againCount;
  final Value<int> hardCount;
  final Value<int> goodCount;
  final Value<int> easyCount;
  final Value<int> durationSeconds;
  final Value<DateTime> completedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const StudySessionsLocalTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.totalCards = const Value.absent(),
    this.newCards = const Value.absent(),
    this.reviewCards = const Value.absent(),
    this.againCount = const Value.absent(),
    this.hardCount = const Value.absent(),
    this.goodCount = const Value.absent(),
    this.easyCount = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsLocalTableCompanion.insert({
    required String id,
    required String deckId,
    required int totalCards,
    required int newCards,
    required int reviewCards,
    required int againCount,
    required int hardCount,
    required int goodCount,
    required int easyCount,
    required int durationSeconds,
    required DateTime completedAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deckId = Value(deckId),
        totalCards = Value(totalCards),
        newCards = Value(newCards),
        reviewCards = Value(reviewCards),
        againCount = Value(againCount),
        hardCount = Value(hardCount),
        goodCount = Value(goodCount),
        easyCount = Value(easyCount),
        durationSeconds = Value(durationSeconds),
        completedAt = Value(completedAt);
  static Insertable<StudySessionsLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<int>? totalCards,
    Expression<int>? newCards,
    Expression<int>? reviewCards,
    Expression<int>? againCount,
    Expression<int>? hardCount,
    Expression<int>? goodCount,
    Expression<int>? easyCount,
    Expression<int>? durationSeconds,
    Expression<DateTime>? completedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (totalCards != null) 'total_cards': totalCards,
      if (newCards != null) 'new_cards': newCards,
      if (reviewCards != null) 'review_cards': reviewCards,
      if (againCount != null) 'again_count': againCount,
      if (hardCount != null) 'hard_count': hardCount,
      if (goodCount != null) 'good_count': goodCount,
      if (easyCount != null) 'easy_count': easyCount,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completedAt != null) 'completed_at': completedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deckId,
      Value<int>? totalCards,
      Value<int>? newCards,
      Value<int>? reviewCards,
      Value<int>? againCount,
      Value<int>? hardCount,
      Value<int>? goodCount,
      Value<int>? easyCount,
      Value<int>? durationSeconds,
      Value<DateTime>? completedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return StudySessionsLocalTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      totalCards: totalCards ?? this.totalCards,
      newCards: newCards ?? this.newCards,
      reviewCards: reviewCards ?? this.reviewCards,
      againCount: againCount ?? this.againCount,
      hardCount: hardCount ?? this.hardCount,
      goodCount: goodCount ?? this.goodCount,
      easyCount: easyCount ?? this.easyCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (totalCards.present) {
      map['total_cards'] = Variable<int>(totalCards.value);
    }
    if (newCards.present) {
      map['new_cards'] = Variable<int>(newCards.value);
    }
    if (reviewCards.present) {
      map['review_cards'] = Variable<int>(reviewCards.value);
    }
    if (againCount.present) {
      map['again_count'] = Variable<int>(againCount.value);
    }
    if (hardCount.present) {
      map['hard_count'] = Variable<int>(hardCount.value);
    }
    if (goodCount.present) {
      map['good_count'] = Variable<int>(goodCount.value);
    }
    if (easyCount.present) {
      map['easy_count'] = Variable<int>(easyCount.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('totalCards: $totalCards, ')
          ..write('newCards: $newCards, ')
          ..write('reviewCards: $reviewCards, ')
          ..write('againCount: $againCount, ')
          ..write('hardCount: $hardCount, ')
          ..write('goodCount: $goodCount, ')
          ..write('easyCount: $easyCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestQuestionsLocalTableTable extends TestQuestionsLocalTable
    with TableInfo<$TestQuestionsLocalTableTable, TestQuestionsLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestQuestionsLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctAnswerMeta =
      const VerificationMeta('correctAnswer');
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
      'correct_answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deckId, question, correctAnswer, optionsJson, topic, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_questions_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<TestQuestionsLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
          _correctAnswerMeta,
          correctAnswer.isAcceptableOrUnknown(
              data['correct_answer']!, _correctAnswerMeta));
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestQuestionsLocalTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestQuestionsLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id'])!,
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question'])!,
      correctAnswer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correct_answer'])!,
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $TestQuestionsLocalTableTable createAlias(String alias) {
    return $TestQuestionsLocalTableTable(attachedDatabase, alias);
  }
}

class TestQuestionsLocalTableData extends DataClass
    implements Insertable<TestQuestionsLocalTableData> {
  final String id;
  final String deckId;
  final String question;
  final String correctAnswer;
  final String optionsJson;
  final String? topic;
  final DateTime cachedAt;
  const TestQuestionsLocalTableData(
      {required this.id,
      required this.deckId,
      required this.question,
      required this.correctAnswer,
      required this.optionsJson,
      this.topic,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['question'] = Variable<String>(question);
    map['correct_answer'] = Variable<String>(correctAnswer);
    map['options_json'] = Variable<String>(optionsJson);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  TestQuestionsLocalTableCompanion toCompanion(bool nullToAbsent) {
    return TestQuestionsLocalTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      question: Value(question),
      correctAnswer: Value(correctAnswer),
      optionsJson: Value(optionsJson),
      topic:
          topic == null && nullToAbsent ? const Value.absent() : Value(topic),
      cachedAt: Value(cachedAt),
    );
  }

  factory TestQuestionsLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestQuestionsLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      question: serializer.fromJson<String>(json['question']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      topic: serializer.fromJson<String?>(json['topic']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'question': serializer.toJson<String>(question),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'topic': serializer.toJson<String?>(topic),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  TestQuestionsLocalTableData copyWith(
          {String? id,
          String? deckId,
          String? question,
          String? correctAnswer,
          String? optionsJson,
          Value<String?> topic = const Value.absent(),
          DateTime? cachedAt}) =>
      TestQuestionsLocalTableData(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        question: question ?? this.question,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        optionsJson: optionsJson ?? this.optionsJson,
        topic: topic.present ? topic.value : this.topic,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  TestQuestionsLocalTableData copyWithCompanion(
      TestQuestionsLocalTableCompanion data) {
    return TestQuestionsLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      question: data.question.present ? data.question.value : this.question,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
      topic: data.topic.present ? data.topic.value : this.topic,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestQuestionsLocalTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('question: $question, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('topic: $topic, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, deckId, question, correctAnswer, optionsJson, topic, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestQuestionsLocalTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.question == this.question &&
          other.correctAnswer == this.correctAnswer &&
          other.optionsJson == this.optionsJson &&
          other.topic == this.topic &&
          other.cachedAt == this.cachedAt);
}

class TestQuestionsLocalTableCompanion
    extends UpdateCompanion<TestQuestionsLocalTableData> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> question;
  final Value<String> correctAnswer;
  final Value<String> optionsJson;
  final Value<String?> topic;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const TestQuestionsLocalTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.question = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.topic = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestQuestionsLocalTableCompanion.insert({
    required String id,
    required String deckId,
    required String question,
    required String correctAnswer,
    required String optionsJson,
    this.topic = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deckId = Value(deckId),
        question = Value(question),
        correctAnswer = Value(correctAnswer),
        optionsJson = Value(optionsJson),
        cachedAt = Value(cachedAt);
  static Insertable<TestQuestionsLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? question,
    Expression<String>? correctAnswer,
    Expression<String>? optionsJson,
    Expression<String>? topic,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (question != null) 'question': question,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (optionsJson != null) 'options_json': optionsJson,
      if (topic != null) 'topic': topic,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestQuestionsLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deckId,
      Value<String>? question,
      Value<String>? correctAnswer,
      Value<String>? optionsJson,
      Value<String?>? topic,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return TestQuestionsLocalTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      optionsJson: optionsJson ?? this.optionsJson,
      topic: topic ?? this.topic,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestQuestionsLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('question: $question, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('topic: $topic, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestResultsLocalTableTable extends TestResultsLocalTable
    with TableInfo<$TestResultsLocalTableTable, TestResultsLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestResultsLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckTitleMeta =
      const VerificationMeta('deckTitle');
  @override
  late final GeneratedColumn<String> deckTitle = GeneratedColumn<String>(
      'deck_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalQuestionsMeta =
      const VerificationMeta('totalQuestions');
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
      'total_questions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _correctCountMeta =
      const VerificationMeta('correctCount');
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
      'correct_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _answersJsonMeta =
      const VerificationMeta('answersJson');
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
      'answers_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionsJsonMeta =
      const VerificationMeta('questionsJson');
  @override
  late final GeneratedColumn<String> questionsJson = GeneratedColumn<String>(
      'questions_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deckId,
        deckTitle,
        totalQuestions,
        correctCount,
        durationSeconds,
        answersJson,
        questionsJson,
        completedAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_results_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<TestResultsLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('deck_title')) {
      context.handle(_deckTitleMeta,
          deckTitle.isAcceptableOrUnknown(data['deck_title']!, _deckTitleMeta));
    } else if (isInserting) {
      context.missing(_deckTitleMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
          _totalQuestionsMeta,
          totalQuestions.isAcceptableOrUnknown(
              data['total_questions']!, _totalQuestionsMeta));
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
          _correctCountMeta,
          correctCount.isAcceptableOrUnknown(
              data['correct_count']!, _correctCountMeta));
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('answers_json')) {
      context.handle(
          _answersJsonMeta,
          answersJson.isAcceptableOrUnknown(
              data['answers_json']!, _answersJsonMeta));
    } else if (isInserting) {
      context.missing(_answersJsonMeta);
    }
    if (data.containsKey('questions_json')) {
      context.handle(
          _questionsJsonMeta,
          questionsJson.isAcceptableOrUnknown(
              data['questions_json']!, _questionsJsonMeta));
    } else if (isInserting) {
      context.missing(_questionsJsonMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestResultsLocalTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestResultsLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id'])!,
      deckTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_title'])!,
      totalQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_questions'])!,
      correctCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_count'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      answersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answers_json'])!,
      questionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}questions_json'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $TestResultsLocalTableTable createAlias(String alias) {
    return $TestResultsLocalTableTable(attachedDatabase, alias);
  }
}

class TestResultsLocalTableData extends DataClass
    implements Insertable<TestResultsLocalTableData> {
  final String id;
  final String deckId;
  final String deckTitle;
  final int totalQuestions;
  final int correctCount;
  final int durationSeconds;
  final String answersJson;
  final String questionsJson;
  final DateTime completedAt;
  final bool synced;
  const TestResultsLocalTableData(
      {required this.id,
      required this.deckId,
      required this.deckTitle,
      required this.totalQuestions,
      required this.correctCount,
      required this.durationSeconds,
      required this.answersJson,
      required this.questionsJson,
      required this.completedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['deck_title'] = Variable<String>(deckTitle);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['correct_count'] = Variable<int>(correctCount);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['answers_json'] = Variable<String>(answersJson);
    map['questions_json'] = Variable<String>(questionsJson);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TestResultsLocalTableCompanion toCompanion(bool nullToAbsent) {
    return TestResultsLocalTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      deckTitle: Value(deckTitle),
      totalQuestions: Value(totalQuestions),
      correctCount: Value(correctCount),
      durationSeconds: Value(durationSeconds),
      answersJson: Value(answersJson),
      questionsJson: Value(questionsJson),
      completedAt: Value(completedAt),
      synced: Value(synced),
    );
  }

  factory TestResultsLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestResultsLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      deckTitle: serializer.fromJson<String>(json['deckTitle']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      questionsJson: serializer.fromJson<String>(json['questionsJson']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'deckTitle': serializer.toJson<String>(deckTitle),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'correctCount': serializer.toJson<int>(correctCount),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'answersJson': serializer.toJson<String>(answersJson),
      'questionsJson': serializer.toJson<String>(questionsJson),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  TestResultsLocalTableData copyWith(
          {String? id,
          String? deckId,
          String? deckTitle,
          int? totalQuestions,
          int? correctCount,
          int? durationSeconds,
          String? answersJson,
          String? questionsJson,
          DateTime? completedAt,
          bool? synced}) =>
      TestResultsLocalTableData(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        deckTitle: deckTitle ?? this.deckTitle,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        correctCount: correctCount ?? this.correctCount,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        answersJson: answersJson ?? this.answersJson,
        questionsJson: questionsJson ?? this.questionsJson,
        completedAt: completedAt ?? this.completedAt,
        synced: synced ?? this.synced,
      );
  TestResultsLocalTableData copyWithCompanion(
      TestResultsLocalTableCompanion data) {
    return TestResultsLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      deckTitle: data.deckTitle.present ? data.deckTitle.value : this.deckTitle,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      answersJson:
          data.answersJson.present ? data.answersJson.value : this.answersJson,
      questionsJson: data.questionsJson.present
          ? data.questionsJson.value
          : this.questionsJson,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsLocalTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('deckTitle: $deckTitle, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctCount: $correctCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('answersJson: $answersJson, ')
          ..write('questionsJson: $questionsJson, ')
          ..write('completedAt: $completedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deckId,
      deckTitle,
      totalQuestions,
      correctCount,
      durationSeconds,
      answersJson,
      questionsJson,
      completedAt,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestResultsLocalTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.deckTitle == this.deckTitle &&
          other.totalQuestions == this.totalQuestions &&
          other.correctCount == this.correctCount &&
          other.durationSeconds == this.durationSeconds &&
          other.answersJson == this.answersJson &&
          other.questionsJson == this.questionsJson &&
          other.completedAt == this.completedAt &&
          other.synced == this.synced);
}

class TestResultsLocalTableCompanion
    extends UpdateCompanion<TestResultsLocalTableData> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> deckTitle;
  final Value<int> totalQuestions;
  final Value<int> correctCount;
  final Value<int> durationSeconds;
  final Value<String> answersJson;
  final Value<String> questionsJson;
  final Value<DateTime> completedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const TestResultsLocalTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.deckTitle = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.questionsJson = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TestResultsLocalTableCompanion.insert({
    required String id,
    required String deckId,
    required String deckTitle,
    required int totalQuestions,
    required int correctCount,
    required int durationSeconds,
    required String answersJson,
    required String questionsJson,
    required DateTime completedAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deckId = Value(deckId),
        deckTitle = Value(deckTitle),
        totalQuestions = Value(totalQuestions),
        correctCount = Value(correctCount),
        durationSeconds = Value(durationSeconds),
        answersJson = Value(answersJson),
        questionsJson = Value(questionsJson),
        completedAt = Value(completedAt);
  static Insertable<TestResultsLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? deckTitle,
    Expression<int>? totalQuestions,
    Expression<int>? correctCount,
    Expression<int>? durationSeconds,
    Expression<String>? answersJson,
    Expression<String>? questionsJson,
    Expression<DateTime>? completedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (deckTitle != null) 'deck_title': deckTitle,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (correctCount != null) 'correct_count': correctCount,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (answersJson != null) 'answers_json': answersJson,
      if (questionsJson != null) 'questions_json': questionsJson,
      if (completedAt != null) 'completed_at': completedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TestResultsLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? deckId,
      Value<String>? deckTitle,
      Value<int>? totalQuestions,
      Value<int>? correctCount,
      Value<int>? durationSeconds,
      Value<String>? answersJson,
      Value<String>? questionsJson,
      Value<DateTime>? completedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return TestResultsLocalTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      deckTitle: deckTitle ?? this.deckTitle,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctCount: correctCount ?? this.correctCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      answersJson: answersJson ?? this.answersJson,
      questionsJson: questionsJson ?? this.questionsJson,
      completedAt: completedAt ?? this.completedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (deckTitle.present) {
      map['deck_title'] = Variable<String>(deckTitle.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (questionsJson.present) {
      map['questions_json'] = Variable<String>(questionsJson.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('deckTitle: $deckTitle, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctCount: $correctCount, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('answersJson: $answersJson, ')
          ..write('questionsJson: $questionsJson, ')
          ..write('completedAt: $completedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsLocalTableTable extends ConversationsLocalTable
    with TableInfo<$ConversationsLocalTableTable, ConversationsLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
      'deck_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deckTitleMeta =
      const VerificationMeta('deckTitle');
  @override
  late final GeneratedColumn<String> deckTitle = GeneratedColumn<String>(
      'deck_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _messageCountMeta =
      const VerificationMeta('messageCount');
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
      'message_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  @override
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>('last_message_preview', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        deckId,
        deckTitle,
        isPinned,
        messageCount,
        lastMessagePreview,
        createdAt,
        updatedAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConversationsLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    }
    if (data.containsKey('deck_title')) {
      context.handle(_deckTitleMeta,
          deckTitle.isAcceptableOrUnknown(data['deck_title']!, _deckTitleMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('message_count')) {
      context.handle(
          _messageCountMeta,
          messageCount.isAcceptableOrUnknown(
              data['message_count']!, _messageCountMeta));
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
          _lastMessagePreviewMeta,
          lastMessagePreview.isAcceptableOrUnknown(
              data['last_message_preview']!, _lastMessagePreviewMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationsLocalTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationsLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_id']),
      deckTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deck_title']),
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      messageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_count'])!,
      lastMessagePreview: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_message_preview']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $ConversationsLocalTableTable createAlias(String alias) {
    return $ConversationsLocalTableTable(attachedDatabase, alias);
  }
}

class ConversationsLocalTableData extends DataClass
    implements Insertable<ConversationsLocalTableData> {
  final String id;
  final String title;
  final String? deckId;
  final String? deckTitle;
  final bool isPinned;
  final int messageCount;
  final String? lastMessagePreview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  const ConversationsLocalTableData(
      {required this.id,
      required this.title,
      this.deckId,
      this.deckTitle,
      required this.isPinned,
      required this.messageCount,
      this.lastMessagePreview,
      required this.createdAt,
      required this.updatedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || deckId != null) {
      map['deck_id'] = Variable<String>(deckId);
    }
    if (!nullToAbsent || deckTitle != null) {
      map['deck_title'] = Variable<String>(deckTitle);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['message_count'] = Variable<int>(messageCount);
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ConversationsLocalTableCompanion toCompanion(bool nullToAbsent) {
    return ConversationsLocalTableCompanion(
      id: Value(id),
      title: Value(title),
      deckId:
          deckId == null && nullToAbsent ? const Value.absent() : Value(deckId),
      deckTitle: deckTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(deckTitle),
      isPinned: Value(isPinned),
      messageCount: Value(messageCount),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory ConversationsLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationsLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      deckId: serializer.fromJson<String?>(json['deckId']),
      deckTitle: serializer.fromJson<String?>(json['deckTitle']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
      lastMessagePreview:
          serializer.fromJson<String?>(json['lastMessagePreview']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'deckId': serializer.toJson<String?>(deckId),
      'deckTitle': serializer.toJson<String?>(deckTitle),
      'isPinned': serializer.toJson<bool>(isPinned),
      'messageCount': serializer.toJson<int>(messageCount),
      'lastMessagePreview': serializer.toJson<String?>(lastMessagePreview),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ConversationsLocalTableData copyWith(
          {String? id,
          String? title,
          Value<String?> deckId = const Value.absent(),
          Value<String?> deckTitle = const Value.absent(),
          bool? isPinned,
          int? messageCount,
          Value<String?> lastMessagePreview = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced}) =>
      ConversationsLocalTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        deckId: deckId.present ? deckId.value : this.deckId,
        deckTitle: deckTitle.present ? deckTitle.value : this.deckTitle,
        isPinned: isPinned ?? this.isPinned,
        messageCount: messageCount ?? this.messageCount,
        lastMessagePreview: lastMessagePreview.present
            ? lastMessagePreview.value
            : this.lastMessagePreview,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
      );
  ConversationsLocalTableData copyWithCompanion(
      ConversationsLocalTableCompanion data) {
    return ConversationsLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      deckTitle: data.deckTitle.present ? data.deckTitle.value : this.deckTitle,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsLocalTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('deckId: $deckId, ')
          ..write('deckTitle: $deckTitle, ')
          ..write('isPinned: $isPinned, ')
          ..write('messageCount: $messageCount, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, deckId, deckTitle, isPinned,
      messageCount, lastMessagePreview, createdAt, updatedAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationsLocalTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.deckId == this.deckId &&
          other.deckTitle == this.deckTitle &&
          other.isPinned == this.isPinned &&
          other.messageCount == this.messageCount &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class ConversationsLocalTableCompanion
    extends UpdateCompanion<ConversationsLocalTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> deckId;
  final Value<String?> deckTitle;
  final Value<bool> isPinned;
  final Value<int> messageCount;
  final Value<String?> lastMessagePreview;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const ConversationsLocalTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.deckId = const Value.absent(),
    this.deckTitle = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsLocalTableCompanion.insert({
    required String id,
    required String title,
    this.deckId = const Value.absent(),
    this.deckTitle = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ConversationsLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? deckId,
    Expression<String>? deckTitle,
    Expression<bool>? isPinned,
    Expression<int>? messageCount,
    Expression<String>? lastMessagePreview,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (deckId != null) 'deck_id': deckId,
      if (deckTitle != null) 'deck_title': deckTitle,
      if (isPinned != null) 'is_pinned': isPinned,
      if (messageCount != null) 'message_count': messageCount,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? deckId,
      Value<String?>? deckTitle,
      Value<bool>? isPinned,
      Value<int>? messageCount,
      Value<String?>? lastMessagePreview,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return ConversationsLocalTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      deckId: deckId ?? this.deckId,
      deckTitle: deckTitle ?? this.deckTitle,
      isPinned: isPinned ?? this.isPinned,
      messageCount: messageCount ?? this.messageCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (deckTitle.present) {
      map['deck_title'] = Variable<String>(deckTitle.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('deckId: $deckId, ')
          ..write('deckTitle: $deckTitle, ')
          ..write('isPinned: $isPinned, ')
          ..write('messageCount: $messageCount, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TutorMessagesLocalTableTable extends TutorMessagesLocalTable
    with TableInfo<$TutorMessagesLocalTableTable, TutorMessagesLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TutorMessagesLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, conversationId, role, content, createdAt, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tutor_messages_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<TutorMessagesLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TutorMessagesLocalTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TutorMessagesLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $TutorMessagesLocalTableTable createAlias(String alias) {
    return $TutorMessagesLocalTableTable(attachedDatabase, alias);
  }
}

class TutorMessagesLocalTableData extends DataClass
    implements Insertable<TutorMessagesLocalTableData> {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool synced;
  const TutorMessagesLocalTableData(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      required this.createdAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  TutorMessagesLocalTableCompanion toCompanion(bool nullToAbsent) {
    return TutorMessagesLocalTableCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      synced: Value(synced),
    );
  }

  factory TutorMessagesLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TutorMessagesLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  TutorMessagesLocalTableData copyWith(
          {String? id,
          String? conversationId,
          String? role,
          String? content,
          DateTime? createdAt,
          bool? synced}) =>
      TutorMessagesLocalTableData(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        synced: synced ?? this.synced,
      );
  TutorMessagesLocalTableData copyWithCompanion(
      TutorMessagesLocalTableCompanion data) {
    return TutorMessagesLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TutorMessagesLocalTableData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, role, content, createdAt, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TutorMessagesLocalTableData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.synced == this.synced);
}

class TutorMessagesLocalTableCompanion
    extends UpdateCompanion<TutorMessagesLocalTableData> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const TutorMessagesLocalTableCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TutorMessagesLocalTableCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    required DateTime createdAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<TutorMessagesLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TutorMessagesLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? role,
      Value<String>? content,
      Value<DateTime>? createdAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return TutorMessagesLocalTableCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TutorMessagesLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GenerationJobsLocalTableTable extends GenerationJobsLocalTable
    with
        TableInfo<$GenerationJobsLocalTableTable,
            GenerationJobsLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenerationJobsLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
      'progress', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _inputTextMeta =
      const VerificationMeta('inputText');
  @override
  late final GeneratedColumn<String> inputText = GeneratedColumn<String>(
      'input_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pdfFileNameMeta =
      const VerificationMeta('pdfFileName');
  @override
  late final GeneratedColumn<String> pdfFileName = GeneratedColumn<String>(
      'pdf_file_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _qualityModeMeta =
      const VerificationMeta('qualityMode');
  @override
  late final GeneratedColumn<String> qualityMode = GeneratedColumn<String>(
      'quality_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requestedCardCountMeta =
      const VerificationMeta('requestedCardCount');
  @override
  late final GeneratedColumn<int> requestedCardCount = GeneratedColumn<int>(
      'requested_card_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _generatedCardsJsonMeta =
      const VerificationMeta('generatedCardsJson');
  @override
  late final GeneratedColumn<String> generatedCardsJson =
      GeneratedColumn<String>('generated_cards_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        source,
        status,
        progress,
        topic,
        inputText,
        pdfFileName,
        qualityMode,
        requestedCardCount,
        generatedCardsJson,
        errorMessage,
        createdAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generation_jobs_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<GenerationJobsLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('input_text')) {
      context.handle(_inputTextMeta,
          inputText.isAcceptableOrUnknown(data['input_text']!, _inputTextMeta));
    }
    if (data.containsKey('pdf_file_name')) {
      context.handle(
          _pdfFileNameMeta,
          pdfFileName.isAcceptableOrUnknown(
              data['pdf_file_name']!, _pdfFileNameMeta));
    }
    if (data.containsKey('quality_mode')) {
      context.handle(
          _qualityModeMeta,
          qualityMode.isAcceptableOrUnknown(
              data['quality_mode']!, _qualityModeMeta));
    } else if (isInserting) {
      context.missing(_qualityModeMeta);
    }
    if (data.containsKey('requested_card_count')) {
      context.handle(
          _requestedCardCountMeta,
          requestedCardCount.isAcceptableOrUnknown(
              data['requested_card_count']!, _requestedCardCountMeta));
    } else if (isInserting) {
      context.missing(_requestedCardCountMeta);
    }
    if (data.containsKey('generated_cards_json')) {
      context.handle(
          _generatedCardsJsonMeta,
          generatedCardsJson.isAcceptableOrUnknown(
              data['generated_cards_json']!, _generatedCardsJsonMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GenerationJobsLocalTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GenerationJobsLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}progress'])!,
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic']),
      inputText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}input_text']),
      pdfFileName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pdf_file_name']),
      qualityMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quality_mode'])!,
      requestedCardCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}requested_card_count'])!,
      generatedCardsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}generated_cards_json']),
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $GenerationJobsLocalTableTable createAlias(String alias) {
    return $GenerationJobsLocalTableTable(attachedDatabase, alias);
  }
}

class GenerationJobsLocalTableData extends DataClass
    implements Insertable<GenerationJobsLocalTableData> {
  final String id;
  final String source;
  final String status;
  final int progress;
  final String? topic;
  final String? inputText;
  final String? pdfFileName;
  final String qualityMode;
  final int requestedCardCount;
  final String? generatedCardsJson;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  const GenerationJobsLocalTableData(
      {required this.id,
      required this.source,
      required this.status,
      required this.progress,
      this.topic,
      this.inputText,
      this.pdfFileName,
      required this.qualityMode,
      required this.requestedCardCount,
      this.generatedCardsJson,
      this.errorMessage,
      required this.createdAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<int>(progress);
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || inputText != null) {
      map['input_text'] = Variable<String>(inputText);
    }
    if (!nullToAbsent || pdfFileName != null) {
      map['pdf_file_name'] = Variable<String>(pdfFileName);
    }
    map['quality_mode'] = Variable<String>(qualityMode);
    map['requested_card_count'] = Variable<int>(requestedCardCount);
    if (!nullToAbsent || generatedCardsJson != null) {
      map['generated_cards_json'] = Variable<String>(generatedCardsJson);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  GenerationJobsLocalTableCompanion toCompanion(bool nullToAbsent) {
    return GenerationJobsLocalTableCompanion(
      id: Value(id),
      source: Value(source),
      status: Value(status),
      progress: Value(progress),
      topic:
          topic == null && nullToAbsent ? const Value.absent() : Value(topic),
      inputText: inputText == null && nullToAbsent
          ? const Value.absent()
          : Value(inputText),
      pdfFileName: pdfFileName == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfFileName),
      qualityMode: Value(qualityMode),
      requestedCardCount: Value(requestedCardCount),
      generatedCardsJson: generatedCardsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(generatedCardsJson),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory GenerationJobsLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GenerationJobsLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<int>(json['progress']),
      topic: serializer.fromJson<String?>(json['topic']),
      inputText: serializer.fromJson<String?>(json['inputText']),
      pdfFileName: serializer.fromJson<String?>(json['pdfFileName']),
      qualityMode: serializer.fromJson<String>(json['qualityMode']),
      requestedCardCount: serializer.fromJson<int>(json['requestedCardCount']),
      generatedCardsJson:
          serializer.fromJson<String?>(json['generatedCardsJson']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<int>(progress),
      'topic': serializer.toJson<String?>(topic),
      'inputText': serializer.toJson<String?>(inputText),
      'pdfFileName': serializer.toJson<String?>(pdfFileName),
      'qualityMode': serializer.toJson<String>(qualityMode),
      'requestedCardCount': serializer.toJson<int>(requestedCardCount),
      'generatedCardsJson': serializer.toJson<String?>(generatedCardsJson),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  GenerationJobsLocalTableData copyWith(
          {String? id,
          String? source,
          String? status,
          int? progress,
          Value<String?> topic = const Value.absent(),
          Value<String?> inputText = const Value.absent(),
          Value<String?> pdfFileName = const Value.absent(),
          String? qualityMode,
          int? requestedCardCount,
          Value<String?> generatedCardsJson = const Value.absent(),
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      GenerationJobsLocalTableData(
        id: id ?? this.id,
        source: source ?? this.source,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        topic: topic.present ? topic.value : this.topic,
        inputText: inputText.present ? inputText.value : this.inputText,
        pdfFileName: pdfFileName.present ? pdfFileName.value : this.pdfFileName,
        qualityMode: qualityMode ?? this.qualityMode,
        requestedCardCount: requestedCardCount ?? this.requestedCardCount,
        generatedCardsJson: generatedCardsJson.present
            ? generatedCardsJson.value
            : this.generatedCardsJson,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  GenerationJobsLocalTableData copyWithCompanion(
      GenerationJobsLocalTableCompanion data) {
    return GenerationJobsLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      topic: data.topic.present ? data.topic.value : this.topic,
      inputText: data.inputText.present ? data.inputText.value : this.inputText,
      pdfFileName:
          data.pdfFileName.present ? data.pdfFileName.value : this.pdfFileName,
      qualityMode:
          data.qualityMode.present ? data.qualityMode.value : this.qualityMode,
      requestedCardCount: data.requestedCardCount.present
          ? data.requestedCardCount.value
          : this.requestedCardCount,
      generatedCardsJson: data.generatedCardsJson.present
          ? data.generatedCardsJson.value
          : this.generatedCardsJson,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GenerationJobsLocalTableData(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('topic: $topic, ')
          ..write('inputText: $inputText, ')
          ..write('pdfFileName: $pdfFileName, ')
          ..write('qualityMode: $qualityMode, ')
          ..write('requestedCardCount: $requestedCardCount, ')
          ..write('generatedCardsJson: $generatedCardsJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      source,
      status,
      progress,
      topic,
      inputText,
      pdfFileName,
      qualityMode,
      requestedCardCount,
      generatedCardsJson,
      errorMessage,
      createdAt,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenerationJobsLocalTableData &&
          other.id == this.id &&
          other.source == this.source &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.topic == this.topic &&
          other.inputText == this.inputText &&
          other.pdfFileName == this.pdfFileName &&
          other.qualityMode == this.qualityMode &&
          other.requestedCardCount == this.requestedCardCount &&
          other.generatedCardsJson == this.generatedCardsJson &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class GenerationJobsLocalTableCompanion
    extends UpdateCompanion<GenerationJobsLocalTableData> {
  final Value<String> id;
  final Value<String> source;
  final Value<String> status;
  final Value<int> progress;
  final Value<String?> topic;
  final Value<String?> inputText;
  final Value<String?> pdfFileName;
  final Value<String> qualityMode;
  final Value<int> requestedCardCount;
  final Value<String?> generatedCardsJson;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const GenerationJobsLocalTableCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.topic = const Value.absent(),
    this.inputText = const Value.absent(),
    this.pdfFileName = const Value.absent(),
    this.qualityMode = const Value.absent(),
    this.requestedCardCount = const Value.absent(),
    this.generatedCardsJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GenerationJobsLocalTableCompanion.insert({
    required String id,
    required String source,
    required String status,
    this.progress = const Value.absent(),
    this.topic = const Value.absent(),
    this.inputText = const Value.absent(),
    this.pdfFileName = const Value.absent(),
    required String qualityMode,
    required int requestedCardCount,
    this.generatedCardsJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        source = Value(source),
        status = Value(status),
        qualityMode = Value(qualityMode),
        requestedCardCount = Value(requestedCardCount),
        createdAt = Value(createdAt);
  static Insertable<GenerationJobsLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? status,
    Expression<int>? progress,
    Expression<String>? topic,
    Expression<String>? inputText,
    Expression<String>? pdfFileName,
    Expression<String>? qualityMode,
    Expression<int>? requestedCardCount,
    Expression<String>? generatedCardsJson,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (topic != null) 'topic': topic,
      if (inputText != null) 'input_text': inputText,
      if (pdfFileName != null) 'pdf_file_name': pdfFileName,
      if (qualityMode != null) 'quality_mode': qualityMode,
      if (requestedCardCount != null)
        'requested_card_count': requestedCardCount,
      if (generatedCardsJson != null)
        'generated_cards_json': generatedCardsJson,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GenerationJobsLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? source,
      Value<String>? status,
      Value<int>? progress,
      Value<String?>? topic,
      Value<String?>? inputText,
      Value<String?>? pdfFileName,
      Value<String>? qualityMode,
      Value<int>? requestedCardCount,
      Value<String?>? generatedCardsJson,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return GenerationJobsLocalTableCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      topic: topic ?? this.topic,
      inputText: inputText ?? this.inputText,
      pdfFileName: pdfFileName ?? this.pdfFileName,
      qualityMode: qualityMode ?? this.qualityMode,
      requestedCardCount: requestedCardCount ?? this.requestedCardCount,
      generatedCardsJson: generatedCardsJson ?? this.generatedCardsJson,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (inputText.present) {
      map['input_text'] = Variable<String>(inputText.value);
    }
    if (pdfFileName.present) {
      map['pdf_file_name'] = Variable<String>(pdfFileName.value);
    }
    if (qualityMode.present) {
      map['quality_mode'] = Variable<String>(qualityMode.value);
    }
    if (requestedCardCount.present) {
      map['requested_card_count'] = Variable<int>(requestedCardCount.value);
    }
    if (generatedCardsJson.present) {
      map['generated_cards_json'] = Variable<String>(generatedCardsJson.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenerationJobsLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('topic: $topic, ')
          ..write('inputText: $inputText, ')
          ..write('pdfFileName: $pdfFileName, ')
          ..write('qualityMode: $qualityMode, ')
          ..write('requestedCardCount: $requestedCardCount, ')
          ..write('generatedCardsJson: $generatedCardsJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FlashcardsLocalTableTable flashcardsLocalTable =
      $FlashcardsLocalTableTable(this);
  late final $PendingGradesTableTable pendingGradesTable =
      $PendingGradesTableTable(this);
  late final $StudySessionsLocalTableTable studySessionsLocalTable =
      $StudySessionsLocalTableTable(this);
  late final $TestQuestionsLocalTableTable testQuestionsLocalTable =
      $TestQuestionsLocalTableTable(this);
  late final $TestResultsLocalTableTable testResultsLocalTable =
      $TestResultsLocalTableTable(this);
  late final $ConversationsLocalTableTable conversationsLocalTable =
      $ConversationsLocalTableTable(this);
  late final $TutorMessagesLocalTableTable tutorMessagesLocalTable =
      $TutorMessagesLocalTableTable(this);
  late final $GenerationJobsLocalTableTable generationJobsLocalTable =
      $GenerationJobsLocalTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        flashcardsLocalTable,
        pendingGradesTable,
        studySessionsLocalTable,
        testQuestionsLocalTable,
        testResultsLocalTable,
        conversationsLocalTable,
        tutorMessagesLocalTable,
        generationJobsLocalTable
      ];
}

typedef $$FlashcardsLocalTableTableCreateCompanionBuilder
    = FlashcardsLocalTableCompanion Function({
  required String id,
  required String deckId,
  required String front,
  required String back,
  Value<String?> hint,
  Value<double> easeFactor,
  Value<int> interval,
  Value<int> repetitions,
  Value<double?> stability,
  Value<double?> difficulty,
  Value<DateTime?> nextReviewAt,
  Value<DateTime?> lastStudiedAt,
  Value<bool> isFavorite,
  Value<bool> isDifficult,
  Value<int> againCount,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FlashcardsLocalTableTableUpdateCompanionBuilder
    = FlashcardsLocalTableCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<String> front,
  Value<String> back,
  Value<String?> hint,
  Value<double> easeFactor,
  Value<int> interval,
  Value<int> repetitions,
  Value<double?> stability,
  Value<double?> difficulty,
  Value<DateTime?> nextReviewAt,
  Value<DateTime?> lastStudiedAt,
  Value<bool> isFavorite,
  Value<bool> isDifficult,
  Value<int> againCount,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FlashcardsLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsLocalTableTable> {
  $$FlashcardsLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDifficult => $composableBuilder(
      column: $table.isDifficult, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get againCount => $composableBuilder(
      column: $table.againCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FlashcardsLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsLocalTableTable> {
  $$FlashcardsLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stability => $composableBuilder(
      column: $table.stability, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDifficult => $composableBuilder(
      column: $table.isDifficult, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get againCount => $composableBuilder(
      column: $table.againCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FlashcardsLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsLocalTableTable> {
  $$FlashcardsLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isDifficult => $composableBuilder(
      column: $table.isDifficult, builder: (column) => column);

  GeneratedColumn<int> get againCount => $composableBuilder(
      column: $table.againCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FlashcardsLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardsLocalTableTable,
    FlashcardsLocalTableData,
    $$FlashcardsLocalTableTableFilterComposer,
    $$FlashcardsLocalTableTableOrderingComposer,
    $$FlashcardsLocalTableTableAnnotationComposer,
    $$FlashcardsLocalTableTableCreateCompanionBuilder,
    $$FlashcardsLocalTableTableUpdateCompanionBuilder,
    (
      FlashcardsLocalTableData,
      BaseReferences<_$AppDatabase, $FlashcardsLocalTableTable,
          FlashcardsLocalTableData>
    ),
    FlashcardsLocalTableData,
    PrefetchHooks Function()> {
  $$FlashcardsLocalTableTableTableManager(
      _$AppDatabase db, $FlashcardsLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsLocalTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsLocalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deckId = const Value.absent(),
            Value<String> front = const Value.absent(),
            Value<String> back = const Value.absent(),
            Value<String?> hint = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<double?> stability = const Value.absent(),
            Value<double?> difficulty = const Value.absent(),
            Value<DateTime?> nextReviewAt = const Value.absent(),
            Value<DateTime?> lastStudiedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isDifficult = const Value.absent(),
            Value<int> againCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardsLocalTableCompanion(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            hint: hint,
            easeFactor: easeFactor,
            interval: interval,
            repetitions: repetitions,
            stability: stability,
            difficulty: difficulty,
            nextReviewAt: nextReviewAt,
            lastStudiedAt: lastStudiedAt,
            isFavorite: isFavorite,
            isDifficult: isDifficult,
            againCount: againCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deckId,
            required String front,
            required String back,
            Value<String?> hint = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<double?> stability = const Value.absent(),
            Value<double?> difficulty = const Value.absent(),
            Value<DateTime?> nextReviewAt = const Value.absent(),
            Value<DateTime?> lastStudiedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isDifficult = const Value.absent(),
            Value<int> againCount = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardsLocalTableCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            hint: hint,
            easeFactor: easeFactor,
            interval: interval,
            repetitions: repetitions,
            stability: stability,
            difficulty: difficulty,
            nextReviewAt: nextReviewAt,
            lastStudiedAt: lastStudiedAt,
            isFavorite: isFavorite,
            isDifficult: isDifficult,
            againCount: againCount,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FlashcardsLocalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $FlashcardsLocalTableTable,
        FlashcardsLocalTableData,
        $$FlashcardsLocalTableTableFilterComposer,
        $$FlashcardsLocalTableTableOrderingComposer,
        $$FlashcardsLocalTableTableAnnotationComposer,
        $$FlashcardsLocalTableTableCreateCompanionBuilder,
        $$FlashcardsLocalTableTableUpdateCompanionBuilder,
        (
          FlashcardsLocalTableData,
          BaseReferences<_$AppDatabase, $FlashcardsLocalTableTable,
              FlashcardsLocalTableData>
        ),
        FlashcardsLocalTableData,
        PrefetchHooks Function()>;
typedef $$PendingGradesTableTableCreateCompanionBuilder
    = PendingGradesTableCompanion Function({
  Value<int> id,
  required String cardId,
  required String deckId,
  required int grade,
  required double newEaseFactor,
  required int newInterval,
  required int newRepetitions,
  Value<double?> newStability,
  Value<double?> newDifficulty,
  required DateTime nextReviewAt,
  required DateTime gradedAt,
  Value<bool> synced,
});
typedef $$PendingGradesTableTableUpdateCompanionBuilder
    = PendingGradesTableCompanion Function({
  Value<int> id,
  Value<String> cardId,
  Value<String> deckId,
  Value<int> grade,
  Value<double> newEaseFactor,
  Value<int> newInterval,
  Value<int> newRepetitions,
  Value<double?> newStability,
  Value<double?> newDifficulty,
  Value<DateTime> nextReviewAt,
  Value<DateTime> gradedAt,
  Value<bool> synced,
});

class $$PendingGradesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingGradesTableTable> {
  $$PendingGradesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get newEaseFactor => $composableBuilder(
      column: $table.newEaseFactor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newInterval => $composableBuilder(
      column: $table.newInterval, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newRepetitions => $composableBuilder(
      column: $table.newRepetitions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get newStability => $composableBuilder(
      column: $table.newStability, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get newDifficulty => $composableBuilder(
      column: $table.newDifficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get gradedAt => $composableBuilder(
      column: $table.gradedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$PendingGradesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingGradesTableTable> {
  $$PendingGradesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get newEaseFactor => $composableBuilder(
      column: $table.newEaseFactor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newInterval => $composableBuilder(
      column: $table.newInterval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newRepetitions => $composableBuilder(
      column: $table.newRepetitions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get newStability => $composableBuilder(
      column: $table.newStability,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get newDifficulty => $composableBuilder(
      column: $table.newDifficulty,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get gradedAt => $composableBuilder(
      column: $table.gradedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$PendingGradesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingGradesTableTable> {
  $$PendingGradesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<double> get newEaseFactor => $composableBuilder(
      column: $table.newEaseFactor, builder: (column) => column);

  GeneratedColumn<int> get newInterval => $composableBuilder(
      column: $table.newInterval, builder: (column) => column);

  GeneratedColumn<int> get newRepetitions => $composableBuilder(
      column: $table.newRepetitions, builder: (column) => column);

  GeneratedColumn<double> get newStability => $composableBuilder(
      column: $table.newStability, builder: (column) => column);

  GeneratedColumn<double> get newDifficulty => $composableBuilder(
      column: $table.newDifficulty, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => column);

  GeneratedColumn<DateTime> get gradedAt =>
      $composableBuilder(column: $table.gradedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$PendingGradesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingGradesTableTable,
    PendingGradesTableData,
    $$PendingGradesTableTableFilterComposer,
    $$PendingGradesTableTableOrderingComposer,
    $$PendingGradesTableTableAnnotationComposer,
    $$PendingGradesTableTableCreateCompanionBuilder,
    $$PendingGradesTableTableUpdateCompanionBuilder,
    (
      PendingGradesTableData,
      BaseReferences<_$AppDatabase, $PendingGradesTableTable,
          PendingGradesTableData>
    ),
    PendingGradesTableData,
    PrefetchHooks Function()> {
  $$PendingGradesTableTableTableManager(
      _$AppDatabase db, $PendingGradesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingGradesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingGradesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingGradesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> cardId = const Value.absent(),
            Value<String> deckId = const Value.absent(),
            Value<int> grade = const Value.absent(),
            Value<double> newEaseFactor = const Value.absent(),
            Value<int> newInterval = const Value.absent(),
            Value<int> newRepetitions = const Value.absent(),
            Value<double?> newStability = const Value.absent(),
            Value<double?> newDifficulty = const Value.absent(),
            Value<DateTime> nextReviewAt = const Value.absent(),
            Value<DateTime> gradedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              PendingGradesTableCompanion(
            id: id,
            cardId: cardId,
            deckId: deckId,
            grade: grade,
            newEaseFactor: newEaseFactor,
            newInterval: newInterval,
            newRepetitions: newRepetitions,
            newStability: newStability,
            newDifficulty: newDifficulty,
            nextReviewAt: nextReviewAt,
            gradedAt: gradedAt,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String cardId,
            required String deckId,
            required int grade,
            required double newEaseFactor,
            required int newInterval,
            required int newRepetitions,
            Value<double?> newStability = const Value.absent(),
            Value<double?> newDifficulty = const Value.absent(),
            required DateTime nextReviewAt,
            required DateTime gradedAt,
            Value<bool> synced = const Value.absent(),
          }) =>
              PendingGradesTableCompanion.insert(
            id: id,
            cardId: cardId,
            deckId: deckId,
            grade: grade,
            newEaseFactor: newEaseFactor,
            newInterval: newInterval,
            newRepetitions: newRepetitions,
            newStability: newStability,
            newDifficulty: newDifficulty,
            nextReviewAt: nextReviewAt,
            gradedAt: gradedAt,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingGradesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingGradesTableTable,
    PendingGradesTableData,
    $$PendingGradesTableTableFilterComposer,
    $$PendingGradesTableTableOrderingComposer,
    $$PendingGradesTableTableAnnotationComposer,
    $$PendingGradesTableTableCreateCompanionBuilder,
    $$PendingGradesTableTableUpdateCompanionBuilder,
    (
      PendingGradesTableData,
      BaseReferences<_$AppDatabase, $PendingGradesTableTable,
          PendingGradesTableData>
    ),
    PendingGradesTableData,
    PrefetchHooks Function()>;
typedef $$StudySessionsLocalTableTableCreateCompanionBuilder
    = StudySessionsLocalTableCompanion Function({
  required String id,
  required String deckId,
  required int totalCards,
  required int newCards,
  required int reviewCards,
  required int againCount,
  required int hardCount,
  required int goodCount,
  required int easyCount,
  required int durationSeconds,
  required DateTime completedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$StudySessionsLocalTableTableUpdateCompanionBuilder
    = StudySessionsLocalTableCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<int> totalCards,
  Value<int> newCards,
  Value<int> reviewCards,
  Value<int> againCount,
  Value<int> hardCount,
  Value<int> goodCount,
  Value<int> easyCount,
  Value<int> durationSeconds,
  Value<DateTime> completedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$StudySessionsLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsLocalTableTable> {
  $$StudySessionsLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCards => $composableBuilder(
      column: $table.totalCards, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newCards => $composableBuilder(
      column: $table.newCards, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewCards => $composableBuilder(
      column: $table.reviewCards, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get againCount => $composableBuilder(
      column: $table.againCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hardCount => $composableBuilder(
      column: $table.hardCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goodCount => $composableBuilder(
      column: $table.goodCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get easyCount => $composableBuilder(
      column: $table.easyCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$StudySessionsLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsLocalTableTable> {
  $$StudySessionsLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCards => $composableBuilder(
      column: $table.totalCards, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newCards => $composableBuilder(
      column: $table.newCards, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewCards => $composableBuilder(
      column: $table.reviewCards, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get againCount => $composableBuilder(
      column: $table.againCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hardCount => $composableBuilder(
      column: $table.hardCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goodCount => $composableBuilder(
      column: $table.goodCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get easyCount => $composableBuilder(
      column: $table.easyCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$StudySessionsLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsLocalTableTable> {
  $$StudySessionsLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<int> get totalCards => $composableBuilder(
      column: $table.totalCards, builder: (column) => column);

  GeneratedColumn<int> get newCards =>
      $composableBuilder(column: $table.newCards, builder: (column) => column);

  GeneratedColumn<int> get reviewCards => $composableBuilder(
      column: $table.reviewCards, builder: (column) => column);

  GeneratedColumn<int> get againCount => $composableBuilder(
      column: $table.againCount, builder: (column) => column);

  GeneratedColumn<int> get hardCount =>
      $composableBuilder(column: $table.hardCount, builder: (column) => column);

  GeneratedColumn<int> get goodCount =>
      $composableBuilder(column: $table.goodCount, builder: (column) => column);

  GeneratedColumn<int> get easyCount =>
      $composableBuilder(column: $table.easyCount, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$StudySessionsLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudySessionsLocalTableTable,
    StudySessionsLocalTableData,
    $$StudySessionsLocalTableTableFilterComposer,
    $$StudySessionsLocalTableTableOrderingComposer,
    $$StudySessionsLocalTableTableAnnotationComposer,
    $$StudySessionsLocalTableTableCreateCompanionBuilder,
    $$StudySessionsLocalTableTableUpdateCompanionBuilder,
    (
      StudySessionsLocalTableData,
      BaseReferences<_$AppDatabase, $StudySessionsLocalTableTable,
          StudySessionsLocalTableData>
    ),
    StudySessionsLocalTableData,
    PrefetchHooks Function()> {
  $$StudySessionsLocalTableTableTableManager(
      _$AppDatabase db, $StudySessionsLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsLocalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsLocalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deckId = const Value.absent(),
            Value<int> totalCards = const Value.absent(),
            Value<int> newCards = const Value.absent(),
            Value<int> reviewCards = const Value.absent(),
            Value<int> againCount = const Value.absent(),
            Value<int> hardCount = const Value.absent(),
            Value<int> goodCount = const Value.absent(),
            Value<int> easyCount = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsLocalTableCompanion(
            id: id,
            deckId: deckId,
            totalCards: totalCards,
            newCards: newCards,
            reviewCards: reviewCards,
            againCount: againCount,
            hardCount: hardCount,
            goodCount: goodCount,
            easyCount: easyCount,
            durationSeconds: durationSeconds,
            completedAt: completedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deckId,
            required int totalCards,
            required int newCards,
            required int reviewCards,
            required int againCount,
            required int hardCount,
            required int goodCount,
            required int easyCount,
            required int durationSeconds,
            required DateTime completedAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsLocalTableCompanion.insert(
            id: id,
            deckId: deckId,
            totalCards: totalCards,
            newCards: newCards,
            reviewCards: reviewCards,
            againCount: againCount,
            hardCount: hardCount,
            goodCount: goodCount,
            easyCount: easyCount,
            durationSeconds: durationSeconds,
            completedAt: completedAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudySessionsLocalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $StudySessionsLocalTableTable,
        StudySessionsLocalTableData,
        $$StudySessionsLocalTableTableFilterComposer,
        $$StudySessionsLocalTableTableOrderingComposer,
        $$StudySessionsLocalTableTableAnnotationComposer,
        $$StudySessionsLocalTableTableCreateCompanionBuilder,
        $$StudySessionsLocalTableTableUpdateCompanionBuilder,
        (
          StudySessionsLocalTableData,
          BaseReferences<_$AppDatabase, $StudySessionsLocalTableTable,
              StudySessionsLocalTableData>
        ),
        StudySessionsLocalTableData,
        PrefetchHooks Function()>;
typedef $$TestQuestionsLocalTableTableCreateCompanionBuilder
    = TestQuestionsLocalTableCompanion Function({
  required String id,
  required String deckId,
  required String question,
  required String correctAnswer,
  required String optionsJson,
  Value<String?> topic,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$TestQuestionsLocalTableTableUpdateCompanionBuilder
    = TestQuestionsLocalTableCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<String> question,
  Value<String> correctAnswer,
  Value<String> optionsJson,
  Value<String?> topic,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$TestQuestionsLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $TestQuestionsLocalTableTable> {
  $$TestQuestionsLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$TestQuestionsLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TestQuestionsLocalTableTable> {
  $$TestQuestionsLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$TestQuestionsLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestQuestionsLocalTableTable> {
  $$TestQuestionsLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$TestQuestionsLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TestQuestionsLocalTableTable,
    TestQuestionsLocalTableData,
    $$TestQuestionsLocalTableTableFilterComposer,
    $$TestQuestionsLocalTableTableOrderingComposer,
    $$TestQuestionsLocalTableTableAnnotationComposer,
    $$TestQuestionsLocalTableTableCreateCompanionBuilder,
    $$TestQuestionsLocalTableTableUpdateCompanionBuilder,
    (
      TestQuestionsLocalTableData,
      BaseReferences<_$AppDatabase, $TestQuestionsLocalTableTable,
          TestQuestionsLocalTableData>
    ),
    TestQuestionsLocalTableData,
    PrefetchHooks Function()> {
  $$TestQuestionsLocalTableTableTableManager(
      _$AppDatabase db, $TestQuestionsLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestQuestionsLocalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TestQuestionsLocalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestQuestionsLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deckId = const Value.absent(),
            Value<String> question = const Value.absent(),
            Value<String> correctAnswer = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TestQuestionsLocalTableCompanion(
            id: id,
            deckId: deckId,
            question: question,
            correctAnswer: correctAnswer,
            optionsJson: optionsJson,
            topic: topic,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deckId,
            required String question,
            required String correctAnswer,
            required String optionsJson,
            Value<String?> topic = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TestQuestionsLocalTableCompanion.insert(
            id: id,
            deckId: deckId,
            question: question,
            correctAnswer: correctAnswer,
            optionsJson: optionsJson,
            topic: topic,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TestQuestionsLocalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TestQuestionsLocalTableTable,
        TestQuestionsLocalTableData,
        $$TestQuestionsLocalTableTableFilterComposer,
        $$TestQuestionsLocalTableTableOrderingComposer,
        $$TestQuestionsLocalTableTableAnnotationComposer,
        $$TestQuestionsLocalTableTableCreateCompanionBuilder,
        $$TestQuestionsLocalTableTableUpdateCompanionBuilder,
        (
          TestQuestionsLocalTableData,
          BaseReferences<_$AppDatabase, $TestQuestionsLocalTableTable,
              TestQuestionsLocalTableData>
        ),
        TestQuestionsLocalTableData,
        PrefetchHooks Function()>;
typedef $$TestResultsLocalTableTableCreateCompanionBuilder
    = TestResultsLocalTableCompanion Function({
  required String id,
  required String deckId,
  required String deckTitle,
  required int totalQuestions,
  required int correctCount,
  required int durationSeconds,
  required String answersJson,
  required String questionsJson,
  required DateTime completedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$TestResultsLocalTableTableUpdateCompanionBuilder
    = TestResultsLocalTableCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<String> deckTitle,
  Value<int> totalQuestions,
  Value<int> correctCount,
  Value<int> durationSeconds,
  Value<String> answersJson,
  Value<String> questionsJson,
  Value<DateTime> completedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$TestResultsLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $TestResultsLocalTableTable> {
  $$TestResultsLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckTitle => $composableBuilder(
      column: $table.deckTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionsJson => $composableBuilder(
      column: $table.questionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$TestResultsLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TestResultsLocalTableTable> {
  $$TestResultsLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckTitle => $composableBuilder(
      column: $table.deckTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctCount => $composableBuilder(
      column: $table.correctCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionsJson => $composableBuilder(
      column: $table.questionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$TestResultsLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestResultsLocalTableTable> {
  $$TestResultsLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get deckTitle =>
      $composableBuilder(column: $table.deckTitle, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => column);

  GeneratedColumn<String> get questionsJson => $composableBuilder(
      column: $table.questionsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TestResultsLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TestResultsLocalTableTable,
    TestResultsLocalTableData,
    $$TestResultsLocalTableTableFilterComposer,
    $$TestResultsLocalTableTableOrderingComposer,
    $$TestResultsLocalTableTableAnnotationComposer,
    $$TestResultsLocalTableTableCreateCompanionBuilder,
    $$TestResultsLocalTableTableUpdateCompanionBuilder,
    (
      TestResultsLocalTableData,
      BaseReferences<_$AppDatabase, $TestResultsLocalTableTable,
          TestResultsLocalTableData>
    ),
    TestResultsLocalTableData,
    PrefetchHooks Function()> {
  $$TestResultsLocalTableTableTableManager(
      _$AppDatabase db, $TestResultsLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestResultsLocalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TestResultsLocalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestResultsLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> deckId = const Value.absent(),
            Value<String> deckTitle = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String> answersJson = const Value.absent(),
            Value<String> questionsJson = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TestResultsLocalTableCompanion(
            id: id,
            deckId: deckId,
            deckTitle: deckTitle,
            totalQuestions: totalQuestions,
            correctCount: correctCount,
            durationSeconds: durationSeconds,
            answersJson: answersJson,
            questionsJson: questionsJson,
            completedAt: completedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String deckId,
            required String deckTitle,
            required int totalQuestions,
            required int correctCount,
            required int durationSeconds,
            required String answersJson,
            required String questionsJson,
            required DateTime completedAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TestResultsLocalTableCompanion.insert(
            id: id,
            deckId: deckId,
            deckTitle: deckTitle,
            totalQuestions: totalQuestions,
            correctCount: correctCount,
            durationSeconds: durationSeconds,
            answersJson: answersJson,
            questionsJson: questionsJson,
            completedAt: completedAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TestResultsLocalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TestResultsLocalTableTable,
        TestResultsLocalTableData,
        $$TestResultsLocalTableTableFilterComposer,
        $$TestResultsLocalTableTableOrderingComposer,
        $$TestResultsLocalTableTableAnnotationComposer,
        $$TestResultsLocalTableTableCreateCompanionBuilder,
        $$TestResultsLocalTableTableUpdateCompanionBuilder,
        (
          TestResultsLocalTableData,
          BaseReferences<_$AppDatabase, $TestResultsLocalTableTable,
              TestResultsLocalTableData>
        ),
        TestResultsLocalTableData,
        PrefetchHooks Function()>;
typedef $$ConversationsLocalTableTableCreateCompanionBuilder
    = ConversationsLocalTableCompanion Function({
  required String id,
  required String title,
  Value<String?> deckId,
  Value<String?> deckTitle,
  Value<bool> isPinned,
  Value<int> messageCount,
  Value<String?> lastMessagePreview,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$ConversationsLocalTableTableUpdateCompanionBuilder
    = ConversationsLocalTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> deckId,
  Value<String?> deckTitle,
  Value<bool> isPinned,
  Value<int> messageCount,
  Value<String?> lastMessagePreview,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$ConversationsLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsLocalTableTable> {
  $$ConversationsLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckTitle => $composableBuilder(
      column: $table.deckTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
      column: $table.lastMessagePreview,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$ConversationsLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsLocalTableTable> {
  $$ConversationsLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckId => $composableBuilder(
      column: $table.deckId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckTitle => $composableBuilder(
      column: $table.deckTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageCount => $composableBuilder(
      column: $table.messageCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
      column: $table.lastMessagePreview,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$ConversationsLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsLocalTableTable> {
  $$ConversationsLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get deckTitle =>
      $composableBuilder(column: $table.deckTitle, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => column);

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
      column: $table.lastMessagePreview, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ConversationsLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsLocalTableTable,
    ConversationsLocalTableData,
    $$ConversationsLocalTableTableFilterComposer,
    $$ConversationsLocalTableTableOrderingComposer,
    $$ConversationsLocalTableTableAnnotationComposer,
    $$ConversationsLocalTableTableCreateCompanionBuilder,
    $$ConversationsLocalTableTableUpdateCompanionBuilder,
    (
      ConversationsLocalTableData,
      BaseReferences<_$AppDatabase, $ConversationsLocalTableTable,
          ConversationsLocalTableData>
    ),
    ConversationsLocalTableData,
    PrefetchHooks Function()> {
  $$ConversationsLocalTableTableTableManager(
      _$AppDatabase db, $ConversationsLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsLocalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsLocalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> deckId = const Value.absent(),
            Value<String?> deckTitle = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<int> messageCount = const Value.absent(),
            Value<String?> lastMessagePreview = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsLocalTableCompanion(
            id: id,
            title: title,
            deckId: deckId,
            deckTitle: deckTitle,
            isPinned: isPinned,
            messageCount: messageCount,
            lastMessagePreview: lastMessagePreview,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> deckId = const Value.absent(),
            Value<String?> deckTitle = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<int> messageCount = const Value.absent(),
            Value<String?> lastMessagePreview = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsLocalTableCompanion.insert(
            id: id,
            title: title,
            deckId: deckId,
            deckTitle: deckTitle,
            isPinned: isPinned,
            messageCount: messageCount,
            lastMessagePreview: lastMessagePreview,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConversationsLocalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ConversationsLocalTableTable,
        ConversationsLocalTableData,
        $$ConversationsLocalTableTableFilterComposer,
        $$ConversationsLocalTableTableOrderingComposer,
        $$ConversationsLocalTableTableAnnotationComposer,
        $$ConversationsLocalTableTableCreateCompanionBuilder,
        $$ConversationsLocalTableTableUpdateCompanionBuilder,
        (
          ConversationsLocalTableData,
          BaseReferences<_$AppDatabase, $ConversationsLocalTableTable,
              ConversationsLocalTableData>
        ),
        ConversationsLocalTableData,
        PrefetchHooks Function()>;
typedef $$TutorMessagesLocalTableTableCreateCompanionBuilder
    = TutorMessagesLocalTableCompanion Function({
  required String id,
  required String conversationId,
  required String role,
  required String content,
  required DateTime createdAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$TutorMessagesLocalTableTableUpdateCompanionBuilder
    = TutorMessagesLocalTableCompanion Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> role,
  Value<String> content,
  Value<DateTime> createdAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$TutorMessagesLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $TutorMessagesLocalTableTable> {
  $$TutorMessagesLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$TutorMessagesLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TutorMessagesLocalTableTable> {
  $$TutorMessagesLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$TutorMessagesLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TutorMessagesLocalTableTable> {
  $$TutorMessagesLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$TutorMessagesLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TutorMessagesLocalTableTable,
    TutorMessagesLocalTableData,
    $$TutorMessagesLocalTableTableFilterComposer,
    $$TutorMessagesLocalTableTableOrderingComposer,
    $$TutorMessagesLocalTableTableAnnotationComposer,
    $$TutorMessagesLocalTableTableCreateCompanionBuilder,
    $$TutorMessagesLocalTableTableUpdateCompanionBuilder,
    (
      TutorMessagesLocalTableData,
      BaseReferences<_$AppDatabase, $TutorMessagesLocalTableTable,
          TutorMessagesLocalTableData>
    ),
    TutorMessagesLocalTableData,
    PrefetchHooks Function()> {
  $$TutorMessagesLocalTableTableTableManager(
      _$AppDatabase db, $TutorMessagesLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TutorMessagesLocalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TutorMessagesLocalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TutorMessagesLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TutorMessagesLocalTableCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String role,
            required String content,
            required DateTime createdAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TutorMessagesLocalTableCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            createdAt: createdAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TutorMessagesLocalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TutorMessagesLocalTableTable,
        TutorMessagesLocalTableData,
        $$TutorMessagesLocalTableTableFilterComposer,
        $$TutorMessagesLocalTableTableOrderingComposer,
        $$TutorMessagesLocalTableTableAnnotationComposer,
        $$TutorMessagesLocalTableTableCreateCompanionBuilder,
        $$TutorMessagesLocalTableTableUpdateCompanionBuilder,
        (
          TutorMessagesLocalTableData,
          BaseReferences<_$AppDatabase, $TutorMessagesLocalTableTable,
              TutorMessagesLocalTableData>
        ),
        TutorMessagesLocalTableData,
        PrefetchHooks Function()>;
typedef $$GenerationJobsLocalTableTableCreateCompanionBuilder
    = GenerationJobsLocalTableCompanion Function({
  required String id,
  required String source,
  required String status,
  Value<int> progress,
  Value<String?> topic,
  Value<String?> inputText,
  Value<String?> pdfFileName,
  required String qualityMode,
  required int requestedCardCount,
  Value<String?> generatedCardsJson,
  Value<String?> errorMessage,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$GenerationJobsLocalTableTableUpdateCompanionBuilder
    = GenerationJobsLocalTableCompanion Function({
  Value<String> id,
  Value<String> source,
  Value<String> status,
  Value<int> progress,
  Value<String?> topic,
  Value<String?> inputText,
  Value<String?> pdfFileName,
  Value<String> qualityMode,
  Value<int> requestedCardCount,
  Value<String?> generatedCardsJson,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$GenerationJobsLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $GenerationJobsLocalTableTable> {
  $$GenerationJobsLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inputText => $composableBuilder(
      column: $table.inputText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdfFileName => $composableBuilder(
      column: $table.pdfFileName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qualityMode => $composableBuilder(
      column: $table.qualityMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get requestedCardCount => $composableBuilder(
      column: $table.requestedCardCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get generatedCardsJson => $composableBuilder(
      column: $table.generatedCardsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$GenerationJobsLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GenerationJobsLocalTableTable> {
  $$GenerationJobsLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inputText => $composableBuilder(
      column: $table.inputText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdfFileName => $composableBuilder(
      column: $table.pdfFileName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qualityMode => $composableBuilder(
      column: $table.qualityMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get requestedCardCount => $composableBuilder(
      column: $table.requestedCardCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get generatedCardsJson => $composableBuilder(
      column: $table.generatedCardsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$GenerationJobsLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GenerationJobsLocalTableTable> {
  $$GenerationJobsLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get inputText =>
      $composableBuilder(column: $table.inputText, builder: (column) => column);

  GeneratedColumn<String> get pdfFileName => $composableBuilder(
      column: $table.pdfFileName, builder: (column) => column);

  GeneratedColumn<String> get qualityMode => $composableBuilder(
      column: $table.qualityMode, builder: (column) => column);

  GeneratedColumn<int> get requestedCardCount => $composableBuilder(
      column: $table.requestedCardCount, builder: (column) => column);

  GeneratedColumn<String> get generatedCardsJson => $composableBuilder(
      column: $table.generatedCardsJson, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$GenerationJobsLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GenerationJobsLocalTableTable,
    GenerationJobsLocalTableData,
    $$GenerationJobsLocalTableTableFilterComposer,
    $$GenerationJobsLocalTableTableOrderingComposer,
    $$GenerationJobsLocalTableTableAnnotationComposer,
    $$GenerationJobsLocalTableTableCreateCompanionBuilder,
    $$GenerationJobsLocalTableTableUpdateCompanionBuilder,
    (
      GenerationJobsLocalTableData,
      BaseReferences<_$AppDatabase, $GenerationJobsLocalTableTable,
          GenerationJobsLocalTableData>
    ),
    GenerationJobsLocalTableData,
    PrefetchHooks Function()> {
  $$GenerationJobsLocalTableTableTableManager(
      _$AppDatabase db, $GenerationJobsLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GenerationJobsLocalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$GenerationJobsLocalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GenerationJobsLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> progress = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> inputText = const Value.absent(),
            Value<String?> pdfFileName = const Value.absent(),
            Value<String> qualityMode = const Value.absent(),
            Value<int> requestedCardCount = const Value.absent(),
            Value<String?> generatedCardsJson = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GenerationJobsLocalTableCompanion(
            id: id,
            source: source,
            status: status,
            progress: progress,
            topic: topic,
            inputText: inputText,
            pdfFileName: pdfFileName,
            qualityMode: qualityMode,
            requestedCardCount: requestedCardCount,
            generatedCardsJson: generatedCardsJson,
            errorMessage: errorMessage,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String source,
            required String status,
            Value<int> progress = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> inputText = const Value.absent(),
            Value<String?> pdfFileName = const Value.absent(),
            required String qualityMode,
            required int requestedCardCount,
            Value<String?> generatedCardsJson = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GenerationJobsLocalTableCompanion.insert(
            id: id,
            source: source,
            status: status,
            progress: progress,
            topic: topic,
            inputText: inputText,
            pdfFileName: pdfFileName,
            qualityMode: qualityMode,
            requestedCardCount: requestedCardCount,
            generatedCardsJson: generatedCardsJson,
            errorMessage: errorMessage,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GenerationJobsLocalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GenerationJobsLocalTableTable,
        GenerationJobsLocalTableData,
        $$GenerationJobsLocalTableTableFilterComposer,
        $$GenerationJobsLocalTableTableOrderingComposer,
        $$GenerationJobsLocalTableTableAnnotationComposer,
        $$GenerationJobsLocalTableTableCreateCompanionBuilder,
        $$GenerationJobsLocalTableTableUpdateCompanionBuilder,
        (
          GenerationJobsLocalTableData,
          BaseReferences<_$AppDatabase, $GenerationJobsLocalTableTable,
              GenerationJobsLocalTableData>
        ),
        GenerationJobsLocalTableData,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FlashcardsLocalTableTableTableManager get flashcardsLocalTable =>
      $$FlashcardsLocalTableTableTableManager(_db, _db.flashcardsLocalTable);
  $$PendingGradesTableTableTableManager get pendingGradesTable =>
      $$PendingGradesTableTableTableManager(_db, _db.pendingGradesTable);
  $$StudySessionsLocalTableTableTableManager get studySessionsLocalTable =>
      $$StudySessionsLocalTableTableTableManager(
          _db, _db.studySessionsLocalTable);
  $$TestQuestionsLocalTableTableTableManager get testQuestionsLocalTable =>
      $$TestQuestionsLocalTableTableTableManager(
          _db, _db.testQuestionsLocalTable);
  $$TestResultsLocalTableTableTableManager get testResultsLocalTable =>
      $$TestResultsLocalTableTableTableManager(_db, _db.testResultsLocalTable);
  $$ConversationsLocalTableTableTableManager get conversationsLocalTable =>
      $$ConversationsLocalTableTableTableManager(
          _db, _db.conversationsLocalTable);
  $$TutorMessagesLocalTableTableTableManager get tutorMessagesLocalTable =>
      $$TutorMessagesLocalTableTableTableManager(
          _db, _db.tutorMessagesLocalTable);
  $$GenerationJobsLocalTableTableTableManager get generationJobsLocalTable =>
      $$GenerationJobsLocalTableTableTableManager(
          _db, _db.generationJobsLocalTable);
}
