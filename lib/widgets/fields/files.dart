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
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/icons.dart';

class FilesInputField extends FieldWidget<List<FileInputValue>> {
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
    bool? readonly,
    bool? visible,
    ValueChanged<List<FileInputValue>>? onSubmitted,
    ValueChanged<List<FileInputValue>>? onApplied,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    ValueChanged<List<FileInputValue>>? onChanged,
    FormFieldValidator<List<FileInputValue>>? validator,
    List<FileInputValue> Function(dynamic value)? parser,
    FieldFocusType? focusType,
    Future<List<FileInputValue>> Function()? fetcher,
    Function(List<FileInputValue> value)? applier,
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
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  _FilesInputFieldState createState() => _FilesInputFieldState();
}

class _FilesInputFieldState
    extends Field<List<FileInputValue>, FilesInputField> {
  final GlobalIcons icons = GlobalIcons();
  final List<FileInputValue> _files = <FileInputValue>[];

  @override
  Future<List<FileInputValue>> lookup() async {
    if (Device.isWeb) {
      final dataFiles = await Device.browse<List<PlatformFile>>(
        scope: widget.scope,
        type: FileType.custom,
        allowMultiple: widget.allowMultiples,
        allowedExtensions:
            widget.allowedExtensions ?? const ['jpeg', 'jpg', 'png', 'pdf'],
        showBusyOnPicking: false,
        withData: true,
        callback: (files) async => files,
      );

      if (dataFiles.isNotEmpty) {
        return dataFiles
            .map(
              (e) => FileInputValue(
                data: e.bytes,
                title: p.basename(e.name),
                extension: e.extension,
              ),
            )
            .toList();
      }
      return <FileInputValue>[];
    } else {
      final bool shouldUseCamera =
          await Utils.dialogs.shouldUseCamera(widget.scope, useDocumentLabel: true);

      List<File> pathFiles = <File>[];

      if (shouldUseCamera) {
        final picture = await Device.photo(
          scope: widget.scope,
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
      } else {
        final picked = await Device.browse<List<File>>(
          scope: widget.scope,
          type: FileType.custom,
          allowMultiple: widget.allowMultiples,
          showBusyOnPicking: false,
          allowedExtensions:
              widget.allowedExtensions ?? const ['jpeg', 'jpg', 'png', 'pdf'],
          callback: (files) async => files.map((f) => File(f.path)).toList(),
        );
        if (picked.isNotEmpty) {
          pathFiles = picked;
        }
      }

      if (pathFiles.isNotEmpty) {
        _files.addAll(
          pathFiles.map(
            (file) => FileInputValue(
              path: file.path,
              title: p.basename(file.path),
              extension: p.extension(file.path).replaceFirst('.', ''),
              url: null,
              id: null,
            ),
          ),
        );
        super.submit(_files);
        return _files;
      }

      return <FileInputValue>[];
    }
  }

  @override
  Widget display([String? text]) {
    final current = value;
    if (current != null && current.isNotEmpty) {
      return Column(
        children: current
            .map(
              (file) => GestureDetector(
                onTap: () async => _preview(file),
                child: Container(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 4, bottom: 2),
                      ),
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
                              color: widget.scope.application.settings.colors
                                  .primary,
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
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: super.display(widget.label),
    );
  }

  Future<void> _preview(FileInputValue value) async {
    dynamic result;
    if (widget.onPreview != null) {
      result = await widget.onPreview!(
        launchUrl: widget.launchUrlPrefix,
        file: value,
        readonly: widget.readonly,
      );
    } else if (widget.scope is ScreenScope) {
      result = await (widget.scope as ScreenScope).push(
        DocumentView(
          launchUrl: widget.launchUrlPrefix,
          file: value,
          initialScale: PhotoViewComputedScale.contained,
          readonly: widget.readonly,
        ),
      );
    }
    present();
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
    String ext = value.extension ?? '';
    if (ext.isEmpty) {
      final pth = value.path;
      ext = (pth != null) ? p.extension(pth).replaceFirst('.', '') : 'txt';
    }
    if (ext.isEmpty) ext = 'txt';

    final meta = icons.getFileMeta(ext);
    return Icon(
      meta.icon ?? Icons.insert_drive_file,
      color: meta.color ?? const Color(0x88000000),
      size: 12,
    );
  }
}
