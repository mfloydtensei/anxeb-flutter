import 'package:flutter/material.dart';

class PlaceholderBlock extends StatelessWidget implements PreferredSizeWidget {
  final double Function() height;
  final Widget Function() body;
  final bool Function()? isVisible;

  const PlaceholderBlock({
    super.key,
    required this.height,
    required this.body,
    this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final visible = isVisible?.call() ?? true;
    if (!visible) return const SizedBox.shrink();

    return body();
  }

  @override
  Size get preferredSize => Size.fromHeight(height());
}
