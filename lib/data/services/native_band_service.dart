import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/band_device_model.dart';
import 'band_permission_service.dart';
import 'band_service.dart';

/// Concrete [BandService] implementation communicating with native iOS [EHGBandNativePlugin].
class NativeBandService implements BandService {
  static const MethodChannel _methodChannel = MethodChannel('com.ehg.smartapp/band');
  static const EventChannel _eventChannel = EventChannel('com.ehg.smartapp/band_events');

  final BandPermissionService _permissionService = const BandPermissionService();

  final StreamController<BandConnectionStatus> _connectionStatusController =
      StreamController<BandConnectionStatus>.broadcast();
  final StreamController<List<DiscoveredBandDevice>> _discoveredDevicesController =
      StreamController<List<DiscoveredBandDevice>>.broadcast();
  final StreamController<int> _liveHeartRateController =
      StreamController<int>.broadcast();
  final StreamController<BandBatteryInfo> _batteryController =
      StreamController<BandBatteryInfo>.broadcast();
  final StreamController<BandMeasurementResult> _measurementResultController =
      StreamController<BandMeasurementResult>.broadcast();
  final StreamController<BandPedometerInfo> _pedometerController =
      StreamController<BandPedometerInfo>.broadcast();
  final StreamController<BandBluetoothState> _bluetoothStateController =
      StreamController<BandBluetoothState>.broadcast();

  StreamSubscription<dynamic>? _eventSubscription;
  final List<DiscoveredBandDevice> _currentDiscovered = [];
  Completer<bool>? _connectCompleter;
  BandConnectionStatus _status = BandConnectionStatus.disconnected;
  String? _lastConnectionError;

  NativeBandService() {
    _initEventSubscription();
  }

