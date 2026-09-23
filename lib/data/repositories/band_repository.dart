import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';
import '../../core/security/secure_storage_service.dart';
import '../models/band_device_model.dart';
import '../services/band_service.dart';
import '../services/mock_band_service.dart';
import '../services/native_band_service.dart';

/// Repository managing the EHG Smart Band connectivity, caching paired device metadata,
/// and dispatching hardware synchronization with Drift SQLite and Secure Storage.
class BandRepository {
  final BandService _service;
  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final StreamController<BandSyncedVitals> _syncedVitalsController =
      StreamController<BandSyncedVitals>.broadcast();

  BandDeviceInfo? _connectedDevice;
  BandBatteryInfo _battery = const BandBatteryInfo(percentage: 0);
  DiscoveredBandDevice? _lastPairedDevice;
  BandSyncedVitals _lastSyncedVitals = const BandSyncedVitals();
  StreamSubscription<BandConnectionStatus>? _statusSubscription;
  StreamSubscription<BandPedometerInfo>? _pedometerSubscription;
  StreamSubscription<BandMeasurementResult>? _measurementSubscription;
  StreamSubscription<BandBatteryInfo>? _batterySubscription;

  bool _isExplicitDisconnect = false;
  bool _isAutoReconnecting = false;
  Timer? _autoReconnectTimer;
  int _reconnectAttempts = 0;
  BandConnectionStatus _currentStatus = BandConnectionStatus.disconnected;
  final Completer<void> _initCompleter = Completer<void>();

  BandRepository({
    BandService? service,
    AppDatabase? database,
    SecureStorageService? secureStorage,
  })  : _service = service ??
            ((Platform.isIOS || Platform.isAndroid)
                ? NativeBandService()
                : MockBandService()),
        _db = database ?? AppDatabase(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    _loadCachedData().whenComplete(() {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    });
    _listenToServiceEvents();
  }

  void _listenToServiceEvents() {
    _statusSubscription = _service.connectionStatusStream.listen((status) {
      _currentStatus = status;
      if (status == BandConnectionStatus.connected) {
        _reconnectAttempts = 0;
        _autoReconnectTimer?.cancel();
        _autoReconnectTimer = null;
        _isAutoReconnecting = false;
        _service.getBattery().then((b) {
          if (b.percentage > 0) {
            _battery = b;
            final mac = _lastPairedDevice?.mac ?? '';
            if (mac.isNotEmpty) {
              _db.deviceDao.updateBattery(mac, b.percentage, b.isCharging);
            }
          }
        });
        // Health synchronization is handled by HealthSyncManager (cold start / pull-to-refresh policy)
      } else if (status == BandConnectionStatus.disconnected) {
        _connectedDevice = null;
        if (!_isExplicitDisconnect && _lastPairedDevice != null) {
          _scheduleAutoReconnect();
        }
      }
    });

    _batterySubscription = _service.batteryStream.listen((battery) {
      if (battery.percentage > 0) {
        _battery = battery;
        final mac = _lastPairedDevice?.mac ?? '';
        if (mac.isNotEmpty) {
          _db.deviceDao.updateBattery(mac, battery.percentage, battery.isCharging);
        }
      }
    });

    _pedometerSubscription = _service.pedometerStream.listen((info) {
      if (info.steps > 0 || info.calories > 0) {
        _lastSyncedVitals = _lastSyncedVitals.copyWith(
          steps: info.steps,
          calories: info.calories,
          distance: info.distance,
        );
        _persistVitals(_lastSyncedVitals);
        _syncedVitalsController.add(_lastSyncedVitals);
      }
    });

    _measurementSubscription = _service.measurementResultStream.listen((result) {
      if (result.success && result.data.isNotEmpty) {
        final d = result.data;
        _lastSyncedVitals = _lastSyncedVitals.copyWith(
          bloodOxygen: (d['spo2'] as num?)?.toDouble(),
          systolicBP: (d['sbp'] as num?)?.toInt(),
          diastolicBP: (d['dbp'] as num?)?.toInt(),
          skinTemperature: (d['temperature'] as num?)?.toDouble(),
          stressLevel: (d['stress'] as num?)?.toInt(),
          hrvMs: (d['hrv'] as num?)?.toInt(),
          restingHeartRate: (d['hr'] as num?)?.toInt(),
        );
        _persistVitals(_lastSyncedVitals);
        _syncedVitalsController.add(_lastSyncedVitals);
      }
    });
  }

