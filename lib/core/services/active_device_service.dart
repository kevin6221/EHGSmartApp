import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../database/daos/device_dao.dart';
import '../security/secure_storage_service.dart';

/// Architecture Single Source of Truth for the currently active wearable band.
///
/// In multi-band environments (e.g. Band 1, Band 2, etc.):
/// - Every health metric is tied to the band's unique MAC address (`deviceId`).
/// - When user switches between bands or rebinds an existing band, [ActiveDeviceService]
///   broadcasts the active MAC address reactively without `setState()`.
/// - Historical health records for unbonded or inactive bands remain permanently intact in the database.
class ActiveDeviceService {
  final DeviceDao deviceDao;
  final SecureStorageService secureStorage;

  static const String _keyActiveDeviceMac = 'active_device_mac';

  final ValueNotifier<String?> _activeDeviceId = ValueNotifier<String?>(null);

  ActiveDeviceService({
    required this.deviceDao,
    required this.secureStorage,
  });

  DeviceDao get _deviceDao => deviceDao;
  SecureStorageService get _secureStorage => secureStorage;

  /// Current active device MAC address / ID.
  String? get activeDeviceId => _activeDeviceId.value;

  /// ValueListenable for reactive UI consumption without `setState()`.
  ValueListenable<String?> get activeDeviceIdListenable => _activeDeviceId;

  /// Initializes the active device from secure storage or database on app launch.
  Future<void> initialize() async {
    try {
      // 1. Check explicitly saved active device MAC
      String? savedMac = await _secureStorage.read(_keyActiveDeviceMac);

      if (savedMac != null && savedMac.isNotEmpty) {
        final device = await _deviceDao.getDeviceByMac(savedMac);
        if (device != null) {
          _activeDeviceId.value = savedMac;
          debugPrint('🎯 [ACTIVE DEVICE] Restored active band: $savedMac (${device.deviceName})');
          return;
        }
      }

      // 2. Fallback to active marked device in DB
      final activeInDb = await _deviceDao.getActiveDevice();
      if (activeInDb != null) {
        _activeDeviceId.value = activeInDb.macAddress;
        await _secureStorage.write(_keyActiveDeviceMac, activeInDb.macAddress);
        debugPrint('🎯 [ACTIVE DEVICE] Loaded active band from DB: ${activeInDb.macAddress}');
        return;
      }

      // 3. Fallback to any bonded device
      final bonded = await _deviceDao.getBondedDevice();
      if (bonded != null) {
        _activeDeviceId.value = bonded.macAddress;
        await _deviceDao.setActiveDevice(bonded.macAddress);
        await _secureStorage.write(_keyActiveDeviceMac, bonded.macAddress);
        debugPrint('🎯 [ACTIVE DEVICE] Fallback to bonded band: ${bonded.macAddress}');
      }
    } catch (e) {
      debugPrint('⚠️ [ACTIVE DEVICE] Initialization error: $e');
    }
  }

  /// Sets the active wearable device by MAC address.
  /// Updates local state, database flag, and secure storage.
  Future<void> setActiveDevice(String macAddress) async {
    if (macAddress.isEmpty) return;
    try {
      await _deviceDao.setActiveDevice(macAddress);
      await _secureStorage.write(_keyActiveDeviceMac, macAddress);
      _activeDeviceId.value = macAddress;
      debugPrint('🔄 [ACTIVE DEVICE] Switched active band to: $macAddress');
    } catch (e) {
      debugPrint('⚠️ [ACTIVE DEVICE] Error setting active device: $e');
      _activeDeviceId.value = macAddress;
    }
  }

  /// Clears active device selection (e.g. when last device is unbound).
  Future<void> clearActiveDevice() async {
    try {
      await _secureStorage.delete(_keyActiveDeviceMac);
      _activeDeviceId.value = null;
      debugPrint('🧹 [ACTIVE DEVICE] Cleared active band selection');
    } catch (e) {
      debugPrint('⚠️ [ACTIVE DEVICE] Error clearing active device: $e');
    }
  }

  /// Gets all registered devices in local database.
  Future<List<BandDeviceEntry>> getAllRegisteredDevices() {
    return _deviceDao.getAllDevices();
  }

  /// Watches all registered devices reactively.
  Stream<List<BandDeviceEntry>> watchRegisteredDevices() {
    return _deviceDao.watchAllDevices();
  }
}
