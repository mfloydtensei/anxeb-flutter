import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/misc/icons.dart' as AnxebIcons;
import 'package:flutter/material.dart' hide Dialog, IconButton, TextButton;
import 'package:flutter/services.dart';

class FormDialog<V, A extends Application> extends ScopeDialog<V> {
  final V model;
  final String title;
  final double width;
  final double? height;
  final String? subtitle;
  final IconData? icon;
  final EdgeInsets? headerPadding;
  final EdgeInsets? contentPadding;
  final EdgeInsets? footerPadding;
  final EdgeInsets? insetPadding;
  final BorderRadius? borderRadius;
  final MainAxisAlignment? buttonAlignment;
  /// Si es true, el diálogo envuelve con RawKeyboardListener y gestiona ESC y focus.
  final bool? dismissable;

  late final Radius _cornerRadius;
  FormScope<A>? _scope;
  Color? _headerFillColor;
  Color? _footerFillColor;
  EdgeInsets? _headerPadding;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _tabsKey = GlobalKey();
  int _index = 0;

  FormDialog(
    Scope scope, {
    required this.model,
    required this.title,
    required this.width,
    this.height,
    this.subtitle,
    this.icon,
    this.headerPadding,
    this.contentPadding,
    this.footerPadding,
    this.insetPadding,
    this.borderRadius,
    this.buttonAlignment,
    this.dismissable,
    bool? dismissible,
    Key? key,
  }) : super(scope) {
    // Conserva el comportamiento original del framework
    if (dismissible != null) {
      super.dismissible = dismissible;
    }
    _cornerRadius = Radius.circular(scope.application.settings.dialogs.dialogRadius);
  }

  @protected
  void init(FormScope<A> scope) {}

  @protected
  Widget? body(FormScope<A> scope) => null;

  @protected
  List<TabItem> tabs(FormScope<A> scope) => const [];

  @protected
  List<FormButton> buttons(FormScope<A> scope) => const [];