  void _scheduleAutoReconnect() {
    if (_isExplicitDisconnect || _lastPairedDevice == null || _isAutoReconnecting) return;
    _autoReconnectTimer?.cancel();
    _reconnectAttempts++;
    final int delaySec = _reconnectAttempts == 1 ? 5 : (_reconnectAttempts == 2 ? 10 : 15);

    debugPrint('⏳ [BAND RECONNECT] Continuous auto-reconnect #$_reconnectAttempts scheduled in $delaySec seconds for ${_lastPairedDevice?.name}...');
    _autoReconnectTimer = Timer(Duration(seconds: delaySec), () async {
      if (!_isExplicitDisconnect && _lastPairedDevice != null && _currentStatus != BandConnectionStatus.connected) {
        _isAutoReconnecting = true;
        try {
          await tryAutoReconnect();
        } finally {
          _isAutoReconnecting = false;
          // Continue retrying if still disconnected and band is paired
          if (!_isExplicitDisconnect && _lastPairedDevice != null && _currentStatus == BandConnectionStatus.disconnected) {
            _scheduleAutoReconnect();
          }
        }
      }
    });
  }

  Future<void> _loadCachedData() async {
    try {
      // 1. Check Drift DB for bonded device or secure storage
      final bonded = await _db.deviceDao.getBondedDevice();
      if (bonded != null) {
        _lastPairedDevice = DiscoveredBandDevice(
          id: bonded.macAddress,
          name: bonded.deviceName,
          mac: bonded.macAddress,
          rssi: -60,
        );
        _connectedDevice = BandDeviceInfo(
          name: bonded.deviceName,
          id: bonded.macAddress,
          macAddress: bonded.macAddress,
          firmwareVersion: bonded.firmwareVersion ?? '1.0.4',
          hardwareVersion: bonded.modelNumber ?? '1.0.0',
        );
        _battery = BandBatteryInfo(
          percentage: bonded.batteryLevel,
          isCharging: bonded.isCharging,
        );
      } else {
        final mac = await _secureStorage.getBondedDeviceMac();
        if (mac != null && mac.isNotEmpty) {
          final dev = await _db.deviceDao.getDeviceByMac(mac);
          if (dev != null) {
            _lastPairedDevice = DiscoveredBandDevice(
              id: dev.macAddress,
              name: dev.deviceName,
              mac: dev.macAddress,
              rssi: -60,
            );
          }
        }
      }

      // 1. Instant check from secure storage cache
      final cachedJson = await _secureStorage.read('cached_band_synced_vitals_v1');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          _lastSyncedVitals = BandSyncedVitals.fromJson(decoded);
          _syncedVitalsController.add(_lastSyncedVitals);
        } catch (_) {}
      }

      // 2. Load today's summary and discrete vitals from Drift SQLite
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final summary = await _db.healthDataDao.getDailySummary('default_user', today);
      final devId = _connectedDevice?.macAddress ?? _lastPairedDevice?.mac ?? 'default_band';
      final latestStress = await _db.healthDataDao.getLatestVital(devId, 'stress');
      final latestHrv = await _db.healthDataDao.getLatestVital(devId, 'hrv');
      final latestBp = await _db.healthDataDao.getLatestVital(devId, 'blood_pressure');
      final latestTemp = await _db.healthDataDao.getLatestVital(devId, 'temperature');

