import 'dart:async';
import 'dart:math';

import '../models/band_device_model.dart';
import 'band_service.dart';

/// Simulator / fallback implementation of [BandService] used when running on
/// environments without physical BLE hardware or during test simulations.
class MockBandService implements BandService {
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

  Timer? _scanTimer;
  Timer? _liveHrTimer;
  BandConnectionStatus _currentStatus = BandConnectionStatus.disconnected;
  BandBluetoothState _currentBtState = BandBluetoothState.poweredOn;
  final Random _rnd = Random();

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
  String? get lastConnectionError => null;

  @override
  Future<BandPermissionDetails> checkPermissions() async {
    return const BandPermissionDetails(
      status: BandPermissionStatus.granted,
      isBluetoothEnabled: true,
      isLocationEnabled: true,
    );
  }

  @override
  Future<BandPermissionDetails> requestPermissions() async {
    _currentBtState = BandBluetoothState.poweredOn;
    _bluetoothStateController.add(_currentBtState);
    return const BandPermissionDetails(
      status: BandPermissionStatus.granted,
      isBluetoothEnabled: true,
      isLocationEnabled: true,
    );
  }

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> requestEnableBluetooth() async {
    _currentBtState = BandBluetoothState.poweredOn;
    _bluetoothStateController.add(_currentBtState);
  }

  @override
  Future<void> openLocationSettings() async {}

  @override
  Future<void> startScan({Duration timeout = const Duration(seconds: 30)}) async {
    _currentStatus = BandConnectionStatus.scanning;
    _connectionStatusController.add(_currentStatus);
    _discoveredDevicesController.add([]);

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 1400), () {
      if (_currentStatus == BandConnectionStatus.scanning) {
        final mockDevice = DiscoveredBandDevice(
          id: 'EH-9F2C-${_rnd.nextInt(9000) + 1000}',
          name: 'EHG Smart Band',
          mac: 'C8:FD:19:9F:2C:${_rnd.nextInt(90) + 10}',
          rssi: -58,
        );
        _discoveredDevicesController.add([mockDevice]);
      }
    });
  }

  @override
  Future<void> stopScan() async {
    _scanTimer?.cancel();
    if (_currentStatus == BandConnectionStatus.scanning) {
      _currentStatus = BandConnectionStatus.disconnected;
      _connectionStatusController.add(_currentStatus);
    }
  }

  @override
  Future<bool> connect(String deviceId) async {
    _scanTimer?.cancel();
    _currentStatus = BandConnectionStatus.connecting;
    _connectionStatusController.add(_currentStatus);

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    _currentStatus = BandConnectionStatus.connected;
    _connectionStatusController.add(_currentStatus);
    _batteryController.add(const BandBatteryInfo(percentage: 92, isCharging: false));
    return true;
  }

  @override
  Future<void> disconnect() async {
    _liveHrTimer?.cancel();
    _currentStatus = BandConnectionStatus.disconnecting;
    _connectionStatusController.add(_currentStatus);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentStatus = BandConnectionStatus.disconnected;
    _connectionStatusController.add(_currentStatus);
  }

  @override
  Future<BandBatteryInfo> getBattery() async {
    const info = BandBatteryInfo(percentage: 88, isCharging: false);
    _batteryController.add(info);
    return info;
  }

  @override
  Future<BandDeviceInfo> getDeviceInfo() async {
    return const BandDeviceInfo(
      name: 'EHG Smart Band',
      id: 'EH-9F2C',
      macAddress: 'C8:FD:19:9F:2C:4E',
      firmwareVersion: '1.0.4',
      hardwareVersion: '1.0.0',
    );
  }

  @override
  Future<bool> syncTime() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<bool> findBand() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> startRealtimeHeartRate() async {
    _liveHrTimer?.cancel();
    int currentHr = 72;
    _liveHrTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentHr = (currentHr + (_rnd.nextInt(5) - 2)).clamp(55, 160);
      _liveHeartRateController.add(currentHr);
    });
    return true;
  }

  @override
  Future<bool> stopRealtimeHeartRate() async {
    _liveHrTimer?.cancel();
    _liveHrTimer = null;
    return true;
  }

  @override
  Future<BandSyncedVitals> syncHistoricalVitals() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return const BandSyncedVitals();
  }

  @override
  Future<BandSyncedVitals> syncFullHealthData() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    return const BandSyncedVitals();
  }

  @override
  Future<bool> startMeasuring(MeasurementType type) async {
    return false;
  }

  @override
  Future<bool> stopMeasuring(MeasurementType type) async {
    return false;
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _liveHrTimer?.cancel();
    _connectionStatusController.close();
    _discoveredDevicesController.close();
    _liveHeartRateController.close();
    _batteryController.close();
    _measurementResultController.close();
    _bluetoothStateController.close();
  }
}
