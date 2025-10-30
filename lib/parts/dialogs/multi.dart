import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;

class MultiOptionsDialog<V> extends ScopeDialog<V> {
  final String title;
  final IconData? icon;
  final List<DialogButton<V>> options;
  final List<V> selectedValues;
  final List<DialogButton> buttons;

  MultiOptionsDialog(
    Scope scope, {
    required this.title,
    this.icon,
    required this.options,
    required this.selectedValues,
    required this.buttons,
  }) : super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(scope.application.settings.dialogs.dialogRadius),
        ),
      ),
      contentPadding: const EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 5),
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
                  fontSize: 16,
                  color: scope.application.settings.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...TextButton.createMultiOptions<V>(
                  context,
                  options,
                  selectedValues: selectedValues,
                  onChanged: (DialogButton<V> option, bool newValue) {
                    setState(() {
                      if (newValue) {
                        if (!selectedValues.contains(option.value)) {
                          selectedValues.add(option.value as V);
                        }
                      } else {
                        selectedValues.remove(option.value);
                      }
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: TextButton.createList(
                      context,
                      buttons,
                      settings: scope.application.settings,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
