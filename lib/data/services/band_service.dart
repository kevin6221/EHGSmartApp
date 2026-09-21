import '../models/band_device_model.dart';

/// Abstract service interface governing all communication with the EHG Smart Band.
abstract class BandService {
  /// Stream of connection status changes.
  Stream<BandConnectionStatus> get connectionStatusStream;

  /// Stream of discovered peripheral devices during BLE scan.
  Stream<List<DiscoveredBandDevice>> get discoveredDevicesStream;

  /// Stream of live real-time heart rate samples in BPM.
  Stream<int> get liveHeartRateStream;

  /// Stream of battery percentage and charging status.
  Stream<BandBatteryInfo> get batteryStream;

  /// Stream of on-demand measurement results (HR, BP, SpO2, etc.).
  Stream<BandMeasurementResult> get measurementResultStream;

  /// Stream of Bluetooth adapter power / state changes.
  Stream<BandBluetoothState> get bluetoothStateStream;

  /// The most recent error message from a failed connection attempt.
  String? get lastConnectionError;

  /// Inspects current OS permission status and Bluetooth/Location state.
  Future<BandPermissionDetails> checkPermissions();

  /// Prompts the user to grant necessary Bluetooth/Location permissions.
  Future<BandPermissionDetails> requestPermissions();

  /// Opens the system application settings page for this app.
  Future<void> openAppSettings();

  /// Requests the OS to enable Bluetooth (e.g. Android ACTION_REQUEST_ENABLE).
  Future<void> requestEnableBluetooth();

  /// Opens system Location settings (on Android if Location is disabled).
  Future<void> openLocationSettings();

  /// Starts BLE scanning for nearby bands.
  Future<void> startScan({Duration timeout = const Duration(seconds: 30)});

  /// Stops ongoing BLE scanning.
  Future<void> stopScan();

  /// Connects to a specific band by its device identifier.
  Future<bool> connect(String deviceId);

  /// Disconnects / unbinds from the currently connected band.
  Future<void> disconnect();

  /// Reads current battery level from the band.
  Future<BandBatteryInfo> getBattery();

  /// Reads device hardware/software version and MAC address.
  Future<BandDeviceInfo> getDeviceInfo();

  /// Synchronizes band time with current smartphone local time.
  Future<bool> syncTime();

  /// Triggers band vibration / find device feature.
  Future<bool> findBand();

  /// Starts streaming real-time heart rate samples.
  Future<bool> startRealtimeHeartRate();

  /// Stops streaming real-time heart rate samples.
  Future<bool> stopRealtimeHeartRate();

  /// Synchronizes historical steps, calories, and sleep records (basic).
  Future<BandSyncedVitals> syncHistoricalVitals();

  /// Synchronizes all available health data from the band in one call:
  /// steps, calories, distance, sleep phases, SpO2, BP, temperature,
  /// stress, HRV, resting HR, and heart rate history.
  Future<BandSyncedVitals> syncFullHealthData();

  /// Starts an on-demand single measurement of the given type.
  Future<bool> startMeasuring(MeasurementType type);

  /// Stops an ongoing on-demand measurement.
  Future<bool> stopMeasuring(MeasurementType type);

  /// Disposes active streams and timers.
  void dispose();
}

