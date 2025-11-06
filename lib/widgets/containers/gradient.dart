import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? fadding;
  final EdgeInsets? padding;
  final Gradient? gradient;
  final Scope scope;
  final Image? image;

  const GradientContainer({
    super.key,
    required this.child,
    required this.scope,
    this.fadding,
    this.padding,
    this.gradient,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: scope.window.available.height,
        child: Stack(
          children: [
            // Fondo con gradiente (si existe)
            if (gradient != null)
              Container(
                decoration: BoxDecoration(gradient: gradient),
              ),

            // Imagen superpuesta opcional
            if (image != null) image!,

            // Contenido principal
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: Container(
                padding: Utils.convert.fromInsetToFraction(
                  fadding ?? EdgeInsets.zero,
                  scope.window.size,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
