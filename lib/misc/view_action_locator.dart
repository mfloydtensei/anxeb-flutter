import 'dart:math' as math;
import 'package:flutter/material.dart';

const double kFloatingActionButtonMargin = 16.0;

/// =======================================================
/// FUNCIONES AUXILIARES PARA POSICIONAMIENTO
/// =======================================================

double _leftOffset(
  ScaffoldPrelayoutGeometry scaffoldGeometry, {
  double offset = 0.0,
}) {
  return kFloatingActionButtonMargin +
      scaffoldGeometry.minInsets.left -
      offset;
}

double _rightOffset(
  ScaffoldPrelayoutGeometry scaffoldGeometry, {
  double offset = 0.0,
}) {
  return scaffoldGeometry.scaffoldSize.width -
      kFloatingActionButtonMargin -
      scaffoldGeometry.minInsets.right -
      scaffoldGeometry.floatingActionButtonSize.width +
      offset;
}

double _endOffset(
  ScaffoldPrelayoutGeometry scaffoldGeometry, {
  required Alignment alignment,
  double offset = 0.0,
}) {
  final bool isLTR = scaffoldGeometry.textDirection == TextDirection.ltr;
  final bool isRTL = scaffoldGeometry.textDirection == TextDirection.rtl;

  if (alignment == Alignment.bottomLeft || isRTL) {
    return _leftOffset(scaffoldGeometry, offset: offset);
  } else if (alignment == Alignment.bottomRight || isLTR) {
    return _rightOffset(scaffoldGeometry, offset: offset);
  }
  // Valor por defecto centrado si no hay match
  return (scaffoldGeometry.scaffoldSize.width -
          scaffoldGeometry.floatingActionButtonSize.width) /
      2;
}

/// =======================================================
/// LOCALIZADOR PERSONALIZADO PARA FAB
/// =======================================================

class ScreenActionLocator extends FloatingActionButtonLocation {
  final Offset offset;
  final Alignment alignment;
  double _altOffset = 0.0;

  ScreenActionLocator({
    this.offset = Offset.zero,
    this.alignment = Alignment.bottomRight,
  });

  /// Calcula la posición vertical del FAB tomando en cuenta snackbar, bottomSheet, etc.
  @protected
  double getDockedY(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
    final double fabHeight =
        scaffoldGeometry.floatingActionButtonSize.height - _altOffset;
    final double contentBottom =
        scaffoldGeometry.scaffoldSize.height - (fabHeight / 2) - 19;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;

    double fabY = contentBottom - fabHeight / 2.0;

    if (snackBarHeight > 0.0) {
      fabY = math.min(fabY, contentBottom - snackBarHeight - (fabHeight / 2));
    }

    if (bottomSheetHeight > 0.0) {
      fabY = math.min(
        fabY,
        contentBottom - bottomSheetHeight - fabHeight / 2.0,
      );
    }

    final double maxFabY = scaffoldGeometry.scaffoldSize.height - fabHeight;

    return math.min(maxFabY, fabY + offset.dy);
  }

  /// Calcula la posición final (X, Y)
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = _endOffset(
      scaffoldGeometry,
      alignment: alignment,
      offset: offset.dx,
    );
    final double fabY = getDockedY(scaffoldGeometry);

    return Offset(fabX, fabY);
  }

  /// Ajuste vertical adicional dinámico (opcional)
  void setAltOffset(double value) {
    _altOffset = value;
  }
}
