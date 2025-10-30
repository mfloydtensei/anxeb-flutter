import 'package:flutter/material.dart';
import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';

class MultiInputField<V> extends FieldWidget<List<V>> {
  final Future<List<V>> Function() options;
  final String Function(V value)? displayText;
  final bool Function(V option, List<V> value)? comparer;

  MultiInputField({
    required Scope scope,
    required String name,
    Key? key,
    String? group,
    String? label,
    IconData? icon,
    EdgeInsets? margin,
    EdgeInsets? padding,
    bool readonly = false,
    bool visible = true,
    ValueChanged<List<V>?>? onSubmitted,
    ValueChanged<List<V>?>? onApplied,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    ValueChanged<List<V>?>? onChanged,
    FormFieldValidator<List<V>?>? validator,
    List<V> Function(dynamic value)? parser,
    FieldFocusType? focusType,
    Future<List<V>?> Function()? fetcher,
    Function(List<V>?)? applier,
    FieldWidgetTheme? theme,
    required this.options,
    this.comparer,
    this.displayText,
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
          onTab: onTab,
          onBlur: onBlur,
          onFocus: onFocus,
          onChanged: onChanged,
          validator: validator,
          parser: parser,
          focusType: focusType,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  Field<List<V>, MultiInputField<V>> createState() =>
      _MultiInputFieldState<V>();
}

class _MultiInputFieldState<V> extends Field<List<V>, MultiInputField<V>> {
  List<V> _options = [];

  @override
  void init() {
    _loadOptions();
  }

  @override
  Future<List<V>?> lookup() async {
    await _loadOptions();
    focus();

    // Diálogo de selección múltiple nativo
    final selected = await showDialog<List<V>>(
      context: context,
      builder: (ctx) {
        final tempSelection = List<V>.from(value ?? []);
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
                final isSelected = tempSelection.contains(option);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(
                    widget.displayText?.call(option) ?? option.toString(),
                  ),
                  onChanged: (checked) {
                    if (checked == true) {
                      tempSelection.add(option);
                    } else {
                      tempSelection.remove(option);
                    }
                    setState(() {});
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(tempSelection),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      if (selected.isEmpty) {
        clear();
      } else {
        return selected;
      }
    }

    return null;
  }

  @override
  Widget display([String? text]) {
    final currentValues = value ?? [];

    if (currentValues.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: currentValues.map((item) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.scope.application.settings.colors.primary,
                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
              ),
              child: Text(
                widget.displayText?.call(item) ?? item.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: super.display(),
      );
    }
  }

  Future<void> _loadOptions() async {
    if (_options.isNotEmpty) return;

    try {
      rasterize(() async => busy = true);
      _options = await widget.options.call();

      if (widget.comparer != null) {
        final selected = _options
            .where((item) => widget.comparer!(item, value ?? []))
            .toList();
        if (selected.isNotEmpty) value = selected;
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
