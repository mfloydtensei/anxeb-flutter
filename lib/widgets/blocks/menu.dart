import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ContextMenu {
  final List<ContextMenuItem> items;
  final Widget? child;
  final double? itemHeight;
  final Offset offset;
  final TextStyle? textStyle;

  const ContextMenu({
    required this.items,
    this.child,
    this.itemHeight,
    this.offset = const Offset(10, 50),
    this.textStyle,
  });
}

class ContextMenuBlock extends StatelessWidget {
  final Scope? scope;
  final List<ContextMenuItem> items;
  final Widget? child;
  final IconData? icon;
  final double? itemHeight;
  final Offset offset;
  final TextStyle? textStyle;
  final double iconSize;
  final ShapeBorder? shape;

  const ContextMenuBlock({
    super.key,
    this.scope,
    required this.items,
    this.child,
    this.icon,
    this.itemHeight,
    this.offset = const Offset(10, 50),
    this.textStyle,
    this.iconSize = 20.0,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return child ?? const SizedBox.shrink();
    }

    return PopupMenuButton<VoidCallback>(
      icon: icon != null
          ? Icon(icon, size: iconSize, color: scope?.application.settings.colors.primary)
          : null,
      offset: offset,
      tooltip: '',
      padding: EdgeInsets.zero,
      shape: shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) {
        final entries = <PopupMenuEntry<VoidCallback>>[];

        for (final item in items) {
          if (item.visible == false) continue;

          if (item.divided == true) entries.add(const PopupMenuDivider());

          entries.add(
            PopupMenuItem<VoidCallback>(
              height: itemHeight ?? 35,
              enabled: item.enabled != false,
              onTap: item.enabled != false
                  ? (item.onTap ?? () {})
                  : null,
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Icon(
                      item.icon,
                      size: iconSize,
                      color: item.color ??
                          scope?.application.settings.colors.primary ??
                          Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: item.enabled == false
                        ? Opacity(
                            opacity: 0.5,
                            child: Text(
                              item.label,
                              style: textStyle ??
                                  TextStyle(
                                    color: scope?.application.settings.colors.primary ??
                                        Colors.black54,
                                  ),
                            ),
                          )
                        : Text(
                            item.label,
                            style: textStyle ??
                                TextStyle(
                                  color: scope?.application.settings.colors.primary ??
                                      Colors.black,
                                ),
                          ),
                  ),
                ],
              ),
            ),
          );
        }

        return entries;
      },
      onSelected: (callback) => callback.call(),
      child: child,
    );
  }
}

class ContextMenuItem {
  final IconData? icon;
  final Color? color;
  final String label;
  final VoidCallback? onTap;
  final bool divided;
  final bool visible;
  final bool enabled;

  const ContextMenuItem({
    this.icon,
    required this.label,
    this.onTap,
    this.color,
    this.divided = false,
    this.visible = true,
    this.enabled = true,
  });
}
