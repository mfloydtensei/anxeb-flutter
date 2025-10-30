import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;

class OptionsDialog<V> extends ScopeDialog<V> {
  final String? title;
  final IconData? icon;
  final List<DialogButton<V>> options;
  final V? selectedValue;

  OptionsDialog(
    Scope scope, {
    this.title,
    this.icon,
    this.options = const [],
    this.selectedValue,
  }) : super(scope) {
    super.dismissible = true;
  }

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
        left: 24,
        right: 24,
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: TextButton.createOptions<V>(
            context,
            options,
            selectedValue: selectedValue ?? options.first.value as V,
            settings: scope.application.settings,
          ),
        ),
      ),
    );
  }
}
