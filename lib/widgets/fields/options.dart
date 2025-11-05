import 'package:flutter/material.dart';
import '../../middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

enum OptionsInputFieldType { dropdown, dialog }

class OptionsInputField<V> extends FieldWidget<V, OptionsInputField<V>> {
  final Future<List<V>> Function() options;
  final OptionsInputFieldType type;
  final String Function(V value)? displayText;
  final IconData Function(V value)? displayIcon;
  final dynamic Function(V? value)? dataValue;
  final bool Function(V option, V value)? comparer;

  OptionsInputField({
    required Scope scope,
    required String name,
    required this.options,
    this.type = OptionsInputFieldType.dropdown,
    this.displayText,
    this.displayIcon,
    this.dataValue,
    this.comparer,
    Key? key,
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
  }) : super(
          scope: scope,
          key: key,
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
          sufixIcon: Icons.keyboard_arrow_down_sharp,
          theme: theme,
        );

  @override
  Field<V, OptionsInputField<V>> createState() => _OptionsInputFieldState<V>();
}

class _OptionsInputFieldState<V> extends Field<V, OptionsInputField<V>> {
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  List<V> _options = [];

  @override
  void init() {
    _loadOptions();
  }

  @override
  dynamic data() => widget.dataValue?.call(value) ?? value;

  @override
  Future<V?> lookup() async {
    await _loadOptions();
    focus();

    if (widget.type == OptionsInputFieldType.dialog) {
      final selected = await showDialog<V>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                widget.scope.application.settings.dialogs.dialogRadius,
              ),
            ),
            title: Text(widget.label ?? 'Seleccionar'),
            content: SingleChildScrollView(
              child: Column(
                children: _options.map((option) {
                  return ListTile(
                    leading: widget.displayIcon != null
                        ? Icon(widget.displayIcon!(option))
                        : null,
                    title: Text(widget.displayText?.call(option) ?? option.toString()),
                    trailing: value != null &&
                            (widget.comparer?.call(option, value as V) ?? option == value)
                        ? Icon(Icons.check,
                            color: widget.scope.application.settings.colors.primary)
                        : null,
                    onTap: () => Navigator.of(ctx).pop(option),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );

      if (selected != null) {
        return selected;
      }
    }

    return null;
  }

  @override
  Widget display([String? text]) {
    if (widget.type == OptionsInputFieldType.dropdown) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<V>(
          key: _fieldKey,
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_sharp),
          style: widget.theme?.inputStyle,
          hint: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: super.display(),
          ),
          onChanged: widget.readonly == true
              ? null
              : (selected) {
                  if (selected != null) submit(selected);
                },
          items: _options.map((item) {
            return DropdownMenuItem<V>(
              value: item,
              child: Text(
                widget.displayText?.call(item) ?? item.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      );
    }

    // Dialog mode
    return InkWell(
      onTap: widget.readonly == true ? null : () async {
        final result = await lookup();
        if (result != null) submit(result);
      },
      child: super.display(
        value != null
            ? widget.displayText?.call(value as V) ?? value.toString()
            : (widget.label ?? ''),
      ),
    );
  }

  @override
  Future<V?> fetch([bool apply = true]) async {
    _options = [];
    value = await widget.fetcher?.call();
    await _loadOptions();
    return value;
  }

  Future<void> _loadOptions() async {
    if (_options.isNotEmpty) return;

    try {
      rasterize(() async => busy = true);
      _options = await widget.options();

      if (widget.comparer != null && value != null) {
        final matched = _options.firstWhere(
          (item) => widget.comparer!(item, value as V),
          orElse: () => value as V,
        );
        value = matched;
      }
    } catch (err) {
      _options = [];
      warning = err.toString();
    } finally {
      rasterize(() async => busy = false);
    }
  }

  List<V> get options => _options;
}
