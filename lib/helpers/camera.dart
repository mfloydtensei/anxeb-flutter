import 'dart:io';
import 'package:anxeb_flutter/middleware/action.dart';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/screen/screen.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:anxeb_flutter/widgets/blocks/empty.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_crop/image_crop.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../middleware/device.dart';
import 'preview.dart';

class CameraHelper extends ScreenWidget<Application> {
  final String? title;
  final bool? allowMainCamera;
  final Image? frameImage;
  final bool? initFaceCamera;
  final bool? fullImage;
  final bool? flash;
  final ResolutionPreset? resolution;
  final String? fileName;

 const CameraHelper({
  required Application application,
  this.title,
  this.allowMainCamera,
  this.initFaceCamera,
  this.frameImage,
  this.fullImage,
  this.flash,
  this.resolution,
  this.fileName,
}) : super('anxeb_camera_helper', application: application, title: title);

  @override
  _CameraHelperState createState() => _CameraHelperState();
}

class _CameraHelperState extends ScreenView<CameraHelper, Application> {
  CameraController? _camera;
  CameraDescription? _mainCamera;
  CameraDescription? _faceCamera;
  Future<void>? _initializeControllerFuture;
  bool _disabled = false;
  bool _initialized = false;

  @override
  Future init() async {
    try {
      final cameras = await availableCameras();
      _mainCamera = cameras.isNotEmpty ? cameras.first : null;
      _faceCamera = cameras.length > 1 ? cameras[1] : null;

      if (widget.initFaceCamera == true) {
        _initCamera(_faceCamera);
      } else {
        _initCamera(_mainCamera);
      }
    } catch (e) {
      await scope.dialogs.error("No se pudo acceder a la cámara").show();
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    window.overlay.extendBodyFullScreen = false;
    window.overlay.apply();
    super.dispose();
  }

  @override
  void setup() {
    window.overlay.brightness = Brightness.dark;
    window.overlay.extendBodyFullScreen = true;
  }

  void _submit(File result) {
    pop(result: result);
  }

  void _takePicture({bool preview = false, bool canRemove = false}) async {
    if (_noCamera || _disabled) return;

    setState(() => _disabled = true);

    try {
      await _initializeControllerFuture;
      final path = join(
        (await getTemporaryDirectory()).path,
        '${widget.fileName ?? DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final xfile = await _camera!.takePicture();
      await xfile.saveTo(path);
      File original = File(xfile.path);

      var properties = await ImageCrop.getImageOptions(file: original);
      File reduced;

      if (widget.fullImage != true) {
        reduced = await ImageCrop.sampleImage(file: original, preferredSize: 1000);
      } else {
        reduced = await ImageCrop.sampleImage(
          file: original,
          preferredSize: properties.width,
        );
      }

      properties = await ImageCrop.getImageOptions(file: reduced);

      File? cropped;
      if (widget.fullImage != true) {
        final horizontal = properties.width > properties.height;
        final width = properties.width.toDouble();
        final height = properties.height.toDouble();
        const topOffset = 0.14577;
        final size = horizontal ? height * 0.9 : width * 0.9;
        final l = horizontal
            ? (height / width) * topOffset
            : ((width - size) / 2) / width;
        final t = horizontal
            ? ((height - size) / 2) / height
            : (width / height) * topOffset;

        final w = size / width;
        final h = size / height;

        cropped = await ImageCrop.cropImage(
          file: reduced,
          area: Rect.fromLTWH(l, t, w, h),
        );
      }

      File finalFile = cropped ?? reduced;
      finalFile = await finalFile.copy(path);

      if (preview) {
        final previewImage = Image.file(finalFile).image;
        setState(() => _disabled = false);

        final result = await push(
          ImagePreviewHelper(
            title: widget.title ?? '',
            application: scope.application,
            image: previewImage,
            fullImage: widget.fullImage ?? false,
            canRemove: canRemove,
            fromCamera: true,
          ),
        );

        if (result == true) _submit(finalFile);
      } else {
        await scope.idle();
        setState(() => _disabled = false);
        _submit(finalFile);
      }
    } catch (err) {
      await scope.dialogs.error(err.toString()).show();
      setState(() => _disabled = false);
    }
  }

  void _swapCameras() {
    if (_noCamera) return;

    if (_camera?.description == _mainCamera) {
      _initCamera(_faceCamera);
    } else {
      _initCamera(_mainCamera);
    }
  }

  void _initCamera(CameraDescription? camera) {
    if (camera == null) return;
    _camera = CameraController(
      camera,
      widget.resolution ?? ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _camera!.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget content() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _camera?.value.isInitialized == true) {
          if (!_initialized) {
            _initialized = true;
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) setState(() {});
            });
          }

          if (widget.fullImage == true) {
            return Container(
              color: scope.application.settings.colors.navigation,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1 / _camera!.value.aspectRatio,
                  child: CameraPreview(_camera!),
                ),
              ),
            );
          }

          return Stack(
            children: [
              SizedBox(
                width: window.size.width,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      alignment: Alignment.topCenter,
                      fit: BoxFit.fitWidth,
                      child: SizedBox(
                        width: window.size.width,
                        height:
                            window.size.width * _camera!.value.aspectRatio,
                        child: CameraPreview(_camera!),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: window.size.width,
                child: widget.frameImage ??
                    Image.asset(
                      'assets/images/common/camera-frame.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return EmptyBlock(
            scope: scope,
            message: translate('anxeb.helpers.camera.empty_block.no_camera'),
            icon: Icons.error_outline,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  ScreenAction action() {
    return ScreenAction(
      scope: scope,
      icon: () => Icons.camera_alt,
      color: () => scope.application.settings.colors.secudary,
      onPressed: () => _takePicture(
        preview: widget.fullImage == true,
        canRemove: widget.fullImage == true,
      ),
      alternates: [
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () =>
              Device.isAndroid ? Icons.arrow_back : Icons.chevron_left,
          onPressed: () => dismiss(),
        ),
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () => _mainCameraActive
              ? Icons.camera_rear
              : Icons.camera_front,
          onPressed: _swapCameras,
          isDisabled: () => _noCamera,
          isVisible: () => _mainCameraAvailable,
        ),
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () => Icons.image,
          onPressed: () => _takePicture(preview: true),
          isVisible: () => widget.fullImage != true,
          isDisabled: () => _noCamera || _disabled,
        ),
      ],
      isDisabled: () => _noCamera,
    );
  }

  bool get _noCamera =>
      _camera == null || !_camera!.value.isInitialized;

  bool get _mainCameraAvailable => widget.allowMainCamera == true;

  bool get _mainCameraActive => _camera?.description == _mainCamera;
}
