import 'package:drift/drift.dart';
import '../tables/health_tables.dart';
import '../app_database.dart';

part 'device_dao.g.dart';

@DriftAccessor(tables: [BandDevicesTable])
class DeviceDao extends DatabaseAccessor<AppDatabase> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  Future<int> upsertDevice(BandDevicesTableCompanion device) {
    return into(bandDevicesTable).insert(device, mode: InsertMode.insertOrReplace);
  }

  Future<BandDeviceEntry?> getDeviceByMac(String macAddress) {
    return (select(bandDevicesTable)..where((tbl) => tbl.macAddress.equals(macAddress)))
        .getSingleOrNull();
  }

  Future<BandDeviceEntry?> getBondedDevice() {
    return (select(bandDevicesTable)
          ..where((tbl) => tbl.isBonded.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<BandDeviceEntry?> watchBondedDevice() {
    return (select(bandDevicesTable)
          ..where((tbl) => tbl.isBonded.equals(true))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<int> updateBattery(String macAddress, int level, bool isCharging) {
    return (update(bandDevicesTable)..where((tbl) => tbl.macAddress.equals(macAddress))).write(
      BandDevicesTableCompanion(
        batteryLevel: Value(level),
        isCharging: Value(isCharging),
      ),
    );
  }

  Future<int> updateSyncTimestamp(String macAddress, DateTime syncTime) {
    return (update(bandDevicesTable)..where((tbl) => tbl.macAddress.equals(macAddress))).write(
      BandDevicesTableCompanion(
        lastSyncAt: Value(syncTime),
      ),
    );
  }

  Future<int> clearBonding() {
    return (update(bandDevicesTable)).write(
      const BandDevicesTableCompanion(
        isBonded: Value(false),
      ),
    );
  }
}
