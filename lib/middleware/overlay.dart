import 'dart:async';
//import 'package:android_middleware/android_middleware.dart';
//import 'package:android_middleware/middleware/window_manager.dart';
import 'package:flutter/services.dart';

import 'device.dart';
import 'scope.dart';

class Overlay {
  bool extendBodyFullScreen = false;
  bool extendBodyBehindAppBar = false;
  bool extendBody = false;

  Brightness? navigationBrightness;
  Color? navigationFill;
  Brightness? statusBrightness;
  Color? statusFill;
  Brightness? brightness;
  Color? fill;
  Color? background;
  SystemUiOverlayStyle? style;
  final Scope scope;

  Overlay({
    required this.scope,
    this.navigationBrightness,
    this.navigationFill,
    this.statusBrightness,
    this.statusFill,
    this.brightness,
    this.fill,
    this.background,
    this.style,
  }) {
    style ??= SystemUiOverlayStyle.light;
  }

  /// Aplica los cambios visuales al sistema (status/navigation bar)
  void apply({bool instant = false}) {
    var $statusBrightness = brightness ??
        statusBrightness ??
        scope.application.settings.overlay.brightness;

    var $navigationBrightness = brightness ??
        navigationBrightness ??
        scope.application.settings.overlay.brightness;

    // Ajuste para Android: se invierte el brillo de los íconos
    if (Device.isAndroid) {
      $statusBrightness =
          $statusBrightness == Brightness.light ? Brightness.dark : Brightness.light;
      $navigationBrightness =
          $navigationBrightness == Brightness.light ? Brightness.dark : Brightness.light;
    }

    if (!Device.isWeb) {
      if (extendBodyFullScreen) {
       // AndroidMiddleware.windowManager
       //     .addFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
      } else {
        // AndroidMiddleware.windowManager
        //     .clearFlags(AndroidWindowManager.FLAG_LAYOUT_NO_LIMITS);
      }

      Future.delayed(Duration(milliseconds: instant ? 0 : 1000), () {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: fill ??
                statusFill ??
                scope.application.settings.overlay.fill,
            statusBarBrightness: $statusBrightness,
            statusBarIconBrightness: $statusBrightness,
            systemNavigationBarColor: fill ??
                navigationFill ??
                scope.application.settings.overlay.fill,
            systemNavigationBarIconBrightness: $navigationBrightness,
          ),
        );
      });
    }
  }
}
