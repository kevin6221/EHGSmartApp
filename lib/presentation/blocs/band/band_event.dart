import 'package:equatable/equatable.dart';
import '../../../data/models/band_device_model.dart';

abstract class BandEvent extends Equatable {
  const BandEvent();

  @override
  List<Object?> get props => [];
}

class StartBandScanEvent extends BandEvent {
  final Duration timeout;
  const StartBandScanEvent({this.timeout = const Duration(seconds: 30)});

  @override
  List<Object?> get props => [timeout];
}

class StopBandScanEvent extends BandEvent {}

class DiscoveredDevicesUpdatedEvent extends BandEvent {
  final List<DiscoveredBandDevice> devices;
  const DiscoveredDevicesUpdatedEvent(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ConnectBandEvent extends BandEvent {
  final DiscoveredBandDevice device;
  const ConnectBandEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class DisconnectBandEvent extends BandEvent {
  final bool unpair;
  const DisconnectBandEvent({this.unpair = false});

  @override
  List<Object?> get props => [unpair];
}

class ConnectionStatusChangedEvent extends BandEvent {
  final BandConnectionStatus status;
  const ConnectionStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class LiveHeartRateUpdatedEvent extends BandEvent {
  final int bpm;
  const LiveHeartRateUpdatedEvent(this.bpm);

  @override
  List<Object?> get props => [bpm];
}

class BatteryUpdatedEvent extends BandEvent {
  final BandBatteryInfo battery;
  const BatteryUpdatedEvent(this.battery);

  @override
  List<Object?> get props => [battery];
}

class PedometerUpdatedEvent extends BandEvent {
  final BandPedometerInfo pedometer;
  const PedometerUpdatedEvent(this.pedometer);

  @override
  List<Object?> get props => [pedometer];
}

class SyncedVitalsUpdatedEvent extends BandEvent {
  final BandSyncedVitals vitals;
  const SyncedVitalsUpdatedEvent(this.vitals);

  @override
  List<Object?> get props => [vitals];
}

class StartLiveHeartRateEvent extends BandEvent {}

class StopLiveHeartRateEvent extends BandEvent {}

class FindBandEvent extends BandEvent {}

class SyncVitalsEvent extends BandEvent {}

class AutoReconnectBandEvent extends BandEvent {}

class CheckBandPermissionsEvent extends BandEvent {}

class RequestBandPermissionsEvent extends BandEvent {}

class OpenAppSettingsEvent extends BandEvent {}

class EnableBluetoothEvent extends BandEvent {}

class OpenLocationSettingsEvent extends BandEvent {}

class BluetoothStateChangedEvent extends BandEvent {
  final BandBluetoothState state;
  const BluetoothStateChangedEvent(this.state);

  @override
  List<Object?> get props => [state];
}

class PermissionDetailsUpdatedEvent extends BandEvent {
  final BandPermissionDetails details;
  const PermissionDetailsUpdatedEvent(this.details);

  @override
  List<Object?> get props => [details];
}
