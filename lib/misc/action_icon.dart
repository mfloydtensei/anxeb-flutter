import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';
import '../middleware/device.dart';

class ActionIcon extends ActionItem {
  final IconData Function()? icon;
  final double Function()? size;
  final Color Function()? color;
  final bool Function()? isDisabled;
  final bool Function()? isVisible;
  final VoidCallback? onPressed;
  final int Function()? notifications;
  final BoxDecoration? notificationDecoration;
  final TextStyle Function()? notificationStyle;
  final EdgeInsets Function()? notificationPadding;
  final Offset Function()? notificationOffset;

  ActionIcon({
    this.icon,
    this.size,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.notifications,
    this.notificationDecoration,
    this.notificationStyle,
    this.notificationPadding,
    this.notificationOffset,
  });

  Widget build() {
    // 🔹 Verificar visibilidad
    if (isVisible?.call() == false) {
      return const SizedBox.shrink();
    }

    final bool disabled = isDisabled?.call() ?? false;
    final Color baseColor = color?.call() ?? Colors.white;
    final Color currentColor = disabled ? baseColor.withValues(alpha: 0.4) : baseColor;

    // 🔹 Crear el botón principal
    final button = IconButton(
      icon: Icon(
        icon?.call() ?? Icons.circle,
        color: currentColor,
        size: size?.call(),
      ),
      onPressed: disabled ? null : onPressed,
    );

    // 🔹 Notificaciones
    final int? nots = notifications?.call();
    if (nots != null && nots > 0) {
      final Offset offset = notificationOffset?.call() ?? const Offset(8, 3);
      final EdgeInsets padding = notificationPadding?.call() ?? const EdgeInsets.all(4);
      final BoxDecoration decoration = notificationDecoration ??
          BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xffd00000),
            border: Border.all(width: 1.5, color: currentColor),
          );
      final TextStyle style = notificationStyle?.call() ??
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white);

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: button,
          ),
          Positioned(
            right: offset.dx,
            top: offset.dy,
            child: Container(
              padding: padding,
              decoration: decoration,
              child: Text(nots.toString(), style: style),
            ),
          ),
        ],
      );
    }

    return button;
  }
}

/// =======================================================
/// BOTONES PREDEFINIDOS
/// =======================================================

class ActionBack extends ActionIcon {
  ActionBack()
      : super(
          icon: () => Device.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
        );

  @override
  Widget build() => const BackButton();
}

class CloseAction extends ActionIcon {
  CloseAction() : super(icon: () => Icons.close);

  @override
  Widget build() => const CloseButton();
}
