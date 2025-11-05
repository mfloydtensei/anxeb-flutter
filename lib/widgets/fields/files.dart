import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';

import '../../middleware/device.dart';
import '../../middleware/utils.dart';
import '../../screen/scope.dart';
import 'file.dart';

import 'package:anxeb_flutter/helpers/document.dart';
import '../../middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/icons.dart';

class FilesInputField extends FieldWidget<List<FileInputValue>, FilesInputField> {
  final bool allowMultiples;
  final List<String>? allowedExtensions;
  final String? launchUrlPrefix;
  final Future<dynamic> Function({
    String? launchUrl,
    FileInputValue? file,
    bool? readonly,
  })? onPreview;

   FilesInputField({
    required Scope scope,
    Key? key,
    required String name,
    String? group,
    String? label,
    IconData? icon,
    EdgeInsets? margin,
    EdgeInsets? padding,
    bool readonly = false,
    bool visible = true,
    ValueChanged<List<FileInputValue>?>? onSubmitted,
    ValueChanged<List<FileInputValue>?>? onApplied,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    ValueChanged<List<FileInputValue>?>? onChanged,
    FormFieldValidator<List<FileInputValue>?>? validator,
    List<FileInputValue>? Function(List<FileInputValue>?)? parser,
    FieldFocusType? focusType,
    Future<List<FileInputValue>?> Function()? fetcher,
    Function(List<FileInputValue>?)? applier,
    FieldWidgetTheme? theme,
    this.allowMultiples = false,
    this.allowedExtensions,
    this.launchUrlPrefix,
    this.onPreview,
  }) : super(
          scope: scope,
          key: key,
          name: name,
          group: group,
          label: label,
          icon: icon,
          margin: margin,
          padding: padding,
          readonly: readonly,
          visible: visible,
          onSubmitted: onSubmitted,
          onApplied: onApplied,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          onChanged: onChanged,
          validator: validator,
          parser: parser == null ? null : (dynamic v) => parser(v as List<FileInputValue>?),
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  Field<List<FileInputValue>, FilesInputField> createState() => _FilesInputFieldState();
}

class _FilesInputFieldState extends Field<List<FileInputValue>, FilesInputField> {
  final GlobalIcons icons = GlobalIcons();
  final List<FileInputValue> _files = <FileInputValue>[];

  @override
  Future<List<FileInputValue>?> lookup() async {
    // Web
    if (Device.isWeb == true) {
      final dataFiles = await Device.browse<List<PlatformFile>>(
        scope: widget.scope as ScreenScope,
        type: FileType.custom,
        allowMultiple: widget.allowMultiples,
        allowedExtensions: widget.allowedExtensions ?? const ['jpeg', 'jpg', 'png', 'pdf'],
        showBusyOnPicking: false,
        withData: true,
        callback: (files) async => files,
      );

      if (dataFiles == null || dataFiles.isEmpty) return <FileInputValue>[];

      final picked = dataFiles
          .map(
            (e) => FileInputValue(
              data: e.bytes,
              title: p.basename(e.name),
              extension: e.extension,
            ),
          )
          .toList();

      // No acumulamos aquí; dejamos que el submit reemplace si aplica.
      _files
        ..clear()
        ..addAll(picked);

      super.submit(_files);
      return _files;
    }

    // Mobile (Cámara o File Picker)
    final bool? shouldUseCamera =
        await Utils.dialogs.shouldUseCamera(widget.scope, useDocumentLabel: true);

    List<File> pathFiles = <File>[];

    if (shouldUseCamera == true) {
      final picture = await Device.photo(
        scope: widget.scope as ScreenScope,
        title: widget.label ?? '',
        fullImage: true,
        initFaceCamera: false,
        allowMainCamera: true,
        fileName: (widget.label ?? '').toLowerCase().replaceAll(' ', '_'),
        flash: true,
        resolution: ResolutionPreset.high,
      );
      if (picture != null) {
        pathFiles.add(picture);
      }
    } else if (shouldUseCamera == false) {
      final picked = await Device.browse<List<File>>(
        scope: widget.scope as ScreenScope,
        type: FileType.custom,
        allowMultiple: widget.allowMultiples,
        showBusyOnPicking: false,
        allowedExtensions: widget.allowedExtensions ?? const ['jpeg', 'jpg', 'png', 'pdf'],
        callback: (files) async => files.map((f) => File(f.path!)).toList(),
      );
      if (picked != null && picked.isNotEmpty) {
        pathFiles = picked;
      }
    }

    if (pathFiles.isEmpty) return <FileInputValue>[];

    final mapped = pathFiles
        .map(
          (file) => FileInputValue(
            path: file.path,
            title: p.basename(file.path),
            extension: p.extension(file.path).replaceFirst('.', ''),
          ),
        )
        .toList();

    _files
      ..clear()
      ..addAll(mapped);

    super.submit(_files);
    return _files;
  }

  @override
  Widget display([String? text]) {
    final current = value ?? _files;

    if (current.isNotEmpty) {
      return Column(
        children: current
            .map(
              (file) => GestureDetector(
                onTap: () async => _preview(file),
                child: Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 2),
                        child: _getMimeIcon(file),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            file.previewText,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              height: 1,
                              fontSize: 16,
                              color: widget.scope.application.settings.colors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    // Fallback visual cuando no hay archivos aún
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: super.display(widget.label),
    );
  }

  Future<void> _preview(FileInputValue file) async {
    dynamic result;

    if (widget.onPreview != null) {
      result = await widget.onPreview!(
        launchUrl: widget.launchUrlPrefix,
        file: file,
        readonly: widget.readonly,
      );
    } else if (widget.scope is ScreenScope) {
      result = await (widget.scope as ScreenScope).push(
        DocumentView(
          application: (widget.scope as ScreenScope).application,
          launchUrl: widget.launchUrlPrefix ?? '',
          file: file,
          initialScale: PhotoViewComputedScale.contained,
          readonly: widget.readonly,
        ),
      );
    }

    present(); // refresca título/preview si cambió algo

    if (result == false) {
      clear();
    }
  }

  @override
  void clear() {
    _files.clear();
    super.clear();
  }

  Icon _getMimeIcon(FileInputValue value) {
    String ext = value.extension?.toLowerCase() ?? '';
    if (ext.isEmpty) {
      final pth = value.path;
      ext = (pth != null) ? p.extension(pth).replaceFirst('.', '').toLowerCase() : 'txt';
    }
    if (ext.isEmpty) ext = 'txt';

    final meta = icons.getFileMeta(ext);
    return Icon(
      meta.icon ,
      color: meta.color ,
      size: 14,
    );
  }
}
