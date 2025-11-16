import 'dart:async';
import 'dart:io';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/screen/screen.dart';
import 'package:anxeb_flutter/misc/action_menu.dart';
import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:anxeb_flutter/widgets/blocks/empty.dart';
import 'package:anxeb_flutter/widgets/fields/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path/path.dart' as Path;
import 'package:photo_view/photo_view.dart';
//import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as Launcher;

class DocumentView extends ScreenWidget<Application> {
  final FileInputValue file;
  final String? launchUrl;
  final bool readonly;
  final Future<void> Function(FileInputValue?)? updated;
  final String? tag;
  final PhotoViewComputedScale? initialScale;

  DocumentView({
  required Application application,
  required this.file,
  this.launchUrl,
  this.readonly = true,
  this.updated,
  this.tag,
  this.initialScale,
}) : super(
        'anxeb_document_helper',
        application: application,
        title: file.title ?? translate('anxeb.helpers.document.title'),
      );
  
  @override
  ScreenView<DocumentView, Application> createState() => _DocumentState();
}

class _DocumentState extends ScreenView<DocumentView, Application> {
  late final PhotoViewController _controller;
  File? _data;
  bool _refreshing = false;
  PDFView? _pdfFileAlt;
  late Completer<PDFViewController> _controllerAlt;
  int _pages = 1;
  int _currentPage = 1;

  @override
  Future init() async {
    _controller = PhotoViewController();
    _controllerAlt = Completer<PDFViewController>();
    await _refresh();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void setup() {}

  @override
  void prebuild() {}

  @override
  ActionsHeader header() {
    return ActionsHeader(
      scope: scope,
      title: () => Text(
        widget.file.title ?? translate('anxeb.helpers.document.title'),
      ),
      actions: [
        ActionMenu(actions: [
          ActionMenuItem(
            caption: () => translate('anxeb.helpers.document.menu.reload_file'),
            icon: () => Icons.refresh,
            onPressed: _refresh,
          ),
          ActionMenuItem(
            caption: () =>
                translate('anxeb.helpers.document.menu.change_title'),
            icon: () => Icons.text_fields,
            onPressed: _changeTitle,
            isVisible: () =>
                widget.readonly != true && widget.file.id != null,
          ),
          ActionMenuItem(
            caption: () =>
                translate('anxeb.helpers.document.menu.open_browser'),
            icon: () => Icons.launch,
            isVisible: () => widget.file.url != null,
            onPressed: _launch,
          ),
          ActionMenuItem(
            caption: () => translate('anxeb.helpers.document.menu.share'),
            icon: () => Icons.share,
            isVisible: () => widget.file.url != null,
            onPressed: _share,
          ),
          ActionMenuItem(
            caption: () =>
                translate('anxeb.helpers.document.menu.download_browser'),
            icon: () => Icons.file_download,
            isVisible: () => widget.file.url != null,
            onPressed: _download,
          ),
          ActionMenuItem(
            caption: () =>
                translate('anxeb.helpers.document.menu.delete_file'),
            icon: () => Icons.close,
            divided: () => true,
            color: () => scope.application.settings.colors.danger,
            onPressed: _removeFile,
            isVisible: () =>
                widget.readonly != true && widget.file.url != null,
          ),
        ]),
      ],
    );
  }

  @override
  Widget content() {
    if (_refreshing && _data == null) {
      return _getLoading();
    } else if (!_refreshing && _data == null) {
      return EmptyBlock(
        scope: scope,
        message:
            translate('anxeb.helpers.document.content.error_loading_file'),
        icon: Icons.cloud_off,
        actionText: translate('anxeb.helpers.document.content.refresh'),
        actionCallback: _refresh,
      );
    }

    if (_isImage) {
      return Stack(
        children: [
          PhotoView(
            imageProvider: FileImage(_data!),
            gaplessPlayback: true,
            backgroundDecoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xfff0f0f0), Color(0xffc3c3c3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            controller: _controller,
            initialScale: widget.initialScale ?? PhotoViewComputedScale.covered,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.broken_image,
                size: 140,
                color: application.settings.colors.primary.withValues(alpha: 0.2),
              ),
            ),
            loadingBuilder: (_, __) => _getLoading(),
          ),
          if (widget.tag != null) _getTag(),
        ],
      );
    }

