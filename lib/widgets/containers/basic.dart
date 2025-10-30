import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';

class BasicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? fadding;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Scope scope;
  final bool fixedHeight;

  const BasicContainer({
    super.key,
    required this.child,
    required this.scope,
    this.fadding,
    this.padding,
    this.margin,
    this.fixedHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fixedHeight ? scope.window.available.height : null,
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        padding: Utils.convert.fromInsetToFraction(
          fadding,
          scope.window.size,
        ),
        margin: margin ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}
