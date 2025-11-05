import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../blocks/menu.dart';

class IconButton extends StatefulWidget {
  final bool keyless;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Future<void> Function()? action;
  final Future<void> Function()? cancel;
  final bool busy;
  final bool enabled;
  final IconData? icon;
  final double iconSize;
  final double scale;
  final EdgeInsets? iconPadding;
  final double size;
  final Color? borderColor;
  final Color? fillColor;
  final Color? innerColor;
  final Color? innerBorderColor;
  final double borderWidth;
  final double borderPadding;
  final bool opaque;

  // Context menu
  final double contextMenuItemHeight;
  final double contextMenuIconSize;
  final Offset contextMenuOffset;
  final TextStyle? contextMenuTextStyle;
  final List<ContextMenuItem>? contextMenuItems;
  final Color? contextMenuTextColor;

  // Tooltip
  final Widget? tooltipContent;
  final String? tooltipText;
  final AxisDirection tooltipDirection;
  final double tooltipElevation;
  final double tooltipTailBaseWidth;
  final Color? tooltipFillColor;
  final BorderRadius tooltipBorderRadius;
  final double tooltipOffset;
  final double tooltipTailLength;
  final Duration tooltipFadeDuration;

  // Effects
  final Color? splashColor;
  final Color? hoverColor;

  final bool visible;

  const IconButton({
    super.key,
    this.keyless = false,
    this.margin,
    this.padding,
    this.action,
    this.cancel,
    this.busy = false,
    this.enabled = true,
    this.icon,
    this.iconSize = 30,
    this.scale = 1.0,
    this.iconPadding,
    this.size = 42,
    this.borderColor,
    this.fillColor,
    this.innerColor,
    this.innerBorderColor,
    this.borderWidth = 0,
    this.borderPadding = 0,
    this.opaque = false,
    this.contextMenuItemHeight = 35,
    this.contextMenuIconSize = 20,
    this.contextMenuOffset = const Offset(10, 50),
    this.contextMenuTextStyle,
    this.contextMenuItems,
    this.contextMenuTextColor,
    this.tooltipContent,
    this.tooltipText,
    this.tooltipDirection = AxisDirection.right,
    this.tooltipElevation = 4.0,
    this.tooltipTailBaseWidth = 12.0,
    this.tooltipFillColor,
    this.tooltipBorderRadius = const BorderRadius.all(Radius.circular(6)),
    this.tooltipOffset = 12.0,
    this.tooltipTailLength = 8.0,
    this.tooltipFadeDuration = const Duration(milliseconds: 400),
    this.splashColor,
    this.hoverColor,
    this.visible = true,
  });

  @override
  State<IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<IconButton> {
  bool _busy = false;
  bool _enableAction = true;

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    final fill = widget.fillColor ?? Colors.green;
    final fore = widget.innerColor ?? Colors.white;

    /// Context menu support
    final hasContextMenu = widget.contextMenuItems != null && widget.contextMenuItems!.isNotEmpty;
    final contextMenu = hasContextMenu
        ? PopupMenuButton<Function>(
            icon: Icon(
              widget.icon ?? Icons.more_vert,
              size: widget.iconSize * widget.scale,
              color: fore,
            ),
            offset: widget.contextMenuOffset,
            tooltip: '',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (func) => func.call(),
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context) {
              return widget.contextMenuItems!
                  .where((item) => item.visible != false)
                  .expand((item) {
                final entries = <PopupMenuEntry<Function>>[];
                if (item.divided == true) entries.add(const PopupMenuDivider());
                entries.add(
                  PopupMenuItem<Function>(
                    height: widget.contextMenuItemHeight,
                    onTap: () => item.onTap!(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          child: Icon(
                            item.icon,
                            size: widget.contextMenuIconSize,
                            color: item.color,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            item.label,
                            style: widget.contextMenuTextStyle ??
                                TextStyle(
                                  color: widget.contextMenuTextColor ??
                                      const Color(0xff333333),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                return entries;
              }).toList();
            },
          )
        : null;

    /// Icon content (or loader)
    final iconBody = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Padding(
        padding: widget.iconPadding ?? EdgeInsets.zero,
        child: widget.busy || _busy
            ? const Padding(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : AnimatedOpacity(
                opacity: _enableAction ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: contextMenu ??
                    Icon(
                      widget.icon,
                      size: widget.iconSize * widget.scale,
                      color: fore,
                    ),
              ),
      ),
    );

    /// Clickable body
    final body = ClipOval(
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(50),
        child: widget.enabled
            ? InkWell(
                splashColor: widget.splashColor ?? Colors.white.withValues(alpha: 0.3),
                hoverColor: widget.hoverColor,
                onTap: _enableAction
                    ? () async {
                        setState(() {
                          _busy = true;
                          _enableAction = false;
                        });
                        try {
                          await widget.action?.call();
                        } finally {
                          if (mounted) {
                            setState(() => _busy = false);
                            Future.delayed(const Duration(milliseconds: 50), () {
                              if (mounted) setState(() => _enableAction = true);
                            });
                          }
                        }
                      }
                    : widget.cancel,
                child: iconBody,
              )
            : iconBody,
      ),
    );

    /// Tooltip wrapper (if present)
    final tooltipWrapper = (widget.tooltipContent != null || widget.tooltipText != null)
        ? JustTheTooltip(
            content: widget.tooltipContent ??
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    widget.tooltipText ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            preferredDirection: widget.tooltipDirection,
            elevation: widget.tooltipElevation,
            tailBaseWidth: widget.tooltipTailBaseWidth,
            tailLength: widget.tooltipTailLength,
            backgroundColor: widget.tooltipFillColor ?? Colors.blue,
            borderRadius: widget.tooltipBorderRadius,
            offset: widget.tooltipOffset,
            hoverShowDuration: Duration.zero,
            fadeOutDuration: widget.tooltipFadeDuration,
            enableFeedback: false,
            child: Opacity(opacity: widget.opaque ? 0.6 : 1.0, child: body),
          )
        : Opacity(opacity: widget.opaque ? 0.6 : 1.0, child: body);

    /// Outer container
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(widget.borderPadding),
            decoration: widget.borderWidth > 0
                ? BoxDecoration(
                    color: widget.innerBorderColor,
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(
                      width: widget.borderWidth,
                      color: widget.borderColor ?? widget.fillColor ?? fill,
                    ),
                  )
                : null,
            child: tooltipWrapper,
          ),
        ],
      ),
    );
  }
}
