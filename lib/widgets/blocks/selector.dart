import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class SelectorBlock extends StatelessWidget {
  final Anxeb.Scope scope;
  final String? name;
  final double? nameFontSize;
  final String? reference;
  final bool selected;
  final String? tail;
  final String? logoUrl;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool flat;
  final Icon? failedIcon;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const SelectorBlock({
    super.key,
    required this.scope,
    this.name,
    this.nameFontSize,
    this.reference,
    this.selected = false,
    this.tail,
    this.logoUrl,
    this.width,
    this.height,
    this.onTap,
    this.flat = false,
    this.failedIcon,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final app = scope.application;
    final colors = app.settings.colors;

    final captionWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Header con nombre y check
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(bottom: 3),
                margin: const EdgeInsets.only(bottom: 3),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.0,
                      color: colors.separator,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name ?? '',
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: selected ? colors.success : colors.primary,
                          height: 0.9,
                          fontSize: nameFontSize ?? 19,
                          fontWeight:
                              selected ? FontWeight.w500 : FontWeight.w300,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        Icons.check_circle,
                        color: colors.success,
                        size: 22,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // 🔹 Línea inferior con referencia y tail
        Row(
          children: [
            Expanded(
              child: Text(
                (reference ?? '').toUpperCase(),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Text(
              tail ?? '',
              style: TextStyle(
                color: colors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );

    final onlyImage = name == null && reference == null;

    // 🔹 Preparar URL de imagen segura
    final hasUrl = logoUrl != null && logoUrl!.isNotEmpty;
    final fullImageUrl = hasUrl
        ? (logoUrl!.startsWith('http')
            ? logoUrl!
            : app.api.getUri('$logoUrl?webp=80&t=${scope.tick}'))
        : null;

    return Container(
      margin: margin,
      child: Anxeb.ImageButton(
        height: height,
        width: width,
        loadingColor: colors.primary.withOpacity(0.5),
        loadingPadding: const EdgeInsets.all(15),
        imageUrl: fullImageUrl,
        failedIconColor: colors.primary.withOpacity(0.2),
        headers: {'Authorization': 'Bearer ${app.api.token}'},
        outerRadius: 10,
        innerRadius: 5,
        innerPadding:
            flat ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        imagePadding:
            const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        outerFill: flat ? null : Colors.white,
        shadow: flat
            ? null
            : [
                const BoxShadow(
                  offset: Offset(0, 2),
                  blurRadius: 2,
                  spreadRadius: 0,
                  color: Color(0x1f555555),
                )
              ],
        fit: BoxFit.contain,
        shape: BoxShape.rectangle,
        onTap: onTap,
        horizontal: !onlyImage,
        expanded: true,
        margin: const EdgeInsets.symmetric(vertical: 5),
        failedBody: onlyImage
            ? null
            : Row(
                children: [
                  Container(
                    width: width ?? 65,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    child: failedIcon ??
                        const Icon(
                          FontAwesome5.building,
                          size: 40,
                        ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            width: 1.0,
                            color: colors.separator,
                          ),
                        ),
                      ),
                      child: captionWidget,
                    ),
                  ),
                ],
              ),
        body: onlyImage
            ? const SizedBox.shrink()
            : Container(
                padding: padding ??
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 1.0, color: colors.separator),
                  ),
                ),
                child: captionWidget,
              ),
      ),
    );
  }
}
