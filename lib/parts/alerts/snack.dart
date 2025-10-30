import 'package:anxeb_flutter/middleware/alert.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart' hide Dialog;
import '../dialogs/form.dart';

class SnackAlert extends ScopeAlert {
  Flushbar<dynamic>? _bar;

  final String title;
  final String? message;
  final dynamic meta;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final IconData? icon;
  final Color? textColor;
  final Color? iconColor;
  final Color? fillColor;
  final int? delay;

  SnackAlert(
    super.scope, {
    required this.title,
    this.message,
    this.meta,
    this.titleStyle,
    this.messageStyle,
    this.icon,
    this.textColor,
    this.iconColor,
    this.fillColor,
    this.delay,
  });

  @override
  Future<void> dispose({bool quick = false}) async {
    if (_bar != null && _bar!.isShowing()) {
      if (quick) {
        _bar!.dismiss();
      } else {
        await _bar!.dismiss();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    await super.dispose(quick: quick);
    _bar = null;
  }

  @override
  Future<void> build() async {
    final Color background =
        fillColor ?? scope.application.settings.colors.navigation;
    final IconData displayIcon = icon ?? Icons.info;
    final TextStyle titleTextStyle = titleStyle ??
        TextStyle(
          fontSize: (message?.isEmpty ?? true) ? 17 : 19,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.white,
        );

    final TextStyle messageTextStyle = messageStyle ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: textColor ?? Colors.white,
        );

    final Widget titleWidget = Text(title, style: titleTextStyle);
    final Widget? messageWidget =
        message != null && message!.isNotEmpty ? Text(message!, style: messageTextStyle) : null;

    // Si estamos dentro de un formulario, no mostramos el flushbar
    if (scope is FormScope) {
      (scope as FormScope).warning = FormWarning(
        message: message,
        body: messageWidget,
        icon: displayIcon,
        iconColor: iconColor,
        textColor: textColor,
        fillColor: fillColor,
        meta: meta,
      );
      return;
    }

    _bar = Flushbar<dynamic>(
      titleText: messageWidget != null ? titleWidget : null,
      messageText: messageWidget ?? titleWidget,
      backgroundGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          background,
          Color.alphaBlend(Colors.black.withOpacity(0.15), background),
        ],
        stops: const [0.0, 1.0],
      ),
      isDismissible: true,
      margin: scope.application.settings.alerts.margin(),
      borderRadius: scope.application.settings.alerts.margin.call() == null
          ? null
          : scope.application.settings.alerts.borderRadius ??
              const BorderRadius.all(Radius.circular(8)),
      boxShadows: const [
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 6,
          spreadRadius: 2,
          color: Color(0x55222222),
        ),
      ],
      flushbarPosition:
          scope.application.settings.alerts.showFromBottom.call() == true
              ? FlushbarPosition.BOTTOM
              : (scope.application.settings.alerts.showFromBottom.call() ==
                      false
                  ? FlushbarPosition.TOP
                  : (scope.window.overlay.extendBodyFullScreen
                      ? FlushbarPosition.BOTTOM
                      : FlushbarPosition.TOP)),
      icon: Icon(
        displayIcon,
        size: (message?.isEmpty ?? true) ? 26 : 30.0,
        color: iconColor ?? Colors.white,
      ),
      shouldIconPulse: false,
      animationDuration: const Duration(milliseconds: 500),
      duration: Duration(milliseconds: delay ?? 3000),
    );

    await _bar!.show(scope.context);
    _bar = null;
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
