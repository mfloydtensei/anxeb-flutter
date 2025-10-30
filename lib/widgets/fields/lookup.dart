import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class LookupInputField<V> extends FieldWidget<V> {
  final Future<V?> Function()? onLookup;
  final String Function(V value)? displayText;
  final dynamic Function(V value)? dataValue;

   LookupInputField({
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
    ValueChanged<V?>? onSubmitted,
    ValueChanged<V?>? onApplied,
    ValueChanged<V?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    FormFieldValidator<V?>? validator,
    V? Function(dynamic value)? parser,
    FieldFocusType? focusType,
    Future<V?> Function()? fetcher,
    Function(V?)? applier,
    FieldWidgetTheme? theme,
    this.onLookup,
    this.displayText,
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
        );

  @override
  State<LookupInputField<V>> createState() => _LookupInputFieldState<V>();
}

class _LookupInputFieldState<V> extends Field<V, LookupInputField<V>> {
  @override
  dynamic data() => widget.dataValue?.call(value as V) ?? value;

  @override
  Future<V?> lookup() async {
    return await widget.onLookup?.call();
  }

  @override
  Widget display([String? text]) {
    final displayText = value != null
        ? widget.displayText?.call(value as V)
        : '';
    return super.display(displayText);
  }
}
