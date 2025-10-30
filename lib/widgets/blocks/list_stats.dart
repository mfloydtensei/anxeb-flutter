import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:flutter/material.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;

class ListStatsBlock extends StatelessWidget {
  final Anxeb.Scope? scope;
  final String? text;
  final Color? color;
  final IconData? icon;
  final EdgeInsets? iconPadding;
  final bool visible;
  final double scale;
  final double fontSize;

  const ListStatsBlock({
    super.key,
    this.scope,
    this.text,
    this.color,
    this.icon,
    this.iconPadding,
    this.visible = true,
    this.scale = 1.0,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible || (text == null && icon == null)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Padding(
              padding: iconPadding ?? const EdgeInsets.only(right: 4),
              child: Icon(
                icon,
                size: 12 * scale,
                color: color ?? Colors.black54,
              ),
            ),
          if (text != null && text!.isNotEmpty)
            Text(
              text!,
              style: TextStyle(
                fontSize: fontSize,
                color: color ?? Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Settings? get settings => scope?.application.settings;
}
