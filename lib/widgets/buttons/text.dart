import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, link, frame }

enum ButtonSize { normal, small, medium, chip }

const Color _baseColor = Color(0xff2e7db2);
const Color _linkColor = Color(0xff0055ff);

const double _normalSize = 18.0;
const double _smallSize = 16.0;
const double _chipSize = 14.0;
const double _mediumSize = 18.0;

class TextButton extends StatefulWidget {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final String? caption;
  final String? subtitle;
  final IconData? icon;
  final bool swapIcon;
  final List<BoxShadow>? shadow;
  final Color? color;
  final Color? iconColor;
  final Color? textColor;
  final double? fontSize;
  final double? radius;
  final double? iconSize;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool enabled;
  final BorderRadius? borderRadius;
  final bool subtitleUppercase;
  final double? width;
  final TextStyle? textStyle;
  final bool visible;

  const TextButton({
    super.key,
    this.padding,
    this.margin,
    this.caption,
    this.subtitle,
    this.icon,
    this.swapIcon = false,
    this.shadow,
    this.color,
    this.iconColor,
    this.textColor,
    this.fontSize,
    this.radius,
    this.iconSize,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.normal,
    this.enabled = true,
    this.borderRadius,
    this.subtitleUppercase = false,
    this.width,
    this.textStyle,
    this.visible = true,
  });

  @override
  State<TextButton> createState() => _TextButtonState();

  // ----------------------------------------------------------------------
  // FACTORY METHODS
  // ----------------------------------------------------------------------

  static List<Widget> createOptions<V>(
    BuildContext context,
    List<DialogButton<V>> options, {
    V? selectedValue,
    Settings? settings,
  }) {
    final cfg = settings ?? Settings();

    return options
        .where((o) => o.visible != false)
        .map(($option) {
          return Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TextButton(
                    caption: $option.caption,
                    radius: cfg.dialogs.buttonRadius,
                    textColor: $option.textColor ??
                        (selectedValue == $option.value
                            ? cfg.colors.active
                            : null),
                    color: $option.fillColor ??
                        ($option.value == '*'
                            ? cfg.colors.asterisk
                            : ($option.value == ''
                                ? cfg.colors.danger
                                : (selectedValue == $option.value
                                    ? cfg.colors.secudary
                                    : cfg.colors.primary))),
                    icon: $option.icon,
                    swapIcon: $option.swapIcon ?? false,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    onPressed: () {
                      final result = $option.onTap!(context);
                      Navigator.of(context).pop(result);
                    },
                    type: ButtonType.primary,
                    size: ButtonSize.small,
                  ),
                ),
              ],
            ),
          );
        })
        .toList();
  }

  static List<Widget> createMultiOptions<V>(
    BuildContext context,
    List<DialogButton<V>> options, {
    List<V>? selectedValues,
    required Function(DialogButton<V>, bool) onChanged,
  }) {
    selectedValues ??= [];

    return options
        .where((o) => o.visible != false)
        .map(($option) {
          final checked = selectedValues!.contains($option.value);
          return CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.only(left: 4, right: 0),
            visualDensity: VisualDensity.compact,
            title: Text($option.caption),
            value: checked,
            onChanged: (newValue) =>
                onChanged($option, newValue ?? false),
          );
        })
        .toList();
  }

  static List<Widget> createList(
    BuildContext context,
    List<DialogButton> buttons, {
    Settings? settings,
    double? width,
  }) {
    final cfg = settings ?? Settings();

    return buttons
        .where((b) => b.visible != false)
        .map(($button) {
          final btn = TextButton(
            caption: $button.caption,
            radius: cfg.dialogs.buttonRadius,
            icon: $button.icon,
            swapIcon: $button.swapIcon ?? false,
            color: $button.fillColor ?? cfg.colors.primary,
            textColor: $button.textColor ?? Colors.white,
            width: width,
            margin: EdgeInsets.only(
              top: 10,
              left: buttons.first == $button ? 0 : 4,
              right: buttons.last == $button ? 0 : 4,
            ),
            onPressed: () async {
              final result = await $button.onTap!(context);
              if (result != null) Navigator.of(context).pop(result);
            },
            type: ButtonType.primary,
            size: ButtonSize.small,
          );

          final isLast = buttons.last.value == $button.value;

          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: btn,
          );
        })
        .toList();
  }
}

