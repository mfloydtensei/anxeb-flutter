import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';

class ScrollableContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? fadding;
  final EdgeInsets? padding;
  final Gradient? gradient;
  final ScrollController? controller;
  final Scope scope;
  final bool fixedHeight;
  final bool disablePhysics;

  const ScrollableContainer({
    super.key,
    required this.child,
    required this.scope,
    this.fadding,
    this.padding,
    this.gradient,
    this.controller,
    this.fixedHeight = false,
    this.disablePhysics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradient != null ? BoxDecoration(gradient: gradient) : null,
      height: fixedHeight ? scope.window.available.height : null,
      child: SingleChildScrollView(
        physics: disablePhysics
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        controller: controller,
        child: Container(
          padding: Utils.convert.fromInsetToFraction(
            fadding ?? EdgeInsets.zero,
            scope.window.size,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
