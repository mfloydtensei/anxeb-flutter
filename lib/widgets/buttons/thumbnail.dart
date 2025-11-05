import 'dart:typed_data';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:anxeb_flutter/misc/icons.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../../middleware/application.dart';

class ThumbnailButton extends StatefulWidget {
  final Anxeb.Scope scope;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTap;
  final Uint8List? bytes;
  final String? previewUrl;
  final String? title;
  final String? subtitle;
  final String? extension;
  final DateTime? modifiedDate;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final String? toolTipTag;

  const ThumbnailButton({
    super.key,
    required this.scope,
    this.onTap,
    this.onDeleteTap,
    this.bytes,
    this.previewUrl,
    this.title,
    this.subtitle,
    this.extension,
    this.modifiedDate,
    this.borderRadius,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.toolTipTag,
  });

  @override
  State<ThumbnailButton> createState() => _ThumbnailButtonState();
}

class _ThumbnailButtonState extends State<ThumbnailButton> {
  ImageProvider? _netImage;
  bool? _imageLoaded;
  final GlobalIcons _icons = GlobalIcons();

  @override
  void initState() {
    super.initState();
    _setupImage();
  }

  @override
  Widget build(BuildContext context) {
    final meta = _icons.getFileMeta(widget.extension ?? '');
    final appColors = widget.scope.application.settings.colors;
    final borderRadius =
        widget.borderRadius ?? const BorderRadius.all(Radius.circular(12.0));

    // Ícono o imagen por defecto
    Widget defaultIcon;
    if (meta.image == false) {
      defaultIcon = Icon(
        meta.icon,
        color: meta.color,
        size: 28,
      );
    } else if (_imageLoaded == null) {
      defaultIcon = const SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    } else if (_netImage == null) {
      defaultIcon = Icon(Icons.image, color: appColors.primary, size: 28);
    } else {
      defaultIcon = const SizedBox.shrink();
    }

    final stack = Stack(
      children: [
        // Imagen de fondo
        AnimatedOpacity(
          opacity: _imageLoaded == true ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              image: _netImage != null
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: _netImage!,
                      alignment: Alignment.center,
                    )
                  : null,
            ),
          ),
        ),

        // Gradiente inferior para overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.5, 1],
              colors: [
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: 0.0),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 10),
            child: defaultIcon,
          ),
        ),

        // Capa táctil
        Material(
          color: appColors.navigation.withValues(alpha: 0.1),
          borderRadius: borderRadius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: borderRadius,
          ),
        ),

        // Contenido textual + tooltip + eliminar
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 10, right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: JustTheTooltip(
                            content: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (widget.toolTipTag != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Anxeb.CommunityMaterialIcons.tag,
                                          size: 9,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.toolTipTag!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (widget.subtitle != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Anxeb.CommunityMaterialIcons.database,
                                          size: 9,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.subtitle!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (widget.modifiedDate != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_filled_outlined,
                                          size: 9,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          Anxeb.Utils.convert
                                              .fromDateToHumanString(
                                                  widget.modifiedDate!,
                                                  complete: true),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            preferredDirection: AxisDirection.up,
                            elevation: 4.0,
                            tailBaseWidth: 12,
                            tailLength: 8,
                            backgroundColor: appColors.primary,
                            borderRadius: BorderRadius.circular(6),
                            offset: 12,
                            hoverShowDuration: Duration.zero,
                            fadeOutDuration:
                                const Duration(milliseconds: 500),
                            enableFeedback: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: meta.image == true &&
                                            _imageLoaded == true
                                        ? Colors.white
                                        : appColors.primary,
                                  ),
                                ),
                                if (widget.subtitle != null)
                                  Text(
                                    widget.subtitle!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      height: 1.15,
                                      color: meta.image == true &&
                                              _imageLoaded == true
                                          ? Colors.white
                                          : appColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.onDeleteTap != null)
                          Anxeb.IconButton(
                            icon: Icons.delete,
                            iconSize: 18,
                            innerColor: appColors.danger,
                            fillColor: Colors.transparent,
                            borderWidth: 0,
                            borderPadding: 0,
                            size: 20,
                            action: () async => widget.onDeleteTap!(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      margin: widget.margin,
      child: stack,
    );
  }

  void _setupImage() {
    final meta = _icons.getFileMeta(widget.extension ?? '');

    if (meta.image == true) {
      if (widget.bytes != null) {
        _netImage = Image.memory(widget.bytes!).image;
        _imageLoaded = true;
      } else if (widget.previewUrl != null) {
        _netImage = Anxeb.SecuredImage(
          application.api.getUri(widget.previewUrl!),
          headers: application.api.token != null
              ? <String, String>{'Authorization': 'Bearer ${application.api.token}'}
              : <String, String>{},
          scale: 1,
        );
        _imageLoaded = null;

        _netImage!.resolve(const ImageConfiguration()).addListener(
              ImageStreamListener((_, __) {
                if (mounted) setState(() => _imageLoaded = true);
              }, onError: (_, __) {
                if (mounted) setState(() => _imageLoaded = false);
              }),
            );
      }
    } else {
      _netImage = null;
      _imageLoaded = null;
    }
  }

  Application get application => widget.scope.application;
}
