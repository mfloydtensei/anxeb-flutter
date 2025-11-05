import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/sheet.dart';
import 'package:flutter/material.dart' hide Dialog;
import '../../middleware/device.dart';

class TipSheet extends ScopeSheet {
  final String? title;
  final String? message;
  final Color? fill;
  final Color? foreground;
  final IconData? icon;
  final Widget? body;
  final bool flat;

  const TipSheet(
    Scope scope, {
    this.title,
    this.message,
    this.fill,
    this.foreground,
    this.icon,
    this.body,
    this.flat = false,
  }) : super(scope);

  @override
  Widget build(BuildContext context) {
    final Color safeFill = fill ?? Colors.white;
    final Color safeForeground =
        foreground ?? scope.application.settings.colors.header;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: scope.window.vertical(0.66),
        minHeight: 0,
      ),
      child: Container(
        decoration: flat
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    safeFill.withValues(alpha: 1),
                    safeFill.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
        color: flat ? safeFill : null,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: scope.window.overlay.extendBodyFullScreen && Device.isAndroid
                ? const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 64)
                : const EdgeInsets.all(25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Header
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: safeForeground,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (icon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              icon,
                              color: safeForeground,
                              size: 23,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            title ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                              color: safeForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Mensaje
                  if (message != null && message!.isNotEmpty)
                    Text(
                      message!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        color:
                            foreground ?? scope.application.settings.colors.text,
                      ),
                    ),

                  // 🔹 Cuerpo adicional opcional
                  if (body != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: body!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
