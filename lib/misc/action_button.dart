import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';

class ActionButton extends ActionItem {
  final IconData Function()? icon;
  final String Function()? caption;
  final Color Function()? color;
  final Color Function()? fill;
  final bool Function()? isDisabled;
  final bool Function()? isVisible;
  final VoidCallback? onPressed;
  final Widget Function()? child;
  final BorderRadius Function()? borderRadius;

  ActionButton({
    this.caption,
    this.icon,
    this.color,
    this.fill,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.child,
    this.borderRadius,
  });

  Widget build() {
    // 🔹 Determinar visibilidad
    if (isVisible?.call() == false) {
      return const SizedBox.shrink();
    }

    final bool disabled = isDisabled?.call() ?? false;
    final Color baseColor = color?.call() ?? Colors.white;
    final Color currentColor = disabled ? baseColor.withOpacity(0.4) : baseColor;
    final Color backgroundColor = fill?.call() ?? Colors.transparent;

    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 10),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius?.call() ?? BorderRadius.circular(8.0),
          ),
        ),
      ),
      onPressed: disabled ? null : onPressed,
      child: child?.call() ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Icon(
                    icon!.call(),
                    color: currentColor,
                  ),
                ),
              if (caption != null)
                Text(
                  caption!.call().toUpperCase(),
                  style: TextStyle(
                    color: currentColor,
                    letterSpacing: -0.2,
                  ),
                ),
            ],
          ),
    );
  }
}