    return Stack(
      children: [
        _pdfFileAlt ?? const SizedBox(),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              '$_currentPage / $_pages',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16),
            ),
          ),
        ),
        if (widget.tag != null) _getTag(),
      ],
    );
  }

  Widget _getTag() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(
              scope.application.settings.dialogs.dialogRadius ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        margin: const EdgeInsets.only(bottom: 10),
        child: Text(
          widget.tag ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 22,
          ),
        ),
      ),
    );
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

  void _share() {
    final title = widget.file.title ?? '';
    //final msg =
        '${translate('anxeb.helpers.document.dialog.shared_file')}\n\n$title';
   // final mime = _isPdf ? 'application/pdf' : 'image/${widget.file.extension}';
    final ext = _isPdf ? '.pdf' : '.${widget.file.extension}';
    final haveExt = Path.extension(_data!.path).isNotEmpty;
    final newFileName =
        Path.join(Path.dirname(_data!.path), '$title${haveExt ? '' : ext}');
    _data!.copy(newFileName);

    final box = scope.context.findRenderObject() as RenderBox?;
    if (box != null) {
      //Share.shareFiles(
        //[newFileName],
        //mimeTypes: [mime],
        //text: msg,
        //subject: title,
        //sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      //);
    }
  }

  Future<void> _launch({bool download = false}) async {
    final option = download ? 'download' : 'open';
    final url = '${widget.launchUrl}${widget.file.url}/$option';

    final uri = Uri.tryParse(url);
    if (uri != null && await Launcher.canLaunchUrl(uri)) {
      await Launcher.launchUrl(uri);
    } else {
      scope.alerts
          .error(translate('anxeb.helpers.document.dialog.error_launching_file'))
          .show();
    }
  }

  void _download() => _launch(download: true);

  Future<void> _refresh() async {
    setState(() {
      _data = null;
      _pdfFileAlt = null;
      _controllerAlt = Completer<PDFViewController>();
      _refreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      setState(() => _data = File(widget.file.path!));
      if (_data == null) return;

      if (_isPdf) {
        setState(() {
          _pdfFileAlt = PDFView(
            filePath: _data!.path,
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
            onError: (error) => scope.alerts.error(error).show(),
            onPageError: (_, error) => scope.alerts.error(error).show(),
            onViewCreated: (controller) => _controllerAlt.complete(controller),
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = (page ?? 0) + 1;
                _pages = total ?? _pages;
              });
            },
          );
        });
      }
    } catch (err) {
      scope.alerts.error(err).show();
    }

    setState(() => _refreshing = false);
  }

  Future<void> _removeFile() async {
    final result = await scope.dialogs
        .confirm(translate('anxeb.helpers.document.dialog.delete_confirmation'))
        .show();
    if (result == true) {
      try {
        if (widget.file.url == null) {
          scope.alerts
              .error(translate('anxeb.helpers.document.dialog.error_no_file_url'))
              .show();
          return;
        }
        await scope.busy();
        await scope.api.delete(widget.file.url!);
        await widget.updated?.call(null);
        pop(force: true);
      } catch (err) {
        scope.alerts.error(err).show();
      } finally {
        await scope.idle();
      }
    }
  }

  Future<void> _changeTitle() async {
   final title = await scope.dialogs.prompt(
      translate('anxeb.helpers.document.dialog.new_title'),
      hint: translate('anxeb.helpers.document.dialog.title'),
      value: widget.file.title,
      icon: Icons.text_fields,
);

    if (title != null && title != widget.file.title) {
      setState(() => widget.file.title = title);
      try {
        await scope.busy();
        await scope.api.post(widget.file.url!, {
          'file': {'id': widget.file.id, 'title': widget.file.title}
        });
        await widget.updated?.call(widget.file);
      } catch (err) {
        scope.alerts.error(err).show();
      } finally {
        await scope.idle();
      }
    }
  }

  bool get _isImage => widget.file.isImage;

  bool get _isPdf => widget.file.extension == 'pdf';
}
