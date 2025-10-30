import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';

class ListTitleBlock extends StatelessWidget {
  final Anxeb.Scope scope;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final bool busy;

  final IconData? icon;
  final EdgeInsets? iconPadding;
  final EdgeInsets? iconTrailPadding;
  final Color? iconColor;
  final double iconScale;
  final double iconSize;

  final IconData? iconAlt;
  final EdgeInsets? iconAltPadding;
  final Color? iconAltColor;
  final double iconAltScale;

  final IconData? iconTrail;
  final Color? iconTrailColor;
  final double iconTrailScale;

  final bool divisor;
  final Color? divisorColor;

  final TextStyle? titleStyle;
  final TextStyle? titleTrailStyle;
  final String? title;
  final TextOverflow titleOverflow;
  final Color? titleColor;
  final String? titleTrail;
  final Widget? titleTrailBody;
  final Color? titleTrailColor;

  final String? subtitle;
  final TextStyle? subtitleStyle;
  final TextOverflow subtitleOverflow;
  final Color? subtitleColor;
  final String? subtitleTrail;
  final TextStyle? subtitleTrailStyle;
  final Color? subtitleTrailColor;
  final Widget? subtitleTrailBody;

  final GestureTapCallback? onTap;
  final GestureTapCallback? onLongPress;
  final Color? splashColor;
  final Color? splashHighlight;
  final Widget? body;
  final Color? fillColor;
  final Decoration? decoration;
  final Color? chipColor;
  final Widget? prefix;

  const ListTitleBlock({
    super.key,
    required this.scope,
    this.padding,
    this.margin,
    this.borderRadius,
    this.busy = false,
    this.icon,
    this.iconPadding,
    this.iconTrailPadding,
    this.iconColor,
    this.iconScale = 1.0,
    this.iconSize = 43.0,
    this.iconAlt,
    this.iconAltPadding,
    this.iconAltColor,
    this.iconAltScale = 1.0,
    this.iconTrail,
    this.iconTrailColor,
    this.iconTrailScale = 1.0,
    this.divisor = false,
    this.divisorColor,
    this.titleStyle,
    this.titleTrailStyle,
    this.title,
    this.titleOverflow = TextOverflow.ellipsis,
    this.titleColor,
    this.titleTrail,
    this.titleTrailBody,
    this.titleTrailColor,
    this.subtitle,
    this.subtitleStyle,
    this.subtitleOverflow = TextOverflow.ellipsis,
    this.subtitleColor,
    this.subtitleTrail,
    this.subtitleTrailStyle,
    this.subtitleTrailColor,
    this.subtitleTrailBody,
    this.onTap,
    this.onLongPress,
    this.splashColor,
    this.splashHighlight,
    this.body,
    this.fillColor,
    this.decoration,
    this.chipColor,
    this.prefix,
  });

  Widget _getMainIcons() {
    final primaryColor = iconColor ?? scope.application.settings.colors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: iconPadding ?? EdgeInsets.zero,
            child: Icon(
              icon,
              size: iconSize * iconScale,
              color: primaryColor,
            ),
          ),
        if (iconAlt != null)
          Padding(
            padding: iconAltPadding ?? EdgeInsets.zero,
            child: Icon(
              iconAlt,
              size: iconSize * iconAltScale,
              color: iconAltColor ?? primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _getBusyIcon(double scale, Color? color) {
    final effectiveColor = color ?? scope.application.settings.colors.primary;
    final baseSize = iconSize * (scale);

    return SizedBox(
      height: baseSize,
      width: baseSize,
      child: Center(
        child: SizedBox(
          height: baseSize * 0.7,
          width: baseSize * 0.7,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(10);

    return Container(
      margin: margin,
      child: Material(
        color: fillColor ?? Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: splashColor,
          highlightColor: splashHighlight,
          borderRadius: radius,
          child: Container(
            decoration: decoration,
            padding: padding ?? const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                prefix ?? const SizedBox.shrink(),
                busy ? _getBusyIcon(iconScale, iconColor) : _getMainIcons(),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Título principal y trailing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title ?? '',
                              overflow: titleOverflow,
                              style: titleStyle ??
                                  TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: titleColor ??
                                        scope.application.settings.colors.primary,
                                  ),
                            ),
                          ),
                          if (titleTrailBody != null)
                            titleTrailBody!
                          else if (titleTrail != null && titleTrail!.isNotEmpty)
                            Text(
                              titleTrail!,
                              textAlign: TextAlign.right,
                              style: titleTrailStyle ??
                                  TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: titleTrailColor ??
                                        scope.application.settings.colors.primary,
                                  ),
                            ),
                        ],
                      ),

                      // 🔹 Línea divisoria opcional
                      if (divisor)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 0.5,
                                color: divisorColor ??
                                    scope.application.settings.colors.separator,
                              ),
                            ),
                          ),
                        ),

                      // 🔹 Subtítulo + trailing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (subtitle != null && subtitle!.isNotEmpty)
                            Container(
                              padding: chipColor != null
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2)
                                  : EdgeInsets.zero,
                              margin: chipColor != null
                                  ? const EdgeInsets.only(top: 2)
                                  : EdgeInsets.zero,
                              decoration: chipColor != null
                                  ? BoxDecoration(
                                      color: chipColor,
                                      borderRadius: BorderRadius.circular(12),
                                    )
                                  : null,
                              child: Text(
                                subtitle!,
                                overflow: subtitleOverflow,
                                style: subtitleStyle ??
                                    TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: subtitleColor ??
                                          scope.application.settings.colors.text,
                                    ),
                              ),
                            ),
                          if (subtitleTrailBody != null)
                            Expanded(child: subtitleTrailBody!)
                          else if (subtitleTrail != null &&
                              subtitleTrail!.isNotEmpty)
                            Expanded(
                              child: Text(
                                subtitleTrail!,
                                textAlign: TextAlign.right,
                                style: subtitleTrailStyle ??
                                    TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: subtitleTrailColor ??
                                          scope.application.settings.colors.text,
                                    ),
                              ),
                            ),
                        ],
                      ),

                      // 🔹 Contenido adicional opcional
                      if (body != null) body!,
                    ],
                  ),
                ),

                // 🔹 Ícono derecho (trail)
                Padding(
                  padding: iconTrailPadding ?? EdgeInsets.zero,
                  child: busy && icon == null
                      ? _getBusyIcon(iconTrailScale, iconTrailColor)
                      : (iconTrail != null
                          ? Icon(
                              iconTrail,
                              size: iconSize * iconTrailScale,
                              color: iconTrailColor ??
                                  scope.application.settings.colors.primary,
                            )
                          : const SizedBox.shrink()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
