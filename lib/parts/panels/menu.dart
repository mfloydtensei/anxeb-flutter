import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';
import 'board.dart';

class MenuPanel extends BoardPanel {
  final List<PanelMenuItem> items;
  final double? textScale;
  final double? iconScale;
  final bool? horizontal;
  final bool? autoHide;
  final double? itemHeight;
  final double? buttonRadius;
  final Color? fillColor;
  @override
  final bool rebuild;

  MenuPanel({
    required Scope scope,
    required this.items,
    double? height,
    this.rebuild = false,
    bool Function()? isDisabled,
    this.itemHeight,
    this.textScale,
    this.iconScale,
    this.horizontal,
    this.autoHide,
    this.buttonRadius,
    bool gapless = false,
    Color? barColor,
    this.fillColor,
  }) : super(
          scope: scope,
          height: height ?? 400,
          isDisabled: isDisabled,
          gapless: gapless,
          barColor: barColor,
        );

  @override
  double get dynamicHeight {
    final visibleCount = items
        .where((item) =>
            item.isVisible?.call() != false &&
            item.actions.any((a) => a.isVisible?.call() != false))
        .length;

    final baseHeight = itemHeight ?? 60;
    return (baseHeight * visibleCount) + 80;
  }

  static Widget getButtons({
    required List<PanelMenuItem> items,
    bool? horizontal,
    double? iconScale,
    double? textScale,
    Future<void> Function()? collapse,
    double? buttonRadius,
    required BuildContext context,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .where((item) => item.isVisible?.call() != false)
          .map((item) {
            final actions = item.actions
                .where((a) => a.isVisible?.call() != false)
                .map((a) {
              final buttonContent = Container(
                width: item.width?.call(),
                padding: item.padding?.call(),
                alignment: Alignment.center,
                child: horizontal == true
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            a.icon(),
                            color: a.iconColor?.call() ?? Colors.white,
                            size: 48.0 *
                                (a.iconScale ?? 1) *
                                (iconScale ?? 1),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            a.label?.call().toUpperCase() ?? '',
                            textAlign: TextAlign.left,
                           textScaler: TextScaler.linear((a.textScale ?? 1.05) * (textScale ?? 1)),
                            style: TextStyle(
                              color: a.textColor?.call() ?? Colors.white,
                              letterSpacing: -0.1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            a.icon(),
                            color: a.iconColor?.call() ?? Colors.white,
                            size: 48.0 *
                                (a.iconScale ?? 1) *
                                (iconScale ?? 1),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            a.label?.call().toUpperCase() ?? '',
                            textAlign: TextAlign.center,
                           textScaler: TextScaler.linear((a.textScale ?? 1.05) * (textScale ?? 1)),
                            style: TextStyle(
                              color: a.textColor?.call() ?? Colors.white,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
              );

              final br = BorderRadius.all(Radius.circular(buttonRadius ?? 10));
              final fill = a.fillColor?.call() ?? Colors.white.withValues(alpha: 0.2);

              final button = a.isDisabled?.call() == true
                  ? Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: br,
                      ),
                      child: Opacity(
                        opacity: 0.5,
                        child: buttonContent,
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(8),
                      child: Material(
                        color: fill,
                        borderRadius: br,
                        child: InkWell(
                          onTap: () async {
                            await collapse?.call();
                            a.onPressed?.call();
                          },
                          borderRadius: br,
                          child: buttonContent,
                        ),
                      ),
                    );

              return Expanded(child: button);
            }).toList();

            if (actions.isEmpty) return const SizedBox.shrink();

            return Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions,
              ),
            );
          })
          .toList(),
    );
  }

  @override
  Widget content([Widget? child]) {
    final visible = items.any((item) => item.actions.any((a) =>
        a.isVisible?.call() != false && a.isDisabled?.call() != true));

    if (autoHide == true && !visible) return const SizedBox.shrink();

    return super.content(
      Container(
        margin: const EdgeInsets.only(top: 5),
        child: getButtons(
          items: items,
          horizontal: horizontal,
          iconScale: iconScale,
          collapse: super.collapse,
          textScale: textScale,
          buttonRadius: buttonRadius,
          context: scope.context,
        ),
      ),
    );
  }

  @protected
  @override
  BoxShadow get shadow => const BoxShadow(
        offset: Offset(0, 0),
        blurRadius: 5,
        spreadRadius: 3,
        color: Color(0x3f555555),
      );

  @override
  Color get fill => fillColor ?? scope.application.settings.colors.navigation;

  @override
  double get paddings => 8;

  @override
  double get margins => 0;

  @override
  double get radius => 0;
}

class PanelMenuItem {
  final List<PanelMenuAction> actions;
  final bool Function()? isVisible;
  final double Function()? height;
  final double Function()? width;
  final EdgeInsets Function()? padding;

  const PanelMenuItem({
    required this.actions,
    this.isVisible,
    this.height,
    this.width,
    this.padding,
  });
}

class PanelMenuAction {
  final IconData Function() icon;
  final String Function()? label;
  final bool Function()? isVisible;
  final bool Function()? isDisabled;
  final VoidCallback? onPressed;
  final double? iconScale;
  final double? textScale;
  final Color Function()? iconColor;
  final Color Function()? fillColor;
  final Color Function()? textColor;

  const PanelMenuAction({
    required this.icon,
    this.label,
    this.isVisible,
    this.isDisabled,
    this.onPressed,
    this.iconScale,
    this.textScale,
    this.iconColor,
    this.fillColor,
    this.textColor,
  });
}