      if (summary != null || latestStress != null || latestHrv != null) {
        _lastSyncedVitals = BandSyncedVitals(
          steps: summary?.steps ?? 0,
          calories: summary?.caloriesBurned.round() ?? 0,
          distance: summary?.distanceMeters.round() ?? 0,
          sleepMinutes: summary?.sleepDurationMinutes ?? 0,
          deepSleepMinutes: summary?.deepSleepMinutes ?? 0,
          bloodOxygen: summary?.avgSpo2 ?? 0.0,
          restingHeartRate: summary?.restingHeartRate ?? 0,
          stressLevel: latestStress?.valueNumeric?.round() ?? 0,
          hrvMs: latestHrv?.valueNumeric?.round() ?? 0,
          systolicBP: latestBp?.valueNumeric?.round() ?? 0,
          diastolicBP: latestBp?.secondaryNumeric?.round() ?? 0,
          skinTemperature: latestTemp?.valueNumeric ?? 0.0,
        );
        _syncedVitalsController.add(_lastSyncedVitals);
      }
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] _loadCachedData error: $e');
    }
  }

  Future<void> _persistVitals(BandSyncedVitals vitals) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final devId = _connectedDevice?.macAddress ?? _lastPairedDevice?.mac ?? 'default_band';
      final now = DateTime.now();

      // 0. Persist JSON to Secure Storage for instant hydration on restart
      _secureStorage.write('cached_band_synced_vitals_v1', jsonEncode(vitals.toJson())).catchError((_) {});

      // 1. Upsert daily summary to Drift DB
      await _db.healthDataDao.upsertDailySummary(
        DailyHealthSummariesTableCompanion(
          userId: const drift.Value('default_user'),
          deviceId: drift.Value(devId),
          date: drift.Value(today),
          steps: drift.Value(vitals.steps),
          caloriesBurned: drift.Value(vitals.calories.toDouble()),
          distanceMeters: drift.Value(vitals.distance.toDouble()),
          restingHeartRate: drift.Value(vitals.restingHeartRate > 0 ? vitals.restingHeartRate : null),
          avgHeartRate: drift.Value(vitals.restingHeartRate > 0 ? vitals.restingHeartRate : null),
          avgSpo2: drift.Value(vitals.bloodOxygen > 0 ? vitals.bloodOxygen : null),
          sleepDurationMinutes: drift.Value(vitals.sleepMinutes),
          deepSleepMinutes: drift.Value(vitals.deepSleepMinutes),
          lastSyncTimestamp: drift.Value(now),
        ),
      );

      // 2. Persist discrete vitals records
      final List<VitalsRecordsTableCompanion> vitalsBatch = [];
      if (vitals.bloodOxygen > 0) {
        vitalsBatch.add(
          VitalsRecordsTableCompanion(
            deviceId: drift.Value(devId),
            vitalType: const drift.Value('spo2'),
            valueNumeric: drift.Value(vitals.bloodOxygen),
            unit: const drift.Value('%'),
            timestamp: drift.Value(now),
          ),
        );
      }
      if (vitals.systolicBP > 0 && vitals.diastolicBP > 0) {
        vitalsBatch.add(
          VitalsRecordsTableCompanion(
            deviceId: drift.Value(devId),
            vitalType: const drift.Value('blood_pressure'),
            valueNumeric: drift.Value(vitals.systolicBP.toDouble()),
            secondaryNumeric: drift.Value(vitals.diastolicBP.toDouble()),
            unit: const drift.Value('mmHg'),
            timestamp: drift.Value(now),
          ),
        );
      }
      if (vitals.skinTemperature > 0) {
        vitalsBatch.add(
          VitalsRecordsTableCompanion(
            deviceId: drift.Value(devId),
            vitalType: const drift.Value('temperature'),
            valueNumeric: drift.Value(vitals.skinTemperature),
            unit: const drift.Value('°C'),
            timestamp: drift.Value(now),
          ),
        );
      }
      if (vitals.stressLevel > 0) {
        vitalsBatch.add(
          VitalsRecordsTableCompanion(
            deviceId: drift.Value(devId),
            vitalType: const drift.Value('stress'),
            valueNumeric: drift.Value(vitals.stressLevel.toDouble()),
            unit: const drift.Value('/100'),
            timestamp: drift.Value(now),
          ),
        );
      }
      if (vitals.hrvMs > 0) {
        vitalsBatch.add(
          VitalsRecordsTableCompanion(
            deviceId: drift.Value(devId),
            vitalType: const drift.Value('hrv'),
            valueNumeric: drift.Value(vitals.hrvMs.toDouble()),
            unit: const drift.Value('ms'),
            timestamp: drift.Value(now),
          ),
        );
      }

      if (vitalsBatch.isNotEmpty) {
        await _db.healthDataDao.insertVitalsBatch(vitalsBatch);
      }

      // 3. Persist heart rate samples
      if (vitals.heartRateHistory.isNotEmpty) {
        final samples = vitals.heartRateHistory.map((hr) {
          final t = DateTime.tryParse(hr.timestamp) ?? now;
          return HeartRateSamplesTableCompanion(
            deviceId: drift.Value(devId),
            timestamp: drift.Value(t),
            bpm: drift.Value(hr.bpm),
            isResting: drift.Value(hr.bpm == vitals.restingHeartRate),
          );
        }).toList();
        await _db.healthDataDao.insertHeartRateSamples(samples);
      }

      // 4. Update sync timestamp on device
      await _db.deviceDao.updateSyncTimestamp(devId, now);
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] _persistVitals error: $e');
    }
  }

  Future<void> _persistDevice(DiscoveredBandDevice device) async {
    try {
      final mac = device.mac.isNotEmpty ? device.mac : device.id;
      await _secureStorage.saveBondedDeviceMac(mac);
      await _db.deviceDao.upsertDevice(
        BandDevicesTableCompanion(
          macAddress: drift.Value(mac),
          deviceName: drift.Value(device.name),
          isBonded: const drift.Value(true),
          lastConnectedAt: drift.Value(DateTime.now()),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] _persistDevice error: $e');
    }
  }

  Stream<BandSyncedVitals> get syncedVitalsStream => _syncedVitalsController.stream;

  Stream<BandConnectionStatus> get connectionStatusStream =>
      _service.connectionStatusStream;

  Stream<List<DiscoveredBandDevice>> get discoveredDevicesStream =>
      _service.discoveredDevicesStream;

  Stream<int> get liveHeartRateStream => _service.liveHeartRateStream;

  Stream<BandBatteryInfo> get batteryStream => _service.batteryStream;

  Stream<BandMeasurementResult> get measurementResultStream =>
      _service.measurementResultStream;

  Stream<BandPedometerInfo> get pedometerStream => _service.pedometerStream;

  Stream<BandBluetoothState> get bluetoothStateStream =>
      _service.bluetoothStateStream;

  BandDeviceInfo? get currentConnectedDevice => _connectedDevice;
  BandBatteryInfo get currentBattery => _battery;
  DiscoveredBandDevice? get lastPairedDevice => _lastPairedDevice;
  BandSyncedVitals get lastSyncedVitals => _lastSyncedVitals;
  String? get lastConnectionError => _service.lastConnectionError;

  /// Waits for SQLite cache restoration to finish on app startup / hot restart.
  Future<void> ensureInitialized() => _initCompleter.future;

  /// Inspects OS permission status and Bluetooth/Location state.
  Future<BandPermissionDetails> checkPermissions() => _service.checkPermissions();

  /// Prompts user to grant required Bluetooth/Location permissions.
  Future<BandPermissionDetails> requestPermissions() => _service.requestPermissions();

  /// Opens the system application settings page.
  Future<void> openAppSettings() => _service.openAppSettings();

  /// Prompts user / launches OS intent to enable Bluetooth.
  Future<void> requestEnableBluetooth() => _service.requestEnableBluetooth();

  /// Opens system Location settings (for Android device discovery).
  Future<void> openLocationSettings() => _service.openLocationSettings();

  /// Starts BLE scanning.
  Future<void> startScan({Duration timeout = const Duration(seconds: 30)}) async {
    await _service.startScan(timeout: timeout);
  }

  /// Stops ongoing scan.
  Future<void> stopScan() async {
    await _service.stopScan();
  }

  /// Connects to a device by ID and performs post-connect handshake in background.
  Future<bool> connect(DiscoveredBandDevice device) async {
    _isExplicitDisconnect = false;
    _reconnectAttempts = 0;
    _autoReconnectTimer?.cancel();
    _autoReconnectTimer = null;
    final success = await _service.connect(device.id);
    if (success) {
      _lastPairedDevice = device;
      _persistDevice(device);
      _connectedDevice = BandDeviceInfo(
        name: device.name,
        id: device.id,
        macAddress: device.mac,
      );
      // Run background post-connect handshake (time sync, vibration, battery, version)
      // without blocking connection resolution.
      _performPostConnectHandshake(device);
      return true;
    }
    return false;
  }

  void _performPostConnectHandshake(DiscoveredBandDevice device) async {
    try {
      await _service.syncTime();
      final info = await _service.getDeviceInfo();
      _connectedDevice = info.copyWith(
        name: device.name,
        id: device.id,
        macAddress: device.mac.isNotEmpty ? device.mac : info.macAddress,
      );
      _battery = await _service.getBattery();
    } catch (_) {
      // Non-fatal handshake errors
    }
  }

  /// Tries auto-reconnecting to the previously paired device if available.
  Future<bool> tryAutoReconnect() async {
    if (!_initCompleter.isCompleted) {
      await _initCompleter.future;
    }
    final target = _lastPairedDevice;
    if (target == null || _isExplicitDisconnect) return false;
    if (_currentStatus == BandConnectionStatus.connected ||
        _currentStatus == BandConnectionStatus.connecting) {
      return true;
    }

    // Check if band is already actively connected natively (prevents reconnect churn on hot restart)
    final alreadyConnected = await _service.isConnected();
    if (alreadyConnected) {
      debugPrint('⚡️ [BAND RECONNECT] Band is already connected natively! Reusing existing connection.');
      _currentStatus = BandConnectionStatus.connected;
      _reconnectAttempts = 0;
      _service.getBattery().then((b) {
        if (b.percentage > 0) {
          _battery = b;
          final mac = target.mac;
          if (mac.isNotEmpty) {
            _db.deviceDao.updateBattery(mac, b.percentage, b.isCharging);
          }
        }
      });
      return true;
    }

    _isAutoReconnecting = true;
    debugPrint('🔄 [BAND RECONNECT] Connecting to ${target.name} (${target.id})...');

    try {
      final ok = await _service.connect(target.id).timeout(
        const Duration(seconds: 15),
        onTimeout: () => false,
      );
      if (ok || _currentStatus == BandConnectionStatus.connected) {
        debugPrint('⚡️ [BAND RECONNECT] Direct connect succeeded!');
        _reconnectAttempts = 0;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('⚠️ [BAND RECONNECT] Reconnect attempt failed: $e');
      return false;
    } finally {
      _isAutoReconnecting = false;
    }
  }

  /// Disconnects from the current device.
  /// If [unpair] is false, preserves paired band info for rapid reconnect / cold reconnect.
  /// If [unpair] is true, removes paired band info from memory and persistent cache.
  Future<void> disconnect({bool unpair = false}) async {
    _isExplicitDisconnect = true;
    _autoReconnectTimer?.cancel();
    _autoReconnectTimer = null;
    _isAutoReconnecting = false;
    await _service.disconnect(unpair: unpair);
    _connectedDevice = null;
    if (unpair) {
      _lastPairedDevice = null;
      await _secureStorage.clearBondedDevice();
      await _db.deviceDao.clearBonding();
    }
  }

  /// Triggers find device vibration on the band.
  Future<bool> findBand() async {
    return _service.findBand();
  }

  /// Starts continuous heart rate measurement stream (training mode only).
  Future<bool> startRealtimeHeartRate() async {
    return _service.startRealtimeHeartRate();
  }

  /// Stops continuous heart rate measurement stream.
  Future<bool> stopRealtimeHeartRate() async {
    return _service.stopRealtimeHeartRate();
  }

  /// Returns the latest recorded heart rate sample from memory or Drift SQLite
  /// without activating the band's optical PPG real-time sensor.
  Future<int?> fetchLatestHeartRateSample() async {
    if (_lastSyncedVitals.restingHeartRate > 0) {
      return _lastSyncedVitals.restingHeartRate;
    }
    try {
      final devId = _connectedDevice?.macAddress ?? _lastPairedDevice?.mac ?? 'default_band';
      final latestHr = await _db.healthDataDao.getLatestVital(devId, 'heart_rate');
      if (latestHr != null && latestHr.valueNumeric != null && latestHr.valueNumeric! > 0) {
        return latestHr.valueNumeric!.round();
      }
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] fetchLatestHeartRateSample error: $e');
    }
    return null;
  }

  /// Synchronizes daily steps, calories, and sleep records.
  Future<BandSyncedVitals> syncHistoricalVitals() async {
    final vitals = await _service.syncHistoricalVitals();
    _lastSyncedVitals = vitals;
    _persistVitals(vitals);
    _syncedVitalsController.add(vitals);
    return vitals;
  }

  bool _isSyncingVitals = false;
  Future<BandSyncedVitals>? _ongoingSyncFuture;

  /// Synchronizes all available health data from the band in one comprehensive call.
  Future<BandSyncedVitals> syncFullHealthData() async {
    if (_isSyncingVitals && _ongoingSyncFuture != null) {
      debugPrint('ℹ️ [BAND REPO] syncFullHealthData already in progress, deduplicating call');
      return _ongoingSyncFuture!;
    }
    _isSyncingVitals = true;
    _ongoingSyncFuture = () async {
      try {
        final rawVitals = await _service.syncFullHealthData();
        // Non-destructive merge with previous vitals to preserve non-zero metrics
        final vitals = _lastSyncedVitals.copyWith(
          steps: rawVitals.steps > 0 ? rawVitals.steps : _lastSyncedVitals.steps,
          calories: rawVitals.calories > 0 ? rawVitals.calories : _lastSyncedVitals.calories,
          distance: rawVitals.distance > 0 ? rawVitals.distance : _lastSyncedVitals.distance,
          sleepMinutes: rawVitals.sleepMinutes > 0 ? rawVitals.sleepMinutes : _lastSyncedVitals.sleepMinutes,
          deepSleepMinutes: rawVitals.deepSleepMinutes > 0 ? rawVitals.deepSleepMinutes : _lastSyncedVitals.deepSleepMinutes,
          bloodOxygen: rawVitals.bloodOxygen > 0 ? rawVitals.bloodOxygen : _lastSyncedVitals.bloodOxygen,
          systolicBP: rawVitals.systolicBP > 0 ? rawVitals.systolicBP : _lastSyncedVitals.systolicBP,
          diastolicBP: rawVitals.diastolicBP > 0 ? rawVitals.diastolicBP : _lastSyncedVitals.diastolicBP,
          skinTemperature: rawVitals.skinTemperature > 0 ? rawVitals.skinTemperature : _lastSyncedVitals.skinTemperature,
          stressLevel: rawVitals.stressLevel > 0 ? rawVitals.stressLevel : _lastSyncedVitals.stressLevel,
          hrvMs: rawVitals.hrvMs > 0 ? rawVitals.hrvMs : _lastSyncedVitals.hrvMs,
          restingHeartRate: rawVitals.restingHeartRate > 0 ? rawVitals.restingHeartRate : _lastSyncedVitals.restingHeartRate,
          breathingRate: rawVitals.breathingRate > 0 ? rawVitals.breathingRate : _lastSyncedVitals.breathingRate,
          sleepPhases: rawVitals.sleepPhases.isNotEmpty ? rawVitals.sleepPhases : _lastSyncedVitals.sleepPhases,
          heartRateHistory: rawVitals.heartRateHistory.isNotEmpty ? rawVitals.heartRateHistory : _lastSyncedVitals.heartRateHistory,
          weeklyHeartRate: rawVitals.weeklyHeartRate.isNotEmpty ? rawVitals.weeklyHeartRate : _lastSyncedVitals.weeklyHeartRate,
          weeklySleep: rawVitals.weeklySleep.isNotEmpty ? rawVitals.weeklySleep : _lastSyncedVitals.weeklySleep,
          weeklyHrv: rawVitals.weeklyHrv.isNotEmpty ? rawVitals.weeklyHrv : _lastSyncedVitals.weeklyHrv,
          weeklyStress: rawVitals.weeklyStress.isNotEmpty ? rawVitals.weeklyStress : _lastSyncedVitals.weeklyStress,
          weeklyOxygen: rawVitals.weeklyOxygen.isNotEmpty ? rawVitals.weeklyOxygen : _lastSyncedVitals.weeklyOxygen,
          weeklyRestingHr: rawVitals.weeklyRestingHr.isNotEmpty ? rawVitals.weeklyRestingHr : _lastSyncedVitals.weeklyRestingHr,
          weeklyBreathing: rawVitals.weeklyBreathing.isNotEmpty ? rawVitals.weeklyBreathing : _lastSyncedVitals.weeklyBreathing,
        );
        _lastSyncedVitals = vitals;
        _persistVitals(vitals);
        _syncedVitalsController.add(vitals);
        return vitals;
      } finally {
        _isSyncingVitals = false;
        _ongoingSyncFuture = null;
      }
    }();
    return _ongoingSyncFuture!;
  }

  /// Starts an on-demand single measurement.
  Future<bool> startMeasuring(MeasurementType type) async {
    return _service.startMeasuring(type);
  }

  /// Stops an ongoing on-demand measurement.
  Future<bool> stopMeasuring(MeasurementType type) async {
    return _service.stopMeasuring(type);
  }

  /// Formats all health and vitals records into an exportable JSON map.
  Map<String, dynamic> exportHealthData() {
    return {
      'exportTimestamp': DateTime.now().toIso8601String(),
      'device': {
        'name': _connectedDevice?.name ?? 'EHG Smart Band',
        'id': _connectedDevice?.id ?? 'EH-9F2C',
        'mac': _connectedDevice?.macAddress ?? 'C8:FD:19:9F:2C:4E',
        'firmwareVersion': _connectedDevice?.firmwareVersion ?? '1.0.4',
        'hardwareVersion': _connectedDevice?.hardwareVersion ?? '1.0.0',
        'batteryLevel': '${_battery.percentage}%',
      },
      'vitals': {
        'steps': _lastSyncedVitals.steps,
        'activeCalories': _lastSyncedVitals.calories,
        'distanceMeters': _lastSyncedVitals.distance,
        'totalSleepMinutes': _lastSyncedVitals.sleepMinutes,
        'deepSleepMinutes': _lastSyncedVitals.deepSleepMinutes,
        'bloodOxygen': _lastSyncedVitals.bloodOxygen,
        'systolicBP': _lastSyncedVitals.systolicBP,
        'diastolicBP': _lastSyncedVitals.diastolicBP,
        'skinTemperature': _lastSyncedVitals.skinTemperature,
        'stressLevel': _lastSyncedVitals.stressLevel,
        'hrvMs': _lastSyncedVitals.hrvMs,
        'restingHeartRate': _lastSyncedVitals.restingHeartRate,
      },
    };
  }

  /// Formats all health and vitals records into an exportable JSON string.
  String exportHealthDataJson() {
    return const JsonEncoder.withIndent('  ').convert(exportHealthData());
  }

  /// Clears cached local device and health data.
  Future<void> clearLocalData() async {
    await disconnect(unpair: true);
    _lastSyncedVitals = const BandSyncedVitals();
    await _secureStorage.deleteAll();
    _syncedVitalsController.add(_lastSyncedVitals);
  }

  /// Disposes background resources.
  void dispose() {
    _autoReconnectTimer?.cancel();
    _autoReconnectTimer = null;
    _statusSubscription?.cancel();
    _pedometerSubscription?.cancel();
    _measurementSubscription?.cancel();
    _batterySubscription?.cancel();
    _syncedVitalsController.close();
    _service.dispose();
  }
}

