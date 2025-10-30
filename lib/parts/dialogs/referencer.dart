import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/utils/referencer.dart';
import 'package:anxeb_flutter/widgets/blocks/referencer.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:flutter_translate/flutter_translate.dart';

class ReferencerDialog<V> extends ScopeDialog<List<V>> {
  final String title;
  final IconData? icon;
  final Referencer<V> referencer;
  final ReferenceItemWidget<V> itemWidget;
  final ReferenceHeaderWidget<V>? headerWidget;
  final ReferenceCreateWidget<V>? footerWidget;
  final Widget Function(ReferencerPage<V>?)? emptyWidget; // ✅ corregido
  final ReferenceFilterHandler<V>? filter;
  final double? buttonsWidth;
  final double? width;
  final double? height;

  ReferencerDialog(
    Scope scope, {
    required this.title,
    required this.referencer,
    this.icon,
    required this.itemWidget,
    this.headerWidget,
    this.footerWidget,
    this.emptyWidget,
    this.filter,
    this.buttonsWidth,
    this.width,
    this.height,
  }) : super(scope) {
    super.dismissible = true;
  }

  @override
  Future<void> setup() async {
    await scope.busy();
    await referencer.init();
    await scope.idle();
  }

  @override
  Widget build(BuildContext context) {
    referencer.onSubmit((result) {
      Navigator.of(context).pop(result);
    });

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(scope.application.settings.dialogs.dialogRadius),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      contentTextStyle: TextStyle(
        fontSize: 16.4,
        color: scope.application.settings.colors.text,
        fontWeight: FontWeight.w400,
      ),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: <Widget>[
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Icon(
                  icon,
                  size: 29,
                  color: scope.application.settings.colors.primary,
                ),
              ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  color: scope.application.settings.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        height: height ?? scope.window.vertical(0.6),
        width: width ?? scope.window.available.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: ReferencerBlock<V>(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                scope: scope,
                referencer: referencer,
                itemWidget: itemWidget,
                headerWidget: headerWidget,
                footerWidget: footerWidget,
                emptyWidget: emptyWidget, // ✅ ya coincide con el tipo
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: TextButton.createList(
                  context,
                  [
                    DialogButton(
                      translate('anxeb.parts.dialogs.referencer.start_button'),
                      null,
                      onTap: (context) async {
                        await referencer.start();
                      },
                    ),
                    DialogButton(
                      translate('anxeb.common.cancel'),
                      null,
                      onTap: (context) async {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                  settings: scope.application.settings,
                  width: buttonsWidth ?? scope.window.available.width,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
