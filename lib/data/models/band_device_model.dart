import 'package:equatable/equatable.dart';

/// Connection states of the EHG Smart Band.
enum BandConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  disconnecting,
}

/// Represents Bluetooth adapter hardware / power state.
enum BandBluetoothState {
  unknown,
  poweredOn,
  poweredOff,
  unauthorized,
  unsupported,
  resetting,
}

/// Represents OS-level permission authorization status.
enum BandPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// Consolidated snapshot of device permissions & hardware readiness.
class BandPermissionDetails extends Equatable {
  final BandPermissionStatus status;
  final bool isBluetoothEnabled;
  final bool isLocationEnabled;
  final bool isPermanentlyDenied;
  final String? message;

  const BandPermissionDetails({
    this.status = BandPermissionStatus.unknown,
    this.isBluetoothEnabled = false,
    this.isLocationEnabled = true,
    this.isPermanentlyDenied = false,
    this.message,
  });

  bool get isReady =>
      status == BandPermissionStatus.granted &&
      isBluetoothEnabled &&
      isLocationEnabled;

  BandPermissionDetails copyWith({
    BandPermissionStatus? status,
    bool? isBluetoothEnabled,
    bool? isLocationEnabled,
    bool? isPermanentlyDenied,
    String? message,
  }) {
    return BandPermissionDetails(
      status: status ?? this.status,
      isBluetoothEnabled: isBluetoothEnabled ?? this.isBluetoothEnabled,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      isPermanentlyDenied: isPermanentlyDenied ?? this.isPermanentlyDenied,
      message: message ?? this.message,
    );
  }

  factory BandPermissionDetails.fromMap(Map<dynamic, dynamic> map) {
    final statusStr = map['status']?.toString();
    BandPermissionStatus status;
    switch (statusStr) {
      case 'granted':
        status = BandPermissionStatus.granted;
        break;
      case 'denied':
        status = BandPermissionStatus.denied;
        break;
      case 'permanentlyDenied':
        status = BandPermissionStatus.permanentlyDenied;
        break;
      case 'restricted':
        status = BandPermissionStatus.restricted;
        break;
      default:
        status = BandPermissionStatus.unknown;
    }

    return BandPermissionDetails(
      status: status,
      isBluetoothEnabled: map['isBluetoothEnabled'] as bool? ?? false,
      isLocationEnabled: map['isLocationEnabled'] as bool? ?? true,
      isPermanentlyDenied:
          map['isPermanentlyDenied'] as bool? ?? (status == BandPermissionStatus.permanentlyDenied),
      message: map['message']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        status,
        isBluetoothEnabled,
        isLocationEnabled,
        isPermanentlyDenied,
        message,
      ];
}

/// Represents a discovered BLE peripheral matching EHG Smart Band.
class DiscoveredBandDevice extends Equatable {
  final String id;
  final String name;
  final String mac;
  final int rssi;

  const DiscoveredBandDevice({
    required this.id,
    required this.name,
    required this.mac,
    required this.rssi,
  });

  /// Formats raw BLE broadcast names (such as H59_4F04, Q_4F04, etc.)
  /// into clean, customer-facing EHG brand names.
  static String normalizeBandName(String rawName) {
    final trimmed = rawName.trim();
    if (trimmed.isEmpty) return 'EHG Band';

    // Matches vendor model names with 4-character hex suffix (e.g. H59_4F04, H59-4F04, Q_4F04, EHG_4F04)
    final match = RegExp(
      r'^(?:h59|h60|h66|h0\d|q|qc|o|r0|r|ehg)[_\-\s]?([0-9a-fA-F]{4})$',
      caseSensitive: false,
    ).firstMatch(trimmed);

    if (match != null) {
      final suffix = match.group(1)?.toUpperCase();
      if (suffix != null && suffix.isNotEmpty) {
        return 'EHG Band ($suffix)';
      }
    }

    if (trimmed.toLowerCase().startsWith('ehg')) {
      return 'EHG Band';
    }

    final isQcModel = RegExp(
      r'^(?:h59|h60|h66|h0\d|qwatch|qring|qc)',
      caseSensitive: false,
    ).hasMatch(trimmed);

    if (isQcModel) {
      return 'EHG Band';
    }

    return trimmed;
  }

  factory DiscoveredBandDevice.fromMap(Map<dynamic, dynamic> map) {
    final rawName = map['name']?.toString() ?? '';
    return DiscoveredBandDevice(
      id: map['id']?.toString() ?? '',
      name: normalizeBandName(rawName),
      mac: map['mac']?.toString() ?? '',
      rssi: (map['rssi'] as num?)?.toInt() ?? -70,
    );
  }

