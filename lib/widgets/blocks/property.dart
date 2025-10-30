import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class PropertyBlock extends StatefulWidget {
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final EdgeInsets? iconMargin;
  final String label;
  final double? valueScale;
  final double? labelScale;
  final String? value;
  final IconData? icon;
  final bool visible;
  final double? iconScale;
  final Color? iconColor;
  final Color? labelColor;
  final Color? valueColor;
  final bool showOnNull;
  final bool isPhone;
  final bool isEmail;
  final double? iconSize;
  final VoidCallback? onTap;
  final bool cache;

  const PropertyBlock({
    super.key,
    this.margin,
    this.padding,
    this.iconMargin,
    required this.label,
    this.valueScale,
    this.labelScale,
    this.value,
    this.icon,
    this.visible = true,
    this.iconScale,
    this.iconColor,
    this.labelColor,
    this.valueColor,
    this.showOnNull = false,
    this.isPhone = false,
    this.isEmail = false,
    this.iconSize,
    this.onTap,
    this.cache = true,
  });

  @override
  State<PropertyBlock> createState() => _PropertyBlockState();
}

class _PropertyBlockState extends State<PropertyBlock> {
  Widget? _cachedValueWidget;

  @override
  Widget build(BuildContext context) {
    final value = widget.value?.trim() ?? '';
    if (!widget.visible || (value.isEmpty && !widget.showOnNull)) {
      return const SizedBox.shrink();
    }

    if (widget.cache) {
      _cachedValueWidget ??= _buildValueWidget(value);
    } else {
      _cachedValueWidget = _buildValueWidget(value);
    }

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        children: [
          Container(
            margin: widget.iconMargin ?? const EdgeInsets.only(right: 5),
            child: ClipOval(
              child: SizedBox(
                width: 30 * (widget.iconScale ?? 1.0),
                height: 30 * (widget.iconScale ?? 1.0),
                child: Container(
                  color: widget.iconColor ?? Colors.blue,
                  child: Icon(
                    widget.icon ?? Icons.info_outline,
                    size: widget.iconSize ?? (20 * (widget.iconScale ?? 1.0)),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11 * (widget.labelScale ?? 1.0),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: widget.labelColor ?? const Color(0xff444444),
                  ),
                ),
                const SizedBox(height: 4),
                _cachedValueWidget ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Construye el widget del valor (texto o lista de teléfonos)
  Widget _buildValueWidget(String value) {
    if (widget.isPhone) {
      final phones = value.replaceAll(' ', '').split(',');
      if (phones.length > 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: phones.map((phone) {
            return Padding(
              padding: EdgeInsets.only(bottom: phone == phones.last ? 0 : 8),
              child: InkWell(
                onTap: () => _launchValueLink(phone),
                borderRadius: BorderRadius.circular(8),
                child: _buildValueText(phone),
              ),
            );
          }).toList(),
        );
      }
    }

    return InkWell(
      onTap: () => _launchValueLink(value),
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.black12,
      child: _buildValueText(value),
    );
  }

  /// 🔹 Texto estilizado del valor
  Widget _buildValueText(String text) {
    return Text(
      text,
      overflow: TextOverflow.clip,
      style: TextStyle(
        height: 1.1,
        fontSize: 17.5 * (widget.valueScale ?? 1),
        decoration: (widget.isEmail || widget.isPhone)
            ? TextDecoration.underline
            : null,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.1,
        color: widget.valueColor ?? Colors.indigo,
      ),
    );
  }

  /// 🔹 Lanza el enlace correspondiente (teléfono, email o callback)
  Future<void> _launchValueLink(String value) async {
    final uri = widget.isPhone
        ? Uri(scheme: 'tel', path: value)
        : widget.isEmail
            ? Uri(scheme: 'mailto', path: value)
            : null;

    if (uri != null) {
      if (await launcher.canLaunchUrl(uri)) {
        await launcher.launchUrl(uri);
        return;
      }
    }

    widget.onTap?.call();
  }
}
