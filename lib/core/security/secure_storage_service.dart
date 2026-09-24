import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Production-grade secure storage service for sensitive keys, tokens, and hardware credentials.
/// Backed by iOS Keychain and Android KeyStore via [FlutterSecureStorage].
class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyBondedMac = 'bonded_device_mac';
  static const String _keyBandAuthPrefix = 'band_auth_key_';
  static const String _keyUserAuthToken = 'user_auth_token';
  static const String _keyRefreshToken = 'user_refresh_token';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  /// Detects if this is a fresh install (or fresh install after app deletion on iOS).
  /// On iOS, the system Keychain persists even after the app is uninstalled.
  /// If the app sandbox documents directory has no install marker, this is a clean new install,
  /// so we wipe any stale Keychain items from previous uninstalled installations.
  Future<void> ensureFreshInstallState() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final markerFile = File('${docDir.path}/.ehg_install_marker');
      if (!await markerFile.exists()) {
        await deleteAll();
        await markerFile.create(recursive: true);
        await markerFile.writeAsString(DateTime.now().toIso8601String());
      }
    } catch (_) {}
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // --- Wearable Specific Accessors ---

  Future<void> saveBondedDeviceMac(String mac) async {
    await write(_keyBondedMac, mac);
  }

  Future<String?> getBondedDeviceMac() async {
    return await read(_keyBondedMac);
  }

  Future<void> clearBondedDevice() async {
    await delete(_keyBondedMac);
  }

  Future<void> saveBandAuthKey(String mac, String authKey) async {
    await write('$_keyBandAuthPrefix$mac', authKey);
  }

  Future<String?> getBandAuthKey(String mac) async {
    return await read('$_keyBandAuthPrefix$mac');
  }

  Future<void> saveUserAuthToken(String token) async {
    await write(_keyUserAuthToken, token);
  }

  Future<String?> getUserAuthToken() async {
    return await read(_keyUserAuthToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await write(_keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    return await read(_keyRefreshToken);
  }

  /// Returns the persistent active user ID derived from user profile or device install.
  Future<String> getActiveUserId() async {
    final email = await getUserEmail();
    if (email != null && email.isNotEmpty) return email;
    final token = await getUserAuthToken();
    if (token != null && token.isNotEmpty) return token;
    final name = await getUserName();
    if (name != null && name.isNotEmpty) return name.toLowerCase().replaceAll(' ', '_');
    return 'ehg_primary_user';
  }

  // --- App & Profile Accessors ---

  Future<void> setOnboardingCompleted(bool completed) async {
    await write('ehg_onboarding_completed', completed ? 'true' : 'false');
  }

  Future<bool> isOnboardingCompleted() async {
    final val = await read('ehg_onboarding_completed');
    return val == 'true';
  }

  Future<void> saveUserName(String name) async {
    await write('ehg_user_name', name);
  }

  Future<String?> getUserName() async {
    return await read('ehg_user_name');
  }

  Future<void> saveUserAge(int age) async {
    await write('ehg_user_age', age.toString());
  }

  Future<int?> getUserAge() async {
    final str = await read('ehg_user_age');
    return str != null ? int.tryParse(str) : null;
  }

  Future<void> saveUserWeight(int weight) async {
    await write('ehg_user_weight', weight.toString());
  }

  Future<int?> getUserWeight() async {
    final str = await read('ehg_user_weight');
    return str != null ? int.tryParse(str) : null;
  }

  Future<void> saveUserEmail(String email) async {
    await write('ehg_user_email', email);
  }

  Future<String?> getUserEmail() async {
    return await read('ehg_user_email');
  }

  Future<void> saveAppearance(String theme) async {
    await write('ehg_appearance_theme', theme);
  }

  Future<String?> getAppearance() async {
    return await read('ehg_appearance_theme');
  }

  Future<void> saveUnitSystem(String unit) async {
    await write('ehg_unit_system', unit);
  }

  Future<String?> getUnitSystem() async {
    return await read('ehg_unit_system');
  }
}
