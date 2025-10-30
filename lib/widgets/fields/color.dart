import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class ColorInputField extends FieldWidget<Color> {
  final Widget Function(Color? value)? displayWidget;
  final dynamic Function(Color? value)? dataValue;

   ColorInputField({
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
    ValueChanged<Color?>? onSubmitted,
    ValueChanged<Color?>? onApplied,
    ValueChanged<Color?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    FormFieldValidator<Color?>? validator,
    Color? Function(dynamic value)? parser,
    FieldFocusType? focusType,
    Future<Color?> Function()? fetcher,
    Function(Color?)? applier,
    FieldWidgetTheme? theme,
    this.displayWidget,
    this.dataValue,
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
  Field<Color, ColorInputField> createState() => _ColorInputFieldState();
}

class _ColorInputFieldState extends Field<Color, ColorInputField> {
  @override
  void init() {
    // Si necesitas inicializar algo al crear el campo, hazlo aquí
  }

  @override
  Widget display([String? text]) {
    // Si el usuario no define displayWidget, muestra un fallback
    if (widget.displayWidget != null) {
      return widget.displayWidget!.call(value);
    }

    // Fallback por defecto: un recuadro con el color actual
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: value ?? Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  dynamic data() {
    // Si el usuario definió dataValue, úsalo; si no, devuelve el color actual
    return widget.dataValue?.call(value) ?? value;
  }

  @override
  Future<Color?> lookup() async {
    // Abre el diálogo de selección de color desde el scope
    return await widget.scope.dialogs
        .color(value: value, icon: widget.icon, title: widget.label)
        .show();
  }
}
