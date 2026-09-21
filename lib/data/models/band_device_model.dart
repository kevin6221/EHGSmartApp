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

  factory DiscoveredBandDevice.fromMap(Map<dynamic, dynamic> map) {
    return DiscoveredBandDevice(
      id: map['id']?.toString() ?? '',
      name: (map['name'] != null && map['name'].toString().isNotEmpty)
          ? map['name'].toString()
          : 'EHG Smart Band',
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
    this.name = 'EHG Smart Band',
    this.id = 'EH-9F2C',
    this.macAddress = '',
    this.firmwareVersion = '1.0.4',
    this.hardwareVersion = '1.0.0',
  });

  factory BandDeviceInfo.fromMap(Map<dynamic, dynamic> map, {String? deviceId, String? name}) {
    return BandDeviceInfo(
      name: name ?? 'EHG Smart Band',
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
  final List<BandSleepPhase> sleepPhases;
  final List<BandHeartRateEntry> heartRateHistory;

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
    this.sleepPhases = const [],
    this.heartRateHistory = const [],
  });

  factory BandSyncedVitals.fromMap(Map<dynamic, dynamic> map) {
    final rawPhases = map['sleepPhases'] as List<dynamic>?;
    final rawHr = map['heartRateHistory'] as List<dynamic>?;

    return BandSyncedVitals(
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
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
      sleepPhases: rawPhases
              ?.map((e) => BandSleepPhase.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
      heartRateHistory: rawHr
              ?.map((e) => BandHeartRateEntry.fromMap(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Returns a formatted blood pressure string like "121/79" or empty if no data.
  String get bloodPressureFormatted =>
      (systolicBP > 0 && diastolicBP > 0) ? '$systolicBP/$diastolicBP' : '';

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
        sleepPhases,
        heartRateHistory,
      ];
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

  @override
  List<Object?> get props => [type, success, data, error];
}

