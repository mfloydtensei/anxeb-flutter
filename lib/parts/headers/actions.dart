import 'package:anxeb_flutter/middleware/header.dart';
import 'package:anxeb_flutter/screen/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';

class ActionsHeader extends ScreenHeader {
  final Widget Function()? _body;
  final List<ActionItem>? actions;
  final Widget? leadingWidget; // ✅ Se define localmente el "leading"

  ActionsHeader({
    required ScreenScope scope,
    Widget Function()? title,
    Widget Function()? body,
    Widget Function()? bottom,
    double Function()? elevation,
    double Function()? height,
    this.actions,
    VoidCallback? dismiss,
    VoidCallback? back,
    ActionIcon? leading,
    bool Function()? isVisible,
    Color Function()? fill,
  })  : _body = body,
        leadingWidget = leading?.build(), // ✅ Guardamos el widget aquí
        super(
          scope: scope,
          dismiss: dismiss,
          back: back,
          title: title,
          bottom: bottom,
          elevation: elevation,
          height: height,
          isVisible: isVisible,
          fill: fill,
        );

  @override
  Widget? body() => _body?.call();

  @override
  List<Widget> content() {
    final visibleActions = actions
            ?.where((a) => a.isVisible?.call() ?? true)
            .map((a) => a.build())
            .toList() ??
        [];

    // ✅ Si existe un leading, lo agregamos como primer elemento
    if (leadingWidget != null) {
      return [leadingWidget!, ...visibleActions];
    }

    return visibleActions;
  }
}

abstract class ActionItem {
  bool Function()? isDisabled;
  bool Function()? isVisible;
  VoidCallback? onPressed;

  Widget build();
}
