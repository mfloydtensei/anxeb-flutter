import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/sheet.dart';
import 'package:anxeb_flutter/widgets/blocks/image.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter_translate/flutter_translate.dart';
import '../../middleware/device.dart';

class NotificationSheet extends ScopeSheet {
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime date;
  final IconData? icon;
  final Widget? body;
  final VoidCallback? onDelete;
  final List<NotificationSheetAction> actions;

  const NotificationSheet(
    Scope scope, {
    required this.title,
    required this.message,
    required this.date,
    this.imageUrl,
    this.icon,
    this.body,
    this.onDelete,
    this.actions = const [],
  }) : super(scope);

  @override
  Widget build(BuildContext context) {
    final foreground = scope.application.settings.colors.text;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: scope.window.available.height,
        minHeight: 0,
      ),
      child: Container(
        color: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header
                  Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.5, color: foreground),
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            icon ?? Icons.notifications,
                            color: foreground,
                            size: 55,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Fecha
                  Row(
                    children: [
                      Text(
                        Anxeb.Utils.convert.fromDateToHumanString(
                          date,
                          withTime: true,
                          complete: true,
                        ),
                        style: TextStyle(
                          color: foreground.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // 🔹 Imagen opcional
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 200,
                      child: ImageLinkBlock(
                        url: imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),

                  // 🔹 Mensaje principal
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 21.5,
                        height: 1.3,
                        fontWeight: FontWeight.w300,
                        color: foreground,
                      ),
                    ),
                  ),

                  // 🔹 Cuerpo opcional
                  if (body != null) body!,

                  // 🔹 Acciones
                  if (actions.isNotEmpty)
                    Column(
                      children: actions
                          .where((a) => a.isVisible != false)
                          .map((action) {
                        return Anxeb.TextButton(
                          caption: action.caption,
                          icon: action.icon,
                          color: action.color ??
                              scope.application.settings.colors.secudary,
                          margin: const EdgeInsets.only(top: 12),
                          radius:
                              scope.application.settings.dialogs.buttonRadius,
                          onPressed: () {
                            Navigator.pop(context);
                            action.onPressed?.call();
                          },
                          type: Anxeb.ButtonType.primary,
                          size: Anxeb.ButtonSize.normal,
                        );
                      }).toList(),
                    ),

                  // 🔹 Botones inferiores (Eliminar / Cerrar)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Anxeb.TextButton(
                            caption: translate('anxeb.common.delete'),
                            color:
                                scope.application.settings.colors.danger,
                            margin: const EdgeInsets.only(right: 6),
                            radius:
                                scope.application.settings.dialogs.buttonRadius,
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete?.call();
                            },
                            type: Anxeb.ButtonType.primary,
                            size: Anxeb.ButtonSize.normal,
                          ),
                        ),
                        Expanded(
                          child: Anxeb.TextButton(
                            caption: translate('anxeb.common.close'),
                            color: scope.application.settings.colors.secudary,
                            margin: const EdgeInsets.only(left: 6),
                            radius:
                                scope.application.settings.dialogs.buttonRadius,
                            onPressed: () => Navigator.pop(context),
                            type: Anxeb.ButtonType.primary,
                            size: Anxeb.ButtonSize.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Color get barrierColor => Colors.black12;

  @override
  double get elevation => 20.0;
}

class NotificationSheetAction {
  final String caption;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool? isDisabled;
  final bool? isVisible;

  const NotificationSheetAction({
    required this.caption,
    this.icon,
    this.onPressed,
    this.color,
    this.isDisabled,
    this.isVisible,
  });
}
