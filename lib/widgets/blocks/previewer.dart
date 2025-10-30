import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import '../../middleware/application.dart';
import '../../screen/scope.dart';

class PreviewerBlock extends StatefulWidget {
  final ScreenScope scope;
  final File file;
  final PhotoViewComputedScale? initialScale;
  final String? tag;

  const PreviewerBlock({
    super.key,
    required this.scope,
    required this.file,
    this.initialScale,
    this.tag,
  });

  @override
  State<PreviewerBlock> createState() => _PreviewerBlockState();
}

class _PreviewerBlockState extends State<PreviewerBlock> {
  late final PhotoViewControllerBase _imageController;
  final Completer<PDFViewController> _pdfController = Completer<PDFViewController>();

  int _pages = 1;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _imageController = PhotoViewController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isPdf ? _buildPdfPreview() : _buildImagePreview();
  }

  /// 🔹 Vista para archivos PDF
  Widget _buildPdfPreview() {
    return Stack(
      children: [
        PDFView(
          filePath: widget.file.path,
          fitEachPage: true,
          fitPolicy: FitPolicy.WIDTH,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: false,
          preventLinkNavigation: true,
          pageSnap: false,
          onRender: (pages) {
            setState(() => _pages = pages ?? 1);
          },
          onError: (error) {
            widget.scope.alerts.error(error.toString()).show();
          },
          onPageError: (page, error) {
            widget.scope.alerts.error(error.toString()).show();
          },
          onViewCreated: (PDFViewController pdfViewController) {
            if (!_pdfController.isCompleted) {
              _pdfController.complete(pdfViewController);
            }
          },
          onPageChanged: (page, total) {
            setState(() {
              _currentPage = (page ?? 0) + 1;
              _pages = total ?? _pages;
            });
          },
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              '$_currentPage / $_pages',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (widget.tag != null) _buildTag(),
      ],
    );
  }

  /// 🔹 Vista para imágenes
  Widget _buildImagePreview() {
    return Stack(
      children: [
        PhotoView(
          imageProvider: FileImage(widget.file),
          controller: _imageController,
          gaplessPlayback: true,
          backgroundDecoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xfff0f0f0), Color(0xffc3c3c3)],
            ),
          ),
          initialScale: widget.initialScale ?? PhotoViewComputedScale.covered,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.broken_image,
              size: 120,
              color: widget.scope.application.settings.colors.primary.withOpacity(0.25),
            ),
          ),
          loadingBuilder: (context, event) => _buildLoading(),
        ),
        if (widget.tag != null) _buildTag(),
      ],
    );
  }

  /// 🔹 Etiqueta inferior
  Widget _buildTag() {
    final app = widget.scope.application;

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(app.settings.dialogs.dialogRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            widget.tag!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Indicador de carga
  Widget _buildLoading() {
    final app = widget.scope.application;
    final length = widget.scope.window.horizontal(0.16);

    return Center(
      child: SizedBox(
        width: length,
        height: length,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(
            app.settings.colors.primary,
          ),
        ),
      ),
    );
  }

  /// 🔹 Verifica si el archivo es PDF
  bool get _isPdf {
    final path = widget.file.path.toLowerCase();
    final ext = path.split('.').lastOrNull ?? '';
    return ext == 'pdf';
  }
}
