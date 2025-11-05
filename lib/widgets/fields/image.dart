import 'package:anxeb_flutter/anxeb.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:anxeb_flutter/helpers/preview.dart';
import 'package:flutter/material.dart';


enum ImageInputFieldType { front, rear, local, web }

class ImageInputField extends FieldWidget<String, ImageInputField> {
  final ImageInputFieldType type;
  final bool fullImage;
  final bool initFaceCamera;
  final bool flash;
  final double height;
  final bool returnPath;
  final ResolutionPreset resolution;
  final FileSourceOption? fileSourceOption;
  final bool showSize;
  final String? url;
  final Future Function({
    String? title,
    ImageProvider? image,
    bool? fullImage,
  })? onPreview;
  final BoxFit fit;

   ImageInputField({
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
    ValueChanged<String?>? onSubmitted,
    ValueChanged<String?>? onApplied,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    ValueChanged<String?>? onChanged,
    FormFieldValidator<String?>? validator,
    String? Function(dynamic)? parser,
    FieldFocusType? focusType,
    Future<String?> Function()? fetcher,
    Function(String?)? applier,
    FieldWidgetTheme? theme,
    this.type = ImageInputFieldType.local,
    this.fullImage = true,
    this.initFaceCamera = false,
    this.flash = false,
    this.height = 180,
    this.returnPath = false,
    this.resolution = ResolutionPreset.medium,
    this.fileSourceOption,
    this.showSize = false,
    this.url,
    this.onPreview,
    this.fit = BoxFit.cover,
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
  Field<String, ImageInputField> createState() => _ImageInputFieldState();
}

class _ImageInputFieldState extends Field<String, ImageInputField> {
  ImageProvider? _imageData;
  String? _imageSize;

  @override
  void init() {
    super.init();
    if (widget.url?.isNotEmpty == true) {
      _loadImage();
    }
  }

  @override
  Future<String?> fetch([apply = true]) async {
    await super.fetch(apply);
    await _loadImage();
    return value;
  }

  Future<void> _loadImage() async {
    if (widget.url?.isEmpty ?? true) return;

    try {
      rasterize(() async => busy = true);

      final req = await widget.scope.api.request(
        ApiMethods.get,
        widget.url!,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = req.data as List<int>;
      _imageData = Image.memory(Uint8List.fromList(bytes)).image;
      _imageSize = Utils.convert.fromAnyToDataSize(bytes.length);
    } catch (err) {
      _imageData = null;
      _imageSize = null;
    } finally {
      rasterize(() async {
        value = '';
        busy = false;
      });
    }
  }

  @override
  Future<String?> lookup() async {
    if (Device.isWeb == true) {
      final dataFile = await Device.browse<PlatformFile>(
        scope: widget.scope,
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: const ['jpeg', 'jpg', 'png'],
        showBusyOnPicking: false,
        withData: true,
        callback: (files) async => files.single,
      );

      if (dataFile?.bytes?.isNotEmpty == true) {
        return 'data:image/png;base64,${base64Encode(dataFile!.bytes!)}';
      }
      return null;
    }

   final scope = widget.scope is ScreenScope
    ? widget.scope as ScreenScope
    : throw Exception('Device.photo requiere un ScreenScope.');

final File? result = await Device.photo(
  scope: scope,
  title: widget.label,
  fullImage: widget.fullImage,
  initFaceCamera: widget.initFaceCamera,
  allowMainCamera: widget.type == ImageInputFieldType.rear,
  flash: widget.flash,
  resolution: widget.resolution,
  option: widget.fileSourceOption ?? FileSourceOption.camera,

);

    if (result == null) return null;

    if (widget.returnPath) {
      return result.path;
    } else {
      final bytes = result.readAsBytesSync();
      return 'data:image/png;base64,${base64Encode(bytes)}';
    }
  }

  @override
  void clear() {
    rasterize(() {
      _imageData = null;
      _imageSize = null;
    });
    super.clear();
  }

  @override
  Widget display([String? text]) {
    if (super.busy == true) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: super.display(widget.label ?? ''),
      );
    }

    final image = _imageData;

    if (image == null) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            widget.scope.application.settings.dialogs.dialogRadius,
          ),
          color: Colors.grey.shade200,
        ),
        child: Icon(
          Icons.image_outlined,
          color: widget.scope.application.settings.colors.primary,
          size: 40,
        ),
      );
    }

    final previewImage = GestureDetector(
      onTap: _preview,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            widget.scope.application.settings.dialogs.dialogRadius,
          ),
          image: DecorationImage(
            fit: widget.fit,
            alignment: Alignment.center,
            image: image,
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: SizedBox(height: widget.height, child: previewImage),
    );
  }

  @override
  String? label() =>
      widget.showSize ? '${widget.label ?? ''} - ${_imageSize ?? ''}' : widget.label;

  @override
  void present() {
    if (value?.isNotEmpty != true || !mounted) return;

    if (Device.isWeb == false && widget.returnPath) {
      final file = File(value!);
      if (file.existsSync()) {
        _imageData = Image.file(file).image;
        _imageSize = Utils.convert.fromAnyToDataSize(file.lengthSync());
      } else {
        _imageData = null;
        _imageSize = null;
      }
    } else if (value != null && value!.startsWith('data:image')) {
      final bytes = base64Decode(value!.substring(value!.indexOf(',') + 1));
      _imageData = Image.memory(bytes).image;
      _imageSize = Utils.convert.fromAnyToDataSize(bytes.length);
    }

    setState(() {});
  }

  Future<void> _preview() async {
    final image = _imageData;
    dynamic result;

    if (widget.onPreview != null) {
      result = await widget.onPreview!(
        title: widget.label,
        image: image,
        fullImage: widget.fullImage,
      );
    } else if (widget.scope is ScreenScope) {
      result = await (widget.scope as ScreenScope).push(
        ImagePreviewHelper(
          application: widget.scope.application,
          title: widget.label ?? '',
          image: image!,
          canRemove: true,
          fullImage: widget.fullImage,
        ),
      );
    } else {
      final newValue = await lookup();
      if (newValue != null) submit(newValue);
    }

    if (result == false) clear();
  }

  @override
  bool get canClear => _imageData != null;

  @override
  bool get hasValue => value?.isNotEmpty == true;
}
