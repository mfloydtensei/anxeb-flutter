import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api.dart';

/// =======================================================
/// GENERAL CONFIGURATION
/// =======================================================
class _General {
  bool badges = true;
}

/// =======================================================
/// ANALYTICS CONFIGURATION
/// =======================================================
class _Analytics {
  bool available = false;
}

/// =======================================================
/// PANELS CONFIGURATION
/// =======================================================
class _Panels {
  double buttonRadius = 8.0;
}

/// =======================================================
/// DIALOGS CONFIGURATION
/// =======================================================
class _Dialogs {
  double buttonRadius = 8.0;
  double dialogRadius = 12.0;
  Color headerColor = Colors.white;
  Color footerColor = Colors.white;
  EdgeInsets buttonPaddingWithIcon =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  EdgeInsets buttonPaddingWithoutIcon =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  TextStyle buttonTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

/// =======================================================
/// ALERTS CONFIGURATION
/// =======================================================
class _Alerts {
  bool Function() showFromBottom = () => true;
  EdgeInsets Function() margin = () => const EdgeInsets.all(12);
  BorderRadius borderRadius = BorderRadius.circular(10);
}

/// =======================================================
/// FIELD CONFIGURATION (TextFields, Inputs, etc.)
/// =======================================================
class _Fields {
  double radius = 8.0;
  Color fillColor = const Color(0x10111111);
  double fontSize = 14.0;

  InputBorder border = OutlineInputBorder(
    borderSide: const BorderSide(color: Color(0xffcccccc), width: 1),
    borderRadius: BorderRadius.circular(8),
  );

  InputBorder disabledBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Color(0xffdddddd), width: 1),
    borderRadius: BorderRadius.circular(8),
  );

  InputBorder enabledBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Color(0xffaaaaaa), width: 1),
    borderRadius: BorderRadius.circular(8),
  );

  InputBorder focusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Color(0xff2e7db2), width: 2),
    borderRadius: BorderRadius.circular(8),
  );

  InputBorder errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red, width: 1),
    borderRadius: BorderRadius.circular(8),
  );

  InputBorder focusedErrorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red, width: 2),
    borderRadius: BorderRadius.circular(8),
  );

  Color hoverColor = const Color(0x10111111);
  Color focusColor = const Color(0x15111111);
  TextStyle errorStyle =
      const TextStyle(color: Colors.redAccent, fontSize: 12);
  EdgeInsets contentPaddingWithIcon =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  EdgeInsets contentPaddingNoIcon =
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  bool isDense = false;
  TextStyle hintStyle =
      const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);
  Color iconColor = Colors.grey;
  Color suffixIconColor = Colors.grey;
}

/// =======================================================
/// COLOR PALETTE
/// =======================================================
class _Colors {
  Color action = Colors.blue.shade500;
  Color background = const Color(0xfffafafa);
  Color primary = const Color(0xff2e7db2);
  Color secudary = const Color(0xff026299);
  Color accent = const Color(0xffef6c00);
  Color success = const Color(0xff4a934a);
  Color neutral = const Color(0xff0c7272);
  Color info = const Color(0xff333377);
  Color warning = const Color(0xffffbb33);
  Color danger = const Color(0xffff4444);
  Color asterisk = const Color(0xff605156);
  Color active = const Color(0xffffff99);
  Color tip = const Color(0xffffffaf);
  Color link = const Color(0xff0055ff);
  Color separator = const Color(0xffcccccc);
  Color text = const Color(0xff222222);
  Color header = const Color(0xff195279);
  Color focus = const Color(0x15111111);
  Color input = const Color(0x10111111);
  Color navigation = const Color(0xff053954);
  Color backdrop = const Color(0x8A000000);
  Color busybox = const Color(0x8A000000);
  Color foreground = const Color(0xffffffff);
}

/// =======================================================
/// AUTH CONFIGURATION
/// =======================================================
class _AuthsApple {
  String fetchCallbackRoute = '';
  String Function() nonce = () => '';
  Api? api;
}

class _AuthsGoogle {
  String clientId = '';
  String hostedDomain = '';
  SignInOption signInOption = SignInOption.standard;
  List<String> scopes = <String>[];
}

class _AuthsTwitter {
  String apiKey = '';
  String apiSecret = '';
}

class _AuthsFacebook {
  String appId = '';
  String appSecret = '';
  String clientToken = '';
}

class _Auths {
  final _google = _AuthsGoogle();
  final _twitter = _AuthsTwitter();
  final _facebook = _AuthsFacebook();
  final _apple = _AuthsApple();

  _AuthsGoogle get google => _google;
  _AuthsTwitter get twitter => _twitter;
  _AuthsFacebook get facebook => _facebook;
  _AuthsApple get apple => _apple;
}

/// =======================================================
/// OVERLAY CONFIGURATION
/// =======================================================
class _Overlay {
  Brightness brightness = Brightness.dark;
  Color fill = Colors.transparent;
}

/// =======================================================
/// MAIN SETTINGS CLASS
/// =======================================================
class Settings {
  final _Colors _colors = _Colors();
  final _Auths _auths = _Auths();
  final _Dialogs _dialogs = _Dialogs();
  final _Alerts _alerts = _Alerts();
  final _Fields _fields = _Fields();
  final _Panels _panels = _Panels();
  final _Analytics _analytics = _Analytics();
  final _General _general = _General();
  final _Overlay _overlay = _Overlay();

  _Colors get colors => _colors;
  _Auths get auths => _auths;
  _Dialogs get dialogs => _dialogs;
  _Alerts get alerts => _alerts;
  _Fields get fields => _fields;
  _Panels get panels => _panels;
  _Analytics get analytics => _analytics;
  _General get general => _general;
  _Overlay get overlay => _overlay;
}