  @override
  List<Object?> get props => [id, name, mac, rssi];
}

/// Detailed metadata retrieved from the connected band.
class BandDeviceInfo extends Equatable {
  final String name;
  final String id;
  final String macAddress;
  final String firmwareVersion;
  final String hardwareVersion;

  const BandDeviceInfo({
    this.name = 'EHG Band',
    this.id = 'EH-9F2C',
    this.macAddress = '',
    this.firmwareVersion = '1.0.4',
    this.hardwareVersion = '1.0.0',
  });

  factory BandDeviceInfo.fromMap(Map<dynamic, dynamic> map, {String? deviceId, String? name}) {
    final resolvedName = (name != null && name.isNotEmpty)
        ? DiscoveredBandDevice.normalizeBandName(name)
        : 'EHG Band';
    return BandDeviceInfo(
      name: resolvedName,
      id: deviceId ?? 'EH-9F2C',
      macAddress: map['macAddress']?.toString() ?? '',
      firmwareVersion: map['softVersion']?.toString() ?? '1.0.4',
      hardwareVersion: map['hardVersion']?.toString() ?? '1.0.0',
    );
  }

  BandDeviceInfo copyWith({
    String? name,
    String? id,
    String? macAddress,
    String? firmwareVersion,
    String? hardwareVersion,
  }) {
    return BandDeviceInfo(
      name: name ?? this.name,
      id: id ?? this.id,
      macAddress: macAddress ?? this.macAddress,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      hardwareVersion: hardwareVersion ?? this.hardwareVersion,
    );
  }

  @override
  List<Object?> get props => [name, id, macAddress, firmwareVersion, hardwareVersion];
}

/// Battery information retrieved from the band.
class BandBatteryInfo extends Equatable {
  final int percentage;
  final bool isCharging;

  const BandBatteryInfo({
    required this.percentage,
    this.isCharging = false,
  });

  factory BandBatteryInfo.fromMap(Map<dynamic, dynamic> map) {
    return BandBatteryInfo(
      percentage: (map['battery'] as num?)?.toInt() ?? 0,
      isCharging: map['charging'] == true,
    );
  }

  @override
  List<Object?> get props => [percentage, isCharging];
}

/// Aggregated vitals data synchronized from the band hardware.
class BandSyncedVitals extends Equatable {
  final int steps;
  final int calories;
  final int distance;
  final int sleepMinutes;
  final int deepSleepMinutes;
  final double bloodOxygen;
  final int systolicBP;
  final int diastolicBP;
  final double skinTemperature;
  final int stressLevel;
  final int hrvMs;
  final int restingHeartRate;
  final double breathingRate;
  final List<BandSleepPhase> sleepPhases;
  final List<BandHeartRateEntry> heartRateHistory;
  final List<double> weeklyHeartRate;
  final List<double> weeklySleep;
  final List<double> weeklyHrv;
  final List<double> weeklyStress;
  final List<double> weeklyOxygen;
  final List<double> weeklyRestingHr;
  final List<double> weeklyBreathing;
  final List<int> hourlySteps;
  final String date;
  final int dayIndex;

  const BandSyncedVitals({
    this.steps = 0,
    this.calories = 0,
    this.distance = 0,
    this.sleepMinutes = 0,
    this.deepSleepMinutes = 0,
    this.bloodOxygen = 0,
    this.systolicBP = 0,
    this.diastolicBP = 0,
    this.skinTemperature = 0,
    this.stressLevel = 0,
    this.hrvMs = 0,
    this.restingHeartRate = 0,
    this.breathingRate = 0,
    this.sleepPhases = const [],
    this.heartRateHistory = const [],
    this.weeklyHeartRate = const [],
    this.weeklySleep = const [],
    this.weeklyHrv = const [],
    this.weeklyStress = const [],
    this.weeklyOxygen = const [],
    this.weeklyRestingHr = const [],
    this.weeklyBreathing = const [],
    this.hourlySteps = const [],
    this.date = '',
    this.dayIndex = 0,
  });

