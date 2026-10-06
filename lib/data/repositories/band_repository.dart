import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';
import '../../core/security/secure_storage_service.dart';
import '../../core/services/active_device_service.dart';
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
  final ActiveDeviceService? activeDeviceService;
  final StreamController<BandSyncedVitals> _syncedVitalsController =
      StreamController<BandSyncedVitals>.broadcast();

  BandDeviceInfo? _connectedDevice;
  BandBatteryInfo _battery = const BandBatteryInfo(percentage: 0);
  DiscoveredBandDevice? _lastPairedDevice;
  BandSyncedVitals _lastSyncedVitals = const BandSyncedVitals();
  StreamSubscription<BandConnectionStatus>? _statusSubscription;
  StreamSubscription<BandPedometerInfo>? _pedometerSubscription;
  StreamSubscription<BandMeasurementResult>? _measurementSubscription;
  StreamSubscription<int>? _liveHeartRateSubscription;
  StreamSubscription<BandBatteryInfo>? _batterySubscription;
  StreamSubscription<String>? _errorSubscription;

  bool _isExplicitDisconnect = false;
  bool _isAutoReconnecting = false;
  Timer? _autoReconnectTimer;
  int _reconnectAttempts = 0;
  BandConnectionStatus _currentStatus = BandConnectionStatus.disconnected;
  final Completer<void> _initCompleter = Completer<void>();

  ActiveDeviceService? get _activeDeviceService => activeDeviceService;
  String? get activeDeviceId => activeDeviceService?.activeDeviceId;

  BandRepository({
    BandService? service,
    AppDatabase? database,
    SecureStorageService? secureStorage,
    this.activeDeviceService,
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
        _service.syncTime().catchError((_) => false);
        _service.getBattery().then((b) {
          if (b.percentage > 0) {
            _battery = b;
            final mac = _lastPairedDevice?.mac ?? '';
            if (mac.isNotEmpty) {
              _db.deviceDao.updateBattery(mac, b.percentage, b.isCharging);
            }
          }
        });
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
      checkMidnightRollover();
      if (info.steps != _lastSyncedVitals.steps ||
          info.calories != _lastSyncedVitals.calories ||
          info.distance != _lastSyncedVitals.distance) {
        _lastSyncedVitals = _lastSyncedVitals.copyWith(
          steps: info.steps,
          calories: info.calories,
          distance: info.distance,
          date: DateTime.now().toIso8601String().substring(0, 10),
        );
        _persistVitals(_lastSyncedVitals);
        _syncedVitalsController.add(_lastSyncedVitals);
      }
    });

    _measurementSubscription = _service.measurementResultStream.listen((result) {
      if (result.success && result.data.isNotEmpty) {
        final d = result.data;
        final int? hr = (d['hr'] as num?)?.toInt();
        List<BandHeartRateEntry> updatedHrHistory = List.from(_lastSyncedVitals.heartRateHistory);
        List<double> updatedWeeklyHr = List.from(
          _lastSyncedVitals.weeklyHeartRate.length == 7
              ? _lastSyncedVitals.weeklyHeartRate
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        );
        if (hr != null && hr > 0) {
          final nowIso = DateTime.now().toIso8601String();
          updatedHrHistory.add(BandHeartRateEntry(bpm: hr, timestamp: nowIso));
          final todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
          if (updatedWeeklyHr.length == 7) {
            updatedWeeklyHr[todayIdx] = hr.toDouble();
          }
        }
        _lastSyncedVitals = _lastSyncedVitals.copyWith(
          bloodOxygen: (d['spo2'] as num?)?.toDouble(),
          systolicBP: (d['sbp'] as num?)?.toInt(),
          diastolicBP: (d['dbp'] as num?)?.toInt(),
          skinTemperature: (d['temperature'] as num?)?.toDouble(),
          stressLevel: (d['stress'] as num?)?.toInt(),
          hrvMs: (d['hrv'] as num?)?.toInt(),
          latestHeartRate: (hr != null && hr > 0) ? hr : _lastSyncedVitals.latestHeartRate,
          restingHeartRate: _lastSyncedVitals.restingHeartRate,
          heartRateHistory: updatedHrHistory,
          weeklyHeartRate: updatedWeeklyHr,
        );
        _persistVitals(_lastSyncedVitals);
        _syncedVitalsController.add(_lastSyncedVitals);
      }
    });

    _liveHeartRateSubscription = _service.liveHeartRateStream.listen((bpm) {
      if (bpm > 0 && bpm != _lastSyncedVitals.latestHeartRate) {
        final nowIso = DateTime.now().toIso8601String();
        final updatedHrHistory = List<BandHeartRateEntry>.from(_lastSyncedVitals.heartRateHistory)
          ..add(BandHeartRateEntry(bpm: bpm, timestamp: nowIso));
        final todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
        final updatedWeekly = List<double>.from(
          _lastSyncedVitals.weeklyHeartRate.length == 7
              ? _lastSyncedVitals.weeklyHeartRate
              : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        );
        updatedWeekly[todayIdx] = bpm.toDouble();

        _lastSyncedVitals = _lastSyncedVitals.copyWith(
          latestHeartRate: bpm,
          heartRateHistory: updatedHrHistory,
          weeklyHeartRate: updatedWeekly,
        );
        _persistVitals(_lastSyncedVitals);
        _syncedVitalsController.add(_lastSyncedVitals);
      }
    });

    _errorSubscription = _service.connectionErrorStream.listen((error) {
      if (error.contains('Pairing info mismatch') || error.contains('Forget This Device')) {
        debugPrint('🛑 [BAND REPO] Auto-reconnect aborted due to pairing info mismatch: $error');
        _autoReconnectTimer?.cancel();
        _autoReconnectTimer = null;
        _isAutoReconnecting = false;
      }
    });
  }

  void _scheduleAutoReconnect() {
    if (_isExplicitDisconnect || _lastPairedDevice == null || _isAutoReconnecting) return;
    _autoReconnectTimer?.cancel();
    _reconnectAttempts++;
    // Exponential backoff: 5s, 10s, 20s, 40s, capped at 60s
    final int delaySec = math.min(60, 5 * math.pow(2, math.min(_reconnectAttempts - 1, 4)).toInt());

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
      await _activeDeviceService?.initialize();
      final activeMac = _activeDeviceService?.activeDeviceId;

      // 1. Check Drift DB for active or bonded device
      BandDeviceEntry? targetDev;
      if (activeMac != null && activeMac.isNotEmpty) {
        targetDev = await _db.deviceDao.getDeviceByMac(activeMac);
      }
      targetDev ??= await _db.deviceDao.getActiveDevice();
      targetDev ??= await _db.deviceDao.getBondedDevice();

      if (targetDev != null) {
        _lastPairedDevice = DiscoveredBandDevice(
          id: targetDev.macAddress,
          name: targetDev.deviceName,
          mac: targetDev.macAddress,
          rssi: -60,
        );
        _connectedDevice = BandDeviceInfo(
          name: targetDev.deviceName,
          id: targetDev.macAddress,
          macAddress: targetDev.macAddress,
          firmwareVersion: targetDev.firmwareVersion ?? '1.0.4',
          hardwareVersion: targetDev.modelNumber ?? '1.0.0',
        );
        _battery = BandBatteryInfo(
          percentage: targetDev.batteryLevel,
          isCharging: targetDev.isCharging,
        );
        await _activeDeviceService?.setActiveDevice(targetDev.macAddress);
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
            await _activeDeviceService?.setActiveDevice(dev.macAddress);
          }
        }
      }

      final devId = _connectedDevice?.macAddress ??
          _lastPairedDevice?.mac ??
          _activeDeviceService?.activeDeviceId ??
          'default_band';

      final today = DateTime.now().toIso8601String().substring(0, 10);
      _lastRecordedDate = today;

      // 1. Instant check from per-device secure storage cache
      final cachedJson = await _secureStorage.read('cached_band_synced_vitals_$devId') ??
          await _secureStorage.read('cached_band_synced_vitals_v1');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          final parsed = BandSyncedVitals.fromJson(decoded);
          if (parsed.date.isNotEmpty && parsed.date != today) {
            // Snapshot belongs to a past date (e.g. Oct 5) - reset today's counters to 0
            _lastSyncedVitals = parsed.copyWith(
              steps: 0,
              calories: 0,
              distance: 0,
              sleepMinutes: 0,
              deepSleepMinutes: 0,
              sleepPhases: const [],
              hourlySteps: List.filled(24, 0),
              date: today,
              dayIndex: 0,
            );
          } else {
            _lastSyncedVitals = parsed.copyWith(date: today);
          }
          _syncedVitalsController.add(_lastSyncedVitals);
        } catch (_) {}
      }

      // 2. Load today's summary and discrete vitals from Drift SQLite for this device
      final userId = await _secureStorage.getActiveUserId();
      final summary = await _db.healthDataDao.getDailySummary(userId, today, deviceId: devId);
      final sleepData = await _db.healthDataDao.getSleepSessionWithPhasesByDate(devId, today);
      final latestStress = await _db.healthDataDao.getLatestVital(devId, 'stress');
      final latestHrv = await _db.healthDataDao.getLatestVital(devId, 'hrv');
      final latestBp = await _db.healthDataDao.getLatestVital(devId, 'blood_pressure');
      final latestTemp = await _db.healthDataDao.getLatestVital(devId, 'temperature');
      final latestHr = await _db.healthDataDao.getLatestVital(devId, 'heart_rate');
      final int dbLatestHr = latestHr?.valueNumeric?.round() ?? 0;

      int loadedSleepMinutes = summary?.sleepDurationMinutes ?? 0;
      List<BandSleepPhase> loadedSleepPhases = const [];
      if (sleepData != null && sleepData.phases.isNotEmpty) {
        if (loadedSleepMinutes == 0) {
          loadedSleepMinutes = sleepData.session.totalDurationMinutes > 0
              ? sleepData.session.totalDurationMinutes
              : sleepData.phases.fold<int>(0, (sum, p) => sum + (p.durationMinutes > 0 ? p.durationMinutes : 1));
        }
        loadedSleepPhases = sleepData.phases.map((p) => BandSleepPhase(
          type: p.phaseType,
          startTime: p.startTime.toIso8601String(),
          endTime: p.endTime.toIso8601String(),
          durationMinutes: p.durationMinutes,
        )).toList();
      }

      if (summary != null || loadedSleepMinutes > 0 || latestStress != null || latestHrv != null || dbLatestHr > 0) {
        _lastSyncedVitals = BandSyncedVitals(
          steps: summary?.steps ?? 0,
          calories: summary?.caloriesBurned.round() ?? 0,
          distance: summary?.distanceMeters.round() ?? 0,
          sleepMinutes: loadedSleepMinutes,
          deepSleepMinutes: summary?.deepSleepMinutes ?? 0,
          sleepPhases: loadedSleepPhases,
          bloodOxygen: summary?.avgSpo2 ?? 0.0,
          restingHeartRate: summary?.restingHeartRate ?? 0,
          latestHeartRate: dbLatestHr > 0 ? dbLatestHr : _lastSyncedVitals.latestHeartRate,
          stressLevel: latestStress?.valueNumeric?.round() ?? 0,
          hrvMs: latestHrv?.valueNumeric?.round() ?? 0,
          systolicBP: latestBp?.valueNumeric?.round() ?? 0,
          diastolicBP: latestBp?.secondaryNumeric?.round() ?? 0,
          skinTemperature: latestTemp?.valueNumeric ?? 0.0,
          date: today,
        );
        _syncedVitalsController.add(_lastSyncedVitals);
      } else if (_lastSyncedVitals.date != today) {
        _lastSyncedVitals = _lastSyncedVitals.copyWith(
          steps: 0,
          calories: 0,
          distance: 0,
          sleepMinutes: 0,
          deepSleepMinutes: 0,
          sleepPhases: const [],
          hourlySteps: List.filled(24, 0),
          date: today,
          dayIndex: 0,
        );
        _syncedVitalsController.add(_lastSyncedVitals);
      }
      _lastRecordedDate = today;
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] _loadCachedData error: $e');
    }
  }

  String _lastRecordedDate = '';

  Future<void> _persistVitals(BandSyncedVitals vitals, {String? targetDate}) async {
    try {
      final now = DateTime.now();
      final today = now.toIso8601String().substring(0, 10);
      final effectiveDate = targetDate ?? (vitals.date.isNotEmpty ? vitals.date : today);
      final devId = _connectedDevice?.macAddress ??
          _lastPairedDevice?.mac ??
          _activeDeviceService?.activeDeviceId ??
          'default_band';
      final userId = await _secureStorage.getActiveUserId();

      final parsedEffectiveDate = DateTime.tryParse(effectiveDate) ?? now;
      final effectiveRecordTimestamp = (effectiveDate == today)
          ? now
          : DateTime(parsedEffectiveDate.year, parsedEffectiveDate.month, parsedEffectiveDate.day, 12, 0, 0);

      // Compute heart rate aggregates from history or latest/resting
      int? calculatedAvgHr;
      int? calculatedMinHr;
      int? calculatedMaxHr;
      int? calculatedRestingHr;

      final validBpmList = vitals.heartRateHistory
          .where((h) => h.bpm > 0)
          .map((h) => h.bpm)
          .toList();

      if (validBpmList.isNotEmpty) {
        calculatedAvgHr = (validBpmList.reduce((a, b) => a + b) / validBpmList.length).round();
        calculatedMinHr = validBpmList.reduce(math.min);
        calculatedMaxHr = validBpmList.reduce(math.max);
        calculatedRestingHr = vitals.restingHeartRate > 0 ? vitals.restingHeartRate : calculatedMinHr;
      } else if (vitals.latestHeartRate > 0) {
        calculatedAvgHr = vitals.latestHeartRate;
        calculatedMinHr = vitals.latestHeartRate;
        calculatedMaxHr = vitals.latestHeartRate;
        calculatedRestingHr = vitals.restingHeartRate > 0 ? vitals.restingHeartRate : vitals.latestHeartRate;
      } else if (vitals.restingHeartRate > 0) {
        calculatedAvgHr = vitals.restingHeartRate;
        calculatedMinHr = vitals.restingHeartRate;
        calculatedMaxHr = vitals.restingHeartRate;
        calculatedRestingHr = vitals.restingHeartRate;
      }

      // 0. Persist JSON to Secure Storage for instant hydration on restart (per-device and legacy key)
      final vitalsWithDate = vitals.copyWith(date: effectiveDate);
      if (effectiveDate == today) {
        _secureStorage.write('cached_band_synced_vitals_$devId', jsonEncode(vitalsWithDate.toJson())).catchError((_) {});
        _secureStorage.write('cached_band_synced_vitals_v1', jsonEncode(vitalsWithDate.toJson())).catchError((_) {});
      }

      // Compute scores for daily summary if vitals data is present
      int? calculatedWellnessScore;
      int? calculatedMoveScore;
      int? calculatedRecoverScore;
      final double calBurned = BandSyncedVitals.sanitizeCalories(vitals.calories, steps: vitals.steps).toDouble();
      if (vitals.steps > 0 || vitals.sleepMinutes > 0 || calBurned > 0 || calculatedRestingHr != null) {
        calculatedMoveScore = (calBurned > 0
            ? (calBurned / 600 * 100).clamp(15, 98).round()
            : (vitals.steps > 0 ? (vitals.steps / 8000 * 100).clamp(15, 98).round() : 0));
        calculatedRecoverScore = (vitals.sleepMinutes > 0
            ? ((vitals.sleepMinutes / 480.0 * 100).clamp(15, 98).round())
            : (calculatedRestingHr != null && calculatedRestingHr > 0 ? 75 : 0));
        final scores = <int>[];
        if (calculatedMoveScore > 0) scores.add(calculatedMoveScore);
        if (calculatedRecoverScore > 0) scores.add(calculatedRecoverScore);
        scores.add(75);
        scores.add(75);
        calculatedWellnessScore = (scores.reduce((a, b) => a + b) / scores.length).round().clamp(1, 100);
      }

      final yesterdayStr = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      if (effectiveDate == yesterdayStr && calculatedWellnessScore != null && calculatedWellnessScore > 0) {
        _secureStorage.write('cached_yesterday_wellness_score', '$calculatedWellnessScore').catchError((_) {});
      }

      // 1. Upsert daily summary to Drift DB
      await _db.healthDataDao.upsertDailySummary(
        DailyHealthSummariesTableCompanion(
          userId: drift.Value(userId),
          deviceId: drift.Value(devId),
          date: drift.Value(effectiveDate),
          steps: drift.Value(vitals.steps),
          caloriesBurned: drift.Value(calBurned),
          distanceMeters: drift.Value(vitals.distance.toDouble()),
          restingHeartRate: drift.Value(calculatedRestingHr),
          avgHeartRate: drift.Value(calculatedAvgHr),
          minHeartRate: drift.Value(calculatedMinHr),
          maxHeartRate: drift.Value(calculatedMaxHr),
          avgSpo2: drift.Value(vitals.bloodOxygen > 0 ? vitals.bloodOxygen : null),
          sleepDurationMinutes: drift.Value(vitals.sleepMinutes),
          deepSleepMinutes: drift.Value(vitals.deepSleepMinutes),
          wellnessScore: calculatedWellnessScore != null ? drift.Value(calculatedWellnessScore) : const drift.Value.absent(),
          moveScore: calculatedMoveScore != null ? drift.Value(calculatedMoveScore) : const drift.Value.absent(),
          recoverScore: calculatedRecoverScore != null ? drift.Value(calculatedRecoverScore) : const drift.Value.absent(),
          lastSyncTimestamp: drift.Value(now),
        ),
      );

      // 2. Persist discrete vitals records with effective historical timestamp
      final List<VitalsRecordsTableCompanion> vitalsBatch = [];
      if (vitals.bloodOxygen > 0) {
        vitalsBatch.add(
          VitalsRecordsTableCompanion(
            deviceId: drift.Value(devId),
            vitalType: const drift.Value('spo2'),
            valueNumeric: drift.Value(vitals.bloodOxygen),
            unit: const drift.Value('%'),
            timestamp: drift.Value(effectiveRecordTimestamp),
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
            timestamp: drift.Value(effectiveRecordTimestamp),
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
            timestamp: drift.Value(effectiveRecordTimestamp),
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
            timestamp: drift.Value(effectiveRecordTimestamp),
          ),
        );
      }
      final hrForRecord = vitals.latestHeartRate > 0 ? vitals.latestHeartRate : (calculatedAvgHr ?? 0);
      if (hrForRecord > 0) {
        vitalsBatch.add(
          VitalsRecordsTableCompanion(
            deviceId: drift.Value(devId),
            vitalType: const drift.Value('heart_rate'),
            valueNumeric: drift.Value(hrForRecord.toDouble()),
            unit: const drift.Value('bpm'),
            timestamp: drift.Value(effectiveRecordTimestamp),
          ),
        );
      }

      if (vitalsBatch.isNotEmpty) {
        await _db.healthDataDao.insertVitalsBatch(vitalsBatch);
      }

      // 3. Persist heart rate samples accurately mapped to historical timestamps
      if (vitals.heartRateHistory.isNotEmpty) {
        final samples = vitals.heartRateHistory.map((hr) {
          DateTime sampleTime;
          if (hr.timestamp.contains('#')) {
            final parts = hr.timestamp.split('#');
            final baseDate = DateTime.tryParse(parts[0]) ?? parsedEffectiveDate;
            final idx = int.tryParse(parts[1]) ?? 0;
            // QCSDK intervals are 5 minutes (288 slots) spanning 00:00 to 23:55
            sampleTime = DateTime(baseDate.year, baseDate.month, baseDate.day).add(Duration(minutes: idx * 5));
          } else {
            sampleTime = DateTime.tryParse(hr.timestamp) ?? parsedEffectiveDate;
          }
          return HeartRateSamplesTableCompanion(
            deviceId: drift.Value(devId),
            timestamp: drift.Value(sampleTime),
            bpm: drift.Value(hr.bpm),
            isResting: drift.Value(calculatedRestingHr != null && hr.bpm == calculatedRestingHr),
          );
        }).toList();
        await _db.healthDataDao.insertHeartRateSamples(samples);
      }

      // 4. Persist sleep session and sleep phases
      if (vitals.sleepMinutes > 0) {
        final sleepEnd = (effectiveDate == today)
            ? now
            : DateTime(parsedEffectiveDate.year, parsedEffectiveDate.month, parsedEffectiveDate.day, 7, 0, 0);
        final sleepStart = sleepEnd.subtract(Duration(minutes: vitals.sleepMinutes));
        final sessionCompanion = SleepSessionsTableCompanion(
          deviceId: drift.Value(devId),
          startTime: drift.Value(sleepStart),
          endTime: drift.Value(sleepEnd),
          totalDurationMinutes: drift.Value(vitals.sleepMinutes),
          deepMinutes: drift.Value(vitals.deepSleepMinutes),
          lightMinutes: drift.Value((vitals.sleepMinutes - vitals.deepSleepMinutes).clamp(0, vitals.sleepMinutes)),
          date: drift.Value(effectiveDate),
          syncedAt: drift.Value(now),
        );
        final phasesList = vitals.sleepPhases.map((p) {
          final start = DateTime.tryParse(p.startTime) ?? sleepEnd.subtract(Duration(minutes: p.durationMinutes));
          final end = DateTime.tryParse(p.endTime) ?? sleepEnd;
          return SleepPhasesTableCompanion(
            phaseType: drift.Value(p.type),
            startTime: drift.Value(start),
            endTime: drift.Value(end),
            durationMinutes: drift.Value(p.durationMinutes),
          );
        }).toList();
        await _db.healthDataDao.insertSleepSessionWithPhases(sessionCompanion, phasesList);
      } else if (effectiveDate == today) {
        await _db.healthDataDao.deleteSleepSessionByDate(devId, effectiveDate);
      }

      // 5. Update sync timestamp on device
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
          isActive: const drift.Value(true),
          lastConnectedAt: drift.Value(DateTime.now()),
        ),
      );
      await _activeDeviceService?.setActiveDevice(mac);
      await _db.healthDataDao.migrateDefaultBandRecords(mac);
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] _persistDevice error: $e');
    }
  }

  /// Switches active band selection to another registered device (Band 1, Band 2, etc.)
  /// and immediately loads that device's isolated historical health records and cached vitals.
  Future<void> switchActiveDevice(String macAddress) async {
    if (macAddress.isEmpty) return;
    try {
      final device = await _db.deviceDao.getDeviceByMac(macAddress);
      if (device == null) return;

      await _activeDeviceService?.setActiveDevice(macAddress);
      _lastPairedDevice = DiscoveredBandDevice(
        id: device.macAddress,
        name: device.deviceName,
        mac: device.macAddress,
        rssi: -60,
      );
      _connectedDevice = BandDeviceInfo(
        name: device.deviceName,
        id: device.macAddress,
        macAddress: device.macAddress,
        firmwareVersion: device.firmwareVersion ?? '1.0.4',
        hardwareVersion: device.modelNumber ?? '1.0.0',
      );
      _battery = BandBatteryInfo(
        percentage: device.batteryLevel,
        isCharging: device.isCharging,
      );

      await loadDeviceData(macAddress);
      debugPrint('🔄 [BAND REPO] Switched active device to $macAddress (${device.deviceName})');
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] switchActiveDevice error: $e');
    }
  }

  /// Loads isolated vitals & health data for a specific device from secure storage and Drift DB.
  Future<void> loadDeviceData(String macAddress) async {
    try {
      // 1. Instant hydration from per-device secure storage cache
      final cachedJson = await _secureStorage.read('cached_band_synced_vitals_$macAddress');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
          final parsed = BandSyncedVitals.fromJson(decoded);
          final today = DateTime.now().toIso8601String().substring(0, 10);
          if (parsed.date.isNotEmpty && parsed.date != today) {
            _lastSyncedVitals = parsed.copyWith(
              steps: 0,
              calories: 0,
              distance: 0,
              sleepMinutes: 0,
              deepSleepMinutes: 0,
              sleepPhases: const [],
              hourlySteps: List.filled(24, 0),
              date: today,
              dayIndex: 0,
            );
          } else {
            _lastSyncedVitals = parsed.copyWith(date: today);
          }
          _syncedVitalsController.add(_lastSyncedVitals);
        } catch (_) {}
      }

      // 2. Load today's summary and discrete vitals from Drift SQLite
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final userId = await _secureStorage.getActiveUserId();
      final summary = await _db.healthDataDao.getDailySummary(userId, today, deviceId: macAddress);
      final sleepData = await _db.healthDataDao.getSleepSessionWithPhasesByDate(macAddress, today);
      final latestStress = await _db.healthDataDao.getLatestVital(macAddress, 'stress');
      final latestHrv = await _db.healthDataDao.getLatestVital(macAddress, 'hrv');
      final latestBp = await _db.healthDataDao.getLatestVital(macAddress, 'blood_pressure');
      final latestTemp = await _db.healthDataDao.getLatestVital(macAddress, 'temperature');
      final latestHr = await _db.healthDataDao.getLatestVital(macAddress, 'heart_rate');
      final int dbLatestHr = latestHr?.valueNumeric?.round() ?? 0;

      int loadedSleepMinutes = summary?.sleepDurationMinutes ?? 0;
      List<BandSleepPhase> loadedSleepPhases = const [];
      if (sleepData != null && sleepData.phases.isNotEmpty) {
        if (loadedSleepMinutes == 0) {
          loadedSleepMinutes = sleepData.session.totalDurationMinutes > 0
              ? sleepData.session.totalDurationMinutes
              : sleepData.phases.fold<int>(0, (sum, p) => sum + (p.durationMinutes > 0 ? p.durationMinutes : 1));
        }
        loadedSleepPhases = sleepData.phases.map((p) => BandSleepPhase(
          type: p.phaseType,
          startTime: p.startTime.toIso8601String(),
          endTime: p.endTime.toIso8601String(),
          durationMinutes: p.durationMinutes,
        )).toList();
      }

      if (summary != null || loadedSleepMinutes > 0 || latestStress != null || latestHrv != null || dbLatestHr > 0) {
        _lastSyncedVitals = BandSyncedVitals(
          steps: summary?.steps ?? 0,
          calories: summary?.caloriesBurned.round() ?? 0,
          distance: summary?.distanceMeters.round() ?? 0,
          sleepMinutes: loadedSleepMinutes,
          deepSleepMinutes: summary?.deepSleepMinutes ?? 0,
          sleepPhases: loadedSleepPhases,
          bloodOxygen: summary?.avgSpo2 ?? 0.0,
          restingHeartRate: summary?.restingHeartRate ?? 0,
          latestHeartRate: dbLatestHr > 0 ? dbLatestHr : _lastSyncedVitals.latestHeartRate,
          stressLevel: latestStress?.valueNumeric?.round() ?? 0,
          hrvMs: latestHrv?.valueNumeric?.round() ?? 0,
          systolicBP: latestBp?.valueNumeric?.round() ?? 0,
          diastolicBP: latestBp?.secondaryNumeric?.round() ?? 0,
          skinTemperature: latestTemp?.valueNumeric ?? 0.0,
          date: today,
        );
        _syncedVitalsController.add(_lastSyncedVitals);
      } else {
        _lastSyncedVitals = _lastSyncedVitals.copyWith(
          steps: 0,
          calories: 0,
          distance: 0,
          sleepMinutes: 0,
          deepSleepMinutes: 0,
          sleepPhases: const [],
          hourlySteps: List.filled(24, 0),
          date: today,
          dayIndex: 0,
        );
        _syncedVitalsController.add(_lastSyncedVitals);
      }
    } catch (e) {
      debugPrint('⚠️ [BAND REPO] loadDeviceData error: $e');
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
  DiscoveredBandDevice? get boundDevice => _lastPairedDevice;
  bool get isBound => _lastPairedDevice != null;
  BandSyncedVitals get lastSyncedVitals => _lastSyncedVitals;
  String? get lastConnectionError => _service.lastConnectionError;
  Stream<String> get connectionErrorStream => _service.connectionErrorStream;
  bool get isConnected => _currentStatus == BandConnectionStatus.connected;
  BandConnectionStatus get connectionStatus => _currentStatus;
  BandService get service => _service;
  Future<bool> reconnect() => tryAutoReconnect();
  Future<bool> syncTime() => _service.syncTime();

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
      final normalizedDevice = DiscoveredBandDevice(
        id: device.id,
        name: DiscoveredBandDevice.normalizeBandName(device.name),
        mac: device.mac,
        rssi: device.rssi,
      );
      _lastPairedDevice = normalizedDevice;
      await _persistDevice(normalizedDevice);
      _connectedDevice = BandDeviceInfo(
        name: normalizedDevice.name,
        id: normalizedDevice.id,
        macAddress: normalizedDevice.mac,
      );
      final devMac = normalizedDevice.mac.isNotEmpty ? normalizedDevice.mac : normalizedDevice.id;
      await loadDeviceData(devMac);

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

      // Manage pairing date baseline (WHOOP / Garmin standard)
      final devMac = device.mac.isNotEmpty ? device.mac : device.id;
      final existingPairingDate = await _secureStorage.getDevicePairingDate(devMac);
      final today = DateTime.now().toIso8601String().substring(0, 10);
      if (existingPairingDate == null) {
        debugPrint('🆕 [BAND REPO] First connection to band $devMac on $today. Establishing pairing baseline.');
        await _secureStorage.saveDevicePairingDate(devMac, today);
      }
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
      _service.syncTime().catchError((_) => false);
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
        _service.syncTime().catchError((_) => false);
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
  /// If [unpair] is true, unbonds device while PERMANENTLY preserving all historical data and cache.
  Future<void> disconnect({bool unpair = false, String? targetMac}) async {
    _isExplicitDisconnect = true;
    _autoReconnectTimer?.cancel();
    _autoReconnectTimer = null;
    _isAutoReconnecting = false;
    await _service.disconnect(unpair: unpair);
    
    final currentMac = targetMac ??
        _connectedDevice?.macAddress ??
        _lastPairedDevice?.mac ??
        _activeDeviceService?.activeDeviceId ??
        '';
    _connectedDevice = null;
    if (unpair) {
      _lastPairedDevice = null;
      _lastSyncedVitals = const BandSyncedVitals();
      _battery = const BandBatteryInfo(percentage: 0);
      _syncedVitalsController.add(_lastSyncedVitals);
      await _secureStorage.clearBondedDevice();
      // Unbind device in DB: preserves device row and all health records!
      if (currentMac.isNotEmpty) {
        await _db.deviceDao.unbindDevice(currentMac);
      }
      await _activeDeviceService?.clearActiveDevice();
    }
  }

  /// Explicitly unbinds the band matching QWatch Pro:
  /// Disconnects GATT, removes OS bond, updates bonding flag in database,
  /// and PRESERVES all historical health records associated with this band.
  Future<void> unbindBand([String? macAddress]) async {
    await disconnect(unpair: true, targetMac: macAddress);
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

  /// Records an on-demand spot or live heart rate measurement immediately.
  /// Updates local memory cache, persists to Drift SQLite and secure storage,
  /// updates weekly trend for today, and notifies all UI listeners.
  Future<void> recordHeartRateMeasurement(int bpm) async {
    if (bpm <= 0) return;
    final nowIso = DateTime.now().toIso8601String();
    final updatedHistory = List<BandHeartRateEntry>.from(_lastSyncedVitals.heartRateHistory)
      ..add(BandHeartRateEntry(bpm: bpm, timestamp: nowIso));

    final todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);
    final updatedWeekly = List<double>.from(
      _lastSyncedVitals.weeklyHeartRate.length == 7
          ? _lastSyncedVitals.weeklyHeartRate
          : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    );
    updatedWeekly[todayIdx] = bpm.toDouble();

    _lastSyncedVitals = _lastSyncedVitals.copyWith(
      latestHeartRate: bpm,
      heartRateHistory: updatedHistory,
      weeklyHeartRate: updatedWeekly,
    );
    await _persistVitals(_lastSyncedVitals);
    _syncedVitalsController.add(_lastSyncedVitals);
  }

  /// Returns the latest recorded heart rate sample from memory or Drift SQLite
  /// without activating the band's optical PPG real-time sensor.
  Future<int?> fetchLatestHeartRateSample() async {
    if (_lastSyncedVitals.latestHeartRate > 0) {
      return _lastSyncedVitals.latestHeartRate;
    }
    if (_lastSyncedVitals.heartRateHistory.isNotEmpty) {
      for (int i = _lastSyncedVitals.heartRateHistory.length - 1; i >= 0; i--) {
        if (_lastSyncedVitals.heartRateHistory[i].bpm > 0) {
          return _lastSyncedVitals.heartRateHistory[i].bpm;
        }
      }
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
    return _lastSyncedVitals.restingHeartRate > 0 ? _lastSyncedVitals.restingHeartRate : null;
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
        checkMidnightRollover();
        final rawVitals = await _service.syncFullHealthData();
        final today = DateTime.now().toIso8601String().substring(0, 10);
        int rawLatest = rawVitals.latestHeartRate;
        if (rawLatest <= 0 && rawVitals.heartRateHistory.isNotEmpty) {
          for (int i = rawVitals.heartRateHistory.length - 1; i >= 0; i--) {
            if (rawVitals.heartRateHistory[i].bpm > 0) {
              rawLatest = rawVitals.heartRateHistory[i].bpm;
              break;
            }
          }
        }

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
          latestHeartRate: rawLatest > 0 ? rawLatest : _lastSyncedVitals.latestHeartRate,
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
          hourlySteps: rawVitals.hourlySteps.isNotEmpty ? rawVitals.hourlySteps : _lastSyncedVitals.hourlySteps,
          date: today,
          dayIndex: 0,
        );
        _lastSyncedVitals = vitals;
        await _persistVitals(vitals, targetDate: today);
        _syncedVitalsController.add(vitals);
        return vitals;
      } finally {
        _isSyncingVitals = false;
        _ongoingSyncFuture = null;
      }
    }();
    return _ongoingSyncFuture!;
  }

  final Set<String> _syncedDatesThisSession = <String>{};
  bool _isBackfillingHistory = false;

  bool isHistoricalDateSynced(String dateStr) => _syncedDatesThisSession.contains(dateStr);
  void markDateSynced(String dateStr) => _syncedDatesThisSession.add(dateStr);

  /// Synchronizes complete health data for a specific historical day (dayIndex 0 to 6).
  /// Automatically stores it indexed by its exact date in Drift SQLite.
  Future<BandSyncedVitals> syncHistoricalDay(int dayIndex) async {
    final now = DateTime.now();
    final targetDate = now.subtract(Duration(days: dayIndex));
    final dateStr = "${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    final raw = await _service.syncHistoricalDay(dayIndex);
    int dayLatest = raw.latestHeartRate;
    if (dayLatest <= 0 && raw.heartRateHistory.isNotEmpty) {
      for (int i = raw.heartRateHistory.length - 1; i >= 0; i--) {
        if (raw.heartRateHistory[i].bpm > 0) {
          dayLatest = raw.heartRateHistory[i].bpm;
          break;
        }
      }
    }
    final vitals = raw.copyWith(
      date: dateStr,
      dayIndex: dayIndex,
      latestHeartRate: dayLatest > 0 ? dayLatest : (dayIndex == 0 ? _lastSyncedVitals.latestHeartRate : null),
    );
    await _persistVitals(vitals, targetDate: dateStr);
    _syncedDatesThisSession.add(dateStr);
    if (dayIndex == 0) {
      _lastSyncedVitals = vitals;
      _syncedVitalsController.add(vitals);
    }
    return vitals;
  }

  /// Batch syncs all 6 historical days (dayIndex 1 to 6) sequentially in the background.
  /// Follows QWatch Pro's architecture: pre-caches the past 7-day ring buffer into Drift SQLite,
  /// ensuring UI date browsing is instantaneous (0ms) and eliminates redundant BLE requests.
  Future<void> syncAllHistoricalDays() async {
    if (!isConnected || _isBackfillingHistory) return;
    _isBackfillingHistory = true;
    try {
      final now = DateTime.now();
      for (int dayIndex = 1; dayIndex <= 6; dayIndex++) {
        if (!isConnected) break;
        final targetDate = now.subtract(Duration(days: dayIndex));
        final dateStr = "${targetDate.year.toString().padLeft(4, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
        if (_syncedDatesThisSession.contains(dateStr)) continue;

        try {
          await syncHistoricalDay(dayIndex);
        } catch (e) {
          debugPrint('⚠️ [BAND REPO] Error backfilling dayIndex $dayIndex: $e');
        }
      }
    } finally {
      _isBackfillingHistory = false;
    }
  }

  /// Performs midnight rollover check:
  /// Resets daily live accumulator metrics when a new day starts (00:00:00)
  /// and automatically archives previous day's finalized counters.
  bool checkMidnightRollover() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    bool didRollover = false;
    if ((_lastRecordedDate.isNotEmpty && _lastRecordedDate != today) ||
        (_lastSyncedVitals.date.isNotEmpty && _lastSyncedVitals.date != today)) {
      final oldDate = _lastRecordedDate.isNotEmpty ? _lastRecordedDate : _lastSyncedVitals.date;
      debugPrint('🌙 [MIDNIGHT ROLLOVER] Date changed from $oldDate to $today. Resetting active counters & archiving previous day.');
      didRollover = true;
      // 1. In background, sync yesterday (dayIndex: 1) to ensure yesterday's finalized records are frozen
      syncHistoricalDay(1).catchError((_) => const BandSyncedVitals());
      // 2. Reset active memory counters for the new day
      _lastSyncedVitals = _lastSyncedVitals.copyWith(
        steps: 0,
        calories: 0,
        distance: 0,
        sleepMinutes: 0,
        deepSleepMinutes: 0,
        sleepPhases: const [],
        hourlySteps: List.filled(24, 0),
        date: today,
        dayIndex: 0,
      );
      _syncedVitalsController.add(_lastSyncedVitals);
      // 3. In background, query the band for dayIndex 0 (today's clean counters)
      if (isConnected) {
        syncHistoricalDay(0).catchError((_) => const BandSyncedVitals());
      }
    }
    _lastRecordedDate = today;
    return didRollover;
  }

  /// Retrieves daily summary record for a specific date from Drift DB.
  Future<DailyHealthSummary?> getDailySummaryForDate(String date, {String? deviceId}) async {
    final userId = await _secureStorage.getActiveUserId();
    final devId = deviceId ??
        _connectedDevice?.macAddress ??
        _lastPairedDevice?.mac ??
        _activeDeviceService?.activeDeviceId;
    return _db.healthDataDao.getDailySummary(userId, date, deviceId: devId);
  }

  /// Retrieves sleep session and individual sleep phases for a specific date.
  Future<({SleepSession session, List<SleepPhase> phases})?> getSleepDataForDate(String date, {String? deviceId}) async {
    final devId = deviceId ??
        _connectedDevice?.macAddress ??
        _lastPairedDevice?.mac ??
        _activeDeviceService?.activeDeviceId ??
        'default_band';
    return _db.healthDataDao.getSleepSessionWithPhasesByDate(devId, date);
  }

  /// Retrieves vitals records (e.g. 'spo2') for a specific date.
  Future<List<VitalsRecord>> getVitalsForDate(String vitalType, String date, {String? deviceId}) async {
    final devId = deviceId ??
        _connectedDevice?.macAddress ??
        _lastPairedDevice?.mac ??
        _activeDeviceService?.activeDeviceId ??
        'default_band';
    return _db.healthDataDao.getVitalsHistoryForDate(devId, vitalType, date);
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

  /// Generates a structured CSV of all historical health summaries from Drift DB.
  Future<String> exportHealthDataCsv() async {
    final summaries = await _db.healthDataDao.getAllDailySummaries();
    final buffer = StringBuffer();
    buffer.writeln('Date,Steps,Calories (kcal),Distance (m),Resting HR (bpm),Avg SpO2 (%),Sleep Duration (min),Deep Sleep (min),Wellness Score,Last Sync');
    for (final s in summaries) {
      buffer.writeln('${s.date},${s.steps},${s.caloriesBurned},${s.distanceMeters},${s.restingHeartRate ?? ""},${s.avgSpo2 ?? ""},${s.sleepDurationMinutes},${s.deepSleepMinutes},${s.wellnessScore ?? ""},${s.lastSyncTimestamp.toIso8601String()}');
    }
    return buffer.toString();
  }

  /// Clears cached local device and health data from both DB and secure storage.
  Future<void> clearLocalData() async {
    await disconnect(unpair: true);
    _lastSyncedVitals = const BandSyncedVitals();
    await _db.healthDataDao.deleteAllHealthData();
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
    _liveHeartRateSubscription?.cancel();
    _batterySubscription?.cancel();
    _errorSubscription?.cancel();
    _syncedVitalsController.close();
    _service.dispose();
  }
}

