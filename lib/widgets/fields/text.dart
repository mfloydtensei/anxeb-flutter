import 'package:anxeb_flutter/middleware/field.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

enum TextInputFieldType {
  digits,
  decimals,
  positive,
  integers,
  natural,
  text,
  email,
  date,
  phone,
  url,
  password,
  maskedDigits,
  pin
}

class TextInputField<V> extends FieldWidget<V> {
  final TextEditingController? controller;
  final TextInputFieldType? type;
  final TextInputFormatter? formatter;
  final bool autofocus;
  final TextInputAction? action;
  final ValueChanged<V?>? onActionSubmit;
  final TextCapitalization capitalization;
  final bool canSelect;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final V Function(String value)? converter;
  final String Function(V? value)? displayText;
  final int? maxLines;
  final int? maxLength;
  final bool suffixActions;
  final int? errorMaxLines;
  final bool selectOnFocus;
  final bool disableCounter;

  TextInputField({
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
    ValueChanged<V?>? onSubmitted,
    ValueChanged<V?>? onApplied,
    ValueChanged<V?>? onChanged,
    GestureTapCallback? onTab,
    GestureTapCallback? onBlur,
    GestureTapCallback? onFocus,
    FormFieldValidator<V?>? validator,
    V? Function(dynamic value)? parser,
    FieldFocusType? focusType,
    bool selected = false,
    Future<V?> Function()? fetcher,
    Function(V?)? applier,
    FieldWidgetTheme? theme,
    this.controller,
    this.type = TextInputFieldType.text,
    this.autofocus = false,
    this.action,
    this.onActionSubmit,
    this.capitalization = TextCapitalization.none,
    this.canSelect = true,
    this.hint,
    this.prefix,
    this.suffix,
    this.converter,
    this.displayText,
    this.maxLines = 1,
    this.maxLength,
    this.suffixActions = true,
    this.errorMaxLines,
    this.selectOnFocus = false,
    this.formatter,
    this.disableCounter = false,
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
          initialSelected: selected,
          fetcher: fetcher,
          applier: applier,
          theme: theme,
        );

  @override
  Field<V, TextInputField<V>> createState() => _TextInputFieldState<V>();
}

class _TextInputFieldState<V> extends Field<V, TextInputField<V>> {
  late TextEditingController _controller;
  final TextEditingController _displayController = TextEditingController();
  bool _obscureText = true;
  bool _editing = false;
  bool _tabbed = false;

  @override
  void init() {
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void focus({String? warning}) {
    if (widget.selectOnFocus) select();
    super.focus(warning: warning);
  }

  @override
  void select() {
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
  }

  List<TextInputFormatter> get _formatters {
    return widget.formatter != null ? [widget.formatter!] : [];
  }

  TextInputType get _keyboardType {
    switch (widget.type) {
      case TextInputFieldType.decimals:
        return const TextInputType.numberWithOptions(decimal: true, signed: true);
      case TextInputFieldType.positive:
        return const TextInputType.numberWithOptions(decimal: true, signed: false);
      case TextInputFieldType.natural:
      case TextInputFieldType.digits:
      case TextInputFieldType.maskedDigits:
      case TextInputFieldType.pin:
        return const TextInputType.numberWithOptions(decimal: false, signed: false);
      case TextInputFieldType.integers:
        return const TextInputType.numberWithOptions(decimal: false, signed: true);
      case TextInputFieldType.email:
        return TextInputType.emailAddress;
      case TextInputFieldType.date:
        return TextInputType.datetime;
      case TextInputFieldType.phone:
        return TextInputType.phone;
      case TextInputFieldType.url:
        return TextInputType.url;
      case TextInputFieldType.password:
      case TextInputFieldType.text:
      default:
        return widget.maxLines != null && widget.maxLines! > 1
            ? TextInputType.multiline
            : TextInputType.text;
    }
  }

  @override
  void onBlur() {
    _displayController.text = widget.displayText?.call(value) ?? '';
    _obscureText = true;
    if (_editing) {
      _editing = false;
      _convertAndSubmit(_controller.text);
    }
    super.onBlur();
  }

  @override
  void onFocus() {
    if (widget.selectOnFocus) select();
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
      _controller.clear();
      _editing = false;
    }
  }

  @override
  void present() {
    _controller.text = value?.toString() ?? '';
    _displayController.text = widget.displayText?.call(value) ?? '';
    if (widget.capitalization == TextCapitalization.characters) {
      _controller.text = _controller.text.toUpperCase();
    }
  }

