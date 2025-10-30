import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/parts/dialogs/message.dart';
import 'package:flutter/material.dart';

class ValueBlock extends StatefulWidget {
  final Scope scope;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool highlight;
  final VoidCallback? onTap;
  final VoidCallback? onPrefixTap;
  final ValueChanged<dynamic>? onNewValue;
  final String? title;
  final String? units;
  final String? caption;
  final bool visible;
  final String? prefix;
  final double? value;
  final bool discrete;
  final MessageDialog? dialog;
  final Color? valueColor;
  final Color? titleColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? separatorColor;
  final double? decimalSize;
  final double? integerSize;
  final String? symbol;
  final double? symbolOffset;
  final List<Widget>? buttons;
  final double? scale;
  final double? titleSize;
  final Widget? icon;
  final BorderRadius? borderRadius;

  const ValueBlock({
    super.key,
    required this.scope,
    this.margin,
    this.padding,
    this.highlight = false,
    this.title,
    this.units,
    this.caption,
    this.visible = true,
    this.prefix,
    this.value,
    this.discrete = false,
    this.dialog,
    this.onNewValue,
    this.onTap,
    this.onPrefixTap,
    this.valueColor,
    this.titleColor,
    this.borderColor,
    this.backgroundColor,
    this.separatorColor,
    this.decimalSize,
    this.integerSize,
    this.symbol,
    this.symbolOffset,
    this.buttons,
    this.scale,
    this.titleSize,
    this.icon,
    this.borderRadius,
  });

  @override
  State<ValueBlock> createState() => _ValueBlockState();
}

class _ValueBlockState extends State<ValueBlock> {
  String get _value {
    return Utils.convert.fromAnyToNumber(
      widget.value,
      decimals: widget.discrete ? 0 : 2,
    );
  }

  String get _integers {
    final value = _value;
    final dotIndex = value.indexOf('.');
    return dotIndex > -1 ? value.substring(0, dotIndex) : value;
  }

  String get _decimals {
    final value = _value;
    final dotIndex = value.indexOf('.');
    return dotIndex > -1 ? value.substring(dotIndex + 1) : '';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final borderRadius =
        widget.borderRadius ?? const BorderRadius.all(Radius.circular(12));
    final scale = widget.scale ?? 1.0;

    // 🔹 Título
    final titleRow = Row(
      children: [
        if (widget.prefix != null)
          GestureDetector(
            onTap: widget.onPrefixTap,
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(
                bottom: 2,
                right: (widget.buttons?.isNotEmpty ?? false) ? 4 : 3,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.7,
                    color: widget.separatorColor ??
                        widget.scope.application.settings.colors.separator,
                  ),
                ),
              ),
              child: Text(
                widget.prefix!.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.titleSize ?? 14,
                  fontWeight: FontWeight.w400,
                  color: widget.titleColor ??
                      widget.scope.application.settings.colors.primary,
                ),
              ),
            ),
          ),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(
              bottom: 2,
              right: (widget.buttons?.isNotEmpty ?? false) ? 4 : 3,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.7,
                  color: widget.separatorColor ??
                      widget.scope.application.settings.colors.separator,
                ),
              ),
            ),
            child: Text(
              (widget.title ?? '').toUpperCase(),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: widget.titleSize ?? 14,
                fontWeight: FontWeight.w400,
                color: widget.titleColor ??
                    widget.scope.application.settings.colors.primary,
              ),
            ),
          ),
        ),
      ],
    );

    // 🔹 Valor
    final valueRow = Row(
      children: [
        if (widget.buttons?.isNotEmpty ?? false)
          Expanded(
            child: Row(children: widget.buttons!),
          ),
        if (widget.symbol != null)
          Container(
            alignment: Alignment.topCenter,
            height: (widget.integerSize ?? 37) * scale,
            padding: EdgeInsets.only(
              right: 3,
              left: (widget.buttons?.isNotEmpty ?? false) ? 2 : 0,
              top: widget.symbolOffset ?? 2,
            ),
            child: Text(
              widget.symbol!,
              style: TextStyle(
                fontSize: (widget.decimalSize ?? 20) * scale,
                letterSpacing: -0.9,
                fontWeight: FontWeight.w400,
                color: widget.valueColor ??
                    widget.scope.application.settings.colors.primary,
              ),
            ),
          ),
        Text(
          _integers,
          style: TextStyle(
            fontSize: (widget.integerSize ?? 39) * scale,
            letterSpacing: -0.9,
            fontWeight: FontWeight.w300,
            color: widget.valueColor ??
                widget.scope.application.settings.colors.primary,
          ),
        ),
        if (_decimals.isNotEmpty)
          Container(
            alignment: Alignment.topCenter,
            height: (widget.integerSize ?? 39) * scale,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              _decimals,
              style: TextStyle(
                fontSize: (widget.decimalSize ?? 24) * scale,
                letterSpacing: -0.9,
                fontWeight: FontWeight.w400,
                color: widget.valueColor ??
                    widget.scope.application.settings.colors.primary,
              ),
            ),
          ),
      ],
    );

    // 🔹 Contenedor principal
    final container = Container(
      margin: widget.margin,
      padding: widget.padding ??
          EdgeInsets.only(top: 5, left: 5, right: 5),
      decoration: BoxDecoration(
        gradient: widget.highlight
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x34ffffff),
                  Color(0x00ffffff),
                ],
                stops: [0.0, 1.0],
              )
            : null,
        border: Border.all(
          color: widget.borderColor ??
              widget.scope.application.settings.colors.separator,
        ),
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: widget.icon,
            ),
          Expanded(
            child: Column(
              children: [titleRow, const SizedBox(height: 2), valueRow],
            ),
          ),
        ],
      ),
    );

    return Material(
      color: widget.backgroundColor ?? Colors.white,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: widget.onTap,
        child: container,
      ),
    );
  }
}
