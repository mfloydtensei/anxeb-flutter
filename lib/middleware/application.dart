import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart' hide Navigator, Overlay;
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'disk.dart';
import 'printer.dart';

/// =======================================================
/// APPLICATION CORE
/// =======================================================
class Application {
  late final Settings _settings;
  Api? _api;
  late String _title;
  late final Disk _disk;
  late final AuthProviders _auths;
  Analytics? _analytics;
  bool _badgesSupport = false;
  LocalizationDelegate? _localization;
  late final Printer _printer;
  late final DeviceInfo _info;

  Application() {
    WidgetsFlutterBinding.ensureInitialized();
    _settings = Settings();
    _title = 'Anxeb';
    _disk = Disk();
    _printer = Printer(this);
    init();
    _auths = AuthProviders(this);

    if (_settings.analytics.available == true) {
      _analytics = Analytics();
    }

    _info = Device.info;
  }

  /// =======================================================
  /// BADGE HANDLING
  /// =======================================================
  Future<void> setBadge(int value) async {
    if (_badgesSupport) {
      if (value > 0) {
        await FlutterAppBadger.updateBadgeCount(value);
      } else {
        await FlutterAppBadger.removeBadge();
      }
    }
  }

  /// =======================================================
  /// INITIALIZATION
  /// =======================================================
  Future<void> setup({required List<String> locales}) async {
    _localization = await LocalizationDelegate.create(
      fallbackLocale: locales.first,
      supportedLocales: locales,
    );

    _badgesSupport = _settings.general.badges == true &&
        await FlutterAppBadger.isAppBadgeSupported();

    if (_settings.analytics.available == true && _analytics != null) {
      await _analytics!.init(onMessage: onMessage);
    }

    await Device.info.init();
  }

  @protected
  void init() {
    // Detecta automáticamente entorno según build mode
    final bool isProd = bool.fromEnvironment('dart.vm.product');
    final String baseUrl = isProd
        ? 'https://api.canarock.info' // 🌍 Producción
        : 'http://192.168.0.64:6401'; // 🧩 Desarrollo local

    _api = Api(baseUrl);
  }

  @protected
  void onMessage(RemoteMessage message, MessageEventType event) {
    if (_analytics != null) {
      setBadge(_analytics!.notifications.length);
    }
  }

  /// =======================================================
  /// EVENT TRACKING
  /// =======================================================
  void onEvent(
    ApplicationEventType type, {
    String? reference,
    String? description,
    dynamic data,
  }) {
    // Override this in your app if needed
  }

  /// =======================================================
  /// GETTERS / SETTERS
  /// =======================================================
  Settings get settings => _settings;
  String get version => 'v0.0.0';
  Api get api => _api ??= Api(_getDefaultApiUrl);
  AuthProviders get auths => _auths;
  Analytics? get analytics => _analytics;
  Disk get disk => _disk;
  Printer get printer => _printer;
  DeviceInfo get info => _info;
  LocalizationDelegate? get localization => _localization;
  String get title => _title;
  Overlay? get overlay => null;

  /// =======================================================
  /// HELPERS
  /// =======================================================
  String get _getDefaultApiUrl {
    final bool isProd = bool.fromEnvironment('dart.vm.product');
    return isProd ? 'https://api.canarock.info' : 'http://192.168.0.64:6401';
  }

  @protected
  set api(Api value) {
    _api = value;
  }

  @protected
  set title(String value) {
    _title = value;
  }

  Widget? drawer(Scope scope) => null;
}

/// =======================================================
/// EVENT TYPES ENUM
/// =======================================================
enum ApplicationEventType {
  error,
  exception,
  asterisk,
  success,
  information,
  notification,
  action,
  debug,
  prompt,
  view
}
