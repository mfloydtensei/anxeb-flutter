import 'package:flutter/material.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

class CheckBoxField extends FieldWidget<bool> {
  final ListTileControlAffinity? controlAffinity;

   CheckBoxField({
    required Scope scope,
    required String name,
    super.key,
    String? group,
    String? label,
    EdgeInsets? margin,
    EdgeInsets? padding,
    ValueChanged<bool?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onFocus,
    FormFieldValidator<bool>? validator,
    FieldFocusType? focusType,
    bool readonly = false,
    Future<bool> Function()? fetcher,
    Function(bool?)? applier,
    FieldWidgetTheme? theme,
    this.controlAffinity,
  }) : super(
          scope: scope,
          name: name,
          group: group,
          margin: margin,
          padding: padding,
          readonly: readonly,
          onChanged: onChanged,
          onFocus: onFocus,
          validator: validator,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
          label: label,
          );
 
  @override
  Field<bool, CheckBoxField> createState() => _CheckBoxFieldState();
}

class _CheckBoxFieldState extends Field<bool, CheckBoxField> {
  @override
  Widget field() {
    return CheckboxListTile(
      contentPadding: const EdgeInsets.only(left: 4, right: 0),
      visualDensity: VisualDensity.standard,
      dense: false,
      activeColor: widget.scope.application.settings.colors.primary,
      // tileColor is meant for backgrounds; keeping transparent to avoid overlay issues
      tileColor: Colors.transparent,
      title: Text(
        widget.label ?? '',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: widget.scope.application.settings.colors.text,
          letterSpacing: 0.2,
          fontSize: 15,
        ),
      ),
      subtitle: warning != null && warning!.isNotEmpty
          ? Text(
              warning!,
              style: TextStyle(
                color: widget.scope.application.settings.colors.danger,
                fontSize: 13,
              ),
            )
          : null,
      value: value ?? false,
      onChanged: (widget.readonly)
          ? null
          : (newValue) {
              if (newValue == null) return;
              setState(() {
                value = newValue;
              });
              validate();
              widget.onChanged?.call(newValue);
            },
      controlAffinity:
          widget.controlAffinity ?? ListTileControlAffinity.leading,
    );
  }
}
