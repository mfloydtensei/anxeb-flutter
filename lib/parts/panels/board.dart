import 'package:anxeb_flutter/middleware/panel.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class BoardPanel extends ScreenPanel {
  final Widget? child;
  final bool rebuild;
  final BoxDecoration? decoration;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? fill;

   BoardPanel({
    required Scope scope,
    this.child,
    double? height,
    bool Function()? isDisabled,
    bool gapless = false,
    Color? barColor,
    bool showBar = true,
    this.rebuild = false,
    this.decoration,
    this.padding,
    this.margin,
    this.fill,
    double backdropOpacity = 0.0,
    double? minHeight,
    Function(double state)? onPanelSlide,
  }) : super(
      scope: scope,
      height: height ?? 400,
      isDisabled: isDisabled,
      gapless: gapless,
      barColor: barColor,
      showBar: showBar,
      backdropOpacity: backdropOpacity,
      minHeight: minHeight ?? 0.0,
      onPanelSlide: onPanelSlide,
    );

  @override
  Widget content([Widget? child]) {
    return super.content(
      Container(
        height: (dynamicHeight ?? height ?? 0) - 70,
        width: scope.window.available.width,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 12),
        padding: padding ?? const EdgeInsets.all(12),
        decoration: decoration ??
            BoxDecoration(
              boxShadow: [shadow],
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
              color: this.fill ?? Colors.white,
            ),
        child: this.child ?? child,
      ),
    );
  }

  @protected
  BoxShadow get shadow => const BoxShadow(
        offset: Offset(0, 6),
        blurRadius: 5,
        spreadRadius: 3,
        color: Color(0x3f555555),
      );

  @protected
  double get radius => 10;

  @protected
  double get paddings => 12;

  @protected
  double get margins => 12;
}
