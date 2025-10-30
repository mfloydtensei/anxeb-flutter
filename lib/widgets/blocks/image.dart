import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/widgets/components/secured_image.dart';
import 'package:flutter/material.dart';

class ImageLinkBlock extends StatefulWidget {
  final IconData? failedIcon;
  final double? failedIconSize;
  final Color? failedIconColor;
  final String? url;
  final Map<String, String>? headers;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? loadingThickness;
  final Color? loadingColor;
  final EdgeInsets? loadingPadding;
  final double? progressSize;
  final double? imageScale;
  final BoxShape? shape;
  final BoxFit? fit;
  final List<BoxShadow>? shadow;

  const ImageLinkBlock({
    super.key,
    this.failedIcon,
    this.failedIconSize,
    this.failedIconColor,
    this.url,
    this.headers,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.loadingThickness,
    this.loadingColor,
    this.loadingPadding,
    this.progressSize,
    this.imageScale,
    this.shape,
    this.fit,
    this.shadow,
  });

  @override
  State<ImageLinkBlock> createState() => _ImageLinkBlockState();
}

class _ImageLinkBlockState extends State<ImageLinkBlock> {
  bool _imageLoaded = false;
  bool _busy = true;
  bool _displayImage = false;
  SecuredImage? _netImage;

  @override
  void initState() {
    super.initState();
    if (widget.url != null && widget.url!.isNotEmpty) {
      _setupImage(widget.url!);
    } else {
      _imageLoaded = false;
      _busy = false;
    }
  }

  void _setupImage(String imageUrl) {
    _busy = true;
    _imageLoaded = false;
    _displayImage = false;

    _netImage = SecuredImage(
      imageUrl,
      scale: widget.imageScale ?? 1,
      headers: widget.headers,
    );

    _netImage!.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (imageInfo, _) {
          if (!mounted) return;
          setState(() {
            _imageLoaded = true;
            _busy = false;
            _displayImage = true;
          });
        },
        onError: (exception, stackTrace) {
          debugPrint('ImageLinkBlock error: $exception');
          if (!mounted) return;
          setState(() {
            _imageLoaded = false;
            _busy = false;
            _displayImage = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_netImage != null && widget.url != _netImage!.url && widget.url != null) {
      _setupImage(widget.url!);
    }

    // 🔹 Imagen cargada correctamente
    final imageWidget = _imageLoaded
        ? AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _displayImage ? 1 : 0,
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                shape: widget.shape ?? BoxShape.rectangle,
                image: DecorationImage(
                  fit: widget.fit ?? BoxFit.cover,
                  alignment: Alignment.center,
                  image: _netImage!,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    // 🔹 Estado de error
    final failedWidget = (!_busy && !_imageLoaded)
        ? AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _displayImage ? 1 : 0,
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: Icon(
                widget.failedIcon ?? Icons.broken_image_outlined,
                color: widget.failedIconColor ?? Colors.white.withOpacity(0.5),
                size: widget.failedIconSize ??
                    ((widget.height ?? widget.width ?? 40) * 0.6),
              ),
            ),
          )
        : const SizedBox.shrink();

    // 🔹 Estado de carga
    final loadingWidget = _busy
        ? Center(
            child: Padding(
              padding: widget.loadingPadding ?? const EdgeInsets.all(10),
              child: SizedBox(
                height: widget.progressSize ?? 28,
                width: widget.progressSize ?? 28,
                child: CircularProgressIndicator(
                  strokeWidth: widget.loadingThickness ?? 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.loadingColor ?? Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              boxShadow: widget.shadow,
              shape: widget.shape ?? BoxShape.rectangle,
            ),
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: imageWidget,
            ),
          ),
          failedWidget,
          loadingWidget,
        ],
      ),
    );
  }
}
