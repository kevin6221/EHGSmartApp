import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/band_device_model.dart';
import '../services/band_service.dart';
import '../services/mock_band_service.dart';
import '../services/native_band_service.dart';

/// Repository managing the EHG Smart Band connectivity, caching paired device metadata,
/// and dispatching hardware synchronization.
class BandRepository {
  static const String _cachedVitalsKey = 'ehg_cached_vitals';
  static const String _cachedDeviceKey = 'ehg_cached_device';

  final BandService _service;
  final StreamController<BandSyncedVitals> _syncedVitalsController =
      StreamController<BandSyncedVitals>.broadcast();

  BandDeviceInfo? _connectedDevice;
  BandBatteryInfo _battery = const BandBatteryInfo(percentage: 0);
  DiscoveredBandDevice? _lastPairedDevice;
  BandSyncedVitals _lastSyncedVitals = const BandSyncedVitals();
  StreamSubscription<BandConnectionStatus>? _statusSubscription;

  BandRepository({BandService? service})
      : _service = service ??
            ((Platform.isIOS || Platform.isAndroid)
                ? NativeBandService()
                : MockBandService()) {
    _loadCachedData();
    _listenToConnectionStatus();
  }

  void _listenToConnectionStatus() {
    _statusSubscription = _service.connectionStatusStream.listen((status) {
      if (status == BandConnectionStatus.connected) {
        // Automatically sync all health data when band connects
        syncFullHealthData();
      }
    });
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vitalsJson = prefs.getString(_cachedVitalsKey);
      if (vitalsJson != null && vitalsJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(vitalsJson);
        _lastSyncedVitals = BandSyncedVitals.fromMap(map);
        _syncedVitalsController.add(_lastSyncedVitals);
      }

      final deviceJson = prefs.getString(_cachedDeviceKey);
      if (deviceJson != null && deviceJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(deviceJson);
        _lastPairedDevice = DiscoveredBandDevice.fromMap(map);
      }
    } catch (_) {
      // Non-fatal cache load error
    }
  }

  Future<void> _persistVitals(BandSyncedVitals vitals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedVitalsKey, jsonEncode(vitals.toMap()));
    } catch (_) {}
  }

  Future<void> _persistDevice(DiscoveredBandDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cachedDeviceKey, jsonEncode({
        'id': device.id,
        'name': device.name,
        'mac': device.mac,
        'rssi': device.rssi,
      }));
    } catch (_) {}
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

  Stream<BandBluetoothState> get bluetoothStateStream =>
      _service.bluetoothStateStream;

  BandDeviceInfo? get currentConnectedDevice => _connectedDevice;
  BandBatteryInfo get currentBattery => _battery;
  DiscoveredBandDevice? get lastPairedDevice => _lastPairedDevice;
  BandSyncedVitals get lastSyncedVitals => _lastSyncedVitals;
  String? get lastConnectionError => _service.lastConnectionError;

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
    if (_lastPairedDevice != null) {
      return connect(_lastPairedDevice!);
    }
    return false;
  }

  /// Disconnects from the current device.
  Future<void> disconnect() async {
    await _service.disconnect();
    _connectedDevice = null;
    _lastPairedDevice = null;
  }

  /// Triggers find device vibration on the band.
  Future<bool> findBand() async {
    return _service.findBand();
  }

  /// Starts continuous heart rate measurement stream.
  Future<bool> startRealtimeHeartRate() async {
    return _service.startRealtimeHeartRate();
  }

  /// Stops continuous heart rate measurement stream.
  Future<bool> stopRealtimeHeartRate() async {
    return _service.stopRealtimeHeartRate();
  }

  /// Synchronizes daily steps, calories, and sleep records.
  Future<BandSyncedVitals> syncHistoricalVitals() async {
    final vitals = await _service.syncHistoricalVitals();
    _lastSyncedVitals = vitals;
    _persistVitals(vitals);
    _syncedVitalsController.add(vitals);
    return vitals;
  }

  /// Synchronizes all available health data from the band in one comprehensive call.
  Future<BandSyncedVitals> syncFullHealthData() async {
    final vitals = await _service.syncFullHealthData();
    _lastSyncedVitals = vitals;
    _persistVitals(vitals);
    _syncedVitalsController.add(vitals);
    return vitals;
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
    await disconnect();
    _lastPairedDevice = null;
    _lastSyncedVitals = const BandSyncedVitals();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedVitalsKey);
      await prefs.remove(_cachedDeviceKey);
      await prefs.remove('ehg_onboarding_completed');
    } catch (_) {}
    _syncedVitalsController.add(_lastSyncedVitals);
  }

  /// Disposes background resources.
  void dispose() {
    _statusSubscription?.cancel();
    _syncedVitalsController.close();
    _service.dispose();
  }
}

