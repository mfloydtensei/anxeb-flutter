import 'package:flutter/material.dart';
import '../../middleware/field.dart';

class CheckBoxField extends FieldWidget<bool, CheckBoxField> {
  final ListTileControlAffinity? controlAffinity;

  const CheckBoxField({
    required super.scope,
    required super.name,
    super.key,
    super.group,
    super.label,
    super.margin,
    super.padding,
    super.readonly = false,
    super.onChanged,
    super.onFocus,
    super.validator,
    super.focusType,
    super.fetcher,
    super.applier,
    super.theme,
    this.controlAffinity,
  });

  @override
  State<CheckBoxField> createState() => _CheckBoxFieldState();
}

class _CheckBoxFieldState extends Field<bool, CheckBoxField> {
  @override
  Widget field() {
    return CheckboxListTile(
      contentPadding: const EdgeInsets.only(left: 4, right: 0),
      visualDensity: VisualDensity.standard,
      dense: false,
      activeColor: widget.scope.application.settings.colors.primary,
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
      onChanged: widget.readonly
          ? null
          : (newValue) {
              if (newValue == null) return;
              setState(() => value = newValue);
              validate();
              widget.onChanged?.call(newValue);
            },
      controlAffinity:
          widget.controlAffinity ?? ListTileControlAffinity.leading,
    );
  }
}
