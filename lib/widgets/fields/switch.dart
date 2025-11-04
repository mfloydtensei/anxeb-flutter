import 'package:flutter/material.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import '../buttons/switch.dart';

class SwitchField extends FieldWidget<bool> {
  final ListTileControlAffinity? controlAffinity;

  SwitchField({
    required Scope scope,
    required String name,
    Key? key,
    String? group,
    String? label,
    IconData? icon,
    EdgeInsets? margin,
    EdgeInsets? padding,
    ValueChanged<bool?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onFocus,
    FormFieldValidator<bool?>? validator,
    FieldFocusType? focusType,
    bool readonly = false,
    Future<bool?> Function()? fetcher,
    Function(bool?)? applier,
    FieldWidgetTheme? theme,
    this.controlAffinity,
  }) : super(
          scope: scope,
          key: key,
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
          icon: icon,
        );

  @override
  Field<bool, SwitchField> createState() => _SwitchFieldState();
}

class _SwitchFieldState extends Field<bool, SwitchField> {
  @override
  Widget field() {
    return FormField<bool>(
      builder: (FormFieldState<bool> state) {
        final double borderSize = widget.theme?.border?.borderSide.width ??
            widget.scope.application.settings.fields.border.borderSide.width;

        return SwitchButton(
          scope: widget.scope,
          margin: widget.margin,
          borderRadius: widget.theme?.borderRadius ??
              BorderRadius.all(Radius.circular(borderSize)),
          color: focused
              ? (widget.theme?.focusColor ??
                  widget.scope.application.settings.fields.focusColor)
              : (widget.theme?.fillColor ??
                  widget.scope.application.settings.fields.fillColor),
          icon: widget.icon,
          text: Text(
            widget.label ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: widget.scope.application.settings.colors.danger,
              letterSpacing: 0.2,
              fontSize: 15,
            ),
          ),
          readonly: widget.readonly ?? false, // ✅ ya es bool, sin ??
          value: value ?? false,     // ✅ nunca nulo
          onToggle: (bool newValue) {
            // ✅ condiciones null-safe y firmas correctas
            if (widget.readonly == true) return;

            value = newValue;
            validate();

            // El callback acepta bool?, así que pasamos el valor directamente
            widget.onChanged?.call(newValue);
          },
        );
      },
    );
  }
}
