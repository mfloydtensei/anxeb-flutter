import 'package:anxeb_flutter/middleware/action.dart';
import 'package:anxeb_flutter/middleware/application.dart';
import 'package:anxeb_flutter/screen/screen.dart';
import 'package:anxeb_flutter/parts/headers/actions.dart';
import 'package:anxeb_flutter/widgets/actions/float.dart';
import 'package:flutter/material.dart';
import 'package:ai_barcode/ai_barcode.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../middleware/device.dart';

class ScannerHelper extends ScreenWidget<Application> {
  final String? title;
  final bool autoflash;

  const ScannerHelper({
    required Application application,
    this.title,
    this.autoflash = false,
  }) : super(
          'anxeb_scanner_helper',
          application: application,
          title: title,
        );

  @override
  ScreenView<ScannerHelper, Application> createState() => _ScannerHelperState();
}

class _ScannerHelperState extends ScreenView<ScannerHelper, Application> {
  late final ScannerController _scannerController;
  bool _flashOn = false;

  @override
  Future<void> init() async {
    _flashOn = widget.autoflash;

    _scannerController = ScannerController(
      scannerResult: (result) {
        pop(result: result, force: true);
      },
      scannerViewCreated: () async {
        if (Device.isIOS) {
          // delay ligero para evitar crash en iOS
          await Future.delayed(const Duration(milliseconds: 700));
        }

        _scannerController.startCamera();
        _scannerController.startCameraPreview();

        if (_flashOn) {
          _onFlash();
        } else {
          _offFlash();
        }
      },
    );
  }

  void _offFlash() {
    try {
      _scannerController.stopCameraPreview();
      _scannerController.closeFlash();
      _scannerController.startCameraPreview();
    } catch (_) {}
  }

  void _onFlash() {
    try {
      _scannerController.stopCameraPreview();
      _scannerController.openFlash();
      _scannerController.startCameraPreview();
    } catch (_) {}
  }

  void _flush() {
    try {
      _scannerController.stopCameraPreview();
    } catch (_) {}
    try {
      _scannerController.stopCamera();
    } catch (_) {}
    _offFlash();
  }

  @override
  void dispose() {
    _flush();
    super.dispose();
  }

  @override
  void setup() {
    window.overlay
      ..brightness = Brightness.dark
      ..extendBodyFullScreen = false
      ..apply();
  }

  @override
  void prebuild() {}

  @override
  ActionsHeader header() {
    return ActionsHeader(
      scope: scope,
      title: () => Text(
        widget.title ?? translate('anxeb.helpers.scanner.default_title'),
      ),
    );
  }

  @override
  Widget content() {
    return Container(
      color: scope.application.settings.colors.navigation,
      child: Center(
        child: PlatformAiBarcodeScannerWidget(
          platformScannerController: _scannerController,
        ),
      ),
    );
  }

  @override
  ScreenAction action() {
    return ScreenAction(
      scope: scope,
      icon: () => _flashOn ? Icons.lightbulb : Icons.lightbulb_outline,
      color: () => scope.application.settings.colors.secudary,
      onPressed: () {
        rasterize(() {
          _flashOn = !_flashOn;
        });
        if (_flashOn) {
          _onFlash();
        } else {
          _offFlash();
        }
      },
      alternates: [
        AltAction(
          color: () => scope.application.settings.colors.secudary,
          icon: () => Icons.clear,
          onPressed: () => dismiss(),
        ),
      ],
    );
  }
}
