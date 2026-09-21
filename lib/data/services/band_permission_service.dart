import 'dart:io';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../models/band_device_model.dart';

/// Platform-agnostic Bluetooth and location permission service powered by
/// the official `permission_handler` package.
class BandPermissionService {
  const BandPermissionService();

  /// Inspects current Bluetooth and Location permission statuses as well as hardware radio states.
  Future<BandPermissionDetails> checkPermissions() async {
    if (Platform.isIOS) {
      final status = await ph.Permission.bluetooth.status;
      final serviceStatus = await ph.Permission.bluetooth.serviceStatus;
      final isBtEnabled = serviceStatus != ph.ServiceStatus.disabled;

      BandPermissionStatus permStatus;
      bool isPermDenied = false;

      if (status.isGranted) {
        permStatus = BandPermissionStatus.granted;
      } else if (status.isPermanentlyDenied) {
        permStatus = BandPermissionStatus.permanentlyDenied;
        isPermDenied = true;
      } else if (status.isRestricted) {
        permStatus = BandPermissionStatus.restricted;
      } else {
        permStatus = BandPermissionStatus.denied;
      }

      return BandPermissionDetails(
        status: permStatus,
        isBluetoothEnabled: isBtEnabled,
        isLocationEnabled: true,
        isPermanentlyDenied: isPermDenied,
        message: isPermDenied
            ? 'Bluetooth permission is permanently denied. Please allow it in Settings.'
            : (status.isDenied
                ? 'Bluetooth permission is required to find your band.'
                : (!isBtEnabled
                    ? 'Bluetooth is turned OFF. Please turn ON Bluetooth.'
                    : 'Ready')),
      );
    } else if (Platform.isAndroid) {
      final scanStatus = await ph.Permission.bluetoothScan.status;
      final connectStatus = await ph.Permission.bluetoothConnect.status;
      final locationStatus = await ph.Permission.location.status;

      final isBtGranted = scanStatus.isGranted && connectStatus.isGranted;
      final isPermDenied =
          scanStatus.isPermanentlyDenied || connectStatus.isPermanentlyDenied;

      final btService = await ph.Permission.bluetooth.serviceStatus;
      final locService = await ph.Permission.location.serviceStatus;

      final isBtEnabled = btService != ph.ServiceStatus.disabled;
      final isLocEnabled = locService != ph.ServiceStatus.disabled;

      BandPermissionStatus permStatus;
      if (isBtGranted || locationStatus.isGranted) {
        permStatus = BandPermissionStatus.granted;
      } else if (isPermDenied || locationStatus.isPermanentlyDenied) {
        permStatus = BandPermissionStatus.permanentlyDenied;
      } else {
        permStatus = BandPermissionStatus.denied;
      }

      return BandPermissionDetails(
        status: permStatus,
        isBluetoothEnabled: isBtEnabled,
        isLocationEnabled: isLocEnabled,
        isPermanentlyDenied: isPermDenied || locationStatus.isPermanentlyDenied,
        message: (isPermDenied || locationStatus.isPermanentlyDenied)
            ? 'Bluetooth / Location permission is permanently denied. Please allow it in Settings.'
            : (permStatus == BandPermissionStatus.denied
                ? 'Bluetooth & Location permissions are required to find your band.'
                : (!isBtEnabled
                    ? 'Bluetooth is turned OFF. Please turn ON Bluetooth.'
                    : (!isLocEnabled
                        ? 'Location services are turned OFF. Please enable Location.'
                        : 'Ready'))),
      );
    }

    return const BandPermissionDetails(
      status: BandPermissionStatus.granted,
      isBluetoothEnabled: true,
      isLocationEnabled: true,
    );
  }

  /// Prompts the user for Bluetooth and Location permissions via the OS dialogs.
  Future<BandPermissionDetails> requestPermissions() async {
    if (Platform.isIOS) {
      final status = await ph.Permission.bluetooth.request();
      final serviceStatus = await ph.Permission.bluetooth.serviceStatus;
      final isBtEnabled = serviceStatus != ph.ServiceStatus.disabled;

      BandPermissionStatus permStatus;
      bool isPermDenied = false;

      if (status.isGranted) {
        permStatus = BandPermissionStatus.granted;
      } else if (status.isPermanentlyDenied) {
        permStatus = BandPermissionStatus.permanentlyDenied;
        isPermDenied = true;
      } else if (status.isRestricted) {
        permStatus = BandPermissionStatus.restricted;
      } else {
        permStatus = BandPermissionStatus.denied;
      }

      return BandPermissionDetails(
        status: permStatus,
        isBluetoothEnabled: isBtEnabled,
        isLocationEnabled: true,
        isPermanentlyDenied: isPermDenied,
      );
    } else if (Platform.isAndroid) {
      final statuses = await [
        ph.Permission.bluetoothScan,
        ph.Permission.bluetoothConnect,
        ph.Permission.location,
      ].request();

      final scanStatus = statuses[ph.Permission.bluetoothScan] ?? ph.PermissionStatus.denied;
      final connectStatus = statuses[ph.Permission.bluetoothConnect] ?? ph.PermissionStatus.denied;
      final locationStatus = statuses[ph.Permission.location] ?? ph.PermissionStatus.denied;

      final isBtGranted = scanStatus.isGranted && connectStatus.isGranted;
      final isPermDenied = scanStatus.isPermanentlyDenied ||
          connectStatus.isPermanentlyDenied ||
          locationStatus.isPermanentlyDenied;

      final btService = await ph.Permission.bluetooth.serviceStatus;
      final locService = await ph.Permission.location.serviceStatus;

      BandPermissionStatus permStatus;
      if (isBtGranted || locationStatus.isGranted) {
        permStatus = BandPermissionStatus.granted;
      } else if (isPermDenied) {
        permStatus = BandPermissionStatus.permanentlyDenied;
      } else {
        permStatus = BandPermissionStatus.denied;
      }

      return BandPermissionDetails(
        status: permStatus,
        isBluetoothEnabled: btService != ph.ServiceStatus.disabled,
        isLocationEnabled: locService != ph.ServiceStatus.disabled,
        isPermanentlyDenied: isPermDenied,
      );
    }

    return const BandPermissionDetails(
      status: BandPermissionStatus.granted,
      isBluetoothEnabled: true,
      isLocationEnabled: true,
    );
  }

  /// Opens the device settings page for this app.
  Future<bool> openAppSettings() async {
    return ph.openAppSettings();
  }
}
