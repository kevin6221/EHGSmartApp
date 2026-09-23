// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_dao.dart';

// ignore_for_file: type=lint
mixin _$DeviceDaoMixin on DatabaseAccessor<AppDatabase> {
  $BandDevicesTableTable get bandDevicesTable =>
      attachedDatabase.bandDevicesTable;
  DeviceDaoManager get managers => DeviceDaoManager(this);
}

class DeviceDaoManager {
  final _$DeviceDaoMixin _db;
  DeviceDaoManager(this._db);
  $$BandDevicesTableTableTableManager get bandDevicesTable =>
      $$BandDevicesTableTableTableManager(
        _db.attachedDatabase,
        _db.bandDevicesTable,
      );
}
