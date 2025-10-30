import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../page/scope.dart';
import '../blocks/menu.dart';

class MenuButton extends StatelessWidget {
  final PageScope scope;
  final String? caption;
  final IconData? icon;
  final bool visible;
  final bool enabled;
  final Color? color;
  final Color? fill;
  final GestureTapCallback? onTap;
  final EdgeInsets? margin;
  final ContextMenu? contextMenu;

  const MenuButton({
    super.key,
    required this.scope,
    this.caption,
    this.icon,
    this.visible = true,
    this.enabled = true,
    this.color,
    this.fill,
    this.onTap,
    this.margin,
    this.contextMenu,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final appColors = scope.application.settings.colors;
    final radius = scope.application.settings.dialogs.buttonRadius;

    Widget button = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(icon, color: color ?? appColors.primary),
            ),
          Text(
            caption ?? '',
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.15,
              fontWeight: FontWeight.w300,
              color: color ?? appColors.primary,
            ),
          ),
        ],
      ),
    );

    if (!enabled) button = Opacity(opacity: 0.5, child: button);

    // Context menu version
    if (contextMenu?.items.isNotEmpty == true && enabled) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Material(
            color: fill ?? Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
            child: ContextMenuBlock(
              scope: scope,
              offset: contextMenu?.offset ?? Offset.zero,
              child: button,
              items: contextMenu!.items,
            ),
          ),
        ),
      );
    }

    // Default clickable version
    return Container(
      margin: margin,
      child: Material(
        color: fill ?? Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: enabled ? onTap : null,
          enableFeedback: enabled,
          borderRadius: BorderRadius.circular(radius),
          child: button,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// SEARCH BUTTON WITH EXPANSION ANIMATION
// -----------------------------------------------------------

class MenuSearchButton extends StatefulWidget {
  final double? width;
  final Color? textColor;
  final double? buttonRadius;
  final EdgeInsets? margin;
  final String? hintText;
  final Color? hintTextColor;
  final TextStyle? inputTextStyle;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onExpansionComplete;
  final VoidCallback? onCollapseComplete;
  final ValueChanged<bool>? onPressButton;
  final int speed;

  const MenuSearchButton({
    super.key,
    this.width,
    this.textColor,
    this.buttonRadius,
    this.margin,
    this.hintText,
    this.hintTextColor,
    this.inputTextStyle,
    this.textInputType = TextInputType.text,
    this.inputFormatters,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onExpansionComplete,
    this.onCollapseComplete,
    this.onPressButton,
    this.speed = 200,
  });

  @override
  State<MenuSearchButton> createState() => _MenuSearchButtonState();
}

class _MenuSearchButtonState extends State<MenuSearchButton>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final AnimationController _animationController;
  late final FocusNode _focusNode;

  bool _active = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _controller = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.speed),
    );

    _focusNode.addListener(() {
      if (mounted && _active && !_focusNode.hasFocus) {
        _toggle(state: false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle({required bool state}) {
    if (_active == state) return;

    setState(() {
      _active = state;
    });

    widget.onPressButton?.call(_active);

    if (_active) {
      FocusScope.of(context).requestFocus(_focusNode);
      _animationController.forward().then((_) {
        if (mounted) {
          widget.onExpansionComplete?.call();
        }
      });
    } else {
      _unfocusKeyboard();
      _animationController.reverse().then((_) {
        if (mounted) {
          widget.onCollapseComplete?.call();
        }
      });
    }
  }

  void _unfocusKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
      currentFocus.unfocus();
    }
  }

  Widget _textFormField() {
    return TextFormField(
      controller: _controller,
      inputFormatters: widget.inputFormatters,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      keyboardType: widget.textInputType,
      onFieldSubmitted: (value) {
        widget.onFieldSubmitted?.call(value);
      },
      onEditingComplete: () {
        _unfocusKeyboard();
        setState(() => _active = false);
        widget.onEditingComplete?.call();
      },
      onChanged: (value) => widget.onChanged?.call(value),
      onSaved: (value) {
        if (value != null) widget.onSaved?.call(value);
      },
      style: widget.inputTextStyle ??
          const TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 20),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          letterSpacing: 0.15,
          fontWeight: FontWeight.w300,
          color: widget.hintTextColor ?? Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.buttonRadius ?? 20;

    return Container(
      margin: widget.margin,
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: _active ? 0 : 1,
            duration: Duration(milliseconds: widget.speed),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _active ? null : () => _toggle(state: true),
                borderRadius: BorderRadius.circular(radius),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: widget.textColor ?? Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Buscar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: widget.textColor ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: widget.speed),
            height: 36,
            width: _active ? (widget.width ?? 300) : 0,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
            ),
            alignment: Alignment.centerLeft,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _active ? 1 : 0,
                    duration: Duration(milliseconds: widget.speed),
                    child: _textFormField(),
                  ),
                ),
                Positioned(
                  right: 6,
                  child: AnimatedOpacity(
                    opacity: _active ? 1 : 0,
                    duration: Duration(milliseconds: widget.speed),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(radius),
                      onTap: () => _toggle(state: false),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
