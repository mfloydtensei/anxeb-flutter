import 'package:flutter/material.dart' hide Overlay;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'overlay.dart';
import 'scope.dart';
import 'utils.dart';
import 'dart:async';

class Window {
  late final KeyboardVisibilityController _keyboardVisibilityController;
  final Scope _scope;
  late final Overlay _overlay;
  bool _isKeyboardActive = false;
  Size _available = Size.zero;
  StreamSubscription<bool>? _keyboardSub;

  Window(this._scope) {
    _overlay = _scope.application.overlay ?? Overlay(scope: _scope);
    _keyboardVisibilityController = KeyboardVisibilityController();
    update(context: _scope.context);
  }

  /// Actualiza el tamaño y escucha cambios de teclado
  Window update({BuildContext? context, BoxConstraints? constraints}) {
    _keyboardSub?.cancel();
    _keyboardSub = _keyboardVisibilityController.onChange.listen((bool visible) {
      _isKeyboardActive = visible;
      _scope.alerts.dispose(quick: true);
      _scope.rasterize();
    });

    final mediaQuery = MediaQuery.of(context ?? _scope.context);
    final maxWidth = constraints?.maxWidth ?? mediaQuery.size.width;
    final maxHeight = constraints?.maxHeight ?? mediaQuery.size.height;

    _available = Size(
      maxWidth,
      maxHeight + (insets.bottom),
    );

    return this;
  }

  /// Calcula ancho relativo
  double horizontal(double fraction) => size.width * fraction;

  /// Calcula alto relativo
  double vertical(double fraction) => size.height * fraction;

  /// Convierte valores absolutos a proporcionales según el tamaño de la pantalla
  EdgeInsets padding({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Utils.convert.fromInsetToFraction(
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      size,
    );
  }

  /// Tamaño actual de pantalla
  Size get size => MediaQuery.of(context).size;

  /// Márgenes del sistema (como teclado)
  EdgeInsets get insets => MediaQuery.of(context).viewInsets;

  /// Overlay personalizado
  Overlay get overlay => _overlay;

  /// Contexto actual
  BuildContext get context => _scope.context;

  /// Estado del teclado
  bool get isKeyboardActive => _isKeyboardActive;

  /// Espacio disponible en pantalla
  Size get available => _available;

  /// Libera recursos
  void dispose() {
    _keyboardSub?.cancel();
  }
}
