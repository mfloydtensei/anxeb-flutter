import 'package:flutter/material.dart' hide Dialog;
import 'package:anxeb_flutter/middleware/sheet.dart';
import 'package:anxeb_flutter/middleware/device.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

class FormSheet extends ScopeSheet {
  final String? title;
  final Color? fill;
  final LinearGradient? gradient;
  final BoxDecoration? boxDecoration;
  final EdgeInsets? titlePadding;
  final TextStyle? titleStyle;

  const FormSheet(
    Scope scope, { // ✅ corregido aquí
    this.title,
    this.fill,
    this.gradient,
    this.boxDecoration,
    this.titlePadding,
    this.titleStyle,
  }) : super(scope);

  @protected
  Widget content(BuildContext context, Scope scope) { // ✅ tipo base
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final safeFill = fill ?? Theme.of(context).colorScheme.surface;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 0),
      child: Container(
        padding: EdgeInsets.only(bottom: scope.window.insets.bottom),
        decoration: boxDecoration ??
            BoxDecoration(
              color: safeFill,
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: gradient ??
                  LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      safeFill.withValues(alpha: 1),
                      safeFill.withValues(alpha: 1),
                    ],
                    stops: const [0.0, 1.0],
                  ),
            ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: scope.window.overlay.extendBodyFullScreen && Device.isAndroid
                ? const EdgeInsets.only(bottom: 64)
                : EdgeInsets.zero,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: titlePadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: Text(
                              title ?? '',
                              style: titleStyle ??
                                  TextStyle(
                                    fontSize: 20,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w600,
                                    color: scope.application.settings.colors.primary,
                                  ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          color: scope.application.settings.colors.primary,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22, right: 22, bottom: 20),
                    child: content(context, scope),
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
