import 'dart:io';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:url_launcher/url_launcher.dart' as UL;
import '../helpers/camera.dart';
import '../screen/scope.dart';
import 'dialog.dart';
import 'utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_store/open_store.dart';
import 'package:app_settings/app_settings.dart';
//import 'package:scan/scan.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Device {
  static final Device _singleton = Device._internal();
  factory Device() => _singleton;
  Device._internal();

  static DeviceInfo info = DeviceInfo();
  static DeviceSettings settings = DeviceSettings();
  static DevicePermissions permission = DevicePermissions();

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;

  static Future<void> launchStore({
    String? appStoreId,
    String? androidAppBundleId,
  }) async {
    await OpenStore.instance.open(
      appStoreId: appStoreId ?? '',
      androidAppBundleId: androidAppBundleId ?? '',
    );
  }

  static Future<void> launchUrl({
    required Scope scope,
    required String url,
    UL.LaunchMode mode = UL.LaunchMode.platformDefault,
  }) async {
    try {
      final uri = Uri.parse(url);
      if (await UL.canLaunchUrl(uri)) {
        await UL.launchUrl(uri, mode: mode);
      } else {
        throw Exception('No se puede abrir el enlace');
      }
    } catch (_) {
      scope.dialogs.exception(translate('anxeb.exceptions.navigator_init')).show();
    }
  }

  static Future<File?> photo({
    required ScreenScope scope,
    FileSourceOption option = FileSourceOption.prompt,
    String? title,
    bool? initFaceCamera,
    bool? allowMainCamera,
    bool? fullImage,
    bool? flash,
    ResolutionPreset? resolution,
    String? fileName,
  }) async {
    bool useCameraHelper = false;
    File? result;

   if (option == FileSourceOption.prompt) {
  final bool? shouldUse = await Utils.dialogs.shouldUseCamera(scope);
  useCameraHelper = shouldUse ?? false;
} else {
  useCameraHelper = option == FileSourceOption.camera;
}


    if (useCameraHelper) {
      result = await scope.push<File?>(
        CameraHelper(
          application: scope.application,
          title: title ?? '',
          fullImage: fullImage ?? false,
          initFaceCamera: initFaceCamera ?? false,
          allowMainCamera: allowMainCamera ?? true,
          flash: flash ?? false,
          resolution: resolution ?? ResolutionPreset.medium,
          fileName: fileName ?? '',
        ),
      );
    } else {
      result = await browse<File>(
        scope: scope,
        type: FileType.image,
        allowMultiple: false,
        callback: (files) async => File(files.single.path!),
      );
    }
    return result;
  }

  static Future<String?> scan({
    required Scope scope,
    FileSourceOption option = FileSourceOption.prompt,
    String? title,
    bool? autoflash,
  }) async {
    String? value;
    bool useCameraHelper = false;

    if (option == FileSourceOption.prompt) {
  final bool? shouldUse = await Utils.dialogs.shouldUseCamera(scope);
  useCameraHelper = shouldUse ?? false;
} else {
  useCameraHelper = option == FileSourceOption.camera;
}


    if (useCameraHelper) {
      try {
        final scanResult = await BarcodeScanner.scan(
          options: ScanOptions(
            strings: {
              'cancel': 'X',
              'flash_on': translate('anxeb.device.camera.flash_on_label'),
              'flash_off': translate('anxeb.device.camera.flash_off_label'),
            },
            autoEnableFlash: autoflash ?? false,
            android: const AndroidOptions(useAutoFocus: true),
          ),
        );
        value = scanResult.rawContent;
      } catch (_) {
        value = null;
      }
    } else {
      value = await browse<String>(
        scope: scope,
        allowedExtensions: ['jpeg', 'jpg', 'png'],
        type: FileType.custom,
        allowMultiple: false,
        callback: (files) async {
          try {
            //final barcodeValue = await Scan.parse(files.first.path!);
            //if (barcodeValue?.isNotEmpty == true) {
            //  return barcodeValue;
            //} else {
            //  scope.alerts.error(translate('anxeb.device.scan.barcode_not_found')).show();
            //}
          } catch (_) {
            scope.alerts.error(translate('anxeb.device.scan.barcode_scan_error')).show();
          }
          return null;
        },
      );
    }

    return (value?.isNotEmpty ?? false) ? value : null;
  }

  static Future<T?> browse<T>({
    required Scope scope,
    required Future<T?> Function(List<PlatformFile>) callback,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    String? dialogTitle,
    bool showBusyOnPicking = true,
  }) async {
    FilePickerResult? picker;
    T? result;
    bool isBusy = false;

    try {
      picker = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
        withData: withData,
        withReadStream: withReadStream,
        dialogTitle: dialogTitle,
        onFileLoading: (state) async {
          if (showBusyOnPicking && state == FilePickerStatus.picking) {
            await scope.busy(
              timeout: 0,
              text: translate('anxeb.device.browse.loading_busy_label'),
            );
            isBusy = true;
          }
        },
      );

      if (showBusyOnPicking) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (picker != null && picker.files.isNotEmpty) {
        result = await callback(picker.files);
      }
    } on PlatformException catch (err) {
      if (isBusy) await scope.idle();
      if (err.code == 'read_external_storage_denied') {
        final action = await scope.dialogs.exception(
          translate('anxeb.device.browse.access_denied_title'),
          dismissible: true,
          message: translate('anxeb.device.browse.access_denied_message'),
          icon: Icons.sd_storage,
          buttons: [
            DialogButton(translate('anxeb.common.yes'), 'settings'),
            DialogButton(translate('anxeb.common.no'), false),
          ],
        ).show();

        if (action == 'settings') {
          await settings.storage();
        }
      } else {
        await scope.alerts.error(err).show();
      }
    } catch (err) {
      if (isBusy) await scope.idle();
      await scope.alerts.error(err).show();
    } finally {
      if (isBusy) await scope.idle();
    }

    return result;
  }
}

