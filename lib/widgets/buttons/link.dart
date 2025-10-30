import 'package:flutter/material.dart';

class LinkButton extends StatelessWidget {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final VoidCallback? onPressed;
  final TextAlign? textAlign;
  final TextStyle? style;

  const LinkButton({
    super.key,
    this.margin,
    this.padding,
    this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.onPressed,
    this.textAlign,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveText = text ?? '';
    final effectiveStyle = style ??
        TextStyle(
          color: color ?? Colors.blue,
          fontSize: fontSize ?? 17,
          fontWeight: fontWeight ?? FontWeight.w300,
          decoration: TextDecoration.underline,
        );

    return MouseRegion(
      cursor: onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Container(
        margin: margin,
        padding: padding,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.translucent,
          child: Text(
            effectiveText,
            textAlign: textAlign ?? TextAlign.start,
            style: effectiveStyle,
          ),
        ),
      ),
    );
  }
}
