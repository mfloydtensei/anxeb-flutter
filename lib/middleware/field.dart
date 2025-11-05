import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Overlay;
import '../misc/after_init.dart';
import 'form.dart';
import 'scope.dart';

class FieldWidgetTheme {
  final bool? isDense;
  final Color? fillColor;
  final Color? focusColor;
  final InputBorder? border;
  final Color? prefixIconColor;
  final Color? iconColor;
  final bool? minimal;
  final double? prefixIconSize;
  final Color? hoverColor;
  final TextStyle? hintStyle;
  final TextStyle? displayStyle;
  final TextStyle? errorStyle;
  final TextStyle? inputStyle;
  final TextStyle? suffixStyle;
  final TextStyle? prefixStyle;
  final Color? suffixIconColor;
  final EdgeInsets? contentPaddingWithIcon;
  final EdgeInsets? contentPaddingNoIcon;
  final BorderRadius? disabledBorder;
  final BorderRadius? enabledBorder;
  final BorderRadius? focusedBorder;
  final BorderRadius? errorBorder;
  final BorderRadius? focusedErrorBorder;
  final FontWeight? labelFontWeight;
  final Color? dangerColor;
  final Color? labelColor;
  final double? labelLetterSpacing;
  final double? labelFontSize;
  final String? labelFontFamily;
  final TextStyle? labelStyle;
  final Color? suffixIconReadonlyColor;
  final double? suffixIconSize;
  final Color? suffixIconDangerColor;
  final Color? suffixIconSuccessColor;
  final Color? suffixIconFocusedColor;
  final double? iconSize;
  final double? fontSize;
  final double? labelSize;
  final bool? borderless;
  final bool? fixedLabel;
  final BorderRadius? borderRadius;

  const FieldWidgetTheme({
    this.isDense,
    this.fillColor,
    this.focusColor,
    this.border,
    this.prefixIconColor,
    this.iconColor,
    this.prefixIconSize,
    this.minimal,
    this.hoverColor,
    this.hintStyle,
    this.displayStyle,
    this.errorStyle,
    this.inputStyle,
    this.suffixStyle,
    this.prefixStyle,
    this.suffixIconColor,
    this.contentPaddingWithIcon,
    this.contentPaddingNoIcon,
    this.disabledBorder,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.labelFontWeight,
    this.dangerColor,
    this.labelColor,
    this.labelLetterSpacing,
    this.labelFontSize,
    this.labelFontFamily,
    this.labelStyle,
    this.suffixIconReadonlyColor,
    this.suffixIconSize,
    this.suffixIconDangerColor,
    this.suffixIconSuccessColor,
    this.suffixIconFocusedColor,
    this.iconSize,
    this.fontSize,
    this.labelSize,
    this.borderless,
    this.fixedLabel,
    this.borderRadius,
  });
}

class FieldWidget<V> extends StatefulWidget {
  final Scope scope;
  final String name;
  final String? group;
  final String? label;
  final IconData? icon;
  final IconData? sufixIcon;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool readonly;
  final bool? visible;
  final ValueChanged<V?>? onSubmitted;
  final ValueChanged<V?>? onApplied;
  final ValueChanged<V?>? onChanged;
  final GestureTapCallback? onTab;
  final GestureTapCallback? onBlur;
  final GestureTapCallback? onFocus;
  final FormFieldValidator<V?>? validator;
  final V? Function(dynamic value)? parser;
  final FieldFocusType? focusType;
  final Future<V?> Function()? fetcher;
  final ValueChanged<V?>? applier;
  final bool? initialSelected;
  final FieldWidgetTheme? theme;

   FieldWidget({
    required this.scope,
    Key? key,
    required this.name,
    this.group,
    this.label,
    this.icon,
    this.margin,
    this.padding,
    this.readonly = false,
    this.visible,
    this.onSubmitted,
    this.onApplied,
    this.onChanged,
    this.onTab,
    this.onBlur,
    this.onFocus,
    this.validator,
    this.parser,
    this.focusType,
    required this.fetcher,
    required this.applier,
    this.initialSelected,
    this.theme,
    this.sufixIcon,
  })  : assert(name != ''),
        super(key: key ?? scope.forms.key(group ?? scope.key, name));

