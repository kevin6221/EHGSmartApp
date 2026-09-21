import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/band_device_model.dart';
import '../../../data/repositories/band_repository.dart';
import '../wellness/wellness_bloc.dart';
import '../wellness/wellness_event.dart';
import 'band_event.dart';
import 'band_state.dart';

class BandBloc extends Bloc<BandEvent, BandState> {
  final BandRepository repository;
  final WellnessBloc? wellnessBloc;

  StreamSubscription<BandConnectionStatus>? _statusSubscription;
  StreamSubscription<List<DiscoveredBandDevice>>? _devicesSubscription;
  StreamSubscription<int>? _hrSubscription;
  StreamSubscription<BandBatteryInfo>? _batterySubscription;
  StreamSubscription<BandBluetoothState>? _btSubscription;

  BandBloc({required this.repository, this.wellnessBloc}) : super(const BandState()) {
    _initSubscriptions();

    on<StartBandScanEvent>(_onStartScan);
    on<StopBandScanEvent>(_onStopScan);
    on<DiscoveredDevicesUpdatedEvent>(_onDevicesUpdated);
    on<ConnectBandEvent>(_onConnect);
    on<DisconnectBandEvent>(_onDisconnect);
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    on<LiveHeartRateUpdatedEvent>(_onLiveHeartRateUpdated);
    on<BatteryUpdatedEvent>(_onBatteryUpdated);
    on<StartLiveHeartRateEvent>(_onStartLiveHeartRate);
    on<StopLiveHeartRateEvent>(_onStopLiveHeartRate);
    on<FindBandEvent>(_onFindBand);
    on<SyncVitalsEvent>(_onSyncVitals);
    on<AutoReconnectBandEvent>(_onAutoReconnect);
    on<CheckBandPermissionsEvent>(_onCheckPermissions);
    on<RequestBandPermissionsEvent>(_onRequestPermissions);
    on<OpenAppSettingsEvent>(_onOpenAppSettings);
    on<EnableBluetoothEvent>(_onEnableBluetooth);
    on<OpenLocationSettingsEvent>(_onOpenLocationSettings);
    on<BluetoothStateChangedEvent>(_onBluetoothStateChanged);
    on<PermissionDetailsUpdatedEvent>(_onPermissionDetailsUpdated);

    // Initial check of permissions and bluetooth state
    add(CheckBandPermissionsEvent());
  }

  void _initSubscriptions() {
    _statusSubscription = repository.connectionStatusStream.listen((status) {
      add(ConnectionStatusChangedEvent(status));
    });

    _devicesSubscription = repository.discoveredDevicesStream.listen((devices) {
      add(DiscoveredDevicesUpdatedEvent(devices));
    });

    _hrSubscription = repository.liveHeartRateStream.listen((bpm) {
      add(LiveHeartRateUpdatedEvent(bpm));
    });

    _batterySubscription = repository.batteryStream.listen((battery) {
      add(BatteryUpdatedEvent(battery));
    });

    _btSubscription = repository.bluetoothStateStream.listen((btState) {
      add(BluetoothStateChangedEvent(btState));
    });
  }

  Future<void> _onCheckPermissions(
    CheckBandPermissionsEvent event,
    Emitter<BandState> emit,
  ) async {
    final details = await repository.checkPermissions();
    final shouldClearError = details.isReady ||
        (details.status == BandPermissionStatus.granted && details.isBluetoothEnabled);
    emit(state.copyWith(
      permissionDetails: details,
      bluetoothState: details.isBluetoothEnabled
          ? BandBluetoothState.poweredOn
          : BandBluetoothState.poweredOff,
      clearError: shouldClearError,
    ));
  }

  Future<void> _onRequestPermissions(
    RequestBandPermissionsEvent event,
    Emitter<BandState> emit,
  ) async {
    final details = await repository.requestPermissions();
    emit(state.copyWith(
      permissionDetails: details,
      bluetoothState: details.isBluetoothEnabled
          ? BandBluetoothState.poweredOn
          : BandBluetoothState.poweredOff,
    ));
  }

  Future<void> _onOpenAppSettings(
    OpenAppSettingsEvent event,
    Emitter<BandState> emit,
  ) async {
    await repository.openAppSettings();
  }

