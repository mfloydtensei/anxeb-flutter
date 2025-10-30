import 'package:flutter/material.dart';

const Color _baseColor = Color(0xff2e7db2);

class ChipButton extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color? fillColor;
  final Color? textColor;
  final bool? disabled;
  final EdgeInsets? margin;
  final IconData? icon;

  final BorderRadius borderRadius;

  const ChipButton({
    super.key,
    this.text,
    this.onPressed,
    this.fillColor,
    this.textColor,
    this.disabled,
    this.margin,
    this.icon,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
  });

  @override
  State<ChipButton> createState() => _ChipButtonState();
}

class _ChipButtonState extends State<ChipButton> {
  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled ?? false;
    final effectiveFill = widget.fillColor ?? _baseColor;
    final effectiveTextColor = widget.textColor ?? Colors.white;

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                widget.icon,
                color: effectiveTextColor,
                size: 14,
              ),
            ),
          Flexible(
            child: Text(
              widget.text ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: effectiveTextColor,
              ),
            ),
          ),
        ],
      ),
    );

    // Estado deshabilitado
    if (isDisabled) {
      return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: effectiveFill.withOpacity(0.5),
          borderRadius: widget.borderRadius,
        ),
        child: body,
      );
    }

    // Estado normal con interacción
    return Container(
      margin: widget.margin,
      child: Material(
        color: effectiveFill,
        borderRadius: widget.borderRadius,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: widget.borderRadius,
          splashColor: Colors.white.withOpacity(0.2),
          child: body,
        ),
      ),
    );
  }
}
