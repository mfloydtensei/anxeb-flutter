import 'dart:io';
import 'dart:typed_data';
import 'package:anxeb_flutter/helpers/document.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/icons.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import '../../middleware/device.dart';
import '../../middleware/utils.dart';
import '../../screen/scope.dart';

class FileInputValue {
  final String? url;
  final String? path;
  final String? extension;
  final Uint8List? data;
  String? title;
  String? id;
  bool useFullUrl;

  FileInputValue({
    this.url,
    this.path,
    this.title,
    this.extension,
    this.data,
    this.id,
    this.useFullUrl = false,
  });

  bool get isImage => ['jpg', 'png', 'jpeg'].contains(extension?.toLowerCase());

  String get previewText => title ?? basename(path ?? '');

  Map<String, dynamic> toJSON() {
    return {'title': title, 'extension': extension};
  }
}

class FileInputField extends FieldWidget<FileInputValue> {
  final List<String>? allowedExtensions;
  final String? launchUrlPrefix;
  final Future Function({
    String? launchUrl,
    FileInputValue? file,
    bool? readonly,
  })? onPreview;

   FileInputField({
    required Scope scope,
    required String name,
    super.key,
    String? group,
    String? label,
    IconData? icon,
    EdgeInsets? margin,
    EdgeInsets? padding,
    bool readonly = false,
    bool visible = true,
    ValueChanged<FileInputValue?>? onSubmitted,
    ValueChanged<FileInputValue?>? onApplied,
    ValueChanged<FileInputValue?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    FormFieldValidator<FileInputValue?>? validator,
    FileInputValue? Function(FileInputValue?)? parser,
    FieldFocusType? focusType,
    Future<FileInputValue?> Function()? fetcher,
    Function(FileInputValue?)? applier,
    FieldWidgetTheme? theme,
    this.allowedExtensions,
    this.launchUrlPrefix,
    this.onPreview,
  }) : super(
          scope: scope,
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
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser == null ? null : (dynamic v) => parser(v as FileInputValue?),
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  Field<FileInputValue, FileInputField> createState() => _FileInputFieldState();
}

class _FileInputFieldState extends Field<FileInputValue, FileInputField> {
  String? _previewText;
  final GlobalIcons icons = GlobalIcons();

  @override
  Future<FileInputValue?> lookup() async {
    // 🔹 Web file selection
    if (Device.isWeb == true) {
      final PlatformFile? dataFile = await Device.browse<PlatformFile>(
        scope: widget.scope as ScreenScope,
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions:
            widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
        showBusyOnPicking: false,
        withData: true,
        callback: (files) async => files.single,
      );

      if (dataFile == null) return null;

      return FileInputValue(
        data: dataFile.bytes,
        title: basename(dataFile.name),
        extension: dataFile.extension,
      );
    }

    // 🔹 Mobile (Camera or File Picker)
    final bool? shouldUseCamera =
        await Utils.dialogs.shouldUseCamera(widget.scope, useDocumentLabel: true);

    File? pathFile;

    if (shouldUseCamera == true) {
      pathFile = await Device.photo(
        scope: widget.scope as ScreenScope,
        title: widget.label,
        fullImage: true,
        initFaceCamera: false,
        allowMainCamera: true,
        fileName: widget.label?.toLowerCase().replaceAll(' ', '_'),
        flash: true,
        resolution: ResolutionPreset.high,
      );
    } else if (shouldUseCamera == false) {
      pathFile = await Device.browse<File>(
        scope: widget.scope as ScreenScope,
        type: FileType.custom,
        allowMultiple: false,
        showBusyOnPicking: false,
        allowedExtensions:
            widget.allowedExtensions ?? ['jpeg', 'jpg', 'png', 'pdf'],
        callback: (files) async => File(files.single.path!),
      );
    }

    if (pathFile == null) return null;

    return FileInputValue(
      path: pathFile.path,
      title: basename(pathFile.path),
      extension:
          (extension(pathFile.path).replaceFirst('.', '')).toLowerCase(),
    );
  }

  @override
  Widget display([String? text]) {
    return GestureDetector(
      onTap: _preview,
      child: Container(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 2),
              child: _getMimeIcon(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  _previewText ?? '-',
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
    );
  }

  @override
  void present() {
    if (!mounted) return;
    setState(() {
      final v = value;
      if (v?.title != null) {
        _previewText = v!.title;
      } else if (v?.path != null) {
        _previewText = basename(v!.path!);
      } else {
        _previewText = '-';
      }
    });
  }

  Future<void> _preview() async {
    if (value == null) return;

    dynamic result;

    if (widget.onPreview != null) {
      result = await widget.onPreview!.call(
        launchUrl: widget.launchUrlPrefix,
        file: value,
        readonly: widget.readonly ?? false,
      );
    } else if (widget.scope is ScreenScope) {
      result = await (widget.scope as ScreenScope).push(
        DocumentView(
          launchUrl: widget.launchUrlPrefix ?? '',
          file: value!,
          initialScale: PhotoViewComputedScale.contained,
          readonly: widget.readonly ?? false,
        ),
      );
    }

    present();

    if (result == false) {
      clear();
    }
  }

  Icon _getMimeIcon() {
    final path = value?.path;
    final ext = value?.extension ??
        (path != null ? extension(path).replaceFirst('.', '') : 'txt');
    final meta = icons.getFileMeta(ext);

    return Icon(
      meta.icon,
      color: meta.color,
      size: 14,
    );
  }
}