class DevicePermissions {
  Permission get calendar => Permission.calendarFullAccess;
  Permission get camera => Permission.camera;
  Permission get contacts => Permission.contacts;
  Permission get location => Permission.location;
  Permission get locationAlways => Permission.locationAlways;
  Permission get locationWhenInUse => Permission.locationWhenInUse;
  Permission get mediaLibrary => Permission.mediaLibrary;
  Permission get microphone => Permission.microphone;
  Permission get phone => Permission.phone;
  Permission get photos => Permission.photos;
  Permission get reminders => Permission.reminders;
  Permission get sensors => Permission.sensors;
  Permission get sms => Permission.sms;
  Permission get speech => Permission.speech;
  Permission get storage => Permission.storage;
  Permission get notification => Permission.notification;
  Permission get accessMediaLocation => Permission.accessMediaLocation;
  Permission get activityRecognition => Permission.activityRecognition;
  Permission get bluetoothConnect => Permission.bluetoothConnect;
  Permission get bluetooth => Permission.bluetooth;
  Permission get bluetoothScan => Permission.bluetoothScan;
  Permission get bluetoothAdvertise => Permission.bluetoothAdvertise;
}

class DeviceSettings {
  Future<void> wifi() => AppSettings.openAppSettings(type: AppSettingsType.wifi);
  Future<void> wireless() => AppSettings.openAppSettings(type: AppSettingsType.wireless);
  Future<void> location() => AppSettings.openAppSettings(type: AppSettingsType.location);
  Future<void> security() => AppSettings.openAppSettings(type: AppSettingsType.security);
  Future<void> lock() => AppSettings.openAppSettings(type: AppSettingsType.lockAndPassword);
  Future<void> bluetooth() => AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  Future<void> roaming() => AppSettings.openAppSettings(type: AppSettingsType.dataRoaming);
  Future<void> date() => AppSettings.openAppSettings(type: AppSettingsType.date);
  Future<void> display() => AppSettings.openAppSettings(type: AppSettingsType.display);
  Future<void> notification() => AppSettings.openAppSettings(type: AppSettingsType.notification);
  Future<void> sound() => AppSettings.openAppSettings(type: AppSettingsType.sound);
  Future<void> storage() => AppSettings.openAppSettings(type: AppSettingsType.internalStorage);
  Future<void> battery() => AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
  Future<void> app() => AppSettings.openAppSettings(); // ✅ corregido
  Future<void> nfc() => AppSettings.openAppSettings(type: AppSettingsType.nfc);
  Future<void> device() => AppSettings.openAppSettings(type: AppSettingsType.device);
  Future<void> vpn() => AppSettings.openAppSettings(type: AppSettingsType.vpn);
  Future<void> accessibility() => AppSettings.openAppSettings(type: AppSettingsType.accessibility);
  Future<void> development() => AppSettings.openAppSettings(); // ✅ corregido
  Future<void> hotspot() => AppSettings.openAppSettings(type: AppSettingsType.hotspot);
}


class DeviceInfo {
  IosDeviceInfo? _ios;
  AndroidDeviceInfo? _android;
  PackageInfo? _package;

  DeviceInfo() {
    init();
  }

  Future<DeviceInfo> init() async {
    if (!kIsWeb) {
      final plugin = DeviceInfoPlugin();
      if (Device.isAndroid) {
        _android = await plugin.androidInfo;
      } else if (Device.isIOS) {
        _ios = await plugin.iosInfo;
      }
    }
    _package = await PackageInfo.fromPlatform();
    return this;
  }

  PackageInfo? get package => _package;
  bool get isAndroid => Device.isAndroid;
  bool get isIOS => Device.isIOS;
  bool get isWeb => Device.isWeb;

  String? get id => _ios?.identifierForVendor ?? _android?.id;
  String? get model => _ios?.utsname.machine ?? _android?.model;
  String? get version => _ios?.systemVersion ?? _android?.version.release;
}

enum FileSourceOption { browse, camera, prompt }