  @override
  Widget build(BuildContext context) {
    final dialogKey = GlobalKey();

    return StatefulBuilder(
      key: dialogKey,
      builder: (context, setState) {
        final mustInit = _scope == null;
        _scope = _scope ?? FormScope<A>(
          context,
          parent: scope,
          setState: setState,
          key: dialogKey,
        );
        if (mustInit) {
          init(_scope!);
        }

        final content = _getTabsWidget() ?? _getBodyWidget() ?? const SizedBox();
        final header = _getDialogHeader();

        final dialog = AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ??
                BorderRadius.all(Radius.circular(scope.application.settings.dialogs.dialogRadius)),
          ),
          contentPadding: EdgeInsets.zero,
          // buttonPadding fue removido de AlertDialog en versiones recientes
          actionsPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          insetPadding: insetPadding ?? const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          contentTextStyle: TextStyle(
            fontSize: 16.4,
            color: scope.application.settings.colors.text,
            fontWeight: FontWeight.w400,
          ),
          title: header,
          content: content,
        );

        if (dismissable != true) {
          return dialog;
        }

        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            // Manejo moderno de ESC (solo en KeyDown para evitar repeticiones)
            if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(_context).pop(null);
            }
          },
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_focusNode);
            },
            child: dialog,
          ),
        );
      },
    );
  }

  Widget? _getTabsWidget() {
    final t = tabs.call(_scope!);
    if (t.isEmpty) return null;

    _headerFillColor = scope.application.settings.dialogs.headerColor;
    _footerFillColor = scope.application.settings.dialogs.footerColor;
    _headerPadding = const EdgeInsets.only(left: 18, top: 18, right: 18, bottom: 6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: height ?? 400,
          margin: const EdgeInsets.only(bottom: 1),
          color: Colors.white,
          child: DefaultTabController(
            key: _tabsKey,
            length: t.length,
            child: Column(
              children: [
                Material(
                  color: _headerFillColor,
                  child: TabBar(
                    indicatorColor: scope.application.settings.colors.success,
                    indicatorPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    onTap: (index) {
                      _scope!.rasterize(() {
                        _index = index;
                      });
                    },
                    tabs: t
                        .map(
                          ($tab) => Tab(
                            height: 28,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4, top: 2),
                                  child: Icon(
                                    $tab.icon?.call(),
                                    color: scope.application.settings.colors.primary,
                                    size: 18,
                                  ),
                                ),
                                Text(
                                  $tab.caption?.call() ?? '',
                                  style: TextStyle(
                                    color: scope.application.settings.colors.primary,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: contentPadding ?? const EdgeInsets.only(left: 18, right: 18, top: 18),
                    child: TabBarView(
                        children: t.map((e) => e.body?.call() ?? const SizedBox()).toList(),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _getDialogFooter(),
      ],
    );
  }

  Widget? _getBodyWidget() {
    final b = body.call(_scope!);
    if (b == null) return null;

    _headerFillColor = null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(bottom: 1),
          color: Colors.white,
          child: Padding(
            padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 18),
            child: b,
          ),
        ),
        _getDialogFooter(),
      ],
    );
  }

  Widget _getDialogFooter() {
    final formButtons = buttons(_scope!);
    final effectiveFooter = footerPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    final warn = _scope!.warning;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: _footerFillColor,
        borderRadius: BorderRadius.only(
          bottomLeft: _cornerRadius,
          bottomRight: _cornerRadius,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: effectiveFooter.left), // simétrico manteniendo compatibilidad
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: effectiveFooter.top),
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              child: warn == null
                  ? const SizedBox.shrink()
                  : Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: warn.fillColor ?? Colors.red,
                        borderRadius: BorderRadius.all(
                          Radius.circular(scope.application.settings.dialogs.buttonRadius),
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            child: Icon(
                              warn.icon ?? AnxebIcons.Typicons.warning,
                              color: warn.iconColor ?? Colors.white,
                              size: 16,
                            ),
                          ),
                          Expanded(
                            child: warn.body ??
                                Text(
                                  warn.message ?? '',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: warn.textColor ?? Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 8),
                            child: IconButton(
                              padding: const EdgeInsets.only(left: 12),
                              iconSize: 18,
                              fillColor: Colors.transparent,
                              innerColor: Colors.white,
                              size: 24,
                              icon: Icons.close,
                              action: () async {
                                _scope!.warning = null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Row(
              mainAxisAlignment: buttonAlignment ?? MainAxisAlignment.end,
              children: formButtons
                  .where(($button) => $button.visible != false)
                  .map(($button) {
                final btn = TextButton(
                  caption: $button.caption,
                  padding: scope.application.settings.dialogs.buttonPaddingWithIcon,
                  radius: scope.application.settings.dialogs.buttonRadius,
                  icon: $button.icon ?? Icons.help_outline,
                  enabled: $button.enabled ?? true,
                  swapIcon: $button.swapIcon ?? false,
                  color: $button.fillColor ?? scope.application.settings.colors.primary,
                  textColor: $button.textColor ?? Colors.white,
                  margin: EdgeInsets.only(
                    left: formButtons.first == $button ? 0 : 4,
                    right: formButtons.last == $button ? 0 : 4,
                  ),
                  onPressed: () async {
                    final result = await $button.onTap?.call(_scope!);
                    if (result == false) {
                      Navigator.of(_context).pop(null);
                    } else if (result == null) {
                      // ignore
                    } else {
                      Navigator.of(_context).pop(result is V ? result : model);
                    }
                  },
                  type: ButtonType.primary,
                  size: ButtonSize.small,
                  textStyle: scope.application.settings.dialogs.buttonTextStyle,
                );

                final isLast = formButtons.last == $button;

                return Row(
                  children: [
                    if ($button.leftDivisor == true)
                      Container(
                        height: 32,
                        padding: const EdgeInsets.only(right: 10),
                        child: DottedLine(
                          direction: Axis.vertical,
                          lineLength: double.infinity,
                          lineThickness: 1,
                          dashLength: 2,
                          dashColor: scope.application.settings.colors.primary,
                          dashRadius: 0.0,
                          dashGapLength: 4.0,
                          dashGapColor: Colors.transparent,
                        ),
                      ),
                    Container(
                      width: btn.width,
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
                      child: btn,
                    ),
                    if ($button.rightDivisor == true)
                      Container(
                        height: 32,
                        padding: const EdgeInsets.only(right: 10),
                        child: DottedLine(
                          direction: Axis.vertical,
                          lineLength: double.infinity,
                          lineThickness: 1,
                          dashLength: 2,
                          dashColor: scope.application.settings.colors.primary,
                          dashRadius: 0.0,
                          dashGapLength: 4.0,
                          dashGapColor: Colors.transparent,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDialogHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _headerFillColor,
        borderRadius: BorderRadius.only(topLeft: _cornerRadius, topRight: _cornerRadius),
      ),
      padding: headerPadding ?? _headerPadding ?? const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(right: 7),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 1.0, color: scope.application.settings.colors.separator),
              ),
            ),
            child: Icon(
              icon, // Icon admite null y renderiza vacío si no hay dato
              size: 46,
              color: scope.application.settings.colors.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    color: scope.application.settings.colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Text(
                      subtitle!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: scope.application.settings.colors.primary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(right: 2, bottom: 6),
              child: InkWell(
                onTap: () async {
                  final result = await close?.call(_scope!);
                  if (result == false) {
                    Navigator.of(_context).pop(null);
                  } else if (result == null) {
                    // ignore
                  } else {
                    Navigator.of(_context).pop(result is V ? result : model);
                  }
                },
                borderRadius: BorderRadius.circular(100),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get index => _index;

  // model es required y no-nullable; existe siempre
  bool get exists => true;

  BuildContext get _context => _scope!.context;

  FormScope<A> get formScope => _scope!;

  @protected
  void pop([dynamic result]) {
    Navigator.of(_context).pop(result ?? model);
  }

  @protected
  Future<dynamic> Function(FormScope<A> scope)? get close => null;
}

class FormWarning {
  final Widget? body;
  final String? message;
  final Color? fillColor;
  final Color? textColor;
  final IconData? icon;
  final Color? iconColor;
  final dynamic meta;

  const FormWarning({
    this.body,
    this.message,
    this.fillColor,
    this.textColor,
    this.icon,
    this.iconColor,
    this.meta,
  });
}

class FormScope<A extends Application> extends Scope implements IScope {
  final GlobalKey _key;
  final Scope parent;
  final StateSetter _setState;
  FormWarning? _warning;

  FormScope(
    BuildContext context, {
    required this.parent,
    required StateSetter setState,
    required GlobalKey key,
  })  : _setState = setState,
        _key = key,
        super(context);

  @override
  A get application => parent.application as A;

  @override
  String get key => parent.key;

  @override
  String get title => parent.title;

  @override
  bool get mounted => _key.currentState?.mounted ?? false;

  @override
  void rasterize([VoidCallback? fn]) {
    _setState(fn ?? () {});
  }

  FormWarning? get warning => _warning;

  set warning(FormWarning? value) {
    var setWarning = true;

    if (value?.meta != null) {
      final meta = value!.meta;
      final fieldsMeta = (meta is Map && meta['fields'] is Iterable) ? meta['fields'] as Iterable : null;

      if (fieldsMeta != null) {
        for (final item in fieldsMeta) {
          try {
            final name = (item is Map && item['name'] is String) ? item['name'] as String : '';
            if (name.isEmpty) continue;

            final parts = name.split('.');
            final form = parts.length > 1 ? forms[parts.first] : forms.current;
            final field = parts.length > 1 ? form.fields[parts.last] : form.fields[name];
            if (field != null) {
              field.focus(warning: value.message);
              setWarning = false;
            }
          } catch (_) {
            // Si algo falla al enfocar, mantenemos el warning visible.
          }
        }
      }
    }

    if (setWarning) {
      rasterize(() {
        _warning = value;
      });
    } else {
      _warning = null;
    }
  }
}

class FormSpacer extends StatelessWidget {
  final bool? column;

  const FormSpacer({super.key, this.column});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: column == true ? 18 : 0,
      width: column != true ? 10 : 0,
    );
  }
}

class FormRowContainer extends StatelessWidget {
  final Scope scope;
  final String? title;
  final bool? visible;
  final IconData? icon;
  final List<Widget>? fields; // (Se mantiene por compatibilidad aunque no se usa aquí)
  final Widget child;
  final bool? latest;
  final double? height;

  const FormRowContainer({
    super.key,
    required this.scope,
    this.title,
    this.visible,
    this.icon,
    this.fields,
    required this.child,
    this.latest,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (visible == false) return const SizedBox();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          margin: const EdgeInsets.only(bottom: 8, top: 12),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (icon != null) Icon(icon, size: 12, color: scope.application.settings.colors.primary),
                  Expanded(
                    child: Text(
                      (title ?? '').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: DottedLine(
                  direction: Axis.horizontal,
                  lineLength: double.infinity,
                  lineThickness: 1,
                  dashLength: 2,
                  dashColor: scope.application.settings.colors.primary,
                  dashRadius: 0.0,
                  dashGapLength: 4.0,
                  dashGapColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