  void _initEventSubscription() {
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      _handleNativeEvent,
      onError: (dynamic error) {
        // Handle stream errors silently or emit disconnected
      },
    );
  }

  void _handleNativeEvent(dynamic event) {
    if (event is! Map) return;

    final String type = event['type']?.toString() ?? '';
    debugPrint('⌚️ [BAND RAW EVENT] Type: "$type" | Data: $event');

    switch (type) {
      case 'connection_state':
        final stateStr = event['state']?.toString() ?? '';
        debugPrint('🔌 [BAND CONNECTION STATE] State: $stateStr (Device: ${event['name'] ?? 'Unknown'}, ID: ${event['id'] ?? ''})');
        if (stateStr == 'connected') {
          _status = BandConnectionStatus.connected;
          _connectionStatusController.add(BandConnectionStatus.connected);
          if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
            _connectCompleter!.complete(true);
          }
        } else if (stateStr == 'connecting') {
          _status = BandConnectionStatus.connecting;
          _connectionStatusController.add(BandConnectionStatus.connecting);
        } else if (stateStr == 'disconnecting') {
          _status = BandConnectionStatus.disconnecting;
          _connectionStatusController.add(BandConnectionStatus.disconnecting);
        } else {
          _status = BandConnectionStatus.disconnected;
          _connectionStatusController.add(BandConnectionStatus.disconnected);
          if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
            _connectCompleter!.complete(false);
          }
        }
        break;

      case 'scan_results':
        final List<dynamic>? rawDevices = event['devices'] as List<dynamic>?;
        if (rawDevices != null) {
          _currentDiscovered.clear();
          for (final d in rawDevices) {
            if (d is Map) {
              _currentDiscovered.add(DiscoveredBandDevice.fromMap(d));
            }
          }
          debugPrint('🔍 [BAND SCAN] Discovered ${_currentDiscovered.length} band(s): ${_currentDiscovered.map((b) => '${b.name} (${b.id})').join(', ')}');
          _discoveredDevicesController.add(List.unmodifiable(_currentDiscovered));
        }
        break;

      case 'scan_finished':
        debugPrint('🔍 [BAND SCAN] Scan completed/stopped');
        if (_status == BandConnectionStatus.scanning) {
          _status = BandConnectionStatus.disconnected;
          _connectionStatusController.add(BandConnectionStatus.disconnected);
        }
        break;

      case 'live_heart_rate':
        final bpm = (event['bpm'] as num?)?.toInt();
        if (bpm != null && bpm > 0) {
          debugPrint('💓 [BAND DATA - LIVE HEART RATE] $bpm BPM (optical PPG)');
          _liveHeartRateController.add(bpm);
        }
        break;

      case 'battery_update':
        final batInfo = BandBatteryInfo.fromMap(event);
        debugPrint('🔋 [BAND DATA - BATTERY] ${batInfo.percentage}% (charging: ${batInfo.isCharging})');
        _batteryController.add(batInfo);
        break;

      case 'measurement_result':
        debugPrint('🩺 [BAND DATA - MEASUREMENT RESULT] Type: ${event['measureType']} | HR: ${event['hr']} | SpO2: ${event['spo2']} | BP: ${event['sbp']}/${event['dbp']} | Temp: ${event['temperature']} | Stress: ${event['stress']} | HRV: ${event['hrv']}');
        _handleMeasurementResult(event);
        break;

      case 'measurement_fail':
        final measTypeStr = event['measureType']?.toString() ?? '';
        final errorMsg = event['error']?.toString() ?? 'Measurement failed';
        debugPrint('⚠️ [BAND DATA - MEASUREMENT FAILED] Type: $measTypeStr | Error: $errorMsg');
        _measurementResultController.add(BandMeasurementResult(
          type: _parseMeasurementType(measTypeStr),
          success: false,
          error: errorMsg,
        ));
        break;

      case 'step_update':
        final steps = (event['steps'] as num?)?.toInt() ?? 0;
        final cal = (event['calories'] as num?)?.toInt() ?? 0;
        final dist = (event['distance'] as num?)?.toInt() ?? 0;
        debugPrint('👟 [BAND DATA - LIVE PEDOMETER] Steps: $steps | Calories: $cal kcal | Distance: $dist m');
        _pedometerController.add(BandPedometerInfo(
          steps: steps,
          calories: cal,
          distance: dist,
        ));
        break;

      case 'connection_failed':
        _lastConnectionError = event['error']?.toString();
        debugPrint('❌ [BAND CONNECTION FAILED] $_lastConnectionError');
        _status = BandConnectionStatus.disconnected;
        _connectionStatusController.add(BandConnectionStatus.disconnected);
        if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
          _connectCompleter!.complete(false);
        }
        break;

      case 'bluetooth_state':
        final stateStr = event['state']?.toString() ?? '';
        debugPrint('📡 [BAND BLUETOOTH STATE] $stateStr');
        BandBluetoothState btState = BandBluetoothState.unknown;
        switch (stateStr) {
          case 'poweredOn':
            btState = BandBluetoothState.poweredOn;
            break;
          case 'poweredOff':
            btState = BandBluetoothState.poweredOff;
            break;
          case 'unauthorized':
          case 'permissionDenied':
            btState = BandBluetoothState.unauthorized;
            break;
          case 'unsupported':
            btState = BandBluetoothState.unsupported;
            break;
          case 'resetting':
            btState = BandBluetoothState.resetting;
            break;
        }
        _bluetoothStateController.add(btState);
        break;
    }
  }

  MeasurementType _parseMeasurementType(String typeStr) {
    switch (typeStr) {
      case 'heartRate':
        return MeasurementType.heartRate;
      case 'bloodPressure':
        return MeasurementType.bloodPressure;
      case 'bloodOxygen':
        return MeasurementType.bloodOxygen;
      case 'temperature':
        return MeasurementType.temperature;
      case 'stress':
        return MeasurementType.stress;
      case 'hrv':
        return MeasurementType.hrv;
      case 'oneKey':
        return MeasurementType.oneKey;
      default:
        return MeasurementType.heartRate;
    }
  }

  void _handleMeasurementResult(Map<dynamic, dynamic> event) {
    final measTypeStr = event['measureType']?.toString() ?? '';
    final data = <String, dynamic>{};

    // Extract measurement-specific fields
    if (event['hr'] != null) data['hr'] = (event['hr'] as num).toInt();
    if (event['sbp'] != null) data['sbp'] = (event['sbp'] as num).toInt();
    if (event['dbp'] != null) data['dbp'] = (event['dbp'] as num).toInt();
    if (event['spo2'] != null) data['spo2'] = (event['spo2'] as num).toDouble();
    if (event['temperature'] != null) data['temperature'] = (event['temperature'] as num).toDouble();
    if (event['stress'] != null) data['stress'] = (event['stress'] as num).toInt();
    if (event['hrv'] != null) data['hrv'] = (event['hrv'] as num).toInt();

    _measurementResultController.add(BandMeasurementResult(
      type: _parseMeasurementType(measTypeStr),
      success: true,
      data: data,
    ));
  }

  @override
  Stream<BandConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  Stream<List<DiscoveredBandDevice>> get discoveredDevicesStream =>
      _discoveredDevicesController.stream;

  @override
  Stream<int> get liveHeartRateStream => _liveHeartRateController.stream;

  @override
  Stream<BandBatteryInfo> get batteryStream => _batteryController.stream;

  @override
  Stream<BandMeasurementResult> get measurementResultStream =>
      _measurementResultController.stream;

  @override
  Stream<BandPedometerInfo> get pedometerStream => _pedometerController.stream;

  @override
  Stream<BandBluetoothState> get bluetoothStateStream =>
      _bluetoothStateController.stream;

  @override
  Future<BandPermissionDetails> checkPermissions() async {
    return _permissionService.checkPermissions();
  }

  @override
  Future<BandPermissionDetails> requestPermissions() async {
    return _permissionService.requestPermissions();
  }

  @override
  Future<void> openAppSettings() async {
    try {
      await _permissionService.openAppSettings();
    } catch (_) {}
    try {
      await _methodChannel.invokeMethod('openAppSettings');
    } catch (_) {}
  }

  @override
  Future<void> requestEnableBluetooth() async {
    try {
      await _methodChannel.invokeMethod('requestEnableBluetooth');
    } catch (_) {}
    try {
      await _permissionService.openAppSettings();
    } catch (_) {}
  }

  @override
  Future<void> openLocationSettings() async {
    try {
      await _methodChannel.invokeMethod('openLocationSettings');
    } catch (_) {}
  }

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 30)}) async {
    _connectionStatusController.add(BandConnectionStatus.scanning);
    _currentDiscovered.clear();
    _discoveredDevicesController.add([]);
    try {
      await _methodChannel.invokeMethod('startScan', {'timeout': timeout.inSeconds});
    } catch (_) {
      // Platform error handling
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      await _methodChannel.invokeMethod('stopScan');
    } catch (_) {}
  }

  @override
  String? get lastConnectionError => _lastConnectionError;

  @override
  Future<bool> connect(String deviceId) async {
    _connectionStatusController.add(BandConnectionStatus.connecting);
    _lastConnectionError = null;
    try {
      final res = await _methodChannel
          .invokeMethod<bool>('connect', {'deviceId': deviceId})
          .timeout(const Duration(seconds: 20), onTimeout: () {
            _lastConnectionError =
                'Connection timed out after 20s. Ensure band is nearby, charged, and unlinked from other apps (like QwatchPro).';
            _connectionStatusController.add(BandConnectionStatus.disconnected);
            return false;
          });
      return res == true;
    } on PlatformException catch (e) {
      _lastConnectionError = e.message ?? e.details?.toString() ?? 'Platform connection error';
      _connectionStatusController.add(BandConnectionStatus.disconnected);
      return false;
    } catch (e) {
      _lastConnectionError = e.toString();
      _connectionStatusController.add(BandConnectionStatus.disconnected);
      return false;
    }
  }

  @override
  Future<bool> isConnected() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('isConnected');
      if (res == true) {
        _status = BandConnectionStatus.connected;
        return true;
      }
    } catch (_) {}
    return _status == BandConnectionStatus.connected;
  }

  @override
  Future<void> disconnect({bool unpair = false}) async {
    _connectionStatusController.add(BandConnectionStatus.disconnecting);
    try {
      await _methodChannel.invokeMethod('disconnect', {'unpair': unpair});
    } catch (_) {}
    _connectionStatusController.add(BandConnectionStatus.disconnected);
  }

  @override
  Future<BandBatteryInfo> getBattery() async {
    try {
      final res = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getBattery');
      if (res != null) {
        final info = BandBatteryInfo.fromMap(res);
        _batteryController.add(info);
        return info;
      }
    } catch (_) {}
    return const BandBatteryInfo(percentage: 0);
  }

  @override
  Future<BandDeviceInfo> getDeviceInfo() async {
    try {
      final res = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getDeviceInfo');
      if (res != null) {
        return BandDeviceInfo.fromMap(res);
      }
    } catch (_) {}
    return const BandDeviceInfo();
  }

  @override
  Future<bool> syncTime() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('setTime');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> findBand() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('findBand');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> startRealtimeHeartRate() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('startRealtimeHeartRate');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> stopRealtimeHeartRate() async {
    try {
      final res = await _methodChannel.invokeMethod<bool>('stopRealtimeHeartRate');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<BandSyncedVitals> syncHistoricalVitals() async {
    try {
      final res = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('syncHistoricalVitals');
      if (res != null) {
        final vitals = BandSyncedVitals.fromMap(res);
        debugPrint('📥 [BAND HISTORICAL SYNC DATA] Steps=${vitals.steps}, Cal=${vitals.calories}, Dist=${vitals.distance}, Sleep=${vitals.sleepMinutes}m, DeepSleep=${vitals.deepSleepMinutes}m');
        return vitals;
      }
    } catch (_) {}
    return const BandSyncedVitals();
  }

  @override
  Future<BandSyncedVitals> syncFullHealthData() async {
    try {
      final res = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('syncFullHealthData');
      if (res != null) {
        final vitals = BandSyncedVitals.fromMap(res);
        debugPrint('═══════════════════════════════════════════════════════════════');
        debugPrint('📊 [BAND FULL SYNC DATA RECEIVED FROM HARDWARE]');
        debugPrint('   • Steps:              ${vitals.steps}');
        debugPrint('   • Calories:           ${vitals.calories} kcal');
        debugPrint('   • Distance:           ${vitals.distance} m');
        debugPrint('   • Sleep Minutes:      ${vitals.sleepMinutes} min (${(vitals.sleepMinutes / 60.0).toStringAsFixed(1)} hrs)');
        debugPrint('   • Deep Sleep:         ${vitals.deepSleepMinutes} min');
        debugPrint('   • Blood Oxygen:       ${vitals.bloodOxygen}%');
        debugPrint('   • Blood Pressure:     ${vitals.systolicBP}/${vitals.diastolicBP} mmHg');
        debugPrint('   • Skin Temperature:   ${vitals.skinTemperature}°C');
        debugPrint('   • Stress Level:       ${vitals.stressLevel} / 100');
        debugPrint('   • HRV:                ${vitals.hrvMs} ms');
        debugPrint('   • Resting Heart Rate: ${vitals.restingHeartRate} bpm');
        debugPrint('   • HR History Points:  ${vitals.heartRateHistory.length} samples');
        debugPrint('   • Sleep Phases:       ${vitals.sleepPhases.length} intervals');
        debugPrint('═══════════════════════════════════════════════════════════════');
        return vitals;
      }
    } catch (e) {
      debugPrint('⚠️ [BAND FULL SYNC ERROR] $e');
    }
    // Fall back to basic sync if full sync is not available
    return syncHistoricalVitals();
  }

  @override
  Future<bool> startMeasuring(MeasurementType type) async {
    try {
      final res = await _methodChannel.invokeMethod<bool>(
        'startMeasuring',
        {'type': type.name},
      );
      return res == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> stopMeasuring(MeasurementType type) async {
    try {
      final res = await _methodChannel.invokeMethod<bool>(
        'stopMeasuring',
        {'type': type.name},
      );
      return res == true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _connectionStatusController.close();
    _discoveredDevicesController.close();
    _liveHeartRateController.close();
    _batteryController.close();
    _measurementResultController.close();
    _pedometerController.close();
    _bluetoothStateController.close();
  }
}