  Future<void> _onEnableBluetooth(
    EnableBluetoothEvent event,
    Emitter<BandState> emit,
  ) async {
    await repository.requestEnableBluetooth();
  }

  Future<void> _onOpenLocationSettings(
    OpenLocationSettingsEvent event,
    Emitter<BandState> emit,
  ) async {
    await repository.openLocationSettings();
  }

  void _onBluetoothStateChanged(
    BluetoothStateChangedEvent event,
    Emitter<BandState> emit,
  ) {
    final isPoweredOn = event.state == BandBluetoothState.poweredOn;
    final clearBtError = isPoweredOn && (state.errorMessage?.contains('Bluetooth') ?? false);
    emit(state.copyWith(
      bluetoothState: event.state,
      clearError: clearBtError,
    ));
    if (isPoweredOn) {
      add(CheckBandPermissionsEvent());
    }
  }

  void _onPermissionDetailsUpdated(
    PermissionDetailsUpdatedEvent event,
    Emitter<BandState> emit,
  ) {
    emit(state.copyWith(permissionDetails: event.details));
  }

  Future<void> _onStartScan(StartBandScanEvent event, Emitter<BandState> emit) async {
    // Senior approach: 1. Verify OS permissions authorization first
    final perm = await repository.checkPermissions();
    emit(state.copyWith(permissionDetails: perm));

    if (perm.status != BandPermissionStatus.granted) {
      if (perm.isPermanentlyDenied) {
        emit(state.copyWith(
          status: BandConnectionStatus.disconnected,
          errorMessage: 'Bluetooth / Nearby Devices permission was denied. Please allow it in Settings.',
        ));
        return;
      }

      final requested = await repository.requestPermissions();
      emit(state.copyWith(permissionDetails: requested));
      if (requested.status != BandPermissionStatus.granted) {
        emit(state.copyWith(
          status: BandConnectionStatus.disconnected,
          errorMessage: requested.isPermanentlyDenied
              ? 'Bluetooth / Nearby Devices permission was denied. Please allow it in Settings.'
              : 'Bluetooth permission is required to find your band.',
        ));
        return;
      }
    }

    final currentPerm = state.permissionDetails ?? perm;

    // 2. Only after permissions are granted, check hardware power state
    if (!currentPerm.isBluetoothEnabled) {
      emit(state.copyWith(
        status: BandConnectionStatus.disconnected,
        bluetoothState: BandBluetoothState.poweredOff,
        errorMessage: 'Bluetooth is turned OFF. Please enable Bluetooth to search for your band.',
      ));
      return;
    }

    // 3. For Android, check location services
    if (!currentPerm.isLocationEnabled) {
      emit(state.copyWith(
        status: BandConnectionStatus.disconnected,
        errorMessage: 'Location services are turned OFF. Please enable Location in phone settings.',
      ));
      return;
    }

    emit(state.copyWith(
      status: BandConnectionStatus.scanning,
      discoveredDevices: const [],
      clearError: true,
    ));
    await repository.startScan(timeout: event.timeout);
  }

  Future<void> _onStopScan(StopBandScanEvent event, Emitter<BandState> emit) async {
    await repository.stopScan();
    emit(state.copyWith(status: BandConnectionStatus.disconnected));
  }

  void _onDevicesUpdated(DiscoveredDevicesUpdatedEvent event, Emitter<BandState> emit) {
    const excludedKeywords = [
      'buds',
      'airpod',
      'earphone',
      'headphone',
      'headset',
      'speaker',
      'audio',
      'sound',
      'tv',
      'macbook',
      'iphone',
      'ipad',
      'laptop',
      'car',
      'echo',
      'beats',
      'sony',
      'jbl',
      'freebuds',
      'linkbuds',
      'pixel',
      'galaxy',
    ];

    final filtered = event.devices.where((d) {
      final nameLower = d.name.toLowerCase();
      if (nameLower.isEmpty) return false;
      if (excludedKeywords.any((kw) => nameLower.contains(kw))) {
        return false;
      }
      return true;
    }).toList();

    emit(state.copyWith(discoveredDevices: filtered));
  }

