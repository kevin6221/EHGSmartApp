import 'dart:async';
import 'package:flutter/foundation.dart';
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
  StreamSubscription<BandPedometerInfo>? _pedometerSubscription;
  StreamSubscription<BandSyncedVitals>? _syncedVitalsSubscription;

  BandBloc({required this.repository, this.wellnessBloc})
      : super(BandState(lastSyncedVitals: repository.lastSyncedVitals)) {
    _initSubscriptions();

    on<StartBandScanEvent>(_onStartScan);
    on<StopBandScanEvent>(_onStopScan);
    on<DiscoveredDevicesUpdatedEvent>(_onDevicesUpdated);
    on<ConnectBandEvent>(_onConnect);
    on<DisconnectBandEvent>(_onDisconnect);
    on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
    on<LiveHeartRateUpdatedEvent>(_onLiveHeartRateUpdated);
    on<BatteryUpdatedEvent>(_onBatteryUpdated);
    on<PedometerUpdatedEvent>(_onPedometerUpdated);
    on<SyncedVitalsUpdatedEvent>(_onSyncedVitalsUpdated);
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

    // Wait for cached vitals to be restored from SQLite before propagating to state & wellnessBloc
    repository.ensureInitialized().then((_) {
      final cached = repository.lastSyncedVitals;
      if (cached.steps > 0 ||
          cached.calories > 0 ||
          cached.stressLevel > 0 ||
          cached.hrvMs > 0) {
        add(SyncedVitalsUpdatedEvent(cached));
      }
    });

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

    // Pedometer real-time stream subscription removed as requested; steps/calories update on sync/init/hot-reload, Heart Rate remains real-time.

    _syncedVitalsSubscription = repository.syncedVitalsStream.listen((vitals) {
      add(SyncedVitalsUpdatedEvent(vitals));
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
    await repository.openAppSettings();
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

    if (!isPoweredOn) {
      // Gracefully reset transient connection/scan states without losing paired device info
      emit(state.copyWith(
        bluetoothState: event.state,
        status: BandConnectionStatus.disconnected,
        liveHeartRate: 0,
        isSyncingVitals: false,
        permissionDetails: state.permissionDetails?.copyWith(isBluetoothEnabled: false),
        clearError: false,
        errorMessage: 'Bluetooth is turned OFF. Please enable Bluetooth from Control Center or Settings.',
      ));
    } else {
      final clearBtError = (state.errorMessage?.contains('Bluetooth') ?? false) ||
          (state.errorMessage?.contains('turned OFF') ?? false);
      emit(state.copyWith(
        bluetoothState: event.state,
        permissionDetails: state.permissionDetails?.copyWith(isBluetoothEnabled: true),
        clearError: clearBtError,
      ));
      add(CheckBandPermissionsEvent());
      // If we have a previously paired band, auto-reconnect gracefully
      if (repository.lastPairedDevice != null && !state.isConnected) {
        add(AutoReconnectBandEvent());
      }
    }
  }

  void _onPermissionDetailsUpdated(
    PermissionDetailsUpdatedEvent event,
    Emitter<BandState> emit,
  ) {
    emit(state.copyWith(permissionDetails: event.details));
  }

  Future<void> _onStartScan(StartBandScanEvent event, Emitter<BandState> emit) async {
    emit(state.copyWith(clearError: true));
    final perm = await repository.checkPermissions();
    emit(state.copyWith(
      permissionDetails: perm,
      bluetoothState: perm.isBluetoothEnabled
          ? BandBluetoothState.poweredOn
          : BandBluetoothState.poweredOff,
    ));

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
        permissionDetails: currentPerm,
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
    if (state.status == BandConnectionStatus.connected ||
        state.status == BandConnectionStatus.connecting) {
      return;
    }
    emit(state.copyWith(
      status: BandConnectionStatus.connecting,
      clearError: true,
    ));
    final success = await repository.tryAutoReconnect();
    if (success) {
      final info = repository.currentConnectedDevice ??
          (repository.lastPairedDevice != null
              ? BandDeviceInfo(
                  name: repository.lastPairedDevice!.name,
                  id: repository.lastPairedDevice!.id,
                  macAddress: repository.lastPairedDevice!.mac,
                )
              : null);
      emit(state.copyWith(
        status: BandConnectionStatus.connected,
        connectedDevice: info,
        battery: repository.currentBattery,
        clearError: true,
      ));
    } else {
      if (state.status != BandConnectionStatus.connected) {
        emit(state.copyWith(status: BandConnectionStatus.disconnected));
      }
    }
  }

  Future<void> _onDisconnect(DisconnectBandEvent event, Emitter<BandState> emit) async {
    await repository.disconnect(unpair: event.unpair);
    emit(state.copyWith(
      status: BandConnectionStatus.disconnected,
      clearConnectedDevice: true,
      liveHeartRate: 0,
    ));
  }

  void _onConnectionStatusChanged(ConnectionStatusChangedEvent event, Emitter<BandState> emit) {
    if (event.status == BandConnectionStatus.connected) {
      final info = repository.currentConnectedDevice ??
          (repository.lastPairedDevice != null
              ? BandDeviceInfo(
                  name: repository.lastPairedDevice!.name,
                  id: repository.lastPairedDevice!.id,
                  macAddress: repository.lastPairedDevice!.mac,
                )
              : null);
      emit(state.copyWith(
        status: BandConnectionStatus.connected,
        connectedDevice: info,
        battery: repository.currentBattery,
        clearError: true,
      ));
    } else if (event.status == BandConnectionStatus.disconnected) {
      emit(state.copyWith(
        status: BandConnectionStatus.disconnected,
        clearConnectedDevice: true,
        liveHeartRate: 0,
      ));
    } else {
      emit(state.copyWith(status: event.status));
    }
  }

  void _onLiveHeartRateUpdated(LiveHeartRateUpdatedEvent event, Emitter<BandState> emit) {
    debugPrint('💓 [BAND BLOC] Live Heart Rate updated from band: ${event.bpm} bpm');
    emit(state.copyWith(liveHeartRate: event.bpm));
  }

  void _onBatteryUpdated(BatteryUpdatedEvent event, Emitter<BandState> emit) {
    debugPrint('🔋 [BAND BLOC] Battery level updated from band: ${event.battery}%');
    emit(state.copyWith(battery: event.battery));
  }

  Future<void> _onStartLiveHeartRate(StartLiveHeartRateEvent event, Emitter<BandState> emit) async {
    debugPrint('▶️ [BAND BLOC] Requesting real-time heart rate / optical PPG activation');
    await repository.startRealtimeHeartRate();
  }

  Future<void> _onStopLiveHeartRate(StopLiveHeartRateEvent event, Emitter<BandState> emit) async {
    debugPrint('⏹️ [BAND BLOC] Stopping real-time heart rate / optical PPG');
    await repository.stopRealtimeHeartRate();
    emit(state.copyWith(liveHeartRate: 0));
  }

  Future<void> _onFindBand(FindBandEvent event, Emitter<BandState> emit) async {
    debugPrint('📳 [BAND BLOC] Triggering find band vibration command');
    await repository.findBand();
  }

  Future<void> _onSyncVitals(SyncVitalsEvent event, Emitter<BandState> emit) async {
    if (state.isSyncingVitals || state.status != BandConnectionStatus.connected) {
      return;
    }
    emit(state.copyWith(isSyncingVitals: true));
    try {
      debugPrint('🔄 [BAND BLOC] Starting full health data sync from band...');
      final vitals = await repository.syncFullHealthData();
      debugPrint('✅ [BAND BLOC] Health data sync complete! Synced:');
      debugPrint('   • Steps: ${vitals.steps}, Calories: ${vitals.calories} kcal, Distance: ${vitals.distance} m');
      debugPrint('   • Sleep: ${vitals.sleepMinutes} min (Deep: ${vitals.deepSleepMinutes} min)');
      debugPrint('   • SpO2: ${vitals.bloodOxygen}%, BP: ${vitals.systolicBP}/${vitals.diastolicBP}, Temp: ${vitals.skinTemperature}°C');
      debugPrint('   • Stress: ${vitals.stressLevel}, HRV: ${vitals.hrvMs} ms, Rest HR: ${vitals.restingHeartRate} bpm');

      emit(state.copyWith(lastSyncedVitals: vitals));
      wellnessBloc?.add(SyncBandFullVitalsEvent(vitals));
    } finally {
      emit(state.copyWith(isSyncingVitals: false));
    }
  }


  void _onPedometerUpdated(PedometerUpdatedEvent event, Emitter<BandState> emit) {
    debugPrint('👟 [BAND BLOC] Pedometer update: ${event.pedometer.steps} steps, ${event.pedometer.calories} kcal, ${event.pedometer.distance} m');
    final current = state.lastSyncedVitals ?? repository.lastSyncedVitals;
    final updatedVitals = current.copyWith(
      steps: event.pedometer.steps,
      calories: event.pedometer.calories,
      distance: event.pedometer.distance,
    );
    emit(state.copyWith(lastSyncedVitals: updatedVitals));
    wellnessBloc?.add(SyncBandFullVitalsEvent(updatedVitals));
  }

  void _onSyncedVitalsUpdated(SyncedVitalsUpdatedEvent event, Emitter<BandState> emit) {
    debugPrint('📊 [BAND BLOC] Synced vitals stream emitted (steps: ${event.vitals.steps}, cal: ${event.vitals.calories})');
    emit(state.copyWith(lastSyncedVitals: event.vitals));
    wellnessBloc?.add(SyncBandFullVitalsEvent(event.vitals));
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    _devicesSubscription?.cancel();
    _hrSubscription?.cancel();
    _batterySubscription?.cancel();
    _btSubscription?.cancel();
    _pedometerSubscription?.cancel();
    _syncedVitalsSubscription?.cancel();
    repository.dispose();
    return super.close();
  }
}
