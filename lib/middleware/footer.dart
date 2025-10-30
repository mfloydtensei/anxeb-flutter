import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'device.dart';

class ScreenFooter {
  final Scope scope;
  final Widget? child;
  final bool Function()? isVisible;
  final Color? color;
  final double? elevation;
  final double? height;
  final double? divisionBorderWidth;
  final bool rebuild;

  const ScreenFooter({
    required this.scope,
    this.isVisible,
    this.child,
    this.color,
    this.elevation,
    this.height,
    this.divisionBorderWidth,
    this.rebuild = false,
  });

  @protected
  Widget? content() => child;

  Widget build() {
    final visible = isVisible?.call() ?? true;
    if (!visible) return const SizedBox.shrink();

    final Color backgroundColor =
        color ?? scope.application.settings.colors.primary;

    final Widget footerBody = Container(
      height: height,
      decoration: Device.isAndroid
          ? BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: divisionBorderWidth ?? 1.0,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            )
          : null,
      child: content(),
    );

    return BottomAppBar(
      color: backgroundColor,
      elevation: elevation ?? 8.0,
      clipBehavior: Clip.antiAlias,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: footerBody,
    );
  }
}
