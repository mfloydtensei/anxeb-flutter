import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../middleware/application.dart';

class SwitchButton extends StatelessWidget {
  final Anxeb.Scope scope;
  final Widget text;
  final EdgeInsets? margin;
  final ValueChanged<bool> onToggle;
  final bool value;
  final IconData? icon;
  final List<BoxShadow>? shadows;
  final TextStyle? style;
  final bool readonly;
  final EdgeInsets? padding;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;

  const SwitchButton({
    super.key,
    required this.scope,
    required this.onToggle,
    required this.text,
    this.value = false,
    this.margin,
    this.icon,
    this.shadows,
    this.style,
    this.readonly = false,
    this.padding,
    this.height,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = scope.application.settings.colors;
    final BorderRadius effectiveRadius =
        borderRadius ?? const BorderRadius.all(Radius.circular(8));

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: shadows,
      ),
      child: Material(
        color: color ?? Colors.white,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: readonly ? null : () => onToggle(!value),
          borderRadius: effectiveRadius,
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
            height: height ?? 48,
            child: Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: appColors.primary,
                    size: 22,
                  ),
                if (icon != null) const SizedBox(width: 8),
                Expanded(
                  child: DefaultTextStyle(
                    style: style ??
                        TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                    child: text,
                  ),
                ),
                CupertinoSwitch(
                  value: value,
                  onChanged: readonly ? null : onToggle,
                  activeColor: appColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Application get application => scope.application;
}
