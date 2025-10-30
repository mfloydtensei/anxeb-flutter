import 'package:anxeb_flutter/middleware/api.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';

class PhotoBlock extends StatefulWidget {
  final Anxeb.Scope scope;
  final String url;
  final int? tick;
  final Api? api;
  final double? width;
  final double? height;
  final int? quality;
  final ColorFilter? filter;
  final BorderRadius? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? fill;
  final BoxFit? fit;
  final Alignment alignment;
  final Icon? failIcon;
  final ValueChanged<bool>? onTap;
  final Widget? failWidget;
  final Widget? absoluteFailWidget;
  final Color? progressColor;
  final double? progressSize;
  final bool ignoreFailIcon;

  const PhotoBlock({
    super.key,
    required this.scope,
    required this.url,
    this.tick,
    this.api,
    this.width,
    this.height,
    this.quality,
    this.filter,
    this.border,
    this.padding,
    this.margin,
    this.fill,
    this.fit,
    this.alignment = Alignment.center,
    this.failIcon,
    this.onTap,
    this.failWidget,
    this.absoluteFailWidget,
    this.progressColor,
    this.progressSize,
    this.ignoreFailIcon = false,
  });

  @override
  State<PhotoBlock> createState() => _PhotoBlockState();
}

class _PhotoBlockState extends State<PhotoBlock> {
  Anxeb.SecuredImage? _netImage;
  bool? _imageLoaded;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _setupImage();
  }

  @override
  void didUpdateWidget(PhotoBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.tick != widget.tick) {
      _setupImage();
    }
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  void _removeListener() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
  }

  void _setLoadedState(bool? value) {
    if (mounted) {
      setState(() => _imageLoaded = value);
    } else {
      _imageLoaded = value;
    }
  }

  void _setupImage() {
    _removeListener();
    _setLoadedState(null);

    final api = widget.api ?? widget.scope.application.api;
    String url = widget.url.startsWith('http')
        ? widget.url
        : api.getUri(widget.url);

    // Se agregan parámetros de cache-busting y calidad
    url += (url.contains('?') ? '&' : '?') +
        'webp=${widget.quality ?? 60}&width=${widget.width?.toInt() ?? 300}&tick=${widget.tick ?? 1}';

    _netImage = Anxeb.SecuredImage(
      url,
      scale: 1,
      headers: {'Authorization': 'Bearer ${api.token}'},
    );

    _stream = _netImage!.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (ImageInfo image, bool _) => _setLoadedState(true),
      onError: (exception, stackTrace) => _setLoadedState(false),
    );

    _stream!.addListener(_listener!);
  }

  @override
  Widget build(BuildContext context) {
    final isError = _imageLoaded == false;
    final isLoaded = _imageLoaded == true;
    final isLoading = _imageLoaded == null;

    if (isError && widget.absoluteFailWidget != null) {
      return widget.absoluteFailWidget!;
    }

    final decoration = isLoaded
        ? BoxDecoration(
            borderRadius: widget.border,
            color: widget.fill,
            image: DecorationImage(
              colorFilter: widget.filter,
              fit: widget.fit ?? BoxFit.contain,
              alignment: widget.alignment,
              image: _netImage!,
            ),
          )
        : null;

    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      padding: widget.padding,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Imagen cargada
          AnimatedOpacity(
            opacity: isLoaded ? 1.0 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(decoration: decoration),
          ),

          // Cargando
          if (isLoading)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                width: widget.progressSize ?? 48,
                height: widget.progressSize ?? 48,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.progressColor ??
                        widget.scope.application.settings.colors.primary,
                  ),
                ),
              ),
            ),

          // Error
          if (isError)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: widget.failWidget ??
                  (widget.ignoreFailIcon
                      ? const SizedBox.shrink()
                      : Center(
                          child: widget.failIcon ??
                              const Icon(
                                Icons.broken_image,
                                color: Colors.black12,
                                size: 90,
                              ),
                        )),
            ),

          // Overlay interactivo
          Material(
            color: Colors.transparent,
            borderRadius: widget.border,
            child: InkWell(
              onTap: () => widget.onTap?.call(isError),
              highlightColor: Colors.transparent,
              splashColor: Colors.black12,
              borderRadius: widget.border,
            ),
          ),
        ],
      ),
    );
  }
}
