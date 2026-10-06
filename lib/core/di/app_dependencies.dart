import '../database/app_database.dart';
import '../security/secure_storage_service.dart';
import '../services/active_device_service.dart';
import '../sync/background_sync_service.dart';
import '../sync/health_sync_manager.dart';
import '../../data/repositories/band_repository.dart';
import '../../data/repositories/wellness_repository.dart';

/// Dependency container providing on-demand (lazy) singletons for heavy services.
///
/// Prevents heavy initializations (SQLite, Keychain access, BLE drivers) from
/// running all at once on app launch. Services are only instantiated when first accessed.
class AppDependencies {
  AppDatabase? _database;
  SecureStorageService? _secureStorage;
  ActiveDeviceService? _activeDeviceService;
  HealthSyncManager? _healthSyncManager;
  WellnessRepository? _wellnessRepository;
  BandRepository? _bandRepository;
  BackgroundSyncService? _backgroundSyncService;

  /// Lazy SQLite / Drift database connection
  AppDatabase get database => _database ??= AppDatabase();

  /// Lazy Flutter secure storage service
  SecureStorageService get secureStorage =>
      _secureStorage ??= SecureStorageService();

  /// Lazy active device management service (multi-band identity)
  ActiveDeviceService get activeDeviceService =>
      _activeDeviceService ??= ActiveDeviceService(
        deviceDao: database.deviceDao,
        secureStorage: secureStorage,
      );

  /// Lazy health synchronization manager
  HealthSyncManager get healthSyncManager =>
      _healthSyncManager ??= HealthSyncManager(secureStorage: secureStorage);

  /// Lazy wellness repository
  WellnessRepository get wellnessRepository =>
      _wellnessRepository ??= WellnessRepository(
        database: database,
        secureStorage: secureStorage,
        activeDeviceService: activeDeviceService,
      );

  /// Lazy band repository
  BandRepository get bandRepository =>
      _bandRepository ??= BandRepository(
        database: database,
        secureStorage: secureStorage,
        activeDeviceService: activeDeviceService,
      );

  /// Lazy background sync service
  BackgroundSyncService get backgroundSyncService =>
      _backgroundSyncService ??= BackgroundSyncService(
        syncManager: healthSyncManager,
        bandRepository: bandRepository,
        wellnessRepository: wellnessRepository,
      );

  /// Disposes active resources and database connections cleanly.
  void dispose() {
    _bandRepository?.dispose();
    _database?.close();
  }
}
