import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/parts/panels/menu.dart';
import 'package:flutter/material.dart' hide Dialog;

class PanelDialog<V> extends ScopeDialog<V> {
  final String title;
  final List<PanelMenuItem> items;
  final bool horizontal;
  final double iconScale;
  final double textScale;
  final double buttonRadius;

  PanelDialog(
    Scope scope, {
    required this.title,
    required this.items,
    this.horizontal = false,
    this.iconScale = 1.0,
    this.textScale = 1.0,
    double? buttonRadius,
  })  : buttonRadius = buttonRadius ?? scope.application.settings.panels.buttonRadius,
        super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Calcula altura total de los paneles visibles
    final double totalHeight = items
        .where(
          (item) =>
              (item.isVisible.call() ?? true) &&
              item.actions.any((a) => a.isVisible.call()),
        )
        .fold<double>(0, (prev, element) => prev + (element.height.call()));

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(scope.application.settings.dialogs.dialogRadius ),
        ),
      ),
      contentPadding: const EdgeInsets.only(bottom: 8, left: 10, right: 10, top: 4),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: scope.application.settings.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(minHeight: totalHeight, maxHeight: totalHeight + 20),
        child: MenuPanel.getButtons(
          items: items,
          horizontal: horizontal,
          iconScale: iconScale,
          textScale: textScale,
          buttonRadius: buttonRadius,
          context: context,
          collapse: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
