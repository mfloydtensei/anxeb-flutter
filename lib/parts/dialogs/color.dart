import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../anxeb.dart';

class ColorDialog extends ScopeDialog<Color> {
  final String? title;
  final IconData? icon;
  Color _value;

  ColorDialog(
    Scope scope, {
    Color? value,
    this.title,
    this.icon,
  })  : _value = value ?? Colors.black,
        super(scope);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            scope.application.settings.dialogs.dialogRadius,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.only(
        bottom: 20,
        left: 20,
        right: 20,
        top: 5,
      ),
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
                child: Icon(icon, size: 29),
              ),
            Expanded(
              child: Text(
                title ?? '',
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ColorPicker(
            pickerColor: _value,
            enableAlpha: false,
            labelTypes: const [],
            displayThumbColor: true,
            onColorChanged: (color) {
              _value = color;
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: TextButton.createList(
              context,
              [
                DialogButton(
                  translate('anxeb.common.accept'),
                  null,
                  onTap: (context) async {
                    Navigator.of(context).pop(_value);
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
            ),
          ),
        ],
      ),
    );
  }
}
