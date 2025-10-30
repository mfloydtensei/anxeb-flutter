import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateInputField extends FieldWidget<DateTime> {
  final String? displayFormat;
  final String Function(DateTime?)? displayText;
  final dynamic Function(DateTime?)? dataValue;
  final String? locale;
  final bool pickTime;

   DateInputField({
    required Scope scope,
    required String name,
    super.key,
    String? group,
    String? label,
    IconData? icon,
    EdgeInsets? margin,
    EdgeInsets? padding,
    bool readonly = false,
    bool visible = true,
    ValueChanged<DateTime?>? onSubmitted,
    ValueChanged<DateTime?>? onApplied,
    ValueChanged<DateTime?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    FormFieldValidator<DateTime?>? validator,
    DateTime? Function(dynamic value)? parser,
    FieldFocusType? focusType,
    Future<DateTime?> Function()? fetcher,
    Function(DateTime?)? applier,
    FieldWidgetTheme? theme,
    this.displayFormat = 'dd/MM/yyyy',
    this.displayText,
    this.dataValue,
    this.locale = 'es_DO',
    this.pickTime = false,
  }) : super(
          scope: scope,
          name: name,
          group: group,
          label: label,
          icon: icon,
          margin: margin,
          padding: padding,
          readonly: readonly,
          visible: visible,
          onSubmitted: onSubmitted,
          onApplied: onApplied,
          onChanged: onChanged,
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
          sufixIcon: Icons.keyboard_arrow_down_sharp,
        );

  @override
  State<DateInputField> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends Field<DateTime, DateInputField> {
  late DateFormat _dateFormat;

  @override
  void init() {
    _dateFormat = DateFormat(widget.displayFormat, widget.locale ?? 'es_DO');
  }

  @override
  Widget display([String? text]) {
    if (value == null) {
      return super.display('-');
    }

    final formatted = widget.displayText?.call(value) ??
        _dateFormat.format(value!);

    return super.display(formatted);
  }

  @override
  dynamic data() {
    return widget.dataValue?.call(value) ?? value;
  }

  @override
  Future<DateTime?> lookup() async {
    return await widget.scope.dialogs
        .dateTime(value: value, pickTime: widget.pickTime)
        .show();
  }
}
