import 'package:flutter/material.dart';

class StateButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final IconData? icon;
  final EdgeInsets? iconPadding;
  final EdgeInsets? padding;
  final double? size;
  final Color? color;
  final String? tooltip;
  final bool active;
  final bool visible;

  const StateButton({
    super.key,
    this.onTap,
    this.icon,
    this.iconPadding,
    this.padding,
    this.size,
    this.color,
    this.tooltip,
    this.active = false,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final Color effectiveColor =
        color ?? (active ? Colors.yellow : Colors.white54);
    final double effectiveSize = size ?? 34;

    final button = Padding(
      padding: padding ?? const EdgeInsets.only(right: 4),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            onTap: onTap,
            child: Padding(
              padding: iconPadding ?? const EdgeInsets.all(4),
              child: Icon(
                icon ?? Icons.circle,
                size: effectiveSize,
                color: effectiveColor,
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip!,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 400),
        showDuration: const Duration(seconds: 3),
        child: button,
      );
    }

    return button;
  }
}
