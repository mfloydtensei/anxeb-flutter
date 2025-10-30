import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/widgets/blocks/paragraph.dart';
import 'package:anxeb_flutter/widgets/components/secured_image.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class ImageButton extends StatefulWidget {
  final bool enabled;
  final Color? splashColor;
  final Color? splashHighlight;
  final IconData? failedIcon;
  final double? failedIconSize;
  final Color? failedIconColor;
  final ImageProvider? imageAsset;
  final String? imageUrl;
  final Map<String, String>? headers;
  final double? width;
  final double? height;
  final double? outerHeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Future<void> Function()? onTap;
  final Function(bool, [ImageInfo?])? onLoaded;
  final double? loadingThickness;
  final Color? loadingColor;
  final EdgeInsets? loadingPadding;
  final double? progressSize;
  final double? imageScale;
  final EdgeInsets? imagePadding;
  final BoxShape? shape;
  final BoxFit? fit;
  final List<BoxShadow>? shadow;
  final String? label;
  final Widget? body;
  final Widget? failedBody;
  final bool autohide;
  final bool horizontal;
  final bool expanded;
  final double? outerRadius;
  final double? outerThickness;
  final Color? outerFill;
  final Color? outerBorderColor;
  final double? innerThickness;
  final EdgeInsets? innerPadding;
  final double? innerRadius;
  final Color? innerBorderColor;
  final ColorFilter? filter;
  final String? tooltip;
  final Color? tooltipFillColor;
  final Color? tooltipTextColor;
  final Widget? tooltipContent;
  final AxisDirection tooltipDirection;
  final double? tooltipOffset;
  final bool replaceFailedWidget;

  const ImageButton({
    super.key,
    this.enabled = true,
    this.splashColor,
    this.splashHighlight,
    this.failedIcon,
    this.failedIconSize,
    this.failedIconColor,
    this.imageAsset,
    this.imageUrl,
    this.headers,
    this.width,
    this.height,
    this.outerHeight,
    this.padding,
    this.margin,
    this.onTap,
    this.onLoaded,
    this.loadingThickness,
    this.loadingColor,
    this.loadingPadding,
    this.progressSize,
    this.imageScale,
    this.imagePadding,
    this.shape,
    this.fit,
    this.shadow,
    this.label,
    this.body,
    this.failedBody,
    this.autohide = false,
    this.horizontal = false,
    this.expanded = false,
    this.outerRadius,
    this.outerThickness,
    this.outerFill,
    this.outerBorderColor,
    this.innerThickness,
    this.innerPadding,
    this.innerRadius,
    this.innerBorderColor,
    this.filter,
    this.tooltip,
    this.tooltipFillColor,
    this.tooltipTextColor,
    this.tooltipContent,
    this.tooltipDirection = AxisDirection.up,
    this.tooltipOffset,
    this.replaceFailedWidget = false,
  });

  @override
  State<ImageButton> createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  bool? _imageLoaded;
  bool _busy = false;
  bool _displayImage = true;
  SecuredImage? _netImage;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null) {
      _setupImage(widget.imageUrl!);
    }
  }

  void _setupImage(String imageUrl) {
    _imageLoaded = null;
    _displayImage = false;

    _netImage = SecuredImage(
      imageUrl,
      scale: widget.imageScale ?? 1,
      headers: widget.headers ?? const <String, String>{},
    );

    _netImage!.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool _) {
          _imageLoaded = true;
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              setState(() => _displayImage = true);
            } else {
              _displayImage = true;
            }
            widget.onLoaded?.call(_imageLoaded!, image);
          });
        },
        onError: (exception, StackTrace? stackTrace) {
          _imageLoaded = false;
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              setState(() => _displayImage = true);
            } else {
              _displayImage = true;
            }
            widget.onLoaded?.call(_imageLoaded!);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_netImage != null && _netImage!.url != widget.imageUrl) {
      if (widget.imageUrl != null) {
        _setupImage(widget.imageUrl!);
      }
    }

    if (widget.autohide && widget.body == null && _imageLoaded != true) {
      return const SizedBox.shrink();
    }

    final emptyWidget = widget.horizontal
        ? Row(
            children: [
              Padding(
                padding: widget.imagePadding ?? EdgeInsets.zero,
                child: SizedBox(height: widget.height, width: widget.width),
              ),
              (widget.expanded
                  ? Expanded(
                      child: Opacity(
                        opacity: 0,
                        child: widget.body ?? const SizedBox(),
                      ),
                    )
                  : Opacity(
                      opacity: 0,
                      child: widget.body ?? const SizedBox(),
                    )),
            ],
          )
        : Column(
            children: [
              Padding(
                padding: widget.imagePadding ?? EdgeInsets.zero,
                child: SizedBox(height: widget.height, width: widget.width),
              ),
              Opacity(opacity: 0, child: widget.body ?? const SizedBox()),
            ],
          );

    final touchWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.enabled
            ? () async {
                setState(() => _busy = true);
                await widget.onTap?.call();
                if (mounted) setState(() => _busy = false);
              }
            : null,
        splashColor: widget.splashColor,
        highlightColor: widget.splashHighlight,
        borderRadius: BorderRadius.circular(widget.outerRadius ?? 100),
        child: Container(
          padding: widget.innerPadding,
          decoration: BoxDecoration(
            shape: widget.shape ?? BoxShape.circle,
            borderRadius: BorderRadius.circular(widget.outerRadius ?? 100),
          ),
          child: emptyWidget,
        ),
      ),
    );

    final failedWidget = _imageLoaded == false
        ? AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _displayImage ? 1 : 0,
            child: widget.failedBody ??
                Icon(
                  widget.failedIcon ?? Icons.broken_image_outlined,
                  size: widget.failedIconSize ?? 40,
                  color: widget.failedIconColor ?? Colors.grey,
                ),
          )
        : null;

    final loadingWidget = _busy
        ? Center(
            child: Container(
              height: widget.height,
              width: widget.width,
              padding: widget.loadingPadding ?? const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: SizedBox(
                height: widget.progressSize ?? 24,
                width: widget.progressSize ?? 24,
                child: CircularProgressIndicator(
                  strokeWidth: widget.loadingThickness ?? 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.loadingColor ?? Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          )
        : null;

    final imageWidget = _imageLoaded == true
        ? AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _displayImage ? 1 : 0,
            child: widget.horizontal
                ? Row(
                    children: [
                      Padding(
                        padding: widget.imagePadding ?? EdgeInsets.zero,
                        child: Container(
                          height: widget.height,
                          width: widget.width,
                          decoration: _buildDecoration(),
                        ),
                      ),
                      widget.expanded
                          ? Expanded(child: widget.body ?? const SizedBox())
                          : (widget.body ?? const SizedBox()),
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                        padding: widget.imagePadding ?? EdgeInsets.zero,
                        child: Container(
                          height: widget.height,
                          width: widget.width,
                          decoration: _buildDecoration(),
                        ),
                      ),
                      widget.body ?? const SizedBox(),
                    ],
                  ),
          )
        : null;

    final button = Container(
      padding: widget.padding,
      margin: widget.margin,
      height: widget.outerHeight,
      child: failedWidget != null && widget.replaceFailedWidget
          ? failedWidget
          : Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        boxShadow: widget.shadow,
                        shape: widget.shape ?? BoxShape.circle,
                        borderRadius:
                            BorderRadius.circular(widget.outerRadius ?? 100),
                        border: Border.all(
                          width: widget.outerThickness ?? 0,
                          color: widget.outerBorderColor ?? Colors.transparent,
                        ),
                        color: widget.outerFill ?? Colors.transparent,
                      ),
                      child: Container(
                        padding: widget.innerPadding,
                        child: imageWidget ?? emptyWidget,
                      ),
                    ),
                    if (widget.label != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: ParagraphBlock(
                          text: widget.label!,
                          bold: widget.enabled,
                        ),
                      ),
                  ],
                ),
                failedWidget ?? const SizedBox(),
                touchWidget,
                loadingWidget ?? const SizedBox(),
              ],
            ),
    );

    if (widget.tooltip != null || widget.tooltipContent != null) {
      return JustTheTooltip(
        content: Padding(
          padding: const EdgeInsets.all(6),
          child: widget.tooltipContent ??
              Text(
                widget.tooltip!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: widget.tooltipTextColor ?? Colors.white,
                ),
              ),
        ),
        preferredDirection: widget.tooltipDirection,
        elevation: 4.0,
        tailBaseWidth: 12,
        tailLength: 8,
        backgroundColor: widget.tooltipFillColor ?? Colors.black87,
        borderRadius: BorderRadius.circular(6),
        offset: widget.tooltipOffset ?? 12.0,
        hoverShowDuration: Duration.zero,
        fadeOutDuration: const Duration(milliseconds: 500),
        enableFeedback: false,
        child: button,
      );
    }

    return button;
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      shape: widget.shape ?? BoxShape.circle,
      borderRadius: BorderRadius.circular(widget.innerRadius ?? 100),
      border: Border.all(
        width: widget.innerThickness ?? 0,
        color: widget.innerBorderColor ?? Colors.transparent,
      ),
      image: (widget.imageAsset != null || _netImage != null)
          ? DecorationImage(
              colorFilter: widget.filter ??
                  (widget.enabled
                      ? null
                      : ColorFilter.mode(
                          Colors.black.withOpacity(0.9),
                          BlendMode.screen,
                        )),
              fit: widget.fit ?? BoxFit.cover,
              alignment: Alignment.center,
              image: _netImage ?? widget.imageAsset!,
            )
          : null,
    );
  }
}
