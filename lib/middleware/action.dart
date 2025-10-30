import 'package:anxeb_flutter/misc/view_action_locator.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:flutter/material.dart';
import '../screen/scope.dart';
import 'device.dart';

class ScreenAction {
  final ScreenScope scope;
  final IconData Function()? icon;
  final VoidCallback? onPressed;
  final Color Function()? color;
  final bool Function()? isDisabled;
  final bool Function()? isVisible;
  final FloatingActionButtonLocation? locator;
  final List<AltAction>? alternates;
  final double? separation;
  final double? offset;
  final bool mini;
  bool _hidden;

  ScreenAction({
    required this.scope,
    this.icon,
    this.onPressed,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.locator,
    this.alternates,
    this.separation,
    this.offset,
    this.mini = false,
  }) : _hidden = false;

  /// Constructor rápido para acción "Back"
  ScreenAction.back({
    required this.scope,
    this.isDisabled,
    this.isVisible,
    this.offset,
  })  : mini = true,
        color = (() => scope.application.settings.colors.primary),
        onPressed = (() => scope.view.dismiss()),
        alternates = null,
        separation = null,
        locator = ScreenActionLocator(alignment: Alignment.bottomLeft),
        icon = (() => Icons.chevron_left),
        _hidden = false;

  /// Mostrar acción flotante
  void show() {
    _hidden = false;
    scope.rasterize();
  }

  /// Ocultar acción flotante
  void hide() {
    _hidden = true;
    scope.rasterize();
  }

  /// Construcción del botón flotante
  Widget? build() {
    // Si está oculto o marcado como no visible, no se muestra
    if (_hidden || (isVisible != null && isVisible!.call() == false)) {
      return const SizedBox.shrink();
    }

    return FloatAction(
      scope: scope,
      onPressed: onPressed ?? () {},
      color: color?.call() ?? scope.application.settings.colors.success,
      icon: icon?.call() ?? Icons.check,
      disabled: isDisabled?.call() ?? false,
      alternates: alternates ?? [],
      separation: separation ?? 0.0,
      topOffset: offset ?? 0.0,
      mini: mini,
      bottomOffset: Device.isAndroid && scope.window.overlay.extendBodyFullScreen
          ? 60.0
          : 0.0,
    );
  }

  bool get rebuild => false;
}
