import 'dart:async';
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

    switch (type) {
      case 'connection_state':
        final stateStr = event['state']?.toString() ?? '';
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
          _discoveredDevicesController.add(List.unmodifiable(_currentDiscovered));
        }
        break;

      case 'scan_finished':
        if (_status == BandConnectionStatus.scanning) {
          _status = BandConnectionStatus.disconnected;
          _connectionStatusController.add(BandConnectionStatus.disconnected);
        }
        break;

      case 'live_heart_rate':
        final bpm = (event['bpm'] as num?)?.toInt();
        if (bpm != null && bpm > 0) {
          _liveHeartRateController.add(bpm);
        }
        break;

      case 'battery_update':
        _batteryController.add(BandBatteryInfo.fromMap(event));
        break;

      case 'measurement_result':
        _handleMeasurementResult(event);
        break;

      case 'measurement_fail':
        final measTypeStr = event['measureType']?.toString() ?? '';
        _measurementResultController.add(BandMeasurementResult(
          type: _parseMeasurementType(measTypeStr),
          success: false,
          error: event['error']?.toString() ?? 'Measurement failed',
        ));
        break;

      case 'step_update':
        // Real-time step push from the band — can be consumed by listeners
        break;

      case 'connection_failed':
        _lastConnectionError = event['error']?.toString();
        _status = BandConnectionStatus.disconnected;
        _connectionStatusController.add(BandConnectionStatus.disconnected);
        if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
          _connectCompleter!.complete(false);
        }
        break;

      case 'bluetooth_state':
        final stateStr = event['state']?.toString() ?? '';
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
    await _permissionService.openAppSettings();
  }

  @override
  Future<void> requestEnableBluetooth() async {
    try {
      await _methodChannel.invokeMethod('requestEnableBluetooth');
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
  Future<void> disconnect() async {
    _connectionStatusController.add(BandConnectionStatus.disconnecting);
    try {
      await _methodChannel.invokeMethod('disconnect');
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
        return BandSyncedVitals.fromMap(res);
      }
    } catch (_) {}
    return const BandSyncedVitals();
  }

  @override
  Future<BandSyncedVitals> syncFullHealthData() async {
    try {
      final res = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('syncFullHealthData');
      if (res != null) {
        return BandSyncedVitals.fromMap(res);
      }
    } catch (_) {}
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
    _bluetoothStateController.close();
  }
}
