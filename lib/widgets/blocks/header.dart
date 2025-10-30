import 'package:flutter/material.dart';

const Color _defaultHeaderColor = Color(0xff195279);
const Color _defaultSubtitleColor = Color(0xff444444);

class HeaderBlock extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String? title;
  final EdgeInsets? padding;
  final String? subtitle;
  final TextAlign? titleAlign;
  final TextAlign? bodyAlign;
  final List<TextSpan>? body;

  const HeaderBlock({
    super.key,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.title,
    this.padding,
    this.subtitle,
    this.titleAlign,
    this.bodyAlign,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final rh = MediaQuery.of(context).size.height;

    final effectiveIconColor = iconColor ?? _defaultHeaderColor;
    final effectiveIconSize = iconSize ?? rh * 0.16;
    final effectiveTitleAlign = titleAlign ?? TextAlign.center;
    final effectiveBodyAlign = bodyAlign ?? TextAlign.justify;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(bottom: rh * 0.003),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: effectiveIconSize,
              ),
            ),

          if (title != null && title!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: rh * 0.008),
              child: Text(
                title!,
                textAlign: effectiveTitleAlign,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: _defaultHeaderColor,
                ),
              ),
            ),

          if (subtitle != null && subtitle!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: rh * 0.005),
              child: Text(
                subtitle!,
                textAlign: effectiveBodyAlign,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                  color: _defaultSubtitleColor,
                ),
              ),
            ),

          if (body != null && body!.isNotEmpty)
            RichText(
              textAlign: effectiveBodyAlign,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                  color: _defaultSubtitleColor,
                ),
                children: body!,
              ),
            ),
        ],
      ),
    );
  }
}
