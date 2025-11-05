import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';
import 'paragraph.dart';

class EmptyBlock extends StatelessWidget {
  final Scope scope;
  final String? message;
  final IconData? icon;
  final bool loading;
  final VoidCallback? actionCallback;
  final String? actionText;
  final bool visible;
  final double? iconScale;
  final bool fawIcon;
  final bool tight;
  final EdgeInsets? margin;
  final Color? fillColor;

  const EmptyBlock({
    super.key,
    required this.scope,
    this.message,
    this.icon,
    this.loading = false,
    this.actionCallback,
    this.actionText,
    this.visible = true,
    this.iconScale,
    this.fawIcon = false,
    this.tight = false,
    this.margin,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final colors = scope.application.settings.colors;
    final iconColor = fillColor ?? colors.navigation.withValues(alpha: 0.1);

    // 🔹 Ícono o indicador de carga
    Widget iconWidget = SizedBox(
      height: 110,
      child: Icon(
        icon ?? Icons.hourglass_empty,
        size: 110 * (iconScale ?? 1.0) * (fawIcon ? 0.8 : 1.0),
        color: iconColor,
      ),
    );

    if (loading) {
      iconWidget = Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 50 * (iconScale ?? 1.0) * (fawIcon ? 0.8 : 1.0),
        width: 50 * (iconScale ?? 1.0) * (fawIcon ? 0.8 : 1.0),
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(
            fillColor ?? colors.primary.withValues(alpha: 0.8),
          ),
        ),
      );
    }

    // 🔹 Mensaje
    Widget messageWidget = const SizedBox.shrink();
    if (message != null && message!.isNotEmpty) {
      messageWidget = Container(
        margin: const EdgeInsets.only(top: 5),
        child: ParagraphBlock(
          alignment: TextAlign.center,
          content: [
            TextSpan(text: message!),
          ],
        ),
      );
    }

    // 🔹 Acción (botón inferior)
    Widget actionWidget = const SizedBox.shrink();
    if (actionText != null && actionText!.isNotEmpty && actionCallback != null) {
      actionWidget = Container(
        margin: const EdgeInsets.only(top: 10),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: actionCallback,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: ParagraphBlock(
                alignment: TextAlign.center,
                content: [
                  TextSpan(
                    text: actionText!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.link,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 🔹 Contenido principal
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        messageWidget,
        actionWidget,
      ],
    );

    // 🔹 Versión compacta o centrada
    if (tight) {
      return Container(
        margin: margin,
        width: size.width * 0.66,
        child: content,
      );
    }

    final bool hasFooter = scope is ScreenScope &&
        (scope as ScreenScope).view.isFooter == true;

    return Center(
      child: Container(
        width: size.width * 0.66,
        margin: margin ??
            EdgeInsets.only(
              bottom: size.height *
                  (0.07 + (hasFooter ? 0 : 0.03)),
            ),
        child: content,
      ),
    );
  }
}