  /// Normalizes raw calories from QC hardware firmware to daily kcal.
  ///
  /// The QC SDK reports calories inconsistently across firmware versions:
  /// - Some report in small calories (cal), yielding values like 44,695
  /// - Some report in kcal directly (200–600 range for a normal day)
  /// - Some report in cal×10 (2,000–5,000 range)
  ///
  /// This normalizer converts all variants to kcal and clamps the result
  /// to a physiologically realistic daily maximum (elite athletes peak
  /// around 8,000–10,000 kcal/day; a normal user is 1,500–3,500 kcal/day).
  static int sanitizeCalories(int rawCal) {
    if (rawCal <= 0) return 0;

    int kcal;
    if (rawCal > 50000) {
      // Extremely high — raw small calories (cal). 50,000 cal = 50 kcal.
      kcal = (rawCal / 1000).round();
    } else if (rawCal > 5000) {
      // Likely small calories or intermediate firmware unit.
      // 5,000–50,000 range: divide by 100 gives 50–500 kcal.
      kcal = (rawCal / 100).round();
    } else if (rawCal > 3500) {
      // 3,500–5,000: likely cal×10 from certain firmware.
      kcal = (rawCal / 10).round();
    } else {
      // 1–3,500: already in kcal (reasonable daily range).
      kcal = rawCal;
    }

    // Final safety clamp: no human burns more than 10,000 kcal/day.
    return kcal.clamp(0, 10000);
  }