  @override
  Widget field() {
    if (!focused) {
      _displayController.text = widget.displayText?.call(value) ?? '';
    }

    return TextField(
      autofocus: widget.autofocus,
      obscureText: _obscureText &&
          (widget.type == TextInputFieldType.password || widget.type == TextInputFieldType.pin),
      focusNode: focusNode,
      textInputAction: widget.action,
      textCapitalization: widget.capitalization,
      controller: focused && !(widget.readonly) ? _controller : _displayController,
     readOnly: widget.readonly,
      enableInteractiveSelection: widget.canSelect,
      autocorrect: false,
      inputFormatters: _formatters,
      maxLength: focused ? widget.maxLength : null,
      maxLines: widget.maxLines == 0 ? null : widget.maxLines,
      keyboardType: _keyboardType,
      onSubmitted: (text) {
        _editing = false;
        _convertAndSubmit(text);
        widget.onActionSubmit?.call(value);
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
      onChanged: (text) {
        final val = _convertValue(text);
        super.setValueSilent(val);
        if (!_editing) warning = null;
        _editing = true;
        widget.onChanged?.call(val);
      },
      textAlign: TextAlign.left,
      style: widget.theme?.inputStyle ??
          (widget.theme?.fontSize != null ? TextStyle(fontSize: widget.theme?.fontSize) : null),
      decoration: InputDecoration(
        filled: true,
        counterText: widget.disableCounter ? '' : null,
        contentPadding:
            widget.theme?.contentPaddingWithIcon ?? const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                size: widget.theme?.iconSize,
                color: widget.theme?.prefixIconColor ??
                    widget.scope.application.settings.colors.primary,
              )
            : null,
        labelText: widget.label,
        hintText: widget.hint,
        errorText: warning,
        errorMaxLines: widget.errorMaxLines,
        fillColor: focused
            ? (widget.theme?.focusColor ??
                widget.scope.application.settings.fields.focusColor)
            : (widget.theme?.fillColor ??
                widget.scope.application.settings.fields.fillColor),
        suffixIcon: widget.suffixActions
            ? GestureDetector(
                onTap: _handleSuffixTap,
                child: _getIcon(),
              )
            : null,
      ),
    );
  }

  V? _convertValue(String text) => widget.converter?.call(text);

  void _convertAndSubmit(String text) => super.submit(_convertValue(text));

  void _handleSuffixTap() {
    if (widget.readonly) return;
    _tabbed = true;

    if (widget.type == TextInputFieldType.password || widget.type == TextInputFieldType.pin) {
      if (_controller.text.isEmpty) {
        focus();
      } else if (focused) {
        setState(() => _obscureText = !_obscureText);
      } else {
        clear();
      }
    } else {
      if (focused && warning == null) {
        _convertAndSubmit(_controller.text);
      } else if (_controller.text.isNotEmpty) {
        clear();
      } else {
        focus();
      }
    }
  }

  Icon _getIcon() {
    if (widget.readonly) {
      return Icon(Icons.lock_outline,
          color: widget.theme?.suffixIconReadonlyColor ??
              widget.theme?.suffixIconColor ??
              widget.scope.application.settings.colors.text);
    }

    if (widget.type == TextInputFieldType.password || widget.type == TextInputFieldType.pin) {
      if (_controller.text.isEmpty) {
        return Icon(Icons.keyboard_arrow_left,
            color: widget.theme?.suffixIconDangerColor ??
                widget.scope.application.settings.colors.danger);
      }
      return Icon(
        _obscureText ? Icons.visibility : Icons.visibility_off,
        semanticLabel: _obscureText
            ? translate('anxeb.widgets.fields.text.show_label')
            : translate('anxeb.widgets.fields.text.hide_label'),
        color: widget.theme?.suffixIconFocusedColor ??
            widget.theme?.suffixIconColor ??
            widget.scope.application.settings.colors.primary,
      );
    }

    if (focused && warning == null) {
      return Icon(Icons.done,
          color: widget.theme?.suffixIconSuccessColor ??
              widget.scope.application.settings.colors.success);
    }

    if (_controller.text.isNotEmpty) {
      return Icon(Icons.clear,
          color: widget.theme?.suffixIconColor ??
              widget.scope.application.settings.colors.primary);
    }

    return Icon(Icons.keyboard_arrow_left,
        color: widget.theme?.suffixIconDangerColor ??
            widget.scope.application.settings.colors.danger);
  }
}
