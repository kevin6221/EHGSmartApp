import 'package:equatable/equatable.dart';
import '../../../data/models/band_device_model.dart';

class BandState extends Equatable {
  final BandConnectionStatus status;
  final List<DiscoveredBandDevice> discoveredDevices;
  final BandDeviceInfo? connectedDevice;
  final BandBatteryInfo battery;
  final int liveHeartRate;
  final bool isSyncingVitals;
  final BandSyncedVitals? lastSyncedVitals;
  final String? errorMessage;
  final BandBluetoothState bluetoothState;
  final BandPermissionDetails? permissionDetails;

  const BandState({
    this.status = BandConnectionStatus.disconnected,
    this.discoveredDevices = const [],
    this.connectedDevice,
    this.battery = const BandBatteryInfo(percentage: 30),
    this.liveHeartRate = 0,
    this.isSyncingVitals = false,
    this.lastSyncedVitals,
    this.errorMessage,
    this.bluetoothState = BandBluetoothState.unknown,
    this.permissionDetails,
  });

  bool get isConnected => status == BandConnectionStatus.connected;
  bool get isScanning => status == BandConnectionStatus.scanning;
  bool get isConnecting => status == BandConnectionStatus.connecting;

  bool get isBluetoothEnabled {
    if (bluetoothState == BandBluetoothState.poweredOff ||
        bluetoothState == BandBluetoothState.unsupported) {
      return false;
    }
    if (permissionDetails != null && !permissionDetails!.isBluetoothEnabled) {
      return false;
    }
    return bluetoothState == BandBluetoothState.poweredOn ||
        (permissionDetails?.isBluetoothEnabled ?? false);
  }

  bool get isPermanentlyDenied =>
      permissionDetails?.isPermanentlyDenied ?? false;

  bool get isPermissionGranted =>
      permissionDetails?.status == BandPermissionStatus.granted;

  bool get isLocationEnabled =>
      permissionDetails?.isLocationEnabled ?? true;

  BandState copyWith({
    BandConnectionStatus? status,
    List<DiscoveredBandDevice>? discoveredDevices,
    BandDeviceInfo? connectedDevice,
    bool clearConnectedDevice = false,
    BandBatteryInfo? battery,
    int? liveHeartRate,
    bool? isSyncingVitals,
    BandSyncedVitals? lastSyncedVitals,
    String? errorMessage,
    bool clearError = false,
    BandBluetoothState? bluetoothState,
    BandPermissionDetails? permissionDetails,
  }) {
    return BandState(
      status: status ?? this.status,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      battery: battery ?? this.battery,
      liveHeartRate: liveHeartRate ?? this.liveHeartRate,
      isSyncingVitals: isSyncingVitals ?? this.isSyncingVitals,
      lastSyncedVitals: lastSyncedVitals ?? this.lastSyncedVitals,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      bluetoothState: bluetoothState ?? this.bluetoothState,
      permissionDetails: permissionDetails ?? this.permissionDetails,
    );
  }

  @override
  List<Object?> get props => [
        status,
        discoveredDevices,
        connectedDevice,
        battery,
        liveHeartRate,
        isSyncingVitals,
        lastSyncedVitals,
        errorMessage,
        bluetoothState,
        permissionDetails,
      ];
}