  @override
Field<V, FieldWidget<V>> createState() => Field<V, FieldWidget<V>>();

}

abstract class FieldState<V, F extends FieldWidget<V>> extends State<F> {
  int index = 0;
  V? value;
  bool focused = false;
  bool isEmpty = true;
  bool busy = false;

  void focus({String? warning});
  void select();
  String? validate({bool showMessage = true});
  bool valid();
  void reset();
  dynamic data();
  void fetch();
  void apply();
}

class Field<V, F extends FieldWidget<V>> extends FieldState<V, F>
    with AfterInitMixin<F> {
  V? _value;
  bool _focused = false;
  int index = 0;
  String? _warning;
  bool _initialized = false;
  bool _hovering = false;

  @protected
  late FocusNode focusNode;

  @protected
  dynamic data() => value;

  @protected
  void present() {}

  @protected
  Future<V?> lookup() async => null;

  @protected
  String? label() => null;

  @protected
  bool get hasValue => value != null;

  @protected
  bool get canClear => false;

  @protected
  Widget display([String? text]) {
    return Padding(
      padding: !hasValue ? const EdgeInsets.only(top: 5) : EdgeInsets.zero,
      child: Text(
        text ?? value?.toString() ?? widget.label ?? '',
        style: widget.theme?.displayStyle ??
            TextStyle(
              fontSize: (widget.theme?.fontSize ?? 16) * 0.9,
              color: hasValue
                  ? widget.scope.application.settings.colors.text
                  : const Color(0x88000000),
            ),
      ),
    );
  }

  void rasterize([VoidCallback? fn]) {
    if (!mounted) return;
    setState(() {
      fn?.call();
    });
  }

  @protected
  void init() {}

  @protected
  void setup() {}

  @override
  void didInitState() {
    setup();
    if (!_initialized) {
      _initialized = true;
      widget.fetcher?.call().then((fvalue) {
        value = fvalue;
        if (widget.initialSelected == true) {
          select();
        }
      });
    }
  }

  @protected
  void focus({String? warning}) {
    this.warning = warning;
    if (mounted && focusNode.context != null && !focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  @protected
  void select() {}

  void unfocus() => widget.scope.unfocus();

  void reset() {
    if (!mounted) return;
    setState(() {
      warning = null;
      value = null;
    });
  }

  Future<V?> fetch([bool apply = true]) async {
    if (apply) {
      value = await widget.fetcher?.call();
      return value;
    } else {
      return await widget.fetcher?.call();
    }
  }

  void apply() {
    widget.applier?.call(value);
    Future.delayed(const Duration(milliseconds: 150), () {
      widget.onApplied?.call(value);
      widget.scope.rasterize();
    });
  }

  String? validate({bool showMessage = true, bool apply = true}) {
    final validation = _getValidation(value);
    if (showMessage) {
      warning = validation;
    } else {
      warning = null;
      if (apply) this.apply();
    }
    return validation;
  }

  bool valid() {
    final result = _getValidation(value) == null;
    if (result) apply();
    return result;
  }

  @protected
  void submit(V? newValue) {
    final warningMsg = _getValidation(newValue);
    focus(warning: warningMsg);
    widget.onSubmitted?.call(value);
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode.addListener(() {
      if (widget.readonly == true) return;

      if (mounted) {
        if (!focusNode.hasFocus) {
          if (isEmpty) warning = null;
          setState(() => _focused = false);
          onBlur();
          widget.onBlur?.call();
        } else {
          setState(() => _focused = true);
          onFocus();
          widget.onFocus?.call();
        }
      }
    });

    form.include(this);
    init();
    if (mounted) rasterize();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visible == false) return Container();
    prebuild();
    return Container(
      padding: widget.padding,
      margin: widget.margin,
      child: field(),
    );
  }

  @protected
  void clear() {
    validate(apply: false);
    Future.delayed(Duration.zero, () {
      reset();
      widget.onChanged?.call(null);
      apply();
    });
  }

  @protected
  void prebuild() {}

  @protected
  void onFocus() {}

  @protected
  void onBlur() {}

  @protected
  String? hint() => null;

  @protected
  Widget field() {
    return MouseRegion(
      cursor: widget.readonly == true
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onHover: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          if (widget.readonly == true) return;
          focus();
          _beginLookup();
        },
        child: FormField(
          builder: (FormFieldState<dynamic> state) {
            return InputDecorator(
              isFocused: _focused,
              decoration: InputDecoration(
                filled: true,
                fillColor: _hovering
                    ? (widget.theme?.hoverColor ?? widget.theme?.fillColor)
                    : widget.theme?.fillColor,
                contentPadding: widget.theme?.contentPaddingWithIcon ??
                    widget.scope.application.settings.fields
                        .contentPaddingWithIcon,
                prefixIcon: widget.theme?.minimal == true
                    ? null
                    : Icon(
                        widget.icon,
                        size: widget.theme?.prefixIconSize,
                        color: widget.theme?.prefixIconColor ??
                            widget.scope.application.settings.colors.primary,
                      ),
                labelText: label() ??
                    (hasValue
                        ? (widget.theme?.fixedLabel == true
                            ? widget.label?.toUpperCase()
                            : widget.label)
                        : null),
                labelStyle: widget.theme?.labelStyle ??
                    TextStyle(
                      fontWeight: widget.theme?.labelFontWeight,
                      color: widget.theme?.labelColor,
                      letterSpacing: widget.theme?.labelLetterSpacing,
                      fontSize: widget.theme?.labelSize,
                    ),
                floatingLabelBehavior: widget.theme?.fixedLabel == true
                    ? FloatingLabelBehavior.always
                    : null,
                hintText: hint(),
                hintStyle: widget.theme?.hintStyle ??
                    widget.scope.application.settings.fields.hintStyle,
                iconColor: widget.theme?.iconColor ??
                    widget.scope.application.settings.fields.iconColor,
                suffixIcon: widget.theme?.minimal == true
                    ? null
                    : MouseRegion(
                        cursor: widget.readonly == true
                            ? SystemMouseCursors.basic
                            : SystemMouseCursors.click,
                        child: GestureDetector(
                          dragStartBehavior: DragStartBehavior.down,
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (widget.readonly == true) return;
                            if (hasValue || canClear) {
                              clear();
                            } else {
                              _beginLookup();
                            }
                          },
                          child: _getIcon(),
                        ),
                      ),
              ),
              child: display(),
            );
          },
        ),
      ),
    );
  }

  void _beginLookup() async {
    final result = await lookup();
    if (result != null) submit(result);
  }

  Widget _getIcon() {
    if (busy) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.scope.application.settings.colors.primary,
            ),
          ),
        ),
      );
    }

    if (widget.readonly == true) {
      return Icon(Icons.lock_outline,
          color: widget.scope.application.settings.colors.primary);
    }

    if (hasValue || canClear) {
      return Icon(Icons.clear,
          color: widget.scope.application.settings.colors.primary);
    }

    return Icon(widget.sufixIcon ?? Icons.search,
        color: widget.scope.application.settings.colors.danger);
  }

  @protected
  void setValueSilent(dynamic val) {
    if (val == null) {
      _value = null;
    } else {
      _value = widget.parser?.call(val);
    }
  }

  String? _getValidation(V? val) =>
      widget.visible != false ? widget.validator?.call(val) : null;

  @protected
  String? get warning => _warning;

  @protected
  set warning(String? val) {
    rasterize(() => _warning = val);
  }

  V? get value => _value;

  set value(V? val) {
    _value = val;
    present();
    rasterize();
  }

  bool get focused => _focused;

  FieldsForm get form => widget.scope.forms[widget.group ?? widget.scope.key];

  bool get isEmpty => value?.toString().isEmpty ?? true;
}

enum FieldFocusType { refocus, unfocus, next, empty }
