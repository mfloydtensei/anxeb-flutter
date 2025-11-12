import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:anxeb_flutter/misc/dialog_process.dart' as Anxeb;
class MessageDialog extends ScopeDialog {
  final String? title;
  final String? message;
  final Widget Function(BuildContext)? body;
  final IconData? icon;
  final double? iconSize;
  final Color? messageColor;
  final Color? titleColor;
  final Color? iconColor;
  final List<DialogButton>? buttons;
  final TextAlign? textAlign;
  final EdgeInsets? contentPadding;
  final EdgeInsets? insetPadding;
  final BorderRadius? borderRadius;
  final double? width;
  final Anxeb.DialogProcessController? controller;
final Future<void> Function()? onSuccess;
final Future<void> Function()? onFail;


  MessageDialog(
    Scope scope, {
    this.title,
    this.message,
    this.body,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.messageColor,
    this.titleColor,
    this.buttons,
    this.textAlign,
    this.contentPadding,
    this.insetPadding,
    this.borderRadius,
    this.width,
    this.controller,
    this.onSuccess,
    this.onFail,
    bool? dismissible,
  }) : super(scope) {
    super.dismissible = dismissible ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ??
            BorderRadius.all(
              Radius.circular(scope.application.settings.dialogs.dialogRadius),
            ),
      ),
      contentPadding: contentPadding ??
          const EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 5),
      insetPadding:
          insetPadding ?? const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      contentTextStyle: TextStyle(
        fontSize: 16.4,
        color: messageColor ?? scope.application.settings.colors.text,
        fontWeight: FontWeight.w400,
      ),
      title: Container(
        width: width,
        child: Row(
          children: <Widget>[
            if (icon != null)
              Container(
                padding: const EdgeInsets.only(right: 7),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: 1.0,
                      color: scope.application.settings.colors.separator,
                    ),
                  ),
                ),
                child: Icon(
                  icon,
                  size: iconSize ?? 72,
                  color: iconColor ?? scope.application.settings.colors.primary,
                ),
              ),
            Expanded(
              child: Text(
                (title ?? '').toUpperCase(),
                softWrap: width != null,
                textAlign: icon == null ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontSize: 16.2,
                  color: titleColor ?? scope.application.settings.colors.primary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
      content: Container(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (message != null && message!.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(bottom: 4, top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message!,
                        softWrap: true,
                        textAlign:
                            textAlign ?? (title != null ? TextAlign.left : TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
            if (body != null) body!(context),
            if (buttons != null && buttons!.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: TextButton.createList(
                    context,
                    buttons!,
                    settings: scope.application.settings,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
