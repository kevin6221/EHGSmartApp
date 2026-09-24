// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DailyHealthSummariesTableTable extends DailyHealthSummariesTable
    with TableInfo<$DailyHealthSummariesTableTable, DailyHealthSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyHealthSummariesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _caloriesBurnedMeta = const VerificationMeta(
    'caloriesBurned',
  );
  @override
  late final GeneratedColumn<double> caloriesBurned = GeneratedColumn<double>(
    'calories_burned',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _activeMinutesMeta = const VerificationMeta(
    'activeMinutes',
  );
  @override
  late final GeneratedColumn<int> activeMinutes = GeneratedColumn<int>(
    'active_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _restingHeartRateMeta = const VerificationMeta(
    'restingHeartRate',
  );
  @override
  late final GeneratedColumn<int> restingHeartRate = GeneratedColumn<int>(
    'resting_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<int> maxHeartRate = GeneratedColumn<int>(
    'max_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minHeartRateMeta = const VerificationMeta(
    'minHeartRate',
  );
  @override
  late final GeneratedColumn<int> minHeartRate = GeneratedColumn<int>(
    'min_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgSpo2Meta = const VerificationMeta(
    'avgSpo2',
  );
  @override
  late final GeneratedColumn<double> avgSpo2 = GeneratedColumn<double>(
    'avg_spo2',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepDurationMinutesMeta =
      const VerificationMeta('sleepDurationMinutes');
  @override
  late final GeneratedColumn<int> sleepDurationMinutes = GeneratedColumn<int>(
    'sleep_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deepSleepMinutesMeta = const VerificationMeta(
    'deepSleepMinutes',
  );
  @override
  late final GeneratedColumn<int> deepSleepMinutes = GeneratedColumn<int>(
    'deep_sleep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lightSleepMinutesMeta = const VerificationMeta(
    'lightSleepMinutes',
  );
  @override
  late final GeneratedColumn<int> lightSleepMinutes = GeneratedColumn<int>(
    'light_sleep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remSleepMinutesMeta = const VerificationMeta(
    'remSleepMinutes',
  );
  @override
  late final GeneratedColumn<int> remSleepMinutes = GeneratedColumn<int>(
    'rem_sleep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _awakeMinutesMeta = const VerificationMeta(
    'awakeMinutes',
  );
  @override
  late final GeneratedColumn<int> awakeMinutes = GeneratedColumn<int>(
    'awake_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sleepScoreMeta = const VerificationMeta(
    'sleepScore',
  );
  @override
  late final GeneratedColumn<int> sleepScore = GeneratedColumn<int>(
    'sleep_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wellnessScoreMeta = const VerificationMeta(
    'wellnessScore',
  );
  @override
  late final GeneratedColumn<int> wellnessScore = GeneratedColumn<int>(
    'wellness_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moveScoreMeta = const VerificationMeta(
    'moveScore',
  );
  @override
  late final GeneratedColumn<int> moveScore = GeneratedColumn<int>(
    'move_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recoverScoreMeta = const VerificationMeta(
    'recoverScore',
  );
  @override
  late final GeneratedColumn<int> recoverScore = GeneratedColumn<int>(
    'recover_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readinessScoreMeta = const VerificationMeta(
    'readinessScore',
  );
  @override
  late final GeneratedColumn<int> readinessScore = GeneratedColumn<int>(
    'readiness_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncTimestampMeta = const VerificationMeta(
    'lastSyncTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncTimestamp =
      GeneratedColumn<DateTime>(
        'last_sync_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    date,
    deviceId,
    steps,
    caloriesBurned,
    distanceMeters,
    activeMinutes,
    restingHeartRate,
    avgHeartRate,
    maxHeartRate,
    minHeartRate,
    avgSpo2,
    sleepDurationMinutes,
    deepSleepMinutes,
    lightSleepMinutes,
    remSleepMinutes,
    awakeMinutes,
    sleepScore,
    wellnessScore,
    moveScore,
    recoverScore,
    readinessScore,
    lastSyncTimestamp,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_health_summaries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyHealthSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('calories_burned')) {
      context.handle(
        _caloriesBurnedMeta,
        caloriesBurned.isAcceptableOrUnknown(
          data['calories_burned']!,
          _caloriesBurnedMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('active_minutes')) {
      context.handle(
        _activeMinutesMeta,
        activeMinutes.isAcceptableOrUnknown(
          data['active_minutes']!,
          _activeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('resting_heart_rate')) {
      context.handle(
        _restingHeartRateMeta,
        restingHeartRate.isAcceptableOrUnknown(
          data['resting_heart_rate']!,
          _restingHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('min_heart_rate')) {
      context.handle(
        _minHeartRateMeta,
        minHeartRate.isAcceptableOrUnknown(
          data['min_heart_rate']!,
          _minHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('avg_spo2')) {
      context.handle(
        _avgSpo2Meta,
        avgSpo2.isAcceptableOrUnknown(data['avg_spo2']!, _avgSpo2Meta),
      );
    }
    if (data.containsKey('sleep_duration_minutes')) {
      context.handle(
        _sleepDurationMinutesMeta,
        sleepDurationMinutes.isAcceptableOrUnknown(
          data['sleep_duration_minutes']!,
          _sleepDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('deep_sleep_minutes')) {
      context.handle(
        _deepSleepMinutesMeta,
        deepSleepMinutes.isAcceptableOrUnknown(
          data['deep_sleep_minutes']!,
          _deepSleepMinutesMeta,
        ),
      );
    }
    if (data.containsKey('light_sleep_minutes')) {
      context.handle(
        _lightSleepMinutesMeta,
        lightSleepMinutes.isAcceptableOrUnknown(
          data['light_sleep_minutes']!,
          _lightSleepMinutesMeta,
        ),
      );
    }
    if (data.containsKey('rem_sleep_minutes')) {
      context.handle(
        _remSleepMinutesMeta,
        remSleepMinutes.isAcceptableOrUnknown(
          data['rem_sleep_minutes']!,
          _remSleepMinutesMeta,
        ),
      );
    }
    if (data.containsKey('awake_minutes')) {
      context.handle(
        _awakeMinutesMeta,
        awakeMinutes.isAcceptableOrUnknown(
          data['awake_minutes']!,
          _awakeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('sleep_score')) {
      context.handle(
        _sleepScoreMeta,
        sleepScore.isAcceptableOrUnknown(data['sleep_score']!, _sleepScoreMeta),
      );
    }
    if (data.containsKey('wellness_score')) {
      context.handle(
        _wellnessScoreMeta,
        wellnessScore.isAcceptableOrUnknown(
          data['wellness_score']!,
          _wellnessScoreMeta,
        ),
      );
    }
    if (data.containsKey('move_score')) {
      context.handle(
        _moveScoreMeta,
        moveScore.isAcceptableOrUnknown(data['move_score']!, _moveScoreMeta),
      );
    }
    if (data.containsKey('recover_score')) {
      context.handle(
        _recoverScoreMeta,
        recoverScore.isAcceptableOrUnknown(
          data['recover_score']!,
          _recoverScoreMeta,
        ),
      );
    }
    if (data.containsKey('readiness_score')) {
      context.handle(
        _readinessScoreMeta,
        readinessScore.isAcceptableOrUnknown(
          data['readiness_score']!,
          _readinessScoreMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_timestamp')) {
      context.handle(
        _lastSyncTimestampMeta,
        lastSyncTimestamp.isAcceptableOrUnknown(
          data['last_sync_timestamp']!,
          _lastSyncTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncTimestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, date};
  @override
  DailyHealthSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyHealthSummary(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      caloriesBurned: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories_burned'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      activeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_minutes'],
      )!,
      restingHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resting_heart_rate'],
      ),
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_heart_rate'],
      ),
      minHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_heart_rate'],
      ),
      avgSpo2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_spo2'],
      ),
      sleepDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_duration_minutes'],
      )!,
      deepSleepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deep_sleep_minutes'],
      )!,
      lightSleepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}light_sleep_minutes'],
      )!,
      remSleepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rem_sleep_minutes'],
      )!,
      awakeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awake_minutes'],
      )!,
      sleepScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_score'],
      ),
      wellnessScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wellness_score'],
      ),
      moveScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move_score'],
      ),
      recoverScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recover_score'],
      ),
      readinessScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}readiness_score'],
      ),
      lastSyncTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_timestamp'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DailyHealthSummariesTableTable createAlias(String alias) {
    return $DailyHealthSummariesTableTable(attachedDatabase, alias);
  }
}

