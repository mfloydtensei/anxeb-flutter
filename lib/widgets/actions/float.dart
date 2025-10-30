import 'package:flutter/material.dart';
import '../../screen/scope.dart';

class FloatAction extends StatefulWidget {
  final ScreenScope scope;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool disabled;
  final List<AltAction> alternates;
  final double separation;
  final double topOffset;
  final double bottomOffset;
  final bool mini;

  const FloatAction({
    super.key,
    required this.scope,
    this.color,
    this.icon,
    this.onPressed,
    this.disabled = false,
    this.alternates = const [],
    this.separation = 50,
    this.topOffset = 15,
    this.bottomOffset = 0,
    this.mini = false,
  });

  @override
  State<FloatAction> createState() => _FloatActionState();
}

class _FloatActionState extends State<FloatAction> {
  @override
  Widget build(BuildContext context) {
    final double separation = widget.separation;
    final double bottom = widget.bottomOffset;
    final double offset = widget.topOffset + bottom;

    final List<Widget> actions = [];

    for (int i = 0; i < widget.alternates.length; i++) {
      final alt = widget.alternates[i];
      final bool disabled = alt.isDisabled?.call() ?? false;
      final bool visible = alt.isVisible?.call() ?? true;
      final IconData icon = alt.icon?.call() ?? Icons.keyboard_arrow_left;
      final Color color = alt.color?.call() ?? Colors.blue;
      final double sepOffset = separation * (i + 1);
      final bool mini = alt.isMini?.call() ?? true;

      if (visible) {
        actions.add(
          Positioned(
            bottom: sepOffset + offset,
            child: Opacity(
              opacity: disabled ? 0.6 : 1,
              child: FloatingActionButton(
                heroTag: '${widget.key}_alt_$i',
                mini: mini,
                onPressed: disabled ? null : alt.onPressed,
                backgroundColor: color,
                child: Icon(icon),
              ),
            ),
          ),
        );
      }
    }

    final double padding = (widget.alternates.length * separation) + (offset - 5);
    widget.scope.view.locator.setAltOffset(padding);

    // Acción principal
    actions.insert(
      0,
      Container(
        padding: EdgeInsets.only(top: padding, bottom: bottom),
        child: Opacity(
          opacity: widget.disabled ? 0.6 : 1,
          child: FloatingActionButton(
            heroTag: '${widget.key}_main',
            mini: widget.mini,
            onPressed: widget.disabled ? null : widget.onPressed,
            backgroundColor: widget.color ?? Theme.of(context).colorScheme.primary,
            child: Icon(widget.icon ?? Icons.add),
          ),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.only(bottom: padding),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: actions,
      ),
    );
  }
}

class AltAction {
  final IconData Function()? icon;
  final VoidCallback? onPressed;
  final Color Function()? color;
  final bool Function()? isDisabled;
  final bool Function()? isVisible;
  final bool Function()? isMini;

  const AltAction({
    this.icon,
    this.onPressed,
    this.color,
    this.isDisabled,
    this.isVisible,
    this.isMini,
  });
}
