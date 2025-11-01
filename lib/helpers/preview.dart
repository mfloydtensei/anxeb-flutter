import 'package:anxeb_flutter/middleware/action.dart';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/screen/screen.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/material.dart';
import '../middleware/device.dart';

class ImagePreviewHelper extends ScreenWidget<Application> {
  final String? title;
  final ImageProvider image;
  final bool canRemove;
  final bool fullImage;
  final bool fromCamera;

  const ImagePreviewHelper({
    required Application application,
    this.title,
    required this.image,
    this.canRemove = false,
    this.fullImage = false,
    this.fromCamera = false,
  }) : super(
          'anxeb_preview_helper',
          application: application,
          title: title,
        );

  @override
  ScreenView<ImagePreviewHelper, Application> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends ScreenView<ImagePreviewHelper, Application> {
  late final PhotoViewController _controller;

  @override
  void setup() {
    window.overlay
      ..brightness = Brightness.light
      ..extendBodyFullScreen = true
      ..apply();
  }

  @override
  Future<void> init() async {
    _controller = PhotoViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getLoading() {
    final length = window.horizontal(0.16);
    return Center(
      child: SizedBox(
        height: length,
        width: length,
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor: AlwaysStoppedAnimation<Color>(
            scope.application.settings.colors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget content() {
    final size = scope.window.horizontal(0.90);
    final topPadding = scope.window.vertical(0.1);

    // 🔹 Mostrar imagen completa con PhotoView
    if (widget.fullImage) {
      return PhotoView(
        imageProvider: widget.image,
        tightMode: false,
        gaplessPlayback: true,
        initialScale: PhotoViewComputedScale.covered,
        backgroundDecoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xfff0f0f0), Color(0xffc3c3c3)],
            stops: [0.0, 1.0],
          ),
        ),
        controller: _controller,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.broken_image,
            size: 140,
            color: scope.application.settings.colors.primary.withOpacity(0.2),
          ),
        ),
        loadingBuilder: (_, __) => _getLoading(),
      );
    }

    // 🔹 Mostrar miniatura centrada
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 5),
                blurRadius: 18,
                spreadRadius: 2,
                color: Color(0xaa888888),
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(22.0)),
            image: DecorationImage(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              image: widget.image,
            ),
          ),
        ),
      ),
    );
  }

  @override
  ScreenAction action() {
    return ScreenAction(
      scope: scope,
      color: () => scope.application.settings.colors.secudary,
      // 👇 Siempre devolver IconData (no IconData?)
      icon: () => widget.fromCamera
          ? Icons.image_outlined // valor por defecto si viene de cámara
          : (Device.isAndroid ? Icons.arrow_back : Icons.chevron_left),
      onPressed: () => pop(result: true),
      alternates: [
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          isVisible: () => widget.fromCamera && widget.canRemove,
          icon: () => Icons.delete,
          onPressed: () => pop(result: false),
        ),
      ],
    );
  }
}
