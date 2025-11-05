import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:flutter/material.dart';

class ActionMenu extends ActionItem {
  final IconData Function()? icon;
  final Color Function()? color;
  final bool Function()? isDisabled;
  final bool Function()? isVisible;
  final VoidCallback? onPressed;
  final bool Function()? divided;
  final List<ActionMenuItem>? actions;
  final Offset? offset;

   ActionMenu({
    this.icon,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.divided,
    this.actions,
    this.offset,
  });

  Widget build() {
    // 🔹 Si no es visible, no se muestra nada
    if (isVisible?.call() == false) return const SizedBox.shrink();

    final bool disabled = isDisabled?.call() ?? false;
    final Color baseColor = color?.call() ?? Colors.white;
    final Color currentColor = disabled ? baseColor.withValues(alpha: 0.4) : baseColor;
    final List<ActionMenuItem> menuActions = actions ?? [];

    final List<PopupMenuEntry<ActionMenuItem>> items = [];

    for (final action in menuActions) {
      if (action.isVisible?.call() == false) continue;
      if (action.divided?.call() == true) {
        items.add(const PopupMenuDivider());
      }
      items.add(action.build());
    }

    return PopupMenuButton<ActionMenuItem>(
      itemBuilder: (context) => items,
      icon: Icon(
        icon?.call() ?? Icons.more_vert,
        color: currentColor,
      ),
      offset: offset ?? const Offset(10, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.zero,
      enabled: !disabled,
      onSelected: (action) {
        if (action.isDisabled?.call() != true) {
          Future.delayed(Duration.zero, () => action.onPressed?.call());
        }
      },
    );
  }
}

class ActionMenuItem {
  final IconData Function()? icon;
  final String Function()? caption;
  final Color Function()? color;
  final Color Function()? iconColor;
  final bool Function()? isDisabled;
  final bool Function()? isVisible;
  final VoidCallback? onPressed;
  final bool Function()? divided;
  final double? iconSize;

  const ActionMenuItem({
    this.caption,
    this.icon,
    this.color,
    this.iconColor,
    this.isDisabled,
    this.isVisible,
    this.onPressed,
    this.divided,
    this.iconSize,
  });

  PopupMenuItem<ActionMenuItem> build() {
    final bool disabled = isDisabled?.call() ?? false;
    final Color baseColor = color?.call() ?? const Color(0xff333333);
    final Color currentColor = disabled ? baseColor.withValues(alpha: 0.4) : baseColor;

    return PopupMenuItem<ActionMenuItem>(
      height: 38,
      value: this,
      child: Row(
        children: [
          if (icon != null)
            SizedBox(
              width: 26,
              child: Icon(
                icon!.call(),
                size: iconSize ?? 22,
                color: iconColor?.call() ?? currentColor,
              ),
            ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                caption!.call(),
                style: TextStyle(color: currentColor, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