  Future<void> _onConnect(ConnectBandEvent event, Emitter<BandState> emit) async {
    emit(state.copyWith(
      status: BandConnectionStatus.connecting,
      clearError: true,
    ));

    final success = await repository.connect(event.device);
    if (success) {
      final info = repository.currentConnectedDevice ??
          BandDeviceInfo(
            name: event.device.name,
            id: event.device.id,
            macAddress: event.device.mac,
          );
      emit(state.copyWith(
        status: BandConnectionStatus.connected,
        connectedDevice: info,
        battery: repository.currentBattery,
      ));

      // Trigger immediate health vitals synchronization upon successful connection
      add(SyncVitalsEvent());
    } else {
      final errorMsg = repository.lastConnectionError ??
          'Failed to connect to ${event.device.name}. Ensure it is charged, nearby, and unlinked from other apps (like QwatchPro).';
      emit(state.copyWith(
        status: BandConnectionStatus.disconnected,
        errorMessage: errorMsg,
      ));
    }
  }

  Future<void> _onAutoReconnect(AutoReconnectBandEvent event, Emitter<BandState> emit) async {
    final success = await repository.tryAutoReconnect();
    if (success) {
      emit(state.copyWith(
        status: BandConnectionStatus.connected,
        connectedDevice: repository.currentConnectedDevice,
        battery: repository.currentBattery,
      ));
      add(SyncVitalsEvent());
    }
  }

  Future<void> _onDisconnect(DisconnectBandEvent event, Emitter<BandState> emit) async {
    await repository.disconnect();
    emit(state.copyWith(
      status: BandConnectionStatus.disconnected,
      clearConnectedDevice: true,
      liveHeartRate: 0,
    ));
  }

  void _onConnectionStatusChanged(ConnectionStatusChangedEvent event, Emitter<BandState> emit) {
    emit(state.copyWith(status: event.status));
  }

  void _onLiveHeartRateUpdated(LiveHeartRateUpdatedEvent event, Emitter<BandState> emit) {
    emit(state.copyWith(liveHeartRate: event.bpm));
    wellnessBloc?.add(SyncBandVitalsEvent(
      steps: state.lastSyncedVitals?.steps ?? 0,
      calories: state.lastSyncedVitals?.calories ?? 0,
      distance: state.lastSyncedVitals?.distance ?? 0,
      sleepMinutes: state.lastSyncedVitals?.sleepMinutes ?? 0,
      deepSleepMinutes: state.lastSyncedVitals?.deepSleepMinutes ?? 0,
      liveHeartRate: event.bpm,
    ));
  }

  void _onBatteryUpdated(BatteryUpdatedEvent event, Emitter<BandState> emit) {
    emit(state.copyWith(battery: event.battery));
  }

  Future<void> _onStartLiveHeartRate(StartLiveHeartRateEvent event, Emitter<BandState> emit) async {
    await repository.startRealtimeHeartRate();
  }

  Future<void> _onStopLiveHeartRate(StopLiveHeartRateEvent event, Emitter<BandState> emit) async {
    await repository.stopRealtimeHeartRate();
    emit(state.copyWith(liveHeartRate: 0));
  }

  Future<void> _onFindBand(FindBandEvent event, Emitter<BandState> emit) async {
    await repository.findBand();
  }

  Future<void> _onSyncVitals(SyncVitalsEvent event, Emitter<BandState> emit) async {
    emit(state.copyWith(isSyncingVitals: true));
    try {
      final vitals = await repository.syncFullHealthData();
      emit(state.copyWith(lastSyncedVitals: vitals));

      wellnessBloc?.add(SyncBandVitalsEvent(
        steps: vitals.steps,
        calories: vitals.calories,
        distance: vitals.distance,
        sleepMinutes: vitals.sleepMinutes,
        deepSleepMinutes: vitals.deepSleepMinutes,
        liveHeartRate: state.liveHeartRate,
        bloodOxygen: vitals.bloodOxygen,
        systolicBP: vitals.systolicBP,
        diastolicBP: vitals.diastolicBP,
        skinTemperature: vitals.skinTemperature,
        stressLevel: vitals.stressLevel,
        hrvMs: vitals.hrvMs,
        restingHeartRate: vitals.restingHeartRate,
      ));
    } finally {
      emit(state.copyWith(isSyncingVitals: false));
    }
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _devicesSubscription?.cancel();
    _hrSubscription?.cancel();
    _batterySubscription?.cancel();
    _btSubscription?.cancel();
    repository.dispose();
    return super.close();
  }
}
