import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'scope.dart';

class ScreenPanel {
  final Scope scope;
  final double? height;
  final bool Function()? isDisabled;
  final bool gapless;
  final Color? barColor;
  final bool showBar;
  final double backdropOpacity;
  final double minHeight;
  final void Function(double position)? onPanelSlide;

  final PanelController _controller = PanelController();

  bool rebuild = false;
  bool _display = true;

  ScreenPanel({
    required this.scope,
    this.height,
    this.isDisabled,
    this.gapless = false,
    this.barColor,
    this.showBar = true,
    this.backdropOpacity = 0.36,
    this.minHeight = 48.0,
    this.onPanelSlide,
  });

  Future<void> collapse() async {
    if (_controller.isAttached) {
      await _controller.close();
    }
  }

  @protected
  Widget content([Widget? child]) => child ?? const SizedBox.shrink();

  Widget wrap(Widget parent) {
    // Si está deshabilitado, devolvemos el contenido original
    if (isDisabled?.call() == true) {
      return parent;
    }

    final panelContent = content();

    return SlidingUpPanel(
      controller: _controller,
      onPanelSlide: (position) {
        onPanelSlide?.call(position);

        final disp = _controller.isAttached && position < 0.2;
        if (_display != disp) {
          scope.rasterize(() => _display = disp);
        }
      },
      panel: Container(
        width: scope.window.available.width,
        color: Colors.transparent,
        child: showBar
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: _display ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      height: 15,
                      width: 100,
                      margin: gapless
                          ? const EdgeInsets.only(bottom: 20, top: 35)
                          : const EdgeInsets.only(bottom: 35, top: 20),
                      decoration: BoxDecoration(
                        color: barColor ??
                            (gapless
                                ? scope.application.settings.colors.navigation
                                : scope.application.settings.colors.primary),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(30, gapless ? 15 : 9),
                          topRight: Radius.elliptical(30, gapless ? 15 : 9),
                          bottomLeft:
                              gapless ? Radius.zero : const Radius.circular(3),
                          bottomRight:
                              gapless ? Radius.zero : const Radius.circular(3),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          width: 50,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                  panelContent,
                ],
              )
            : panelContent,
      ),
      backdropEnabled: true,
      renderPanelSheet: false,
      backdropTapClosesPanel: true,
      backdropOpacity: backdropOpacity,
      body: parent,
      minHeight: minHeight,
      maxHeight: dynamicHeight ?? height ?? 200,
    );
  }

  @protected
  double? get dynamicHeight => null;
}