class _TextButtonState extends State<TextButton> {
  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    // Define paddings & font size based on button size
    EdgeInsets padding = widget.padding ?? const EdgeInsets.all(12);
    double fontSize = widget.fontSize ?? _normalSize;

    switch (widget.size) {
      case ButtonSize.chip:
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        fontSize = widget.fontSize ?? _chipSize;
        break;
      case ButtonSize.small:
        padding = const EdgeInsets.all(8);
        fontSize = widget.fontSize ?? _smallSize;
        break;
      case ButtonSize.medium:
        padding = const EdgeInsets.all(10);
        fontSize = widget.fontSize ?? _mediumSize;
        break;
      case ButtonSize.normal:
        break;
    }

    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.radius ?? 30.0);

    // Define colors and text styles
    Color fillColor = widget.color ?? _baseColor;
    TextStyle textStyle = widget.textStyle ??
        TextStyle(
          fontSize: fontSize,
          color: widget.textColor ?? Colors.white,
          fontWeight: FontWeight.normal,
        );
    final subtitleStyle = TextStyle(
      fontSize: fontSize - 5,
      color: (widget.textColor ?? Colors.white).withValues(alpha: 0.9),
      fontWeight: FontWeight.w300,
    );

    ShapeBorder? shape;

    switch (widget.type) {
      case ButtonType.secondary:
        fillColor = widget.color ?? Colors.white.withValues(alpha: 0.5);
        textStyle = textStyle.copyWith(color: widget.textColor ?? Colors.black);
        break;
      case ButtonType.link:
        fillColor = Colors.transparent;
        textStyle = textStyle.copyWith(color: widget.textColor ?? _linkColor);
        padding = const EdgeInsets.all(5);
        break;
      case ButtonType.frame:
        fillColor = Colors.transparent;
        textStyle = textStyle.copyWith(color: widget.textColor ?? Colors.black);
        shape = RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
              color: widget.textColor ?? Colors.black, width: 1.5),
        );
        break;
      case ButtonType.primary:
        break;
    }

    // ---------------------------
    // BUTTON CONTENT
    // ---------------------------
    final buttonContent = Padding(
      padding: padding,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.swapIcon
                ? [
                    Text(widget.caption ?? '', style: textStyle),
                    if (widget.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor ?? Colors.white,
                          size: widget.iconSize ?? 20,
                        ),
                      ),
                  ]
                : [
                    if (widget.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor ?? Colors.white,
                          size: widget.iconSize ?? 20,
                        ),
                      ),
                    Flexible(
                      child: Text(widget.caption ?? '', style: textStyle),
                    ),
                  ],
          ),
          if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                widget.subtitleUppercase
                    ? widget.subtitle!.toUpperCase()
                    : widget.subtitle!,
                textAlign: TextAlign.center,
                style: subtitleStyle,
              ),
            ),
        ],
      ),
    );

    // ---------------------------
    // BUTTON WRAPPER
    // ---------------------------
    final button = widget.enabled
        ? Material(
            color: fillColor,
            shape: shape,
            borderRadius: shape == null ? borderRadius : null,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: borderRadius,
              child: buttonContent,
            ),
          )
        : Opacity(
            opacity: 0.3,
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                boxShadow:
                    widget.type == ButtonType.frame ? null : widget.shadow,
                borderRadius: borderRadius,
              ),
              child: buttonContent,
            ),
          );

    return Container(
      margin: widget.margin,
      width: widget.width,
      decoration: BoxDecoration(
        boxShadow: widget.type == ButtonType.frame ? null : widget.shadow,
        borderRadius: borderRadius,
      ),
      child: button,
    );
  }
}
