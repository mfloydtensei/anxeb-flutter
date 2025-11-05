import 'package:flutter/material.dart';

class StatusBlock extends StatefulWidget {
  const StatusBlock({
    super.key,
    this.margin,
    this.padding,
    this.title,
    this.caption,
    this.subcaption,
    this.action,
    this.captionAction,
    this.cancel,
    this.busy = false,
    this.enabled = true,
    this.icon,
    this.iconScale = 1.0,
    this.circleScale = 1.0,
    this.iconColor,
    this.titleColor,
    this.captionColor,
    this.subcaptionColor,
    this.titleSize = 18,
    this.captionSize = 16,
    this.subcaptionSize = 13,
    this.iconBorderWidth = 0,
    this.iconBorderPadding = 0,
    this.controller,
  });

  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final String? title;
  final String? caption;
  final String? subcaption;
  final Future<void> Function()? action;
  final Future<void> Function()? cancel;
  final VoidCallback? captionAction;
  final bool busy;
  final bool enabled;
  final IconData? icon;
  final double iconScale;
  final double circleScale;
  final Color? iconColor;
  final Color? titleColor;
  final Color? captionColor;
  final Color? subcaptionColor;
  final double titleSize;
  final double captionSize;
  final double subcaptionSize;
  final double iconBorderWidth;
  final double iconBorderPadding;
  final StatusBlockController? controller;

  @override
  State<StatusBlock> createState() => _StatusBlockState();
}

class _StatusBlockState extends State<StatusBlock> {
  bool _busy = false;
  bool _enableAction = true;

  @override
  Widget build(BuildContext context) {
    final Color mainColor = widget.iconColor ?? Colors.green;

    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Botón circular con animación
          Container(
            padding: EdgeInsets.all(widget.iconBorderPadding),
            decoration: widget.iconBorderWidth > 0
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(
                      width: widget.iconBorderWidth,
                      color: mainColor.withValues(alpha: 0.7),
                    ),
                  )
                : null,
            child: ClipOval(
              child: Material(
                color: mainColor,
                child: InkWell(
                  splashColor: Colors.white,
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
                              Future.delayed(
                                const Duration(milliseconds: 50),
                                () {
                                  if (mounted) {
                                    setState(() => _enableAction = true);
                                  } else {
                                    _enableAction = true;
                                  }
                                },
                              );
                            }
                          }
                        }
                      : () async => await widget.cancel?.call(),
                  child: SizedBox(
                    width: widget.circleScale * 42.0,
                    height: widget.circleScale * 42.0,
                    child: _buildIcon(mainColor),
                  ),
                ),
              ),
            ),
          ),
          // 🔹 Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              widget.title ?? '',
              style: TextStyle(
                fontSize: widget.titleSize,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.4,
                color: widget.titleColor ?? mainColor,
              ),
            ),
          ),
          // 🔹 Captión y subcaptión (lado derecho)
          Expanded(
            child: Container(
              alignment: Alignment.topRight,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: widget.captionAction,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: _StatusCaption(
                      controller: widget.controller,
                      caption: widget.caption,
                      subcaption: widget.subcaption,
                      captionColor: widget.captionColor,
                      subcaptionColor: widget.subcaptionColor,
                      captionSize: widget.captionSize,
                      subcaptionSize: widget.subcaptionSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(Color mainColor) {
    if (widget.busy || _busy) {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.9)),
        ),
      );
    }

    return AnimatedOpacity(
      opacity: _enableAction ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Icon(
        widget.icon ?? Icons.check_circle,
        size: 30 * widget.iconScale,
        color: Colors.white,
      ),
    );
  }
}

class _StatusCaption extends StatefulWidget {
  const _StatusCaption({
    this.caption,
    this.captionSize,
    this.subcaption,
    this.subcaptionSize,
    this.captionColor,
    this.subcaptionColor,
    this.controller,
  });

  final StatusBlockController? controller;
  final String? caption;
  final double? captionSize;
  final String? subcaption;
  final double? subcaptionSize;
  final Color? captionColor;
  final Color? subcaptionColor;

  @override
  State<_StatusCaption> createState() => _StatusCaptionState();
}

class _StatusCaptionState extends State<_StatusCaption> {
  @override
  void initState() {
    super.initState();
    widget.controller?._onUpdate(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final caption = controller?.caption ?? widget.caption ?? '';
    final subcaption = controller?.subcaption ?? widget.subcaption;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          caption,
          style: TextStyle(
            fontSize: widget.captionSize ?? 18,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: widget.captionColor ?? Colors.green,
          ),
        ),
        if (subcaption != null && subcaption.isNotEmpty)
          Text(
            subcaption,
            style: TextStyle(
              fontSize: widget.subcaptionSize ?? 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
              color: widget.subcaptionColor ?? Colors.green,
            ),
          ),
      ],
    );
  }
}

class StatusBlockController {
  VoidCallback? _callback;
  String? _caption;
  String? _subcaption;

  void _onUpdate(VoidCallback callback) {
    _callback = callback;
  }

  set caption(String? value) {
    _caption = value;
    _callback?.call();
  }

  set subcaption(String? value) {
    _subcaption = value;
    _callback?.call();
  }

  String? get caption => _caption;
  String? get subcaption => _subcaption;
}