  factory BandSyncedVitals.fromMap(Map<dynamic, dynamic> map) {
    final rawPhases = map['sleepPhases'] as List<dynamic>?;
    final rawHr = map['heartRateHistory'] as List<dynamic>?;

    List<double> parseDoubleList(dynamic val) {
      if (val is List) {
        return val.map((e) => (e as num).toDouble()).toList();
      }
      return const [];
    }

    List<int> parseIntList(dynamic val) {
      if (val is List) {
        return val.map((e) => (e as num).toInt()).toList();
      }
      return const [];
    }

    int rawCal = (map['calories'] as num?)?.toInt() ?? 0;
    int normalizedCal = sanitizeCalories(rawCal);

    return BandSyncedVitals(
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      calories: normalizedCal,
      distance: (map['distance'] as num?)?.toInt() ?? 0,
      sleepMinutes: (map['sleepMinutes'] as num?)?.toInt() ?? 0,
      deepSleepMinutes: (map['deepSleepMinutes'] as num?)?.toInt() ?? 0,
      bloodOxygen: (map['bloodOxygen'] as num?)?.toDouble() ?? 0,
      systolicBP: (map['systolicBP'] as num?)?.toInt() ?? 0,
      diastolicBP: (map['diastolicBP'] as num?)?.toInt() ?? 0,
      skinTemperature: (map['skinTemperature'] as num?)?.toDouble() ?? 0,
      stressLevel: (map['stressLevel'] as num?)?.toInt() ?? 0,
      hrvMs: (map['hrvMs'] as num?)?.toInt() ?? 0,
      restingHeartRate: (map['restingHeartRate'] as num?)?.toInt() ?? 0,
      breathingRate: (map['breathingRate'] as num?)?.toDouble() ?? 0,
      sleepPhases: rawPhases
              ?.map((e) => BandSleepPhase.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
      heartRateHistory: rawHr
              ?.map((e) => BandHeartRateEntry.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
      weeklyHeartRate: parseDoubleList(map['weeklyHeartRate']),
      weeklySleep: parseDoubleList(map['weeklySleep']),
      weeklyHrv: parseDoubleList(map['weeklyHrv']),
      weeklyStress: parseDoubleList(map['weeklyStress']),
      weeklyOxygen: parseDoubleList(map['weeklyOxygen']),
      weeklyRestingHr: parseDoubleList(map['weeklyRestingHr']),
      weeklyBreathing: parseDoubleList(map['weeklyBreathing']),
      hourlySteps: parseIntList(map['hourlySteps']),
      date: map['date']?.toString() ?? '',
      dayIndex: (map['dayIndex'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'sleepMinutes': sleepMinutes,
      'deepSleepMinutes': deepSleepMinutes,
      'bloodOxygen': bloodOxygen,
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'skinTemperature': skinTemperature,
      'stressLevel': stressLevel,
      'hrvMs': hrvMs,
      'restingHeartRate': restingHeartRate,
      'breathingRate': breathingRate,
      'sleepPhases': sleepPhases.map((e) => e.toMap()).toList(),
      'heartRateHistory': heartRateHistory.map((e) => e.toMap()).toList(),
      'weeklyHeartRate': weeklyHeartRate,
      'weeklySleep': weeklySleep,
      'weeklyHrv': weeklyHrv,
      'weeklyStress': weeklyStress,
      'weeklyOxygen': weeklyOxygen,
      'weeklyRestingHr': weeklyRestingHr,
      'weeklyBreathing': weeklyBreathing,
      'hourlySteps': hourlySteps,
      'date': date,
      'dayIndex': dayIndex,
    };
  }

  /// Returns a formatted blood pressure string like "121/79" or "--" if no data.
  String get bloodPressureFormatted =>
      (systolicBP > 0 && diastolicBP > 0) ? '$systolicBP/$diastolicBP' : '--';

  BandSyncedVitals copyWith({
    int? steps,
    int? calories,
    int? distance,
    int? sleepMinutes,
    int? deepSleepMinutes,
    double? bloodOxygen,
    int? systolicBP,
    int? diastolicBP,
    double? skinTemperature,
    int? stressLevel,
    int? hrvMs,
    int? restingHeartRate,
    double? breathingRate,
    List<BandSleepPhase>? sleepPhases,
    List<BandHeartRateEntry>? heartRateHistory,
    List<double>? weeklyHeartRate,
    List<double>? weeklySleep,
    List<double>? weeklyHrv,
    List<double>? weeklyStress,
    List<double>? weeklyOxygen,
    List<double>? weeklyRestingHr,
    List<double>? weeklyBreathing,
    List<int>? hourlySteps,
    String? date,
    int? dayIndex,
  }) {
    return BandSyncedVitals(
      steps: steps ?? this.steps,
      calories: calories != null ? sanitizeCalories(calories) : this.calories,
      distance: distance ?? this.distance,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
      bloodOxygen: bloodOxygen ?? this.bloodOxygen,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      skinTemperature: skinTemperature ?? this.skinTemperature,
      stressLevel: stressLevel ?? this.stressLevel,
      hrvMs: hrvMs ?? this.hrvMs,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      breathingRate: breathingRate ?? this.breathingRate,
      sleepPhases: sleepPhases ?? this.sleepPhases,
      heartRateHistory: heartRateHistory ?? this.heartRateHistory,
      weeklyHeartRate: weeklyHeartRate ?? this.weeklyHeartRate,
      weeklySleep: weeklySleep ?? this.weeklySleep,
      weeklyHrv: weeklyHrv ?? this.weeklyHrv,
      weeklyStress: weeklyStress ?? this.weeklyStress,
      weeklyOxygen: weeklyOxygen ?? this.weeklyOxygen,
      weeklyRestingHr: weeklyRestingHr ?? this.weeklyRestingHr,
      weeklyBreathing: weeklyBreathing ?? this.weeklyBreathing,
      hourlySteps: hourlySteps ?? this.hourlySteps,
      date: date ?? this.date,
      dayIndex: dayIndex ?? this.dayIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'steps': steps,
    'calories': calories,
    'distance': distance,
    'sleepMinutes': sleepMinutes,
    'deepSleepMinutes': deepSleepMinutes,
    'bloodOxygen': bloodOxygen,
    'systolicBP': systolicBP,
    'diastolicBP': diastolicBP,
    'skinTemperature': skinTemperature,
    'stressLevel': stressLevel,
    'hrvMs': hrvMs,
    'restingHeartRate': restingHeartRate,
    'breathingRate': breathingRate,
    'weeklyHeartRate': weeklyHeartRate,
    'weeklySleep': weeklySleep,
    'weeklyHrv': weeklyHrv,
    'weeklyStress': weeklyStress,
    'weeklyOxygen': weeklyOxygen,
    'weeklyRestingHr': weeklyRestingHr,
    'weeklyBreathing': weeklyBreathing,
    'hourlySteps': hourlySteps,
    'date': date,
    'dayIndex': dayIndex,
  };

  factory BandSyncedVitals.fromJson(Map<String, dynamic> json) {
    int rawCal = (json['calories'] as num?)?.toInt() ?? 0;
    int normalizedCal = sanitizeCalories(rawCal);

    return BandSyncedVitals(
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      calories: normalizedCal,
      distance: (json['distance'] as num?)?.toInt() ?? 0,
    sleepMinutes: (json['sleepMinutes'] as num?)?.toInt() ?? 0,
    deepSleepMinutes: (json['deepSleepMinutes'] as num?)?.toInt() ?? 0,
    bloodOxygen: (json['bloodOxygen'] as num?)?.toDouble() ?? 0.0,
    systolicBP: (json['systolicBP'] as num?)?.toInt() ?? 0,
    diastolicBP: (json['diastolicBP'] as num?)?.toInt() ?? 0,
    skinTemperature: (json['skinTemperature'] as num?)?.toDouble() ?? 0.0,
    stressLevel: (json['stressLevel'] as num?)?.toInt() ?? 0,
    hrvMs: (json['hrvMs'] as num?)?.toInt() ?? 0,
    restingHeartRate: (json['restingHeartRate'] as num?)?.toInt() ?? 0,
    breathingRate: (json['breathingRate'] as num?)?.toDouble() ?? 0.0,
    weeklyHeartRate: (json['weeklyHeartRate'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    weeklySleep: (json['weeklySleep'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    weeklyHrv: (json['weeklyHrv'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    weeklyStress: (json['weeklyStress'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    weeklyOxygen: (json['weeklyOxygen'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    weeklyRestingHr: (json['weeklyRestingHr'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    weeklyBreathing: (json['weeklyBreathing'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [],
    hourlySteps: (json['hourlySteps'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const [],
    date: json['date']?.toString() ?? '',
    dayIndex: (json['dayIndex'] as num?)?.toInt() ?? 0,
  );
}

  @override
  List<Object?> get props => [
        steps,
        calories,
        distance,
        sleepMinutes,
        deepSleepMinutes,
        bloodOxygen,
        systolicBP,
        diastolicBP,
        skinTemperature,
        stressLevel,
        hrvMs,
        restingHeartRate,
        breathingRate,
        sleepPhases,
        heartRateHistory,
        weeklyHeartRate,
        weeklySleep,
        weeklyHrv,
        weeklyStress,
        weeklyOxygen,
        weeklyRestingHr,
        weeklyBreathing,
        hourlySteps,
        date,
        dayIndex,
      ];
}

/// Real-time live pedometer data emitted from band (CMD 0x02).
class BandPedometerInfo extends Equatable {
  final int steps;
  final int calories;
  final int distance;

  const BandPedometerInfo({
    required this.steps,
    required this.calories,
    required this.distance,
  });

  @override
  List<Object?> get props => [steps, calories, distance];
}

/// Represents a single sleep phase segment from the band.
class BandSleepPhase extends Equatable {
  /// Sleep type: 0=none, 1=awake, 2=light, 3=deep, 4=rem, 5=unweared
  final int type;
  final String startTime;
  final String endTime;
  final int durationMinutes;

  const BandSleepPhase({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });

  factory BandSleepPhase.fromMap(Map<dynamic, dynamic> map) {
    return BandSleepPhase(
      type: (map['type'] as num?)?.toInt() ?? 0,
      startTime: map['startTime']?.toString() ?? '',
      endTime: map['endTime']?.toString() ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'durationMinutes': durationMinutes,
    };
  }

  String get phaseName {
    switch (type) {
      case 1:
        return 'Awake';
      case 2:
        return 'Light';
      case 3:
        return 'Deep';
      case 4:
        return 'REM';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [type, startTime, endTime, durationMinutes];
}

/// A timestamped heart rate value from the band.
class BandHeartRateEntry extends Equatable {
  final int bpm;
  final String timestamp;

  const BandHeartRateEntry({required this.bpm, required this.timestamp});

  factory BandHeartRateEntry.fromMap(Map<dynamic, dynamic> map) {
    return BandHeartRateEntry(
      bpm: (map['bpm'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bpm': bpm,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [bpm, timestamp];
}

/// Types of on-demand measurements the band supports.
enum MeasurementType {
  heartRate,
  bloodPressure,
  bloodOxygen,
  temperature,
  stress,
  hrv,
  oneKey,
}

/// Result of an on-demand measurement.
class BandMeasurementResult extends Equatable {
  final MeasurementType type;
  final bool success;
  final Map<String, dynamic> data;
  final String? error;

  const BandMeasurementResult({
    required this.type,
    required this.success,
    this.data = const {},
    this.error,
  });

  /// Convenience getter for heart rate value in BPM if present.
  int? get heartRate =>
      (data['hr'] as num?)?.toInt() ??
      (data['heartRate'] as num?)?.toInt() ??
      (data['value'] as num?)?.toInt();

  /// Primary numeric value of the measurement result if present.
  num? get value =>
      (data['value'] as num?) ??
      (data['hr'] as num?) ??
      (data['heartRate'] as num?) ??
      (data['spo2'] as num?) ??
      (data['systolic'] as num?);

  @override
  List<Object?> get props => [type, success, data, error];
}

