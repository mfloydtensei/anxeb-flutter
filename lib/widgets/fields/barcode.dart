import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../middleware/device.dart';

enum BarcodeInputFieldType { numeric, alphanumeric }

class BarcodeInputField extends FieldWidget<String> {
  final TextEditingController? controller;
  final BarcodeInputFieldType? type;
  final bool autofocus;
  final TextInputAction? action;
  final bool canSelect;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final bool autoflash;
  final ValueChanged<String>? onScan;

   BarcodeInputField({
    required Scope scope,
    super.key,
    required String name,
    String? group,
    String? label,
    IconData? icon,
    EdgeInsets? margin,
    EdgeInsets? padding,
    bool readonly = false,
    bool visible = true,
    ValueChanged<String?>? onSubmitted,
    ValueChanged<String?>? onApplied,
    ValueChanged<String?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    FormFieldValidator<String>? validator,
    String Function(dynamic value)? parser,
    FieldFocusType? focusType,
    bool selected = false,
    Future<String> Function()? fetcher,
    Function(String?)? applier,
    FieldWidgetTheme? theme,
    this.controller,
    this.type = BarcodeInputFieldType.alphanumeric,
    this.autofocus = false,
    this.action,
    this.canSelect = true,
    this.hint,
    this.prefix,
    this.suffix,
    this.autoflash = false,
    this.onScan,
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
          initialSelected: selected,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  Field<String, BarcodeInputField> createState() => _BarcodeInputFieldState();
}

class _BarcodeInputFieldState extends Field<String, BarcodeInputField> {
  late TextEditingController _controller;
  bool _editing = false;
  bool _tabbed = false;

  @override
  void init() {
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void focus({String? warning}) {
    select();
    super.focus(warning: warning);
  }

  @override
  void select() {
    if (_controller.text.isNotEmpty) {
      _controller.selection =
          TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    }
  }

  @override
  void onBlur() {
    if (_editing) {
      _editing = false;
      super.submit(_controller.text);
    }
    super.onBlur();
  }

  @override
  void onFocus() {
    _editing = false;
    super.onFocus();
  }

  @override
  void reset() {
    super.reset();
    if (mounted) {
      setState(() {
        _editing = false;
        _controller.clear();
      });
    } else {
      _editing = false;
      _controller.clear();
    }
  }

  @override
  void present() {
    _controller.text = (value ?? '').toUpperCase();
  }

  Future<void> _scan() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final result = await Device.scan(
      scope: widget.scope,
      autoflash: widget.autoflash,
    );
    super.value = result;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    validate();
    widget.onScan?.call(value ?? '');
    widget.onSubmitted?.call(value ?? '');
  }

  @override
  Widget field() {
    return TextField(
      autofocus: widget.autofocus,
      focusNode: focusNode,
      textInputAction: widget.action,
      textCapitalization: TextCapitalization.characters,
      controller: _controller,
      readOnly: widget.readonly,
      enableInteractiveSelection: widget.canSelect,
      autocorrect: false,
      keyboardType: widget.type == BarcodeInputFieldType.alphanumeric
          ? TextInputType.text
          : const TextInputType.numberWithOptions(signed: false, decimal: false),
      onSubmitted: (value) {
        _editing = false;
        super.submit(value);
      },
      onTap: () {
        if (widget.readonly) return;

        if (_tabbed) {
          _tabbed = false;
        } else {
          _editing = false;
          if (!focusNode.hasFocus) focus();
          widget.onTab?.call();
        }
      },
      onChanged: (value) {
        if (!_editing) warning = null;
        _editing = true;
        widget.onChanged?.call(value);
      },
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        filled: true,
        contentPadding:
            widget.scope.application.settings.fields.contentPaddingWithIcon,
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: widget.scope.application.settings.colors.primary,
              )
            : null,
        labelText: widget.theme?.fixedLabel == true
            ? widget.label?.toUpperCase()
            : widget.label,
        labelStyle: widget.theme?.fixedLabel == true
            ? TextStyle(
                fontWeight:
                    widget.theme?.labelFontWeight ?? FontWeight.w500,
                color: widget.theme?.dangerColor ??
                    widget.scope.application.settings.colors.danger,
                letterSpacing: widget.theme?.labelLetterSpacing ?? 0.8,
                fontSize: widget.theme?.labelFontSize ?? 15,
                fontFamily: widget.theme?.labelFontFamily,
              )
            : widget.theme?.labelStyle,
        floatingLabelBehavior: widget.theme?.fixedLabel == true
            ? FloatingLabelBehavior.always
            : null,
        hintText: widget.hint,
        hintStyle: widget.scope.application.settings.fields.hintStyle,
        iconColor: widget.scope.application.settings.fields.iconColor,
        suffixIconColor:
            widget.scope.application.settings.fields.suffixIconColor,
        prefixStyle: widget.theme?.prefixStyle ??
            TextStyle(
              color: widget.scope.application.settings.colors.text,
              fontSize: 16,
            ),
        suffixStyle: widget.theme?.suffixStyle ??
            TextStyle(
              color: widget.scope.application.settings.colors.text,
              fontSize: 16,
            ),
        prefixText: widget.prefix,
        suffixText: widget.suffix,
        errorText: warning,
        border: widget.theme?.borderRadius != null
            ? UnderlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: widget.theme!.borderRadius!,
              )
            : (widget.theme?.border ?? widget.scope.application.settings.fields.border),
        disabledBorder: widget.theme?.borderless == true
            ? null
            : (widget.theme?.disabledBorder as InputBorder? ??
                widget.scope.application.settings.fields.disabledBorder),
        enabledBorder: widget.theme?.borderless == true
            ? null
            : (widget.theme?.enabledBorder as InputBorder? ??
                widget.scope.application.settings.fields.enabledBorder),
        focusedBorder: widget.theme?.borderless == true
            ? null
            : (widget.theme?.focusedBorder as InputBorder? ??
                widget.scope.application.settings.fields.focusedBorder),
        errorBorder: widget.theme?.borderless == true
            ? null
            : (widget.theme?.errorBorder as InputBorder? ??
                widget.scope.application.settings.fields.errorBorder),
        focusedErrorBorder: widget.theme?.borderless == true
            ? null
            : (widget.theme?.focusedErrorBorder as InputBorder? ??
                widget.scope.application.settings.fields.focusedErrorBorder),
        fillColor: focused
            ? (widget.theme?.focusColor ??
                widget.scope.application.settings.fields.focusColor)
            : (widget.theme?.fillColor ??
                widget.scope.application.settings.fields.fillColor),

        hoverColor: widget.theme?.hoverColor ??
            widget.scope.application.settings.fields.hoverColor,
        errorStyle: widget.theme?.errorStyle ??
            widget.scope.application.settings.fields.errorStyle,
        isDense: widget.theme?.isDense ??
            widget.scope.application.settings.fields.isDense,
        suffixIcon: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.readonly == true) return;
            _tabbed = true;

            if (focused && warning == null && _controller.text.isNotEmpty) {
              _editing = false;
              super.submit(_controller.text);
            } else {
              if (_controller.text.isNotEmpty) {
                clear();
              } else {
                _scan();
              }
            }
          },
          child: _getIcon(),
        ),
      ),
    );
  }

  Icon _getIcon() {
    final theme = widget.theme;
    final colors = widget.scope.application.settings.colors;

    if (widget.readonly == true) {
      return Icon(
        Icons.lock_outline,
        color: theme?.suffixIconReadonlyColor ?? theme?.suffixIconColor,
        size: theme?.suffixIconSize,
      );
    }

    if (focused && warning == null && _controller.text.isNotEmpty) {
      return Icon(
        Icons.done,
        color: theme?.suffixIconSuccessColor ?? colors.success,
      );
    } else if (_controller.text.isNotEmpty) {
      return Icon(
        Icons.clear,
        color: theme?.suffixIconColor ?? colors.primary,
      );
    } else {
      return Icon(
        Icons.filter_center_focus,
        color: theme?.suffixIconDangerColor ?? colors.danger,
      );
    }
  }
}