class DailyHealthSummary extends DataClass
    implements Insertable<DailyHealthSummary> {
  final String userId;
  final String date;
  final String deviceId;
  final int steps;
  final double caloriesBurned;
  final double distanceMeters;
  final int activeMinutes;
  final int? restingHeartRate;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? minHeartRate;
  final double? avgSpo2;
  final int sleepDurationMinutes;
  final int deepSleepMinutes;
  final int lightSleepMinutes;
  final int remSleepMinutes;
  final int awakeMinutes;
  final int? sleepScore;
  final int? wellnessScore;
  final int? moveScore;
  final int? recoverScore;
  final int? readinessScore;
  final DateTime lastSyncTimestamp;
  final DateTime createdAt;
  const DailyHealthSummary({
    required this.userId,
    required this.date,
    required this.deviceId,
    required this.steps,
    required this.caloriesBurned,
    required this.distanceMeters,
    required this.activeMinutes,
    this.restingHeartRate,
    this.avgHeartRate,
    this.maxHeartRate,
    this.minHeartRate,
    this.avgSpo2,
    required this.sleepDurationMinutes,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
    required this.remSleepMinutes,
    required this.awakeMinutes,
    this.sleepScore,
    this.wellnessScore,
    this.moveScore,
    this.recoverScore,
    this.readinessScore,
    required this.lastSyncTimestamp,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<String>(date);
    map['device_id'] = Variable<String>(deviceId);
    map['steps'] = Variable<int>(steps);
    map['calories_burned'] = Variable<double>(caloriesBurned);
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['active_minutes'] = Variable<int>(activeMinutes);
    if (!nullToAbsent || restingHeartRate != null) {
      map['resting_heart_rate'] = Variable<int>(restingHeartRate);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate);
    }
    if (!nullToAbsent || minHeartRate != null) {
      map['min_heart_rate'] = Variable<int>(minHeartRate);
    }
    if (!nullToAbsent || avgSpo2 != null) {
      map['avg_spo2'] = Variable<double>(avgSpo2);
    }
    map['sleep_duration_minutes'] = Variable<int>(sleepDurationMinutes);
    map['deep_sleep_minutes'] = Variable<int>(deepSleepMinutes);
    map['light_sleep_minutes'] = Variable<int>(lightSleepMinutes);
    map['rem_sleep_minutes'] = Variable<int>(remSleepMinutes);
    map['awake_minutes'] = Variable<int>(awakeMinutes);
    if (!nullToAbsent || sleepScore != null) {
      map['sleep_score'] = Variable<int>(sleepScore);
    }
    if (!nullToAbsent || wellnessScore != null) {
      map['wellness_score'] = Variable<int>(wellnessScore);
    }
    if (!nullToAbsent || moveScore != null) {
      map['move_score'] = Variable<int>(moveScore);
    }
    if (!nullToAbsent || recoverScore != null) {
      map['recover_score'] = Variable<int>(recoverScore);
    }
    if (!nullToAbsent || readinessScore != null) {
      map['readiness_score'] = Variable<int>(readinessScore);
    }
    map['last_sync_timestamp'] = Variable<DateTime>(lastSyncTimestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DailyHealthSummariesTableCompanion toCompanion(bool nullToAbsent) {
    return DailyHealthSummariesTableCompanion(
      userId: Value(userId),
      date: Value(date),
      deviceId: Value(deviceId),
      steps: Value(steps),
      caloriesBurned: Value(caloriesBurned),
      distanceMeters: Value(distanceMeters),
      activeMinutes: Value(activeMinutes),
      restingHeartRate: restingHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(restingHeartRate),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      minHeartRate: minHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(minHeartRate),
      avgSpo2: avgSpo2 == null && nullToAbsent
          ? const Value.absent()
          : Value(avgSpo2),
      sleepDurationMinutes: Value(sleepDurationMinutes),
      deepSleepMinutes: Value(deepSleepMinutes),
      lightSleepMinutes: Value(lightSleepMinutes),
      remSleepMinutes: Value(remSleepMinutes),
      awakeMinutes: Value(awakeMinutes),
      sleepScore: sleepScore == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepScore),
      wellnessScore: wellnessScore == null && nullToAbsent
          ? const Value.absent()
          : Value(wellnessScore),
      moveScore: moveScore == null && nullToAbsent
          ? const Value.absent()
          : Value(moveScore),
      recoverScore: recoverScore == null && nullToAbsent
          ? const Value.absent()
          : Value(recoverScore),
      readinessScore: readinessScore == null && nullToAbsent
          ? const Value.absent()
          : Value(readinessScore),
      lastSyncTimestamp: Value(lastSyncTimestamp),
      createdAt: Value(createdAt),
    );
  }

  factory DailyHealthSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyHealthSummary(
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<String>(json['date']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      steps: serializer.fromJson<int>(json['steps']),
      caloriesBurned: serializer.fromJson<double>(json['caloriesBurned']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      activeMinutes: serializer.fromJson<int>(json['activeMinutes']),
      restingHeartRate: serializer.fromJson<int?>(json['restingHeartRate']),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      maxHeartRate: serializer.fromJson<int?>(json['maxHeartRate']),
      minHeartRate: serializer.fromJson<int?>(json['minHeartRate']),
      avgSpo2: serializer.fromJson<double?>(json['avgSpo2']),
      sleepDurationMinutes: serializer.fromJson<int>(
        json['sleepDurationMinutes'],
      ),
      deepSleepMinutes: serializer.fromJson<int>(json['deepSleepMinutes']),
      lightSleepMinutes: serializer.fromJson<int>(json['lightSleepMinutes']),
      remSleepMinutes: serializer.fromJson<int>(json['remSleepMinutes']),
      awakeMinutes: serializer.fromJson<int>(json['awakeMinutes']),
      sleepScore: serializer.fromJson<int?>(json['sleepScore']),
      wellnessScore: serializer.fromJson<int?>(json['wellnessScore']),
      moveScore: serializer.fromJson<int?>(json['moveScore']),
      recoverScore: serializer.fromJson<int?>(json['recoverScore']),
      readinessScore: serializer.fromJson<int?>(json['readinessScore']),
      lastSyncTimestamp: serializer.fromJson<DateTime>(
        json['lastSyncTimestamp'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<String>(date),
      'deviceId': serializer.toJson<String>(deviceId),
      'steps': serializer.toJson<int>(steps),
      'caloriesBurned': serializer.toJson<double>(caloriesBurned),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'activeMinutes': serializer.toJson<int>(activeMinutes),
      'restingHeartRate': serializer.toJson<int?>(restingHeartRate),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'maxHeartRate': serializer.toJson<int?>(maxHeartRate),
      'minHeartRate': serializer.toJson<int?>(minHeartRate),
      'avgSpo2': serializer.toJson<double?>(avgSpo2),
      'sleepDurationMinutes': serializer.toJson<int>(sleepDurationMinutes),
      'deepSleepMinutes': serializer.toJson<int>(deepSleepMinutes),
      'lightSleepMinutes': serializer.toJson<int>(lightSleepMinutes),
      'remSleepMinutes': serializer.toJson<int>(remSleepMinutes),
      'awakeMinutes': serializer.toJson<int>(awakeMinutes),
      'sleepScore': serializer.toJson<int?>(sleepScore),
      'wellnessScore': serializer.toJson<int?>(wellnessScore),
      'moveScore': serializer.toJson<int?>(moveScore),
      'recoverScore': serializer.toJson<int?>(recoverScore),
      'readinessScore': serializer.toJson<int?>(readinessScore),
      'lastSyncTimestamp': serializer.toJson<DateTime>(lastSyncTimestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DailyHealthSummary copyWith({
    String? userId,
    String? date,
    String? deviceId,
    int? steps,
    double? caloriesBurned,
    double? distanceMeters,
    int? activeMinutes,
    Value<int?> restingHeartRate = const Value.absent(),
    Value<int?> avgHeartRate = const Value.absent(),
    Value<int?> maxHeartRate = const Value.absent(),
    Value<int?> minHeartRate = const Value.absent(),
    Value<double?> avgSpo2 = const Value.absent(),
    int? sleepDurationMinutes,
    int? deepSleepMinutes,
    int? lightSleepMinutes,
    int? remSleepMinutes,
    int? awakeMinutes,
    Value<int?> sleepScore = const Value.absent(),
    Value<int?> wellnessScore = const Value.absent(),
    Value<int?> moveScore = const Value.absent(),
    Value<int?> recoverScore = const Value.absent(),
    Value<int?> readinessScore = const Value.absent(),
    DateTime? lastSyncTimestamp,
    DateTime? createdAt,
  }) => DailyHealthSummary(
    userId: userId ?? this.userId,
    date: date ?? this.date,
    deviceId: deviceId ?? this.deviceId,
    steps: steps ?? this.steps,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    activeMinutes: activeMinutes ?? this.activeMinutes,
    restingHeartRate: restingHeartRate.present
        ? restingHeartRate.value
        : this.restingHeartRate,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    maxHeartRate: maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
    minHeartRate: minHeartRate.present ? minHeartRate.value : this.minHeartRate,
    avgSpo2: avgSpo2.present ? avgSpo2.value : this.avgSpo2,
    sleepDurationMinutes: sleepDurationMinutes ?? this.sleepDurationMinutes,
    deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
    lightSleepMinutes: lightSleepMinutes ?? this.lightSleepMinutes,
    remSleepMinutes: remSleepMinutes ?? this.remSleepMinutes,
    awakeMinutes: awakeMinutes ?? this.awakeMinutes,
    sleepScore: sleepScore.present ? sleepScore.value : this.sleepScore,
    wellnessScore: wellnessScore.present
        ? wellnessScore.value
        : this.wellnessScore,
    moveScore: moveScore.present ? moveScore.value : this.moveScore,
    recoverScore: recoverScore.present ? recoverScore.value : this.recoverScore,
    readinessScore: readinessScore.present
        ? readinessScore.value
        : this.readinessScore,
    lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
    createdAt: createdAt ?? this.createdAt,
  );
  DailyHealthSummary copyWithCompanion(
    DailyHealthSummariesTableCompanion data,
  ) {
    return DailyHealthSummary(
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      steps: data.steps.present ? data.steps.value : this.steps,
      caloriesBurned: data.caloriesBurned.present
          ? data.caloriesBurned.value
          : this.caloriesBurned,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      activeMinutes: data.activeMinutes.present
          ? data.activeMinutes.value
          : this.activeMinutes,
      restingHeartRate: data.restingHeartRate.present
          ? data.restingHeartRate.value
          : this.restingHeartRate,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      minHeartRate: data.minHeartRate.present
          ? data.minHeartRate.value
          : this.minHeartRate,
      avgSpo2: data.avgSpo2.present ? data.avgSpo2.value : this.avgSpo2,
      sleepDurationMinutes: data.sleepDurationMinutes.present
          ? data.sleepDurationMinutes.value
          : this.sleepDurationMinutes,
      deepSleepMinutes: data.deepSleepMinutes.present
          ? data.deepSleepMinutes.value
          : this.deepSleepMinutes,
      lightSleepMinutes: data.lightSleepMinutes.present
          ? data.lightSleepMinutes.value
          : this.lightSleepMinutes,
      remSleepMinutes: data.remSleepMinutes.present
          ? data.remSleepMinutes.value
          : this.remSleepMinutes,
      awakeMinutes: data.awakeMinutes.present
          ? data.awakeMinutes.value
          : this.awakeMinutes,
      sleepScore: data.sleepScore.present
          ? data.sleepScore.value
          : this.sleepScore,
      wellnessScore: data.wellnessScore.present
          ? data.wellnessScore.value
          : this.wellnessScore,
      moveScore: data.moveScore.present ? data.moveScore.value : this.moveScore,
      recoverScore: data.recoverScore.present
          ? data.recoverScore.value
          : this.recoverScore,
      readinessScore: data.readinessScore.present
          ? data.readinessScore.value
          : this.readinessScore,
      lastSyncTimestamp: data.lastSyncTimestamp.present
          ? data.lastSyncTimestamp.value
          : this.lastSyncTimestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthSummary(')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('deviceId: $deviceId, ')
          ..write('steps: $steps, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('activeMinutes: $activeMinutes, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('minHeartRate: $minHeartRate, ')
          ..write('avgSpo2: $avgSpo2, ')
          ..write('sleepDurationMinutes: $sleepDurationMinutes, ')
          ..write('deepSleepMinutes: $deepSleepMinutes, ')
          ..write('lightSleepMinutes: $lightSleepMinutes, ')
          ..write('remSleepMinutes: $remSleepMinutes, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('wellnessScore: $wellnessScore, ')
          ..write('moveScore: $moveScore, ')
          ..write('recoverScore: $recoverScore, ')
          ..write('readinessScore: $readinessScore, ')
          ..write('lastSyncTimestamp: $lastSyncTimestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    userId,
    date,
    deviceId,
    steps,
    caloriesBurned,
    distanceMeters,
    activeMinutes,
    restingHeartRate,
    avgHeartRate,
    maxHeartRate,
    minHeartRate,
    avgSpo2,
    sleepDurationMinutes,
    deepSleepMinutes,
    lightSleepMinutes,
    remSleepMinutes,
    awakeMinutes,
    sleepScore,
    wellnessScore,
    moveScore,
    recoverScore,
    readinessScore,
    lastSyncTimestamp,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyHealthSummary &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.deviceId == this.deviceId &&
          other.steps == this.steps &&
          other.caloriesBurned == this.caloriesBurned &&
          other.distanceMeters == this.distanceMeters &&
          other.activeMinutes == this.activeMinutes &&
          other.restingHeartRate == this.restingHeartRate &&
          other.avgHeartRate == this.avgHeartRate &&
          other.maxHeartRate == this.maxHeartRate &&
          other.minHeartRate == this.minHeartRate &&
          other.avgSpo2 == this.avgSpo2 &&
          other.sleepDurationMinutes == this.sleepDurationMinutes &&
          other.deepSleepMinutes == this.deepSleepMinutes &&
          other.lightSleepMinutes == this.lightSleepMinutes &&
          other.remSleepMinutes == this.remSleepMinutes &&
          other.awakeMinutes == this.awakeMinutes &&
          other.sleepScore == this.sleepScore &&
          other.wellnessScore == this.wellnessScore &&
          other.moveScore == this.moveScore &&
          other.recoverScore == this.recoverScore &&
          other.readinessScore == this.readinessScore &&
          other.lastSyncTimestamp == this.lastSyncTimestamp &&
          other.createdAt == this.createdAt);
}

class DailyHealthSummariesTableCompanion
    extends UpdateCompanion<DailyHealthSummary> {
  final Value<String> userId;
  final Value<String> date;
  final Value<String> deviceId;
  final Value<int> steps;
  final Value<double> caloriesBurned;
  final Value<double> distanceMeters;
  final Value<int> activeMinutes;
  final Value<int?> restingHeartRate;
  final Value<int?> avgHeartRate;
  final Value<int?> maxHeartRate;
  final Value<int?> minHeartRate;
  final Value<double?> avgSpo2;
  final Value<int> sleepDurationMinutes;
  final Value<int> deepSleepMinutes;
  final Value<int> lightSleepMinutes;
  final Value<int> remSleepMinutes;
  final Value<int> awakeMinutes;
  final Value<int?> sleepScore;
  final Value<int?> wellnessScore;
  final Value<int?> moveScore;
  final Value<int?> recoverScore;
  final Value<int?> readinessScore;
  final Value<DateTime> lastSyncTimestamp;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DailyHealthSummariesTableCompanion({
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.steps = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.activeMinutes = const Value.absent(),
    this.restingHeartRate = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.minHeartRate = const Value.absent(),
    this.avgSpo2 = const Value.absent(),
    this.sleepDurationMinutes = const Value.absent(),
    this.deepSleepMinutes = const Value.absent(),
    this.lightSleepMinutes = const Value.absent(),
    this.remSleepMinutes = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.sleepScore = const Value.absent(),
    this.wellnessScore = const Value.absent(),
    this.moveScore = const Value.absent(),
    this.recoverScore = const Value.absent(),
    this.readinessScore = const Value.absent(),
    this.lastSyncTimestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyHealthSummariesTableCompanion.insert({
    required String userId,
    required String date,
    required String deviceId,
    this.steps = const Value.absent(),
    this.caloriesBurned = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.activeMinutes = const Value.absent(),
    this.restingHeartRate = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.minHeartRate = const Value.absent(),
    this.avgSpo2 = const Value.absent(),
    this.sleepDurationMinutes = const Value.absent(),
    this.deepSleepMinutes = const Value.absent(),
    this.lightSleepMinutes = const Value.absent(),
    this.remSleepMinutes = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.sleepScore = const Value.absent(),
    this.wellnessScore = const Value.absent(),
    this.moveScore = const Value.absent(),
    this.recoverScore = const Value.absent(),
    this.readinessScore = const Value.absent(),
    required DateTime lastSyncTimestamp,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       date = Value(date),
       deviceId = Value(deviceId),
       lastSyncTimestamp = Value(lastSyncTimestamp);
  static Insertable<DailyHealthSummary> custom({
    Expression<String>? userId,
    Expression<String>? date,
    Expression<String>? deviceId,
    Expression<int>? steps,
    Expression<double>? caloriesBurned,
    Expression<double>? distanceMeters,
    Expression<int>? activeMinutes,
    Expression<int>? restingHeartRate,
    Expression<int>? avgHeartRate,
    Expression<int>? maxHeartRate,
    Expression<int>? minHeartRate,
    Expression<double>? avgSpo2,
    Expression<int>? sleepDurationMinutes,
    Expression<int>? deepSleepMinutes,
    Expression<int>? lightSleepMinutes,
    Expression<int>? remSleepMinutes,
    Expression<int>? awakeMinutes,
    Expression<int>? sleepScore,
    Expression<int>? wellnessScore,
    Expression<int>? moveScore,
    Expression<int>? recoverScore,
    Expression<int>? readinessScore,
    Expression<DateTime>? lastSyncTimestamp,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (deviceId != null) 'device_id': deviceId,
      if (steps != null) 'steps': steps,
      if (caloriesBurned != null) 'calories_burned': caloriesBurned,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (activeMinutes != null) 'active_minutes': activeMinutes,
      if (restingHeartRate != null) 'resting_heart_rate': restingHeartRate,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (minHeartRate != null) 'min_heart_rate': minHeartRate,
      if (avgSpo2 != null) 'avg_spo2': avgSpo2,
      if (sleepDurationMinutes != null)
        'sleep_duration_minutes': sleepDurationMinutes,
      if (deepSleepMinutes != null) 'deep_sleep_minutes': deepSleepMinutes,
      if (lightSleepMinutes != null) 'light_sleep_minutes': lightSleepMinutes,
      if (remSleepMinutes != null) 'rem_sleep_minutes': remSleepMinutes,
      if (awakeMinutes != null) 'awake_minutes': awakeMinutes,
      if (sleepScore != null) 'sleep_score': sleepScore,
      if (wellnessScore != null) 'wellness_score': wellnessScore,
      if (moveScore != null) 'move_score': moveScore,
      if (recoverScore != null) 'recover_score': recoverScore,
      if (readinessScore != null) 'readiness_score': readinessScore,
      if (lastSyncTimestamp != null) 'last_sync_timestamp': lastSyncTimestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyHealthSummariesTableCompanion copyWith({
    Value<String>? userId,
    Value<String>? date,
    Value<String>? deviceId,
    Value<int>? steps,
    Value<double>? caloriesBurned,
    Value<double>? distanceMeters,
    Value<int>? activeMinutes,
    Value<int?>? restingHeartRate,
    Value<int?>? avgHeartRate,
    Value<int?>? maxHeartRate,
    Value<int?>? minHeartRate,
    Value<double?>? avgSpo2,
    Value<int>? sleepDurationMinutes,
    Value<int>? deepSleepMinutes,
    Value<int>? lightSleepMinutes,
    Value<int>? remSleepMinutes,
    Value<int>? awakeMinutes,
    Value<int?>? sleepScore,
    Value<int?>? wellnessScore,
    Value<int?>? moveScore,
    Value<int?>? recoverScore,
    Value<int?>? readinessScore,
    Value<DateTime>? lastSyncTimestamp,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DailyHealthSummariesTableCompanion(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      deviceId: deviceId ?? this.deviceId,
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      minHeartRate: minHeartRate ?? this.minHeartRate,
      avgSpo2: avgSpo2 ?? this.avgSpo2,
      sleepDurationMinutes: sleepDurationMinutes ?? this.sleepDurationMinutes,
      deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
      lightSleepMinutes: lightSleepMinutes ?? this.lightSleepMinutes,
      remSleepMinutes: remSleepMinutes ?? this.remSleepMinutes,
      awakeMinutes: awakeMinutes ?? this.awakeMinutes,
      sleepScore: sleepScore ?? this.sleepScore,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      moveScore: moveScore ?? this.moveScore,
      recoverScore: recoverScore ?? this.recoverScore,
      readinessScore: readinessScore ?? this.readinessScore,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (caloriesBurned.present) {
      map['calories_burned'] = Variable<double>(caloriesBurned.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (activeMinutes.present) {
      map['active_minutes'] = Variable<int>(activeMinutes.value);
    }
    if (restingHeartRate.present) {
      map['resting_heart_rate'] = Variable<int>(restingHeartRate.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate.value);
    }
    if (minHeartRate.present) {
      map['min_heart_rate'] = Variable<int>(minHeartRate.value);
    }
    if (avgSpo2.present) {
      map['avg_spo2'] = Variable<double>(avgSpo2.value);
    }
    if (sleepDurationMinutes.present) {
      map['sleep_duration_minutes'] = Variable<int>(sleepDurationMinutes.value);
    }
    if (deepSleepMinutes.present) {
      map['deep_sleep_minutes'] = Variable<int>(deepSleepMinutes.value);
    }
    if (lightSleepMinutes.present) {
      map['light_sleep_minutes'] = Variable<int>(lightSleepMinutes.value);
    }
    if (remSleepMinutes.present) {
      map['rem_sleep_minutes'] = Variable<int>(remSleepMinutes.value);
    }
    if (awakeMinutes.present) {
      map['awake_minutes'] = Variable<int>(awakeMinutes.value);
    }
    if (sleepScore.present) {
      map['sleep_score'] = Variable<int>(sleepScore.value);
    }
    if (wellnessScore.present) {
      map['wellness_score'] = Variable<int>(wellnessScore.value);
    }
    if (moveScore.present) {
      map['move_score'] = Variable<int>(moveScore.value);
    }
    if (recoverScore.present) {
      map['recover_score'] = Variable<int>(recoverScore.value);
    }
    if (readinessScore.present) {
      map['readiness_score'] = Variable<int>(readinessScore.value);
    }
    if (lastSyncTimestamp.present) {
      map['last_sync_timestamp'] = Variable<DateTime>(lastSyncTimestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyHealthSummariesTableCompanion(')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('deviceId: $deviceId, ')
          ..write('steps: $steps, ')
          ..write('caloriesBurned: $caloriesBurned, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('activeMinutes: $activeMinutes, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('minHeartRate: $minHeartRate, ')
          ..write('avgSpo2: $avgSpo2, ')
          ..write('sleepDurationMinutes: $sleepDurationMinutes, ')
          ..write('deepSleepMinutes: $deepSleepMinutes, ')
          ..write('lightSleepMinutes: $lightSleepMinutes, ')
          ..write('remSleepMinutes: $remSleepMinutes, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('wellnessScore: $wellnessScore, ')
          ..write('moveScore: $moveScore, ')
          ..write('recoverScore: $recoverScore, ')
          ..write('readinessScore: $readinessScore, ')
          ..write('lastSyncTimestamp: $lastSyncTimestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeartRateSamplesTableTable extends HeartRateSamplesTable
    with TableInfo<$HeartRateSamplesTableTable, HeartRateSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeartRateSamplesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bpmMeta = const VerificationMeta('bpm');
  @override
  late final GeneratedColumn<int> bpm = GeneratedColumn<int>(
    'bpm',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRestingMeta = const VerificationMeta(
    'isResting',
  );
  @override
  late final GeneratedColumn<bool> isResting = GeneratedColumn<bool>(
    'is_resting',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_resting" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [deviceId, timestamp, bpm, isResting];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'heart_rate_samples_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HeartRateSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('bpm')) {
      context.handle(
        _bpmMeta,
        bpm.isAcceptableOrUnknown(data['bpm']!, _bpmMeta),
      );
    } else if (isInserting) {
      context.missing(_bpmMeta);
    }
    if (data.containsKey('is_resting')) {
      context.handle(
        _isRestingMeta,
        isResting.isAcceptableOrUnknown(data['is_resting']!, _isRestingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, timestamp};
  @override
  HeartRateSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeartRateSample(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      bpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bpm'],
      )!,
      isResting: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_resting'],
      )!,
    );
  }

  @override
  $HeartRateSamplesTableTable createAlias(String alias) {
    return $HeartRateSamplesTableTable(attachedDatabase, alias);
  }
}

class HeartRateSample extends DataClass implements Insertable<HeartRateSample> {
  final String deviceId;
  final DateTime timestamp;
  final int bpm;
  final bool isResting;
  const HeartRateSample({
    required this.deviceId,
    required this.timestamp,
    required this.bpm,
    required this.isResting,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['bpm'] = Variable<int>(bpm);
    map['is_resting'] = Variable<bool>(isResting);
    return map;
  }

  HeartRateSamplesTableCompanion toCompanion(bool nullToAbsent) {
    return HeartRateSamplesTableCompanion(
      deviceId: Value(deviceId),
      timestamp: Value(timestamp),
      bpm: Value(bpm),
      isResting: Value(isResting),
    );
  }

  factory HeartRateSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeartRateSample(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      bpm: serializer.fromJson<int>(json['bpm']),
      isResting: serializer.fromJson<bool>(json['isResting']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'bpm': serializer.toJson<int>(bpm),
      'isResting': serializer.toJson<bool>(isResting),
    };
  }

  HeartRateSample copyWith({
    String? deviceId,
    DateTime? timestamp,
    int? bpm,
    bool? isResting,
  }) => HeartRateSample(
    deviceId: deviceId ?? this.deviceId,
    timestamp: timestamp ?? this.timestamp,
    bpm: bpm ?? this.bpm,
    isResting: isResting ?? this.isResting,
  );
  HeartRateSample copyWithCompanion(HeartRateSamplesTableCompanion data) {
    return HeartRateSample(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      bpm: data.bpm.present ? data.bpm.value : this.bpm,
      isResting: data.isResting.present ? data.isResting.value : this.isResting,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeartRateSample(')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp, ')
          ..write('bpm: $bpm, ')
          ..write('isResting: $isResting')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, timestamp, bpm, isResting);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeartRateSample &&
          other.deviceId == this.deviceId &&
          other.timestamp == this.timestamp &&
          other.bpm == this.bpm &&
          other.isResting == this.isResting);
}

class HeartRateSamplesTableCompanion extends UpdateCompanion<HeartRateSample> {
  final Value<String> deviceId;
  final Value<DateTime> timestamp;
  final Value<int> bpm;
  final Value<bool> isResting;
  final Value<int> rowid;
  const HeartRateSamplesTableCompanion({
    this.deviceId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.bpm = const Value.absent(),
    this.isResting = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeartRateSamplesTableCompanion.insert({
    required String deviceId,
    required DateTime timestamp,
    required int bpm,
    this.isResting = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       timestamp = Value(timestamp),
       bpm = Value(bpm);
  static Insertable<HeartRateSample> custom({
    Expression<String>? deviceId,
    Expression<DateTime>? timestamp,
    Expression<int>? bpm,
    Expression<bool>? isResting,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (timestamp != null) 'timestamp': timestamp,
      if (bpm != null) 'bpm': bpm,
      if (isResting != null) 'is_resting': isResting,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeartRateSamplesTableCompanion copyWith({
    Value<String>? deviceId,
    Value<DateTime>? timestamp,
    Value<int>? bpm,
    Value<bool>? isResting,
    Value<int>? rowid,
  }) {
    return HeartRateSamplesTableCompanion(
      deviceId: deviceId ?? this.deviceId,
      timestamp: timestamp ?? this.timestamp,
      bpm: bpm ?? this.bpm,
      isResting: isResting ?? this.isResting,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (bpm.present) {
      map['bpm'] = Variable<int>(bpm.value);
    }
    if (isResting.present) {
      map['is_resting'] = Variable<bool>(isResting.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeartRateSamplesTableCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('timestamp: $timestamp, ')
          ..write('bpm: $bpm, ')
          ..write('isResting: $isResting, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepSessionsTableTable extends SleepSessionsTable
    with TableInfo<$SleepSessionsTableTable, SleepSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDurationMinutesMeta =
      const VerificationMeta('totalDurationMinutes');
  @override
  late final GeneratedColumn<int> totalDurationMinutes = GeneratedColumn<int>(
    'total_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deepMinutesMeta = const VerificationMeta(
    'deepMinutes',
  );
  @override
  late final GeneratedColumn<int> deepMinutes = GeneratedColumn<int>(
    'deep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lightMinutesMeta = const VerificationMeta(
    'lightMinutes',
  );
  @override
  late final GeneratedColumn<int> lightMinutes = GeneratedColumn<int>(
    'light_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _remMinutesMeta = const VerificationMeta(
    'remMinutes',
  );
  @override
  late final GeneratedColumn<int> remMinutes = GeneratedColumn<int>(
    'rem_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _awakeMinutesMeta = const VerificationMeta(
    'awakeMinutes',
  );
  @override
  late final GeneratedColumn<int> awakeMinutes = GeneratedColumn<int>(
    'awake_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sleepScoreMeta = const VerificationMeta(
    'sleepScore',
  );
  @override
  late final GeneratedColumn<int> sleepScore = GeneratedColumn<int>(
    'sleep_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    startTime,
    endTime,
    totalDurationMinutes,
    deepMinutes,
    lightMinutes,
    remMinutes,
    awakeMinutes,
    sleepScore,
    date,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('total_duration_minutes')) {
      context.handle(
        _totalDurationMinutesMeta,
        totalDurationMinutes.isAcceptableOrUnknown(
          data['total_duration_minutes']!,
          _totalDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalDurationMinutesMeta);
    }
    if (data.containsKey('deep_minutes')) {
      context.handle(
        _deepMinutesMeta,
        deepMinutes.isAcceptableOrUnknown(
          data['deep_minutes']!,
          _deepMinutesMeta,
        ),
      );
    }
    if (data.containsKey('light_minutes')) {
      context.handle(
        _lightMinutesMeta,
        lightMinutes.isAcceptableOrUnknown(
          data['light_minutes']!,
          _lightMinutesMeta,
        ),
      );
    }
    if (data.containsKey('rem_minutes')) {
      context.handle(
        _remMinutesMeta,
        remMinutes.isAcceptableOrUnknown(data['rem_minutes']!, _remMinutesMeta),
      );
    }
    if (data.containsKey('awake_minutes')) {
      context.handle(
        _awakeMinutesMeta,
        awakeMinutes.isAcceptableOrUnknown(
          data['awake_minutes']!,
          _awakeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('sleep_score')) {
      context.handle(
        _sleepScoreMeta,
        sleepScore.isAcceptableOrUnknown(data['sleep_score']!, _sleepScoreMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {deviceId, date},
  ];
  @override
  SleepSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      totalDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_minutes'],
      )!,
      deepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deep_minutes'],
      )!,
      lightMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}light_minutes'],
      )!,
      remMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rem_minutes'],
      )!,
      awakeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}awake_minutes'],
      )!,
      sleepScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_score'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $SleepSessionsTableTable createAlias(String alias) {
    return $SleepSessionsTableTable(attachedDatabase, alias);
  }
}

class SleepSession extends DataClass implements Insertable<SleepSession> {
  final int id;
  final String deviceId;
  final DateTime startTime;
  final DateTime endTime;
  final int totalDurationMinutes;
  final int deepMinutes;
  final int lightMinutes;
  final int remMinutes;
  final int awakeMinutes;
  final int? sleepScore;
  final String date;
  final DateTime syncedAt;
  const SleepSession({
    required this.id,
    required this.deviceId,
    required this.startTime,
    required this.endTime,
    required this.totalDurationMinutes,
    required this.deepMinutes,
    required this.lightMinutes,
    required this.remMinutes,
    required this.awakeMinutes,
    this.sleepScore,
    required this.date,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['total_duration_minutes'] = Variable<int>(totalDurationMinutes);
    map['deep_minutes'] = Variable<int>(deepMinutes);
    map['light_minutes'] = Variable<int>(lightMinutes);
    map['rem_minutes'] = Variable<int>(remMinutes);
    map['awake_minutes'] = Variable<int>(awakeMinutes);
    if (!nullToAbsent || sleepScore != null) {
      map['sleep_score'] = Variable<int>(sleepScore);
    }
    map['date'] = Variable<String>(date);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  SleepSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return SleepSessionsTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      startTime: Value(startTime),
      endTime: Value(endTime),
      totalDurationMinutes: Value(totalDurationMinutes),
      deepMinutes: Value(deepMinutes),
      lightMinutes: Value(lightMinutes),
      remMinutes: Value(remMinutes),
      awakeMinutes: Value(awakeMinutes),
      sleepScore: sleepScore == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepScore),
      date: Value(date),
      syncedAt: Value(syncedAt),
    );
  }

  factory SleepSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepSession(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      totalDurationMinutes: serializer.fromJson<int>(
        json['totalDurationMinutes'],
      ),
      deepMinutes: serializer.fromJson<int>(json['deepMinutes']),
      lightMinutes: serializer.fromJson<int>(json['lightMinutes']),
      remMinutes: serializer.fromJson<int>(json['remMinutes']),
      awakeMinutes: serializer.fromJson<int>(json['awakeMinutes']),
      sleepScore: serializer.fromJson<int?>(json['sleepScore']),
      date: serializer.fromJson<String>(json['date']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'totalDurationMinutes': serializer.toJson<int>(totalDurationMinutes),
      'deepMinutes': serializer.toJson<int>(deepMinutes),
      'lightMinutes': serializer.toJson<int>(lightMinutes),
      'remMinutes': serializer.toJson<int>(remMinutes),
      'awakeMinutes': serializer.toJson<int>(awakeMinutes),
      'sleepScore': serializer.toJson<int?>(sleepScore),
      'date': serializer.toJson<String>(date),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  SleepSession copyWith({
    int? id,
    String? deviceId,
    DateTime? startTime,
    DateTime? endTime,
    int? totalDurationMinutes,
    int? deepMinutes,
    int? lightMinutes,
    int? remMinutes,
    int? awakeMinutes,
    Value<int?> sleepScore = const Value.absent(),
    String? date,
    DateTime? syncedAt,
  }) => SleepSession(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
    deepMinutes: deepMinutes ?? this.deepMinutes,
    lightMinutes: lightMinutes ?? this.lightMinutes,
    remMinutes: remMinutes ?? this.remMinutes,
    awakeMinutes: awakeMinutes ?? this.awakeMinutes,
    sleepScore: sleepScore.present ? sleepScore.value : this.sleepScore,
    date: date ?? this.date,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  SleepSession copyWithCompanion(SleepSessionsTableCompanion data) {
    return SleepSession(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      totalDurationMinutes: data.totalDurationMinutes.present
          ? data.totalDurationMinutes.value
          : this.totalDurationMinutes,
      deepMinutes: data.deepMinutes.present
          ? data.deepMinutes.value
          : this.deepMinutes,
      lightMinutes: data.lightMinutes.present
          ? data.lightMinutes.value
          : this.lightMinutes,
      remMinutes: data.remMinutes.present
          ? data.remMinutes.value
          : this.remMinutes,
      awakeMinutes: data.awakeMinutes.present
          ? data.awakeMinutes.value
          : this.awakeMinutes,
      sleepScore: data.sleepScore.present
          ? data.sleepScore.value
          : this.sleepScore,
      date: data.date.present ? data.date.value : this.date,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepSession(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('totalDurationMinutes: $totalDurationMinutes, ')
          ..write('deepMinutes: $deepMinutes, ')
          ..write('lightMinutes: $lightMinutes, ')
          ..write('remMinutes: $remMinutes, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('date: $date, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    startTime,
    endTime,
    totalDurationMinutes,
    deepMinutes,
    lightMinutes,
    remMinutes,
    awakeMinutes,
    sleepScore,
    date,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepSession &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.totalDurationMinutes == this.totalDurationMinutes &&
          other.deepMinutes == this.deepMinutes &&
          other.lightMinutes == this.lightMinutes &&
          other.remMinutes == this.remMinutes &&
          other.awakeMinutes == this.awakeMinutes &&
          other.sleepScore == this.sleepScore &&
          other.date == this.date &&
          other.syncedAt == this.syncedAt);
}

class SleepSessionsTableCompanion extends UpdateCompanion<SleepSession> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> totalDurationMinutes;
  final Value<int> deepMinutes;
  final Value<int> lightMinutes;
  final Value<int> remMinutes;
  final Value<int> awakeMinutes;
  final Value<int?> sleepScore;
  final Value<String> date;
  final Value<DateTime> syncedAt;
  const SleepSessionsTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.totalDurationMinutes = const Value.absent(),
    this.deepMinutes = const Value.absent(),
    this.lightMinutes = const Value.absent(),
    this.remMinutes = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.sleepScore = const Value.absent(),
    this.date = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SleepSessionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime startTime,
    required DateTime endTime,
    required int totalDurationMinutes,
    this.deepMinutes = const Value.absent(),
    this.lightMinutes = const Value.absent(),
    this.remMinutes = const Value.absent(),
    this.awakeMinutes = const Value.absent(),
    this.sleepScore = const Value.absent(),
    required String date,
    this.syncedAt = const Value.absent(),
  }) : deviceId = Value(deviceId),
       startTime = Value(startTime),
       endTime = Value(endTime),
       totalDurationMinutes = Value(totalDurationMinutes),
       date = Value(date);
  static Insertable<SleepSession> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? totalDurationMinutes,
    Expression<int>? deepMinutes,
    Expression<int>? lightMinutes,
    Expression<int>? remMinutes,
    Expression<int>? awakeMinutes,
    Expression<int>? sleepScore,
    Expression<String>? date,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (totalDurationMinutes != null)
        'total_duration_minutes': totalDurationMinutes,
      if (deepMinutes != null) 'deep_minutes': deepMinutes,
      if (lightMinutes != null) 'light_minutes': lightMinutes,
      if (remMinutes != null) 'rem_minutes': remMinutes,
      if (awakeMinutes != null) 'awake_minutes': awakeMinutes,
      if (sleepScore != null) 'sleep_score': sleepScore,
      if (date != null) 'date': date,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SleepSessionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<int>? totalDurationMinutes,
    Value<int>? deepMinutes,
    Value<int>? lightMinutes,
    Value<int>? remMinutes,
    Value<int>? awakeMinutes,
    Value<int?>? sleepScore,
    Value<String>? date,
    Value<DateTime>? syncedAt,
  }) {
    return SleepSessionsTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      deepMinutes: deepMinutes ?? this.deepMinutes,
      lightMinutes: lightMinutes ?? this.lightMinutes,
      remMinutes: remMinutes ?? this.remMinutes,
      awakeMinutes: awakeMinutes ?? this.awakeMinutes,
      sleepScore: sleepScore ?? this.sleepScore,
      date: date ?? this.date,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (totalDurationMinutes.present) {
      map['total_duration_minutes'] = Variable<int>(totalDurationMinutes.value);
    }
    if (deepMinutes.present) {
      map['deep_minutes'] = Variable<int>(deepMinutes.value);
    }
    if (lightMinutes.present) {
      map['light_minutes'] = Variable<int>(lightMinutes.value);
    }
    if (remMinutes.present) {
      map['rem_minutes'] = Variable<int>(remMinutes.value);
    }
    if (awakeMinutes.present) {
      map['awake_minutes'] = Variable<int>(awakeMinutes.value);
    }
    if (sleepScore.present) {
      map['sleep_score'] = Variable<int>(sleepScore.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('totalDurationMinutes: $totalDurationMinutes, ')
          ..write('deepMinutes: $deepMinutes, ')
          ..write('lightMinutes: $lightMinutes, ')
          ..write('remMinutes: $remMinutes, ')
          ..write('awakeMinutes: $awakeMinutes, ')
          ..write('sleepScore: $sleepScore, ')
          ..write('date: $date, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $SleepPhasesTableTable extends SleepPhasesTable
    with TableInfo<$SleepPhasesTableTable, SleepPhase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepPhasesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sleep_sessions_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _phaseTypeMeta = const VerificationMeta(
    'phaseType',
  );
  @override
  late final GeneratedColumn<int> phaseType = GeneratedColumn<int>(
    'phase_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    phaseType,
    startTime,
    endTime,
    durationMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_phases_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepPhase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('phase_type')) {
      context.handle(
        _phaseTypeMeta,
        phaseType.isAcceptableOrUnknown(data['phase_type']!, _phaseTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseTypeMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepPhase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepPhase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      phaseType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phase_type'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
    );
  }

  @override
  $SleepPhasesTableTable createAlias(String alias) {
    return $SleepPhasesTableTable(attachedDatabase, alias);
  }
}

class SleepPhase extends DataClass implements Insertable<SleepPhase> {
  final int id;
  final int sessionId;
  final int phaseType;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  const SleepPhase({
    required this.id,
    required this.sessionId,
    required this.phaseType,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['phase_type'] = Variable<int>(phaseType);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    return map;
  }

  SleepPhasesTableCompanion toCompanion(bool nullToAbsent) {
    return SleepPhasesTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      phaseType: Value(phaseType),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationMinutes: Value(durationMinutes),
    );
  }

  factory SleepPhase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepPhase(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      phaseType: serializer.fromJson<int>(json['phaseType']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'phaseType': serializer.toJson<int>(phaseType),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
    };
  }

  SleepPhase copyWith({
    int? id,
    int? sessionId,
    int? phaseType,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
  }) => SleepPhase(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    phaseType: phaseType ?? this.phaseType,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    durationMinutes: durationMinutes ?? this.durationMinutes,
  );
  SleepPhase copyWithCompanion(SleepPhasesTableCompanion data) {
    return SleepPhase(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      phaseType: data.phaseType.present ? data.phaseType.value : this.phaseType,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepPhase(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('phaseType: $phaseType, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    phaseType,
    startTime,
    endTime,
    durationMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepPhase &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.phaseType == this.phaseType &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationMinutes == this.durationMinutes);
}

class SleepPhasesTableCompanion extends UpdateCompanion<SleepPhase> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> phaseType;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> durationMinutes;
  const SleepPhasesTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.phaseType = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationMinutes = const Value.absent(),
  });
  SleepPhasesTableCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int phaseType,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
  }) : sessionId = Value(sessionId),
       phaseType = Value(phaseType),
       startTime = Value(startTime),
       endTime = Value(endTime),
       durationMinutes = Value(durationMinutes);
  static Insertable<SleepPhase> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? phaseType,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (phaseType != null) 'phase_type': phaseType,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
    });
  }

  SleepPhasesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? phaseType,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<int>? durationMinutes,
  }) {
    return SleepPhasesTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      phaseType: phaseType ?? this.phaseType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (phaseType.present) {
      map['phase_type'] = Variable<int>(phaseType.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepPhasesTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('phaseType: $phaseType, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes')
          ..write(')'))
        .toString();
  }
}

class $VitalsRecordsTableTable extends VitalsRecordsTable
    with TableInfo<$VitalsRecordsTableTable, VitalsRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VitalsRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vitalTypeMeta = const VerificationMeta(
    'vitalType',
  );
  @override
  late final GeneratedColumn<String> vitalType = GeneratedColumn<String>(
    'vital_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueNumericMeta = const VerificationMeta(
    'valueNumeric',
  );
  @override
  late final GeneratedColumn<double> valueNumeric = GeneratedColumn<double>(
    'value_numeric',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryNumericMeta = const VerificationMeta(
    'secondaryNumeric',
  );
  @override
  late final GeneratedColumn<double> secondaryNumeric = GeneratedColumn<double>(
    'secondary_numeric',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawPayloadMeta = const VerificationMeta(
    'rawPayload',
  );
  @override
  late final GeneratedColumn<String> rawPayload = GeneratedColumn<String>(
    'raw_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    vitalType,
    valueNumeric,
    secondaryNumeric,
    unit,
    timestamp,
    rawPayload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vitals_records_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VitalsRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('vital_type')) {
      context.handle(
        _vitalTypeMeta,
        vitalType.isAcceptableOrUnknown(data['vital_type']!, _vitalTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_vitalTypeMeta);
    }
    if (data.containsKey('value_numeric')) {
      context.handle(
        _valueNumericMeta,
        valueNumeric.isAcceptableOrUnknown(
          data['value_numeric']!,
          _valueNumericMeta,
        ),
      );
    }
    if (data.containsKey('secondary_numeric')) {
      context.handle(
        _secondaryNumericMeta,
        secondaryNumeric.isAcceptableOrUnknown(
          data['secondary_numeric']!,
          _secondaryNumericMeta,
        ),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('raw_payload')) {
      context.handle(
        _rawPayloadMeta,
        rawPayload.isAcceptableOrUnknown(data['raw_payload']!, _rawPayloadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VitalsRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VitalsRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      vitalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vital_type'],
      )!,
      valueNumeric: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_numeric'],
      ),
      secondaryNumeric: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}secondary_numeric'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      rawPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_payload'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VitalsRecordsTableTable createAlias(String alias) {
    return $VitalsRecordsTableTable(attachedDatabase, alias);
  }
}

class VitalsRecord extends DataClass implements Insertable<VitalsRecord> {
  final int id;
  final String deviceId;
  final String vitalType;
  final double? valueNumeric;
  final double? secondaryNumeric;
  final String? unit;
  final DateTime timestamp;
  final String? rawPayload;
  final DateTime createdAt;
  const VitalsRecord({
    required this.id,
    required this.deviceId,
    required this.vitalType,
    this.valueNumeric,
    this.secondaryNumeric,
    this.unit,
    required this.timestamp,
    this.rawPayload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['vital_type'] = Variable<String>(vitalType);
    if (!nullToAbsent || valueNumeric != null) {
      map['value_numeric'] = Variable<double>(valueNumeric);
    }
    if (!nullToAbsent || secondaryNumeric != null) {
      map['secondary_numeric'] = Variable<double>(secondaryNumeric);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || rawPayload != null) {
      map['raw_payload'] = Variable<String>(rawPayload);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VitalsRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return VitalsRecordsTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      vitalType: Value(vitalType),
      valueNumeric: valueNumeric == null && nullToAbsent
          ? const Value.absent()
          : Value(valueNumeric),
      secondaryNumeric: secondaryNumeric == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryNumeric),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      timestamp: Value(timestamp),
      rawPayload: rawPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(rawPayload),
      createdAt: Value(createdAt),
    );
  }

  factory VitalsRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VitalsRecord(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      vitalType: serializer.fromJson<String>(json['vitalType']),
      valueNumeric: serializer.fromJson<double?>(json['valueNumeric']),
      secondaryNumeric: serializer.fromJson<double?>(json['secondaryNumeric']),
      unit: serializer.fromJson<String?>(json['unit']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      rawPayload: serializer.fromJson<String?>(json['rawPayload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'vitalType': serializer.toJson<String>(vitalType),
      'valueNumeric': serializer.toJson<double?>(valueNumeric),
      'secondaryNumeric': serializer.toJson<double?>(secondaryNumeric),
      'unit': serializer.toJson<String?>(unit),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'rawPayload': serializer.toJson<String?>(rawPayload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VitalsRecord copyWith({
    int? id,
    String? deviceId,
    String? vitalType,
    Value<double?> valueNumeric = const Value.absent(),
    Value<double?> secondaryNumeric = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    DateTime? timestamp,
    Value<String?> rawPayload = const Value.absent(),
    DateTime? createdAt,
  }) => VitalsRecord(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    vitalType: vitalType ?? this.vitalType,
    valueNumeric: valueNumeric.present ? valueNumeric.value : this.valueNumeric,
    secondaryNumeric: secondaryNumeric.present
        ? secondaryNumeric.value
        : this.secondaryNumeric,
    unit: unit.present ? unit.value : this.unit,
    timestamp: timestamp ?? this.timestamp,
    rawPayload: rawPayload.present ? rawPayload.value : this.rawPayload,
    createdAt: createdAt ?? this.createdAt,
  );
  VitalsRecord copyWithCompanion(VitalsRecordsTableCompanion data) {
    return VitalsRecord(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      vitalType: data.vitalType.present ? data.vitalType.value : this.vitalType,
      valueNumeric: data.valueNumeric.present
          ? data.valueNumeric.value
          : this.valueNumeric,
      secondaryNumeric: data.secondaryNumeric.present
          ? data.secondaryNumeric.value
          : this.secondaryNumeric,
      unit: data.unit.present ? data.unit.value : this.unit,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      rawPayload: data.rawPayload.present
          ? data.rawPayload.value
          : this.rawPayload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VitalsRecord(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('vitalType: $vitalType, ')
          ..write('valueNumeric: $valueNumeric, ')
          ..write('secondaryNumeric: $secondaryNumeric, ')
          ..write('unit: $unit, ')
          ..write('timestamp: $timestamp, ')
          ..write('rawPayload: $rawPayload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    vitalType,
    valueNumeric,
    secondaryNumeric,
    unit,
    timestamp,
    rawPayload,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VitalsRecord &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.vitalType == this.vitalType &&
          other.valueNumeric == this.valueNumeric &&
          other.secondaryNumeric == this.secondaryNumeric &&
          other.unit == this.unit &&
          other.timestamp == this.timestamp &&
          other.rawPayload == this.rawPayload &&
          other.createdAt == this.createdAt);
}

class VitalsRecordsTableCompanion extends UpdateCompanion<VitalsRecord> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> vitalType;
  final Value<double?> valueNumeric;
  final Value<double?> secondaryNumeric;
  final Value<String?> unit;
  final Value<DateTime> timestamp;
  final Value<String?> rawPayload;
  final Value<DateTime> createdAt;
  const VitalsRecordsTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.vitalType = const Value.absent(),
    this.valueNumeric = const Value.absent(),
    this.secondaryNumeric = const Value.absent(),
    this.unit = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rawPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VitalsRecordsTableCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required String vitalType,
    this.valueNumeric = const Value.absent(),
    this.secondaryNumeric = const Value.absent(),
    this.unit = const Value.absent(),
    required DateTime timestamp,
    this.rawPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : deviceId = Value(deviceId),
       vitalType = Value(vitalType),
       timestamp = Value(timestamp);
  static Insertable<VitalsRecord> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? vitalType,
    Expression<double>? valueNumeric,
    Expression<double>? secondaryNumeric,
    Expression<String>? unit,
    Expression<DateTime>? timestamp,
    Expression<String>? rawPayload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (vitalType != null) 'vital_type': vitalType,
      if (valueNumeric != null) 'value_numeric': valueNumeric,
      if (secondaryNumeric != null) 'secondary_numeric': secondaryNumeric,
      if (unit != null) 'unit': unit,
      if (timestamp != null) 'timestamp': timestamp,
      if (rawPayload != null) 'raw_payload': rawPayload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VitalsRecordsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String>? vitalType,
    Value<double?>? valueNumeric,
    Value<double?>? secondaryNumeric,
    Value<String?>? unit,
    Value<DateTime>? timestamp,
    Value<String?>? rawPayload,
    Value<DateTime>? createdAt,
  }) {
    return VitalsRecordsTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      vitalType: vitalType ?? this.vitalType,
      valueNumeric: valueNumeric ?? this.valueNumeric,
      secondaryNumeric: secondaryNumeric ?? this.secondaryNumeric,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      rawPayload: rawPayload ?? this.rawPayload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (vitalType.present) {
      map['vital_type'] = Variable<String>(vitalType.value);
    }
    if (valueNumeric.present) {
      map['value_numeric'] = Variable<double>(valueNumeric.value);
    }
    if (secondaryNumeric.present) {
      map['secondary_numeric'] = Variable<double>(secondaryNumeric.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rawPayload.present) {
      map['raw_payload'] = Variable<String>(rawPayload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VitalsRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('vitalType: $vitalType, ')
          ..write('valueNumeric: $valueNumeric, ')
          ..write('secondaryNumeric: $secondaryNumeric, ')
          ..write('unit: $unit, ')
          ..write('timestamp: $timestamp, ')
          ..write('rawPayload: $rawPayload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BandDevicesTableTable extends BandDevicesTable
    with TableInfo<$BandDevicesTableTable, BandDeviceEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BandDevicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _macAddressMeta = const VerificationMeta(
    'macAddress',
  );
  @override
  late final GeneratedColumn<String> macAddress = GeneratedColumn<String>(
    'mac_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelNumberMeta = const VerificationMeta(
    'modelNumber',
  );
  @override
  late final GeneratedColumn<String> modelNumber = GeneratedColumn<String>(
    'model_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firmwareVersionMeta = const VerificationMeta(
    'firmwareVersion',
  );
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
    'firmware_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryLevelMeta = const VerificationMeta(
    'batteryLevel',
  );
  @override
  late final GeneratedColumn<int> batteryLevel = GeneratedColumn<int>(
    'battery_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isChargingMeta = const VerificationMeta(
    'isCharging',
  );
  @override
  late final GeneratedColumn<bool> isCharging = GeneratedColumn<bool>(
    'is_charging',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_charging" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBondedMeta = const VerificationMeta(
    'isBonded',
  );
  @override
  late final GeneratedColumn<bool> isBonded = GeneratedColumn<bool>(
    'is_bonded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bonded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastConnectedAtMeta = const VerificationMeta(
    'lastConnectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastConnectedAt =
      GeneratedColumn<DateTime>(
        'last_connected_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    macAddress,
    deviceName,
    modelNumber,
    firmwareVersion,
    batteryLevel,
    isCharging,
    isBonded,
    lastConnectedAt,
    lastSyncAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'band_devices_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BandDeviceEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mac_address')) {
      context.handle(
        _macAddressMeta,
        macAddress.isAcceptableOrUnknown(data['mac_address']!, _macAddressMeta),
      );
    } else if (isInserting) {
      context.missing(_macAddressMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('model_number')) {
      context.handle(
        _modelNumberMeta,
        modelNumber.isAcceptableOrUnknown(
          data['model_number']!,
          _modelNumberMeta,
        ),
      );
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
        _firmwareVersionMeta,
        firmwareVersion.isAcceptableOrUnknown(
          data['firmware_version']!,
          _firmwareVersionMeta,
        ),
      );
    }
    if (data.containsKey('battery_level')) {
      context.handle(
        _batteryLevelMeta,
        batteryLevel.isAcceptableOrUnknown(
          data['battery_level']!,
          _batteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('is_charging')) {
      context.handle(
        _isChargingMeta,
        isCharging.isAcceptableOrUnknown(data['is_charging']!, _isChargingMeta),
      );
    }
    if (data.containsKey('is_bonded')) {
      context.handle(
        _isBondedMeta,
        isBonded.isAcceptableOrUnknown(data['is_bonded']!, _isBondedMeta),
      );
    }
    if (data.containsKey('last_connected_at')) {
      context.handle(
        _lastConnectedAtMeta,
        lastConnectedAt.isAcceptableOrUnknown(
          data['last_connected_at']!,
          _lastConnectedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {macAddress};
  @override
  BandDeviceEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BandDeviceEntry(
      macAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mac_address'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      modelNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_number'],
      ),
      firmwareVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmware_version'],
      ),
      batteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_level'],
      )!,
      isCharging: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_charging'],
      )!,
      isBonded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bonded'],
      )!,
      lastConnectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_connected_at'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BandDevicesTableTable createAlias(String alias) {
    return $BandDevicesTableTable(attachedDatabase, alias);
  }
}

class BandDeviceEntry extends DataClass implements Insertable<BandDeviceEntry> {
  final String macAddress;
  final String deviceName;
  final String? modelNumber;
  final String? firmwareVersion;
  final int batteryLevel;
  final bool isCharging;
  final bool isBonded;
  final DateTime? lastConnectedAt;
  final DateTime? lastSyncAt;
  final DateTime createdAt;
  const BandDeviceEntry({
    required this.macAddress,
    required this.deviceName,
    this.modelNumber,
    this.firmwareVersion,
    required this.batteryLevel,
    required this.isCharging,
    required this.isBonded,
    this.lastConnectedAt,
    this.lastSyncAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mac_address'] = Variable<String>(macAddress);
    map['device_name'] = Variable<String>(deviceName);
    if (!nullToAbsent || modelNumber != null) {
      map['model_number'] = Variable<String>(modelNumber);
    }
    if (!nullToAbsent || firmwareVersion != null) {
      map['firmware_version'] = Variable<String>(firmwareVersion);
    }
    map['battery_level'] = Variable<int>(batteryLevel);
    map['is_charging'] = Variable<bool>(isCharging);
    map['is_bonded'] = Variable<bool>(isBonded);
    if (!nullToAbsent || lastConnectedAt != null) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BandDevicesTableCompanion toCompanion(bool nullToAbsent) {
    return BandDevicesTableCompanion(
      macAddress: Value(macAddress),
      deviceName: Value(deviceName),
      modelNumber: modelNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(modelNumber),
      firmwareVersion: firmwareVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(firmwareVersion),
      batteryLevel: Value(batteryLevel),
      isCharging: Value(isCharging),
      isBonded: Value(isBonded),
      lastConnectedAt: lastConnectedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConnectedAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      createdAt: Value(createdAt),
    );
  }

  factory BandDeviceEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BandDeviceEntry(
      macAddress: serializer.fromJson<String>(json['macAddress']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      modelNumber: serializer.fromJson<String?>(json['modelNumber']),
      firmwareVersion: serializer.fromJson<String?>(json['firmwareVersion']),
      batteryLevel: serializer.fromJson<int>(json['batteryLevel']),
      isCharging: serializer.fromJson<bool>(json['isCharging']),
      isBonded: serializer.fromJson<bool>(json['isBonded']),
      lastConnectedAt: serializer.fromJson<DateTime?>(json['lastConnectedAt']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'macAddress': serializer.toJson<String>(macAddress),
      'deviceName': serializer.toJson<String>(deviceName),
      'modelNumber': serializer.toJson<String?>(modelNumber),
      'firmwareVersion': serializer.toJson<String?>(firmwareVersion),
      'batteryLevel': serializer.toJson<int>(batteryLevel),
      'isCharging': serializer.toJson<bool>(isCharging),
      'isBonded': serializer.toJson<bool>(isBonded),
      'lastConnectedAt': serializer.toJson<DateTime?>(lastConnectedAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BandDeviceEntry copyWith({
    String? macAddress,
    String? deviceName,
    Value<String?> modelNumber = const Value.absent(),
    Value<String?> firmwareVersion = const Value.absent(),
    int? batteryLevel,
    bool? isCharging,
    bool? isBonded,
    Value<DateTime?> lastConnectedAt = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
    DateTime? createdAt,
  }) => BandDeviceEntry(
    macAddress: macAddress ?? this.macAddress,
    deviceName: deviceName ?? this.deviceName,
    modelNumber: modelNumber.present ? modelNumber.value : this.modelNumber,
    firmwareVersion: firmwareVersion.present
        ? firmwareVersion.value
        : this.firmwareVersion,
    batteryLevel: batteryLevel ?? this.batteryLevel,
    isCharging: isCharging ?? this.isCharging,
    isBonded: isBonded ?? this.isBonded,
    lastConnectedAt: lastConnectedAt.present
        ? lastConnectedAt.value
        : this.lastConnectedAt,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    createdAt: createdAt ?? this.createdAt,
  );
  BandDeviceEntry copyWithCompanion(BandDevicesTableCompanion data) {
    return BandDeviceEntry(
      macAddress: data.macAddress.present
          ? data.macAddress.value
          : this.macAddress,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      modelNumber: data.modelNumber.present
          ? data.modelNumber.value
          : this.modelNumber,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      isCharging: data.isCharging.present
          ? data.isCharging.value
          : this.isCharging,
      isBonded: data.isBonded.present ? data.isBonded.value : this.isBonded,
      lastConnectedAt: data.lastConnectedAt.present
          ? data.lastConnectedAt.value
          : this.lastConnectedAt,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BandDeviceEntry(')
          ..write('macAddress: $macAddress, ')
          ..write('deviceName: $deviceName, ')
          ..write('modelNumber: $modelNumber, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('isCharging: $isCharging, ')
          ..write('isBonded: $isBonded, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    macAddress,
    deviceName,
    modelNumber,
    firmwareVersion,
    batteryLevel,
    isCharging,
    isBonded,
    lastConnectedAt,
    lastSyncAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BandDeviceEntry &&
          other.macAddress == this.macAddress &&
          other.deviceName == this.deviceName &&
          other.modelNumber == this.modelNumber &&
          other.firmwareVersion == this.firmwareVersion &&
          other.batteryLevel == this.batteryLevel &&
          other.isCharging == this.isCharging &&
          other.isBonded == this.isBonded &&
          other.lastConnectedAt == this.lastConnectedAt &&
          other.lastSyncAt == this.lastSyncAt &&
          other.createdAt == this.createdAt);
}

class BandDevicesTableCompanion extends UpdateCompanion<BandDeviceEntry> {
  final Value<String> macAddress;
  final Value<String> deviceName;
  final Value<String?> modelNumber;
  final Value<String?> firmwareVersion;
  final Value<int> batteryLevel;
  final Value<bool> isCharging;
  final Value<bool> isBonded;
  final Value<DateTime?> lastConnectedAt;
  final Value<DateTime?> lastSyncAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BandDevicesTableCompanion({
    this.macAddress = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.modelNumber = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.isCharging = const Value.absent(),
    this.isBonded = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BandDevicesTableCompanion.insert({
    required String macAddress,
    required String deviceName,
    this.modelNumber = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.isCharging = const Value.absent(),
    this.isBonded = const Value.absent(),
    this.lastConnectedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : macAddress = Value(macAddress),
       deviceName = Value(deviceName);
  static Insertable<BandDeviceEntry> custom({
    Expression<String>? macAddress,
    Expression<String>? deviceName,
    Expression<String>? modelNumber,
    Expression<String>? firmwareVersion,
    Expression<int>? batteryLevel,
    Expression<bool>? isCharging,
    Expression<bool>? isBonded,
    Expression<DateTime>? lastConnectedAt,
    Expression<DateTime>? lastSyncAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (macAddress != null) 'mac_address': macAddress,
      if (deviceName != null) 'device_name': deviceName,
      if (modelNumber != null) 'model_number': modelNumber,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (isCharging != null) 'is_charging': isCharging,
      if (isBonded != null) 'is_bonded': isBonded,
      if (lastConnectedAt != null) 'last_connected_at': lastConnectedAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BandDevicesTableCompanion copyWith({
    Value<String>? macAddress,
    Value<String>? deviceName,
    Value<String?>? modelNumber,
    Value<String?>? firmwareVersion,
    Value<int>? batteryLevel,
    Value<bool>? isCharging,
    Value<bool>? isBonded,
    Value<DateTime?>? lastConnectedAt,
    Value<DateTime?>? lastSyncAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BandDevicesTableCompanion(
      macAddress: macAddress ?? this.macAddress,
      deviceName: deviceName ?? this.deviceName,
      modelNumber: modelNumber ?? this.modelNumber,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      isBonded: isBonded ?? this.isBonded,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (macAddress.present) {
      map['mac_address'] = Variable<String>(macAddress.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (modelNumber.present) {
      map['model_number'] = Variable<String>(modelNumber.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<int>(batteryLevel.value);
    }
    if (isCharging.present) {
      map['is_charging'] = Variable<bool>(isCharging.value);
    }
    if (isBonded.present) {
      map['is_bonded'] = Variable<bool>(isBonded.value);
    }
    if (lastConnectedAt.present) {
      map['last_connected_at'] = Variable<DateTime>(lastConnectedAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BandDevicesTableCompanion(')
          ..write('macAddress: $macAddress, ')
          ..write('deviceName: $deviceName, ')
          ..write('modelNumber: $modelNumber, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('isCharging: $isCharging, ')
          ..write('isBonded: $isBonded, ')
          ..write('lastConnectedAt: $lastConnectedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    endpoint,
    payload,
    status,
    retryCount,
    createdAt,
    lastAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final int id;
  final String endpoint;
  final String payload;
  final String status;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  const SyncQueueItem({
    required this.id,
    required this.endpoint,
    required this.payload,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.lastAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['endpoint'] = Variable<String>(endpoint);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      endpoint: Value(endpoint),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory SyncQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'endpoint': serializer.toJson<String>(endpoint),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  SyncQueueItem copyWith({
    int? id,
    String? endpoint,
    String? payload,
    String? status,
    int? retryCount,
    DateTime? createdAt,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
  }) => SyncQueueItem(
    id: id ?? this.id,
    endpoint: endpoint ?? this.endpoint,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
  );
  SyncQueueItem copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    endpoint,
    payload,
    status,
    retryCount,
    createdAt,
    lastAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.endpoint == this.endpoint &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> endpoint;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    this.id = const Value.absent(),
    required String endpoint,
    required String payload,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
  }) : endpoint = Value(endpoint),
       payload = Value(payload);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? endpoint,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (endpoint != null) 'endpoint': endpoint,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<int>? id,
    Value<String>? endpoint,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttemptAt,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTableTable extends WorkoutSessionsTable
    with TableInfo<$WorkoutSessionsTableTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _burnedCaloriesMeta = const VerificationMeta(
    'burnedCalories',
  );
  @override
  late final GeneratedColumn<int> burnedCalories = GeneratedColumn<int>(
    'burned_calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _peakHeartRateMeta = const VerificationMeta(
    'peakHeartRate',
  );
  @override
  late final GeneratedColumn<int> peakHeartRate = GeneratedColumn<int>(
    'peak_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    category,
    durationSeconds,
    burnedCalories,
    avgHeartRate,
    peakHeartRate,
    startTime,
    endTime,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('burned_calories')) {
      context.handle(
        _burnedCaloriesMeta,
        burnedCalories.isAcceptableOrUnknown(
          data['burned_calories']!,
          _burnedCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('peak_heart_rate')) {
      context.handle(
        _peakHeartRateMeta,
        peakHeartRate.isAcceptableOrUnknown(
          data['peak_heart_rate']!,
          _peakHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      burnedCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}burned_calories'],
      )!,
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      )!,
      peakHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peak_heart_rate'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTableTable createAlias(String alias) {
    return $WorkoutSessionsTableTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final int id;
  final String userId;
  final String title;
  final String category;
  final int durationSeconds;
  final int burnedCalories;
  final int avgHeartRate;
  final int peakHeartRate;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.durationSeconds,
    required this.burnedCalories,
    required this.avgHeartRate,
    required this.peakHeartRate,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['burned_calories'] = Variable<int>(burnedCalories);
    map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    map['peak_heart_rate'] = Variable<int>(peakHeartRate);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkoutSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      category: Value(category),
      durationSeconds: Value(durationSeconds),
      burnedCalories: Value(burnedCalories),
      avgHeartRate: Value(avgHeartRate),
      peakHeartRate: Value(peakHeartRate),
      startTime: Value(startTime),
      endTime: Value(endTime),
      createdAt: Value(createdAt),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      burnedCalories: serializer.fromJson<int>(json['burnedCalories']),
      avgHeartRate: serializer.fromJson<int>(json['avgHeartRate']),
      peakHeartRate: serializer.fromJson<int>(json['peakHeartRate']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'burnedCalories': serializer.toJson<int>(burnedCalories),
      'avgHeartRate': serializer.toJson<int>(avgHeartRate),
      'peakHeartRate': serializer.toJson<int>(peakHeartRate),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkoutSession copyWith({
    int? id,
    String? userId,
    String? title,
    String? category,
    int? durationSeconds,
    int? burnedCalories,
    int? avgHeartRate,
    int? peakHeartRate,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
  }) => WorkoutSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    category: category ?? this.category,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    burnedCalories: burnedCalories ?? this.burnedCalories,
    avgHeartRate: avgHeartRate ?? this.avgHeartRate,
    peakHeartRate: peakHeartRate ?? this.peakHeartRate,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    createdAt: createdAt ?? this.createdAt,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsTableCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      burnedCalories: data.burnedCalories.present
          ? data.burnedCalories.value
          : this.burnedCalories,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      peakHeartRate: data.peakHeartRate.present
          ? data.peakHeartRate.value
          : this.peakHeartRate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('burnedCalories: $burnedCalories, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('peakHeartRate: $peakHeartRate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    category,
    durationSeconds,
    burnedCalories,
    avgHeartRate,
    peakHeartRate,
    startTime,
    endTime,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.category == this.category &&
          other.durationSeconds == this.durationSeconds &&
          other.burnedCalories == this.burnedCalories &&
          other.avgHeartRate == this.avgHeartRate &&
          other.peakHeartRate == this.peakHeartRate &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.createdAt == this.createdAt);
}

class WorkoutSessionsTableCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> category;
  final Value<int> durationSeconds;
  final Value<int> burnedCalories;
  final Value<int> avgHeartRate;
  final Value<int> peakHeartRate;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<DateTime> createdAt;
  const WorkoutSessionsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.burnedCalories = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.peakHeartRate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WorkoutSessionsTableCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required String title,
    required String category,
    required int durationSeconds,
    this.burnedCalories = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.peakHeartRate = const Value.absent(),
    required DateTime startTime,
    required DateTime endTime,
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       category = Value(category),
       durationSeconds = Value(durationSeconds),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<WorkoutSession> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? category,
    Expression<int>? durationSeconds,
    Expression<int>? burnedCalories,
    Expression<int>? avgHeartRate,
    Expression<int>? peakHeartRate,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (burnedCalories != null) 'burned_calories': burnedCalories,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (peakHeartRate != null) 'peak_heart_rate': peakHeartRate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WorkoutSessionsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? category,
    Value<int>? durationSeconds,
    Value<int>? burnedCalories,
    Value<int>? avgHeartRate,
    Value<int>? peakHeartRate,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<DateTime>? createdAt,
  }) {
    return WorkoutSessionsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      burnedCalories: burnedCalories ?? this.burnedCalories,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      peakHeartRate: peakHeartRate ?? this.peakHeartRate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (burnedCalories.present) {
      map['burned_calories'] = Variable<int>(burnedCalories.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (peakHeartRate.present) {
      map['peak_heart_rate'] = Variable<int>(peakHeartRate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('burnedCalories: $burnedCalories, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('peakHeartRate: $peakHeartRate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserRoutinesTableTable extends UserRoutinesTable
    with TableInfo<$UserRoutinesTableTable, UserRoutine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRoutinesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _routineNameMeta = const VerificationMeta(
    'routineName',
  );
  @override
  late final GeneratedColumn<String> routineName = GeneratedColumn<String>(
    'routine_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
    'duration_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(14),
  );
  static const VerificationMeta _movementsJsonMeta = const VerificationMeta(
    'movementsJson',
  );
  @override
  late final GeneratedColumn<String> movementsJson = GeneratedColumn<String>(
    'movements_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _wellnessJsonMeta = const VerificationMeta(
    'wellnessJson',
  );
  @override
  late final GeneratedColumn<String> wellnessJson = GeneratedColumn<String>(
    'wellness_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _routineItemsJsonMeta = const VerificationMeta(
    'routineItemsJson',
  );
  @override
  late final GeneratedColumn<String> routineItemsJson = GeneratedColumn<String>(
    'routine_items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    routineName,
    durationDays,
    movementsJson,
    wellnessJson,
    routineItemsJson,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_routines_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRoutine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('routine_name')) {
      context.handle(
        _routineNameMeta,
        routineName.isAcceptableOrUnknown(
          data['routine_name']!,
          _routineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineNameMeta);
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    }
    if (data.containsKey('movements_json')) {
      context.handle(
        _movementsJsonMeta,
        movementsJson.isAcceptableOrUnknown(
          data['movements_json']!,
          _movementsJsonMeta,
        ),
      );
    }
    if (data.containsKey('wellness_json')) {
      context.handle(
        _wellnessJsonMeta,
        wellnessJson.isAcceptableOrUnknown(
          data['wellness_json']!,
          _wellnessJsonMeta,
        ),
      );
    }
    if (data.containsKey('routine_items_json')) {
      context.handle(
        _routineItemsJsonMeta,
        routineItemsJson.isAcceptableOrUnknown(
          data['routine_items_json']!,
          _routineItemsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRoutine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRoutine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      routineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_name'],
      )!,
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_days'],
      )!,
      movementsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movements_json'],
      )!,
      wellnessJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wellness_json'],
      )!,
      routineItemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_items_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserRoutinesTableTable createAlias(String alias) {
    return $UserRoutinesTableTable(attachedDatabase, alias);
  }
}

class UserRoutine extends DataClass implements Insertable<UserRoutine> {
  final int id;
  final String userId;
  final String routineName;
  final int durationDays;
  final String movementsJson;
  final String wellnessJson;
  final String routineItemsJson;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserRoutine({
    required this.id,
    required this.userId,
    required this.routineName,
    required this.durationDays,
    required this.movementsJson,
    required this.wellnessJson,
    required this.routineItemsJson,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['routine_name'] = Variable<String>(routineName);
    map['duration_days'] = Variable<int>(durationDays);
    map['movements_json'] = Variable<String>(movementsJson);
    map['wellness_json'] = Variable<String>(wellnessJson);
    map['routine_items_json'] = Variable<String>(routineItemsJson);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserRoutinesTableCompanion toCompanion(bool nullToAbsent) {
    return UserRoutinesTableCompanion(
      id: Value(id),
      userId: Value(userId),
      routineName: Value(routineName),
      durationDays: Value(durationDays),
      movementsJson: Value(movementsJson),
      wellnessJson: Value(wellnessJson),
      routineItemsJson: Value(routineItemsJson),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserRoutine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRoutine(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      routineName: serializer.fromJson<String>(json['routineName']),
      durationDays: serializer.fromJson<int>(json['durationDays']),
      movementsJson: serializer.fromJson<String>(json['movementsJson']),
      wellnessJson: serializer.fromJson<String>(json['wellnessJson']),
      routineItemsJson: serializer.fromJson<String>(json['routineItemsJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'routineName': serializer.toJson<String>(routineName),
      'durationDays': serializer.toJson<int>(durationDays),
      'movementsJson': serializer.toJson<String>(movementsJson),
      'wellnessJson': serializer.toJson<String>(wellnessJson),
      'routineItemsJson': serializer.toJson<String>(routineItemsJson),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserRoutine copyWith({
    int? id,
    String? userId,
    String? routineName,
    int? durationDays,
    String? movementsJson,
    String? wellnessJson,
    String? routineItemsJson,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserRoutine(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    routineName: routineName ?? this.routineName,
    durationDays: durationDays ?? this.durationDays,
    movementsJson: movementsJson ?? this.movementsJson,
    wellnessJson: wellnessJson ?? this.wellnessJson,
    routineItemsJson: routineItemsJson ?? this.routineItemsJson,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserRoutine copyWithCompanion(UserRoutinesTableCompanion data) {
    return UserRoutine(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      routineName: data.routineName.present
          ? data.routineName.value
          : this.routineName,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      movementsJson: data.movementsJson.present
          ? data.movementsJson.value
          : this.movementsJson,
      wellnessJson: data.wellnessJson.present
          ? data.wellnessJson.value
          : this.wellnessJson,
      routineItemsJson: data.routineItemsJson.present
          ? data.routineItemsJson.value
          : this.routineItemsJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRoutine(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('routineName: $routineName, ')
          ..write('durationDays: $durationDays, ')
          ..write('movementsJson: $movementsJson, ')
          ..write('wellnessJson: $wellnessJson, ')
          ..write('routineItemsJson: $routineItemsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    routineName,
    durationDays,
    movementsJson,
    wellnessJson,
    routineItemsJson,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRoutine &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.routineName == this.routineName &&
          other.durationDays == this.durationDays &&
          other.movementsJson == this.movementsJson &&
          other.wellnessJson == this.wellnessJson &&
          other.routineItemsJson == this.routineItemsJson &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserRoutinesTableCompanion extends UpdateCompanion<UserRoutine> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> routineName;
  final Value<int> durationDays;
  final Value<String> movementsJson;
  final Value<String> wellnessJson;
  final Value<String> routineItemsJson;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserRoutinesTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.routineName = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.movementsJson = const Value.absent(),
    this.wellnessJson = const Value.absent(),
    this.routineItemsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserRoutinesTableCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required String routineName,
    this.durationDays = const Value.absent(),
    this.movementsJson = const Value.absent(),
    this.wellnessJson = const Value.absent(),
    this.routineItemsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : routineName = Value(routineName);
  static Insertable<UserRoutine> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? routineName,
    Expression<int>? durationDays,
    Expression<String>? movementsJson,
    Expression<String>? wellnessJson,
    Expression<String>? routineItemsJson,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (routineName != null) 'routine_name': routineName,
      if (durationDays != null) 'duration_days': durationDays,
      if (movementsJson != null) 'movements_json': movementsJson,
      if (wellnessJson != null) 'wellness_json': wellnessJson,
      if (routineItemsJson != null) 'routine_items_json': routineItemsJson,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserRoutinesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? routineName,
    Value<int>? durationDays,
    Value<String>? movementsJson,
    Value<String>? wellnessJson,
    Value<String>? routineItemsJson,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return UserRoutinesTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routineName: routineName ?? this.routineName,
      durationDays: durationDays ?? this.durationDays,
      movementsJson: movementsJson ?? this.movementsJson,
      wellnessJson: wellnessJson ?? this.wellnessJson,
      routineItemsJson: routineItemsJson ?? this.routineItemsJson,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (routineName.present) {
      map['routine_name'] = Variable<String>(routineName.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (movementsJson.present) {
      map['movements_json'] = Variable<String>(movementsJson.value);
    }
    if (wellnessJson.present) {
      map['wellness_json'] = Variable<String>(wellnessJson.value);
    }
    if (routineItemsJson.present) {
      map['routine_items_json'] = Variable<String>(routineItemsJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRoutinesTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('routineName: $routineName, ')
          ..write('durationDays: $durationDays, ')
          ..write('movementsJson: $movementsJson, ')
          ..write('wellnessJson: $wellnessJson, ')
          ..write('routineItemsJson: $routineItemsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyHealthSummariesTableTable dailyHealthSummariesTable =
      $DailyHealthSummariesTableTable(this);
  late final $HeartRateSamplesTableTable heartRateSamplesTable =
      $HeartRateSamplesTableTable(this);
  late final $SleepSessionsTableTable sleepSessionsTable =
      $SleepSessionsTableTable(this);
  late final $SleepPhasesTableTable sleepPhasesTable = $SleepPhasesTableTable(
    this,
  );
  late final $VitalsRecordsTableTable vitalsRecordsTable =
      $VitalsRecordsTableTable(this);
  late final $BandDevicesTableTable bandDevicesTable = $BandDevicesTableTable(
    this,
  );
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $WorkoutSessionsTableTable workoutSessionsTable =
      $WorkoutSessionsTableTable(this);
  late final $UserRoutinesTableTable userRoutinesTable =
      $UserRoutinesTableTable(this);
  late final HealthDataDao healthDataDao = HealthDataDao(this as AppDatabase);
  late final DeviceDao deviceDao = DeviceDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dailyHealthSummariesTable,
    heartRateSamplesTable,
    sleepSessionsTable,
    sleepPhasesTable,
    vitalsRecordsTable,
    bandDevicesTable,
    syncQueueTable,
    workoutSessionsTable,
    userRoutinesTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sleep_sessions_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sleep_phases_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DailyHealthSummariesTableTableCreateCompanionBuilder =
    DailyHealthSummariesTableCompanion Function({
      required String userId,
      required String date,
      required String deviceId,
      Value<int> steps,
      Value<double> caloriesBurned,
      Value<double> distanceMeters,
      Value<int> activeMinutes,
      Value<int?> restingHeartRate,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> minHeartRate,
      Value<double?> avgSpo2,
      Value<int> sleepDurationMinutes,
      Value<int> deepSleepMinutes,
      Value<int> lightSleepMinutes,
      Value<int> remSleepMinutes,
      Value<int> awakeMinutes,
      Value<int?> sleepScore,
      Value<int?> wellnessScore,
      Value<int?> moveScore,
      Value<int?> recoverScore,
      Value<int?> readinessScore,
      required DateTime lastSyncTimestamp,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DailyHealthSummariesTableTableUpdateCompanionBuilder =
    DailyHealthSummariesTableCompanion Function({
      Value<String> userId,
      Value<String> date,
      Value<String> deviceId,
      Value<int> steps,
      Value<double> caloriesBurned,
      Value<double> distanceMeters,
      Value<int> activeMinutes,
      Value<int?> restingHeartRate,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> minHeartRate,
      Value<double?> avgSpo2,
      Value<int> sleepDurationMinutes,
      Value<int> deepSleepMinutes,
      Value<int> lightSleepMinutes,
      Value<int> remSleepMinutes,
      Value<int> awakeMinutes,
      Value<int?> sleepScore,
      Value<int?> wellnessScore,
      Value<int?> moveScore,
      Value<int?> recoverScore,
      Value<int?> readinessScore,
      Value<DateTime> lastSyncTimestamp,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DailyHealthSummariesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyHealthSummariesTableTable> {
  $$DailyHealthSummariesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeMinutes => $composableBuilder(
    column: $table.activeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minHeartRate => $composableBuilder(
    column: $table.minHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpo2 => $composableBuilder(
    column: $table.avgSpo2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepDurationMinutes => $composableBuilder(
    column: $table.sleepDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deepSleepMinutes => $composableBuilder(
    column: $table.deepSleepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lightSleepMinutes => $composableBuilder(
    column: $table.lightSleepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remSleepMinutes => $composableBuilder(
    column: $table.remSleepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wellnessScore => $composableBuilder(
    column: $table.wellnessScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moveScore => $composableBuilder(
    column: $table.moveScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recoverScore => $composableBuilder(
    column: $table.recoverScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readinessScore => $composableBuilder(
    column: $table.readinessScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyHealthSummariesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyHealthSummariesTableTable> {
  $$DailyHealthSummariesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeMinutes => $composableBuilder(
    column: $table.activeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minHeartRate => $composableBuilder(
    column: $table.minHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpo2 => $composableBuilder(
    column: $table.avgSpo2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepDurationMinutes => $composableBuilder(
    column: $table.sleepDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deepSleepMinutes => $composableBuilder(
    column: $table.deepSleepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lightSleepMinutes => $composableBuilder(
    column: $table.lightSleepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remSleepMinutes => $composableBuilder(
    column: $table.remSleepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wellnessScore => $composableBuilder(
    column: $table.wellnessScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moveScore => $composableBuilder(
    column: $table.moveScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recoverScore => $composableBuilder(
    column: $table.recoverScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readinessScore => $composableBuilder(
    column: $table.readinessScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyHealthSummariesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyHealthSummariesTableTable> {
  $$DailyHealthSummariesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<double> get caloriesBurned => $composableBuilder(
    column: $table.caloriesBurned,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeMinutes => $composableBuilder(
    column: $table.activeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minHeartRate => $composableBuilder(
    column: $table.minHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpo2 =>
      $composableBuilder(column: $table.avgSpo2, builder: (column) => column);

  GeneratedColumn<int> get sleepDurationMinutes => $composableBuilder(
    column: $table.sleepDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deepSleepMinutes => $composableBuilder(
    column: $table.deepSleepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lightSleepMinutes => $composableBuilder(
    column: $table.lightSleepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remSleepMinutes => $composableBuilder(
    column: $table.remSleepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wellnessScore => $composableBuilder(
    column: $table.wellnessScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get moveScore =>
      $composableBuilder(column: $table.moveScore, builder: (column) => column);

  GeneratedColumn<int> get recoverScore => $composableBuilder(
    column: $table.recoverScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readinessScore => $composableBuilder(
    column: $table.readinessScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncTimestamp => $composableBuilder(
    column: $table.lastSyncTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DailyHealthSummariesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyHealthSummariesTableTable,
          DailyHealthSummary,
          $$DailyHealthSummariesTableTableFilterComposer,
          $$DailyHealthSummariesTableTableOrderingComposer,
          $$DailyHealthSummariesTableTableAnnotationComposer,
          $$DailyHealthSummariesTableTableCreateCompanionBuilder,
          $$DailyHealthSummariesTableTableUpdateCompanionBuilder,
          (
            DailyHealthSummary,
            BaseReferences<
              _$AppDatabase,
              $DailyHealthSummariesTableTable,
              DailyHealthSummary
            >,
          ),
          DailyHealthSummary,
          PrefetchHooks Function()
        > {
  $$DailyHealthSummariesTableTableTableManager(
    _$AppDatabase db,
    $DailyHealthSummariesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyHealthSummariesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DailyHealthSummariesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DailyHealthSummariesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<double> caloriesBurned = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> activeMinutes = const Value.absent(),
                Value<int?> restingHeartRate = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> minHeartRate = const Value.absent(),
                Value<double?> avgSpo2 = const Value.absent(),
                Value<int> sleepDurationMinutes = const Value.absent(),
                Value<int> deepSleepMinutes = const Value.absent(),
                Value<int> lightSleepMinutes = const Value.absent(),
                Value<int> remSleepMinutes = const Value.absent(),
                Value<int> awakeMinutes = const Value.absent(),
                Value<int?> sleepScore = const Value.absent(),
                Value<int?> wellnessScore = const Value.absent(),
                Value<int?> moveScore = const Value.absent(),
                Value<int?> recoverScore = const Value.absent(),
                Value<int?> readinessScore = const Value.absent(),
                Value<DateTime> lastSyncTimestamp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyHealthSummariesTableCompanion(
                userId: userId,
                date: date,
                deviceId: deviceId,
                steps: steps,
                caloriesBurned: caloriesBurned,
                distanceMeters: distanceMeters,
                activeMinutes: activeMinutes,
                restingHeartRate: restingHeartRate,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                minHeartRate: minHeartRate,
                avgSpo2: avgSpo2,
                sleepDurationMinutes: sleepDurationMinutes,
                deepSleepMinutes: deepSleepMinutes,
                lightSleepMinutes: lightSleepMinutes,
                remSleepMinutes: remSleepMinutes,
                awakeMinutes: awakeMinutes,
                sleepScore: sleepScore,
                wellnessScore: wellnessScore,
                moveScore: moveScore,
                recoverScore: recoverScore,
                readinessScore: readinessScore,
                lastSyncTimestamp: lastSyncTimestamp,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String date,
                required String deviceId,
                Value<int> steps = const Value.absent(),
                Value<double> caloriesBurned = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> activeMinutes = const Value.absent(),
                Value<int?> restingHeartRate = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> minHeartRate = const Value.absent(),
                Value<double?> avgSpo2 = const Value.absent(),
                Value<int> sleepDurationMinutes = const Value.absent(),
                Value<int> deepSleepMinutes = const Value.absent(),
                Value<int> lightSleepMinutes = const Value.absent(),
                Value<int> remSleepMinutes = const Value.absent(),
                Value<int> awakeMinutes = const Value.absent(),
                Value<int?> sleepScore = const Value.absent(),
                Value<int?> wellnessScore = const Value.absent(),
                Value<int?> moveScore = const Value.absent(),
                Value<int?> recoverScore = const Value.absent(),
                Value<int?> readinessScore = const Value.absent(),
                required DateTime lastSyncTimestamp,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyHealthSummariesTableCompanion.insert(
                userId: userId,
                date: date,
                deviceId: deviceId,
                steps: steps,
                caloriesBurned: caloriesBurned,
                distanceMeters: distanceMeters,
                activeMinutes: activeMinutes,
                restingHeartRate: restingHeartRate,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                minHeartRate: minHeartRate,
                avgSpo2: avgSpo2,
                sleepDurationMinutes: sleepDurationMinutes,
                deepSleepMinutes: deepSleepMinutes,
                lightSleepMinutes: lightSleepMinutes,
                remSleepMinutes: remSleepMinutes,
                awakeMinutes: awakeMinutes,
                sleepScore: sleepScore,
                wellnessScore: wellnessScore,
                moveScore: moveScore,
                recoverScore: recoverScore,
                readinessScore: readinessScore,
                lastSyncTimestamp: lastSyncTimestamp,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $DailyHealthSummariesTableTable,
                    DailyHealthSummary
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DailyHealthSummariesTableTable,
                    DailyHealthSummary
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyHealthSummariesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyHealthSummariesTableTable,
      DailyHealthSummary,
      $$DailyHealthSummariesTableTableFilterComposer,
      $$DailyHealthSummariesTableTableOrderingComposer,
      $$DailyHealthSummariesTableTableAnnotationComposer,
      $$DailyHealthSummariesTableTableCreateCompanionBuilder,
      $$DailyHealthSummariesTableTableUpdateCompanionBuilder,
      (
        DailyHealthSummary,
        BaseReferences<
          _$AppDatabase,
          $DailyHealthSummariesTableTable,
          DailyHealthSummary
        >,
      ),
      DailyHealthSummary,
      PrefetchHooks Function()
    >;
typedef $$HeartRateSamplesTableTableCreateCompanionBuilder =
    HeartRateSamplesTableCompanion Function({
      required String deviceId,
      required DateTime timestamp,
      required int bpm,
      Value<bool> isResting,
      Value<int> rowid,
    });
typedef $$HeartRateSamplesTableTableUpdateCompanionBuilder =
    HeartRateSamplesTableCompanion Function({
      Value<String> deviceId,
      Value<DateTime> timestamp,
      Value<int> bpm,
      Value<bool> isResting,
      Value<int> rowid,
    });

class $$HeartRateSamplesTableTableFilterComposer
    extends Composer<_$AppDatabase, $HeartRateSamplesTableTable> {
  $$HeartRateSamplesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isResting => $composableBuilder(
    column: $table.isResting,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HeartRateSamplesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HeartRateSamplesTableTable> {
  $$HeartRateSamplesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bpm => $composableBuilder(
    column: $table.bpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isResting => $composableBuilder(
    column: $table.isResting,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HeartRateSamplesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeartRateSamplesTableTable> {
  $$HeartRateSamplesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get bpm =>
      $composableBuilder(column: $table.bpm, builder: (column) => column);

  GeneratedColumn<bool> get isResting =>
      $composableBuilder(column: $table.isResting, builder: (column) => column);
}

class $$HeartRateSamplesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HeartRateSamplesTableTable,
          HeartRateSample,
          $$HeartRateSamplesTableTableFilterComposer,
          $$HeartRateSamplesTableTableOrderingComposer,
          $$HeartRateSamplesTableTableAnnotationComposer,
          $$HeartRateSamplesTableTableCreateCompanionBuilder,
          $$HeartRateSamplesTableTableUpdateCompanionBuilder,
          (
            HeartRateSample,
            BaseReferences<
              _$AppDatabase,
              $HeartRateSamplesTableTable,
              HeartRateSample
            >,
          ),
          HeartRateSample,
          PrefetchHooks Function()
        > {
  $$HeartRateSamplesTableTableTableManager(
    _$AppDatabase db,
    $HeartRateSamplesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeartRateSamplesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HeartRateSamplesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HeartRateSamplesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> bpm = const Value.absent(),
                Value<bool> isResting = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeartRateSamplesTableCompanion(
                deviceId: deviceId,
                timestamp: timestamp,
                bpm: bpm,
                isResting: isResting,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required DateTime timestamp,
                required int bpm,
                Value<bool> isResting = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeartRateSamplesTableCompanion.insert(
                deviceId: deviceId,
                timestamp: timestamp,
                bpm: bpm,
                isResting: isResting,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HeartRateSamplesTableTable, HeartRateSample>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $HeartRateSamplesTableTable,
                    HeartRateSample
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HeartRateSamplesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HeartRateSamplesTableTable,
      HeartRateSample,
      $$HeartRateSamplesTableTableFilterComposer,
      $$HeartRateSamplesTableTableOrderingComposer,
      $$HeartRateSamplesTableTableAnnotationComposer,
      $$HeartRateSamplesTableTableCreateCompanionBuilder,
      $$HeartRateSamplesTableTableUpdateCompanionBuilder,
      (
        HeartRateSample,
        BaseReferences<
          _$AppDatabase,
          $HeartRateSamplesTableTable,
          HeartRateSample
        >,
      ),
      HeartRateSample,
      PrefetchHooks Function()
    >;
typedef $$SleepSessionsTableTableCreateCompanionBuilder =
    SleepSessionsTableCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime startTime,
      required DateTime endTime,
      required int totalDurationMinutes,
      Value<int> deepMinutes,
      Value<int> lightMinutes,
      Value<int> remMinutes,
      Value<int> awakeMinutes,
      Value<int?> sleepScore,
      required String date,
      Value<DateTime> syncedAt,
    });
typedef $$SleepSessionsTableTableUpdateCompanionBuilder =
    SleepSessionsTableCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<int> totalDurationMinutes,
      Value<int> deepMinutes,
      Value<int> lightMinutes,
      Value<int> remMinutes,
      Value<int> awakeMinutes,
      Value<int?> sleepScore,
      Value<String> date,
      Value<DateTime> syncedAt,
    });

final class $$SleepSessionsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $SleepSessionsTableTable, SleepSession> {
  $$SleepSessionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SleepPhasesTableTable, List<SleepPhase>>
  _sleepPhasesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sleepPhasesTable,
    aliasName: 'sleep_sessions_table__id__sleep_phases_table__session_id',
  );

  $$SleepPhasesTableTableProcessedTableManager get sleepPhasesTableRefs {
    final manager = $$SleepPhasesTableTableTableManager(
      $_db,
      $_db.sleepPhasesTable,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sleepPhasesTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SleepSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SleepSessionsTableTable> {
  $$SleepSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationMinutes => $composableBuilder(
    column: $table.totalDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deepMinutes => $composableBuilder(
    column: $table.deepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lightMinutes => $composableBuilder(
    column: $table.lightMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remMinutes => $composableBuilder(
    column: $table.remMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sleepPhasesTableRefs(
    Expression<bool> Function($$SleepPhasesTableTableFilterComposer f) f,
  ) {
    final $$SleepPhasesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sleepPhasesTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SleepPhasesTableTableFilterComposer(
            $db: $db,
            $table: $db.sleepPhasesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SleepSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepSessionsTableTable> {
  $$SleepSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationMinutes => $composableBuilder(
    column: $table.totalDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deepMinutes => $composableBuilder(
    column: $table.deepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lightMinutes => $composableBuilder(
    column: $table.lightMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remMinutes => $composableBuilder(
    column: $table.remMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepSessionsTableTable> {
  $$SleepSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get totalDurationMinutes => $composableBuilder(
    column: $table.totalDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deepMinutes => $composableBuilder(
    column: $table.deepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lightMinutes => $composableBuilder(
    column: $table.lightMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remMinutes => $composableBuilder(
    column: $table.remMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awakeMinutes => $composableBuilder(
    column: $table.awakeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepScore => $composableBuilder(
    column: $table.sleepScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  Expression<T> sleepPhasesTableRefs<T extends Object>(
    Expression<T> Function($$SleepPhasesTableTableAnnotationComposer a) f,
  ) {
    final $$SleepPhasesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sleepPhasesTable,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SleepPhasesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sleepPhasesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SleepSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepSessionsTableTable,
          SleepSession,
          $$SleepSessionsTableTableFilterComposer,
          $$SleepSessionsTableTableOrderingComposer,
          $$SleepSessionsTableTableAnnotationComposer,
          $$SleepSessionsTableTableCreateCompanionBuilder,
          $$SleepSessionsTableTableUpdateCompanionBuilder,
          (SleepSession, $$SleepSessionsTableTableReferences),
          SleepSession,
          PrefetchHooks Function({bool sleepPhasesTableRefs})
        > {
  $$SleepSessionsTableTableTableManager(
    _$AppDatabase db,
    $SleepSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepSessionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<int> totalDurationMinutes = const Value.absent(),
                Value<int> deepMinutes = const Value.absent(),
                Value<int> lightMinutes = const Value.absent(),
                Value<int> remMinutes = const Value.absent(),
                Value<int> awakeMinutes = const Value.absent(),
                Value<int?> sleepScore = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => SleepSessionsTableCompanion(
                id: id,
                deviceId: deviceId,
                startTime: startTime,
                endTime: endTime,
                totalDurationMinutes: totalDurationMinutes,
                deepMinutes: deepMinutes,
                lightMinutes: lightMinutes,
                remMinutes: remMinutes,
                awakeMinutes: awakeMinutes,
                sleepScore: sleepScore,
                date: date,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime startTime,
                required DateTime endTime,
                required int totalDurationMinutes,
                Value<int> deepMinutes = const Value.absent(),
                Value<int> lightMinutes = const Value.absent(),
                Value<int> remMinutes = const Value.absent(),
                Value<int> awakeMinutes = const Value.absent(),
                Value<int?> sleepScore = const Value.absent(),
                required String date,
                Value<DateTime> syncedAt = const Value.absent(),
              }) => SleepSessionsTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                startTime: startTime,
                endTime: endTime,
                totalDurationMinutes: totalDurationMinutes,
                deepMinutes: deepMinutes,
                lightMinutes: lightMinutes,
                remMinutes: remMinutes,
                awakeMinutes: awakeMinutes,
                sleepScore: sleepScore,
                date: date,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepSessionsTableTable, SleepSession>(table),
                  $$SleepSessionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sleepPhasesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sleepPhasesTableRefs) db.sleepPhasesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sleepPhasesTableRefs)
                    await $_getPrefetchedData<
                      SleepSession,
                      $SleepSessionsTableTable,
                      SleepPhase
                    >(
                      currentTable: table,
                      referencedTable: $$SleepSessionsTableTableReferences
                          ._sleepPhasesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SleepSessionsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).sleepPhasesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SleepSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepSessionsTableTable,
      SleepSession,
      $$SleepSessionsTableTableFilterComposer,
      $$SleepSessionsTableTableOrderingComposer,
      $$SleepSessionsTableTableAnnotationComposer,
      $$SleepSessionsTableTableCreateCompanionBuilder,
      $$SleepSessionsTableTableUpdateCompanionBuilder,
      (SleepSession, $$SleepSessionsTableTableReferences),
      SleepSession,
      PrefetchHooks Function({bool sleepPhasesTableRefs})
    >;
typedef $$SleepPhasesTableTableCreateCompanionBuilder =
    SleepPhasesTableCompanion Function({
      Value<int> id,
      required int sessionId,
      required int phaseType,
      required DateTime startTime,
      required DateTime endTime,
      required int durationMinutes,
    });
typedef $$SleepPhasesTableTableUpdateCompanionBuilder =
    SleepPhasesTableCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> phaseType,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<int> durationMinutes,
    });

final class $$SleepPhasesTableTableReferences
    extends BaseReferences<_$AppDatabase, $SleepPhasesTableTable, SleepPhase> {
  $$SleepPhasesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SleepSessionsTableTable _sessionIdTable(_$AppDatabase db) => db
      .sleepSessionsTable
      .createAlias('sleep_phases_table__session_id__sleep_sessions_table__id');

  $$SleepSessionsTableTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SleepSessionsTableTableTableManager(
      $_db,
      $_db.sleepSessionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SleepPhasesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SleepPhasesTableTable> {
  $$SleepPhasesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get phaseType => $composableBuilder(
    column: $table.phaseType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$SleepSessionsTableTableFilterComposer get sessionId {
    final $$SleepSessionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sleepSessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SleepSessionsTableTableFilterComposer(
            $db: $db,
            $table: $db.sleepSessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SleepPhasesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepPhasesTableTable> {
  $$SleepPhasesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get phaseType => $composableBuilder(
    column: $table.phaseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SleepSessionsTableTableOrderingComposer get sessionId {
    final $$SleepSessionsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sleepSessionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SleepSessionsTableTableOrderingComposer(
            $db: $db,
            $table: $db.sleepSessionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SleepPhasesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepPhasesTableTable> {
  $$SleepPhasesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get phaseType =>
      $composableBuilder(column: $table.phaseType, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  $$SleepSessionsTableTableAnnotationComposer get sessionId {
    final $$SleepSessionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sessionId,
          referencedTable: $db.sleepSessionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SleepSessionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.sleepSessionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SleepPhasesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepPhasesTableTable,
          SleepPhase,
          $$SleepPhasesTableTableFilterComposer,
          $$SleepPhasesTableTableOrderingComposer,
          $$SleepPhasesTableTableAnnotationComposer,
          $$SleepPhasesTableTableCreateCompanionBuilder,
          $$SleepPhasesTableTableUpdateCompanionBuilder,
          (SleepPhase, $$SleepPhasesTableTableReferences),
          SleepPhase,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SleepPhasesTableTableTableManager(
    _$AppDatabase db,
    $SleepPhasesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepPhasesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepPhasesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepPhasesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> phaseType = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
              }) => SleepPhasesTableCompanion(
                id: id,
                sessionId: sessionId,
                phaseType: phaseType,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int phaseType,
                required DateTime startTime,
                required DateTime endTime,
                required int durationMinutes,
              }) => SleepPhasesTableCompanion.insert(
                id: id,
                sessionId: sessionId,
                phaseType: phaseType,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepPhasesTableTable, SleepPhase>(table),
                  $$SleepPhasesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SleepPhasesTableTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SleepPhasesTableTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SleepPhasesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepPhasesTableTable,
      SleepPhase,
      $$SleepPhasesTableTableFilterComposer,
      $$SleepPhasesTableTableOrderingComposer,
      $$SleepPhasesTableTableAnnotationComposer,
      $$SleepPhasesTableTableCreateCompanionBuilder,
      $$SleepPhasesTableTableUpdateCompanionBuilder,
      (SleepPhase, $$SleepPhasesTableTableReferences),
      SleepPhase,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$VitalsRecordsTableTableCreateCompanionBuilder =
    VitalsRecordsTableCompanion Function({
      Value<int> id,
      required String deviceId,
      required String vitalType,
      Value<double?> valueNumeric,
      Value<double?> secondaryNumeric,
      Value<String?> unit,
      required DateTime timestamp,
      Value<String?> rawPayload,
      Value<DateTime> createdAt,
    });
typedef $$VitalsRecordsTableTableUpdateCompanionBuilder =
    VitalsRecordsTableCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String> vitalType,
      Value<double?> valueNumeric,
      Value<double?> secondaryNumeric,
      Value<String?> unit,
      Value<DateTime> timestamp,
      Value<String?> rawPayload,
      Value<DateTime> createdAt,
    });

class $$VitalsRecordsTableTableFilterComposer
    extends Composer<_$AppDatabase, $VitalsRecordsTableTable> {
  $$VitalsRecordsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vitalType => $composableBuilder(
    column: $table.vitalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueNumeric => $composableBuilder(
    column: $table.valueNumeric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get secondaryNumeric => $composableBuilder(
    column: $table.secondaryNumeric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VitalsRecordsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VitalsRecordsTableTable> {
  $$VitalsRecordsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vitalType => $composableBuilder(
    column: $table.vitalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueNumeric => $composableBuilder(
    column: $table.valueNumeric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get secondaryNumeric => $composableBuilder(
    column: $table.secondaryNumeric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VitalsRecordsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VitalsRecordsTableTable> {
  $$VitalsRecordsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get vitalType =>
      $composableBuilder(column: $table.vitalType, builder: (column) => column);

  GeneratedColumn<double> get valueNumeric => $composableBuilder(
    column: $table.valueNumeric,
    builder: (column) => column,
  );

  GeneratedColumn<double> get secondaryNumeric => $composableBuilder(
    column: $table.secondaryNumeric,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VitalsRecordsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VitalsRecordsTableTable,
          VitalsRecord,
          $$VitalsRecordsTableTableFilterComposer,
          $$VitalsRecordsTableTableOrderingComposer,
          $$VitalsRecordsTableTableAnnotationComposer,
          $$VitalsRecordsTableTableCreateCompanionBuilder,
          $$VitalsRecordsTableTableUpdateCompanionBuilder,
          (
            VitalsRecord,
            BaseReferences<
              _$AppDatabase,
              $VitalsRecordsTableTable,
              VitalsRecord
            >,
          ),
          VitalsRecord,
          PrefetchHooks Function()
        > {
  $$VitalsRecordsTableTableTableManager(
    _$AppDatabase db,
    $VitalsRecordsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VitalsRecordsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VitalsRecordsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VitalsRecordsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> vitalType = const Value.absent(),
                Value<double?> valueNumeric = const Value.absent(),
                Value<double?> secondaryNumeric = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> rawPayload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VitalsRecordsTableCompanion(
                id: id,
                deviceId: deviceId,
                vitalType: vitalType,
                valueNumeric: valueNumeric,
                secondaryNumeric: secondaryNumeric,
                unit: unit,
                timestamp: timestamp,
                rawPayload: rawPayload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required String vitalType,
                Value<double?> valueNumeric = const Value.absent(),
                Value<double?> secondaryNumeric = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                required DateTime timestamp,
                Value<String?> rawPayload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VitalsRecordsTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                vitalType: vitalType,
                valueNumeric: valueNumeric,
                secondaryNumeric: secondaryNumeric,
                unit: unit,
                timestamp: timestamp,
                rawPayload: rawPayload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VitalsRecordsTableTable, VitalsRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $VitalsRecordsTableTable,
                    VitalsRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VitalsRecordsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VitalsRecordsTableTable,
      VitalsRecord,
      $$VitalsRecordsTableTableFilterComposer,
      $$VitalsRecordsTableTableOrderingComposer,
      $$VitalsRecordsTableTableAnnotationComposer,
      $$VitalsRecordsTableTableCreateCompanionBuilder,
      $$VitalsRecordsTableTableUpdateCompanionBuilder,
      (
        VitalsRecord,
        BaseReferences<_$AppDatabase, $VitalsRecordsTableTable, VitalsRecord>,
      ),
      VitalsRecord,
      PrefetchHooks Function()
    >;
typedef $$BandDevicesTableTableCreateCompanionBuilder =
    BandDevicesTableCompanion Function({
      required String macAddress,
      required String deviceName,
      Value<String?> modelNumber,
      Value<String?> firmwareVersion,
      Value<int> batteryLevel,
      Value<bool> isCharging,
      Value<bool> isBonded,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime?> lastSyncAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$BandDevicesTableTableUpdateCompanionBuilder =
    BandDevicesTableCompanion Function({
      Value<String> macAddress,
      Value<String> deviceName,
      Value<String?> modelNumber,
      Value<String?> firmwareVersion,
      Value<int> batteryLevel,
      Value<bool> isCharging,
      Value<bool> isBonded,
      Value<DateTime?> lastConnectedAt,
      Value<DateTime?> lastSyncAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BandDevicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $BandDevicesTableTable> {
  $$BandDevicesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBonded => $composableBuilder(
    column: $table.isBonded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BandDevicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BandDevicesTableTable> {
  $$BandDevicesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBonded => $composableBuilder(
    column: $table.isBonded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BandDevicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BandDevicesTableTable> {
  $$BandDevicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get macAddress => $composableBuilder(
    column: $table.macAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelNumber => $composableBuilder(
    column: $table.modelNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBonded =>
      $composableBuilder(column: $table.isBonded, builder: (column) => column);

  GeneratedColumn<DateTime> get lastConnectedAt => $composableBuilder(
    column: $table.lastConnectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BandDevicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BandDevicesTableTable,
          BandDeviceEntry,
          $$BandDevicesTableTableFilterComposer,
          $$BandDevicesTableTableOrderingComposer,
          $$BandDevicesTableTableAnnotationComposer,
          $$BandDevicesTableTableCreateCompanionBuilder,
          $$BandDevicesTableTableUpdateCompanionBuilder,
          (
            BandDeviceEntry,
            BaseReferences<
              _$AppDatabase,
              $BandDevicesTableTable,
              BandDeviceEntry
            >,
          ),
          BandDeviceEntry,
          PrefetchHooks Function()
        > {
  $$BandDevicesTableTableTableManager(
    _$AppDatabase db,
    $BandDevicesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BandDevicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BandDevicesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BandDevicesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> macAddress = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<String?> modelNumber = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<int> batteryLevel = const Value.absent(),
                Value<bool> isCharging = const Value.absent(),
                Value<bool> isBonded = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BandDevicesTableCompanion(
                macAddress: macAddress,
                deviceName: deviceName,
                modelNumber: modelNumber,
                firmwareVersion: firmwareVersion,
                batteryLevel: batteryLevel,
                isCharging: isCharging,
                isBonded: isBonded,
                lastConnectedAt: lastConnectedAt,
                lastSyncAt: lastSyncAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String macAddress,
                required String deviceName,
                Value<String?> modelNumber = const Value.absent(),
                Value<String?> firmwareVersion = const Value.absent(),
                Value<int> batteryLevel = const Value.absent(),
                Value<bool> isCharging = const Value.absent(),
                Value<bool> isBonded = const Value.absent(),
                Value<DateTime?> lastConnectedAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BandDevicesTableCompanion.insert(
                macAddress: macAddress,
                deviceName: deviceName,
                modelNumber: modelNumber,
                firmwareVersion: firmwareVersion,
                batteryLevel: batteryLevel,
                isCharging: isCharging,
                isBonded: isBonded,
                lastConnectedAt: lastConnectedAt,
                lastSyncAt: lastSyncAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BandDevicesTableTable, BandDeviceEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BandDevicesTableTable,
                    BandDeviceEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BandDevicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BandDevicesTableTable,
      BandDeviceEntry,
      $$BandDevicesTableTableFilterComposer,
      $$BandDevicesTableTableOrderingComposer,
      $$BandDevicesTableTableAnnotationComposer,
      $$BandDevicesTableTableCreateCompanionBuilder,
      $$BandDevicesTableTableUpdateCompanionBuilder,
      (
        BandDeviceEntry,
        BaseReferences<_$AppDatabase, $BandDevicesTableTable, BandDeviceEntry>,
      ),
      BandDeviceEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<int> id,
      required String endpoint,
      required String payload,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttemptAt,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<int> id,
      Value<String> endpoint,
      Value<String> payload,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<DateTime?> lastAttemptAt,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueItem,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueItem,
            BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueItem>,
          ),
          SyncQueueItem,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                endpoint: endpoint,
                payload: payload,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String endpoint,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                endpoint: endpoint,
                payload: payload,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncQueueTableTable, SyncQueueItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncQueueTableTable,
                    SyncQueueItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueItem,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueItem,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueItem>,
      ),
      SyncQueueItem,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableTableCreateCompanionBuilder =
    WorkoutSessionsTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      required String title,
      required String category,
      required int durationSeconds,
      Value<int> burnedCalories,
      Value<int> avgHeartRate,
      Value<int> peakHeartRate,
      required DateTime startTime,
      required DateTime endTime,
      Value<DateTime> createdAt,
    });
typedef $$WorkoutSessionsTableTableUpdateCompanionBuilder =
    WorkoutSessionsTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> title,
      Value<String> category,
      Value<int> durationSeconds,
      Value<int> burnedCalories,
      Value<int> avgHeartRate,
      Value<int> peakHeartRate,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<DateTime> createdAt,
    });

class $$WorkoutSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTableTable> {
  $$WorkoutSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get burnedCalories => $composableBuilder(
    column: $table.burnedCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peakHeartRate => $composableBuilder(
    column: $table.peakHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTableTable> {
  $$WorkoutSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get burnedCalories => $composableBuilder(
    column: $table.burnedCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peakHeartRate => $composableBuilder(
    column: $table.peakHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTableTable> {
  $$WorkoutSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get burnedCalories => $composableBuilder(
    column: $table.burnedCalories,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get peakHeartRate => $composableBuilder(
    column: $table.peakHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WorkoutSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTableTable,
          WorkoutSession,
          $$WorkoutSessionsTableTableFilterComposer,
          $$WorkoutSessionsTableTableOrderingComposer,
          $$WorkoutSessionsTableTableAnnotationComposer,
          $$WorkoutSessionsTableTableCreateCompanionBuilder,
          $$WorkoutSessionsTableTableUpdateCompanionBuilder,
          (
            WorkoutSession,
            BaseReferences<
              _$AppDatabase,
              $WorkoutSessionsTableTable,
              WorkoutSession
            >,
          ),
          WorkoutSession,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> burnedCalories = const Value.absent(),
                Value<int> avgHeartRate = const Value.absent(),
                Value<int> peakHeartRate = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkoutSessionsTableCompanion(
                id: id,
                userId: userId,
                title: title,
                category: category,
                durationSeconds: durationSeconds,
                burnedCalories: burnedCalories,
                avgHeartRate: avgHeartRate,
                peakHeartRate: peakHeartRate,
                startTime: startTime,
                endTime: endTime,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required String title,
                required String category,
                required int durationSeconds,
                Value<int> burnedCalories = const Value.absent(),
                Value<int> avgHeartRate = const Value.absent(),
                Value<int> peakHeartRate = const Value.absent(),
                required DateTime startTime,
                required DateTime endTime,
                Value<DateTime> createdAt = const Value.absent(),
              }) => WorkoutSessionsTableCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                category: category,
                durationSeconds: durationSeconds,
                burnedCalories: burnedCalories,
                avgHeartRate: avgHeartRate,
                peakHeartRate: peakHeartRate,
                startTime: startTime,
                endTime: endTime,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTableTable, WorkoutSession>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutSessionsTableTable,
                    WorkoutSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTableTable,
      WorkoutSession,
      $$WorkoutSessionsTableTableFilterComposer,
      $$WorkoutSessionsTableTableOrderingComposer,
      $$WorkoutSessionsTableTableAnnotationComposer,
      $$WorkoutSessionsTableTableCreateCompanionBuilder,
      $$WorkoutSessionsTableTableUpdateCompanionBuilder,
      (
        WorkoutSession,
        BaseReferences<
          _$AppDatabase,
          $WorkoutSessionsTableTable,
          WorkoutSession
        >,
      ),
      WorkoutSession,
      PrefetchHooks Function()
    >;
typedef $$UserRoutinesTableTableCreateCompanionBuilder =
    UserRoutinesTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      required String routineName,
      Value<int> durationDays,
      Value<String> movementsJson,
      Value<String> wellnessJson,
      Value<String> routineItemsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$UserRoutinesTableTableUpdateCompanionBuilder =
    UserRoutinesTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> routineName,
      Value<int> durationDays,
      Value<String> movementsJson,
      Value<String> wellnessJson,
      Value<String> routineItemsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$UserRoutinesTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserRoutinesTableTable> {
  $$UserRoutinesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementsJson => $composableBuilder(
    column: $table.movementsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wellnessJson => $composableBuilder(
    column: $table.wellnessJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routineItemsJson => $composableBuilder(
    column: $table.routineItemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserRoutinesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserRoutinesTableTable> {
  $$UserRoutinesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementsJson => $composableBuilder(
    column: $table.movementsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wellnessJson => $composableBuilder(
    column: $table.wellnessJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routineItemsJson => $composableBuilder(
    column: $table.routineItemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserRoutinesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserRoutinesTableTable> {
  $$UserRoutinesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get routineName => $composableBuilder(
    column: $table.routineName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movementsJson => $composableBuilder(
    column: $table.movementsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wellnessJson => $composableBuilder(
    column: $table.wellnessJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routineItemsJson => $composableBuilder(
    column: $table.routineItemsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserRoutinesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserRoutinesTableTable,
          UserRoutine,
          $$UserRoutinesTableTableFilterComposer,
          $$UserRoutinesTableTableOrderingComposer,
          $$UserRoutinesTableTableAnnotationComposer,
          $$UserRoutinesTableTableCreateCompanionBuilder,
          $$UserRoutinesTableTableUpdateCompanionBuilder,
          (
            UserRoutine,
            BaseReferences<_$AppDatabase, $UserRoutinesTableTable, UserRoutine>,
          ),
          UserRoutine,
          PrefetchHooks Function()
        > {
  $$UserRoutinesTableTableTableManager(
    _$AppDatabase db,
    $UserRoutinesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRoutinesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserRoutinesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserRoutinesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> routineName = const Value.absent(),
                Value<int> durationDays = const Value.absent(),
                Value<String> movementsJson = const Value.absent(),
                Value<String> wellnessJson = const Value.absent(),
                Value<String> routineItemsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserRoutinesTableCompanion(
                id: id,
                userId: userId,
                routineName: routineName,
                durationDays: durationDays,
                movementsJson: movementsJson,
                wellnessJson: wellnessJson,
                routineItemsJson: routineItemsJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required String routineName,
                Value<int> durationDays = const Value.absent(),
                Value<String> movementsJson = const Value.absent(),
                Value<String> wellnessJson = const Value.absent(),
                Value<String> routineItemsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserRoutinesTableCompanion.insert(
                id: id,
                userId: userId,
                routineName: routineName,
                durationDays: durationDays,
                movementsJson: movementsJson,
                wellnessJson: wellnessJson,
                routineItemsJson: routineItemsJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserRoutinesTableTable, UserRoutine>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserRoutinesTableTable,
                    UserRoutine
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserRoutinesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserRoutinesTableTable,
      UserRoutine,
      $$UserRoutinesTableTableFilterComposer,
      $$UserRoutinesTableTableOrderingComposer,
      $$UserRoutinesTableTableAnnotationComposer,
      $$UserRoutinesTableTableCreateCompanionBuilder,
      $$UserRoutinesTableTableUpdateCompanionBuilder,
      (
        UserRoutine,
        BaseReferences<_$AppDatabase, $UserRoutinesTableTable, UserRoutine>,
      ),
      UserRoutine,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyHealthSummariesTableTableTableManager get dailyHealthSummariesTable =>
      $$DailyHealthSummariesTableTableTableManager(
        _db,
        _db.dailyHealthSummariesTable,
      );
  $$HeartRateSamplesTableTableTableManager get heartRateSamplesTable =>
      $$HeartRateSamplesTableTableTableManager(_db, _db.heartRateSamplesTable);
  $$SleepSessionsTableTableTableManager get sleepSessionsTable =>
      $$SleepSessionsTableTableTableManager(_db, _db.sleepSessionsTable);
  $$SleepPhasesTableTableTableManager get sleepPhasesTable =>
      $$SleepPhasesTableTableTableManager(_db, _db.sleepPhasesTable);
  $$VitalsRecordsTableTableTableManager get vitalsRecordsTable =>
      $$VitalsRecordsTableTableTableManager(_db, _db.vitalsRecordsTable);
  $$BandDevicesTableTableTableManager get bandDevicesTable =>
      $$BandDevicesTableTableTableManager(_db, _db.bandDevicesTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$WorkoutSessionsTableTableTableManager get workoutSessionsTable =>
      $$WorkoutSessionsTableTableTableManager(_db, _db.workoutSessionsTable);
  $$UserRoutinesTableTableTableManager get userRoutinesTable =>
      $$UserRoutinesTableTableTableManager(_db, _db.userRoutinesTable);
}
