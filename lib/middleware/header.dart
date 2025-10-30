import 'package:flutter/material.dart';
import '../screen/scope.dart';

class ScreenHeader {
  final ScreenScope scope;
  final List<Widget>? childs;
  final VoidCallback? dismiss;
  final VoidCallback? back;
  final Widget Function()? title;
  final double Function()? elevation;
  final double Function()? height;
  final Widget Function()? bottom;
  final bool Function()? isVisible;
  final Color Function()? fill;
  final Widget? leading;

  const ScreenHeader({
    required this.scope,
    this.childs,
    this.dismiss,
    this.back,
    this.leading,
    this.title,
    this.elevation,
    this.height,
    this.bottom,
    this.isVisible,
    this.fill,
  });

  @protected
  List<Widget>? content() => childs;

  @protected
  Widget? body() => null;

  PreferredSizeWidget build() {
    final backgroundColor =
        fill?.call() ??
        scope.window.overlay.background;

    final double appBarElevation = elevation?.call() ?? 0;
    final Widget? appBarTitle = body() ?? title?.call() ?? Text(scope.view.title);

    final Widget? appBarBottom = scope.view.parts.tabs.header.call(
          bottomBody: bottom?.call() ?? const SizedBox.shrink(),
          height: height ?? () => 0.0,
        );

    final bool showActions = isVisible?.call() ?? true;
    final bool showLeading =
        !(back == null && dismiss == null && leading == null);

    return AppBar(
      title: appBarTitle,
      elevation: appBarElevation,
      automaticallyImplyLeading: !showLeading ? true : false,
      leading: leading ??
          (back != null
              ? BackButton(onPressed: back)
              : (dismiss != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: dismiss,
                    )
                  : null)),
      backgroundColor: backgroundColor,
      bottom: appBarBottom is PreferredSizeWidget ? appBarBottom : null,
      actions: showActions ? (content() ?? []) : [],
    );
  }

  bool get rebuild => false;
}
