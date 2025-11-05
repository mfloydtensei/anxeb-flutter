import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import '../middleware/application.dart';
import '../middleware/menu.dart';
import 'scope.dart';
import 'screen.dart';

class ScreenNavigatorController {
  VoidCallback? _collapse;
  VoidCallback? _home;
  VoidCallback? _exit;
  VoidCallback? _lobby;

  void collapse() => _collapse?.call();
  void home() => _home?.call();
  void exit() => _exit?.call();
  void lobby() => _lobby?.call();

  void _init({
    VoidCallback? collapse,
    VoidCallback? home,
    VoidCallback? exit,
    VoidCallback? lobby,
  }) {
    _collapse = collapse;
    _home = home;
    _exit = exit;
    _lobby = lobby;
  }
}

class ScreenNavigator extends StatefulWidget {
  final ScreenScope scope;
  final bool Function(Anxeb.MenuItem item) isActive;
  final bool Function() isVisible;
  final List<MenuGroup> Function() groups;
  final String Function() role;
  final List<String> Function() roles;
  final Widget Function() header;
  final Widget Function() footer;
  final Color? backgroundColor;
  final ScreenNavigatorController? controller;

  const ScreenNavigator({
    super.key,
    required this.scope,
    required this.isActive,
    required this.isVisible,
    required this.groups,
    required this.role,
    required this.roles,
    required this.header,
    required this.footer,
    this.backgroundColor,
    this.controller,
  });

  @override
  State<ScreenNavigator> createState() => _ScreenNavigatorState();
}

class _ScreenNavigatorState extends State<ScreenNavigator> {
  GlobalKey<ScreenState>? _currentScreenKey;
  late List<MenuGroup> _groups;
  late String _role;
  late List<String> _roles;
  late Widget _header;
  late Widget _footer;

  @override
  void initState() {
    widget.controller?._init(
      collapse: collapse,
      home: home,
      exit: exit,
      lobby: lobby,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _groups = widget.groups();
    _role = widget.role();
    _roles = widget.roles();
    _header = widget.header();
    _footer = widget.footer();

    if (_groups.isEmpty || widget.isVisible() == false) {
      return const SizedBox.shrink();
    }

    return Drawer(
      elevation: 20.0,
      backgroundColor: widget.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _header,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._groups.map((group) => _buildItem(group)),
                _footer,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Anxeb.MenuItem item, [Anxeb.MenuItem? parent]) {
    final hidden = item.visible == false || (item.isVisible?.call() == false);
    final unauthorized = (item.roles != null && !item.roles!.contains(_role)) ||
        (item.roles != null && !_roles.any((r) => item.roles!.contains(r)));

    if (hidden || unauthorized) return const SizedBox.shrink();

    var enabled = item.enabled;
    if (item.isDisabled?.call() == true) enabled = false;

    final error = item.error ?? item.isError?.call();
    final active = _isItemActive(item);

    final app = application;
    final colors = app.settings.colors;
    final activeColor = colors.primary;
    const fontSize = 18.0;

    Color navigationColor = colors.navigation;
    TextStyle itemStyle = TextStyle(
      color: navigationColor,
      fontSize: fontSize,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w400,
    );

    if (active) {
      navigationColor = activeColor;
      itemStyle = itemStyle.copyWith(color: activeColor);
    } else if (!enabled) {
      navigationColor = (error != null)
          ? colors.danger.withAlpha(150)
          : colors.primary.withAlpha(90);
      itemStyle = itemStyle.copyWith(
        color: (error != null)
            ? colors.danger.withAlpha(150)
            : colors.text.withAlpha(90),
      );
    }

    final menuItemContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              right: 16.0 +
                  ((item.iconHOffset ?? 0) < 0 ? -(item.iconHOffset ?? 0) : 0),
              left: (item.iconHOffset ?? 0) > 0 ? (item.iconHOffset ?? 0) : 0,
              bottom: (item.iconVOffset ?? 0) > 0 ? (item.iconVOffset ?? 0) : 0,
              top: (item.iconVOffset ?? 0) < 0 ? -(item.iconVOffset ?? 0) : 0,
            ),
            alignment: Alignment.center,
            width: 42,
            child: Icon(
              item.icon,
              color: navigationColor,
              size: 25.0 * (item.iconScale ?? 1),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.caption?.call() ?? '', style: itemStyle),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      error.toUpperCase(),
                      style: TextStyle(
                        color: !enabled
                            ? colors.danger.withAlpha(150)
                            : colors.danger,
                        fontSize: 11,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    final group = item is MenuGroup ? item : null;
    final anyChildActive = group != null &&
        group.items.isNotEmpty &&
        group.items.any(_isItemActive);

    return Container(
      decoration: BoxDecoration(
        color: active
            ? app.settings.colors.navigation.withValues(alpha: 0.05)
            : Colors.transparent,
        border: item.divider == true
            ? Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: app.settings.colors.separator,
                ),
              )
            : null,
      ),
      child: group != null && group.items.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 8.0,
                    color: app.settings.colors.navigation.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: anyChildActive,
                title: menuItemContent,
                children:
                    group.items.map((subItem) => _buildItem(subItem, group)).toList(),
              ),
            )
          : ListTile(
              dense: error != null,
              enabled: enabled,
              title: menuItemContent,
              onTap: enabled
                  ? () async {
                      final result = await item.onTap?.call();
                      if (result != false) await _onItemTap(item);
                    }
                  : null,
            ),
    );
  }

  Future<void> _onItemTap(Anxeb.MenuItem item) async {
    if (item.home == true) await home();
    if (item.view == null) return;

    final screen = await item.view!(GlobalKey<ScreenState>());
    final result = await push((_) async => screen as ScreenWidget);
    item.result?.call(result);
  }

  void collapse() {
    final scaffold = _parentScreen.scaffold;
    if (scaffold.currentState?.isDrawerOpen == true) {
      scaffold.currentState?.openEndDrawer();
    }
  }

  Future<T?> push<T>(Future<ScreenWidget> Function(Key key) getScreen) async {
    final dismissed = await _currentScreen?.dismiss() ?? true;
    if (!dismissed) return null;

    _currentScreenKey = GlobalKey<ScreenState>();
    final screen = await getScreen(_currentScreenKey!);
    final openedKey = _currentScreenKey;
    final result = await _parentScreen.push<T>(
      screen,
      transition: ScreenTransitionType.fade,
    );

    if (_currentScreenKey == openedKey) _currentScreenKey = null;
    return result;
  }

  Future<void> end() async => await _currentScreen?.pop(force: true);

  Future<bool> home() async {
    final dismissed = await _currentScreen?.dismiss() ?? true;
    if (dismissed) _currentScreenKey = null;
    return dismissed;
  }

  bool _isItemActive(Anxeb.MenuItem item) {
    if (item.active == true) return true;
    if (_currentScreen?.name == item.key) return true;
    if (_currentScreen == null && item.home == true) return true;
    return widget.isActive(item);
  }

  void lobby() => Navigator.of(context).popUntil((route) => route.isFirst);

  Future<bool> exit([dynamic result]) async =>
      await _parentScreen.pop(result: result);

  ScreenState? get _currentScreen =>
      _currentScreenKey?.currentState?.mounted == true
          ? _currentScreenKey?.currentState
          : null;

  ScreenView get _parentScreen => widget.scope.view;
  Application get application => widget.scope.application;
}
