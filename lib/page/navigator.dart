import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart';
import '../middleware/application.dart';
import '../middleware/menu.dart';

class PageNavigator extends StatefulWidget {
  final Application application;
  final bool Function(Anxeb.MenuItem item) isActive;
  final bool Function()? isVisible;
  final List<MenuGroup> Function()? groups;
  final String Function()? role;
  final List<String> Function()? roles;
  final Widget Function()? header;
  final Widget Function()? footer;
  final Color? backgroundColor;

  const PageNavigator({
    super.key,
    required this.application,
    required this.isActive,
    this.isVisible,
    this.groups,
    this.role,
    this.roles,
    this.header,
    this.footer,
    this.backgroundColor,
  });

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  late final ScrollController _scrollController;
  bool _showTopButton = false;
  bool _showDownButton = false;

  List<MenuGroup> _groups = [];
  String _role = '';
  List<String> _roles = [];
  Widget? _header;
  Widget? _footer;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final showTop = _scrollController.offset > 0;
      final showDown = _scrollController.offset <
          _scrollController.position.maxScrollExtent - 5;

      if (_showTopButton != showTop || _showDownButton != showDown) {
        setState(() {
          _showTopButton = showTop;
          _showDownButton = showDown;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Recuperar props de callbacks, con fallback
    _groups = widget.groups?.call() ?? [];
    _role = widget.role?.call() ?? '';
    _roles = widget.roles?.call() ?? [];
    _header = widget.header?.call();
    _footer = widget.footer?.call();

    if (_groups.isEmpty || widget.isVisible?.call() == false) {
      return const SizedBox.shrink();
    }

    return Container(
      color: widget.backgroundColor ?? Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header ?? const SizedBox.shrink(),
          Expanded(
            child: Stack(
              children: [
                // 🔹 Contenido scrollable
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final group in _groups) _buildItem(group),
                        if (_footer != null) _footer!,
                      ],
                    ),
                  ),
                ),

                // 🔹 Botones de navegación arriba / abajo
                Column(
                  children: [
                    _getAnimatedButton(
                      icon: Icons.arrow_drop_up_sharp,
                      visible: _showTopButton,
                      onTap: () => _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                      ),
                    ),
                    const Spacer(),
                    _getAnimatedButton(
                      icon: Icons.arrow_drop_down_sharp,
                      visible: _showDownButton,
                      onTap: () => _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.decelerate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =======================================================
  /// Helper: botón animado para scroll
  /// =======================================================
  Widget _getAnimatedButton({
    required IconData icon,
    required bool visible,
    required VoidCallback onTap,
  }) {
    return Material(
      color: widget.backgroundColor ?? Colors.black,
      child: InkWell(
        enableFeedback: true,
        hoverColor: Colors.white24,
        onTap: visible ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.ease,
          height: visible ? 24 : 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                curve: Curves.ease,
                opacity: visible ? 1 : 0,
                child: Icon(icon, size: 24, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =======================================================
  /// Helper: construcción de item del menú
  /// =======================================================
  Widget _buildItem(Anxeb.MenuItem item) {
    final settings = widget.application.settings;
    final activeColor = settings.colors.active;
    final error = item.error ?? item.isError?.call();
    final active = _isItemActive(item);
    const fontSize = 10.0;
    final hidden =
        item.visible == false || (item.isVisible?.call() == false);
    final unauthorized = (item.roles != null &&
            !item.roles!.contains(_role)) ||
        (item.roles != null &&
            !_roles.any((r) => item.roles!.contains(r)));
    final disabled = item.isDisabled?.call() ?? false;
    final enabled = disabled ? false : (item.enabled);

    if (hidden || unauthorized) return const SizedBox.shrink();

    Color textColor = Colors.white;
    if (active) {
      textColor = activeColor;
    } else if (!enabled) {
      textColor = error != null
          ? settings.colors.danger.withAlpha(150)
          : settings.colors.text.withAlpha(90);
    }

    final itemStyle = TextStyle(
      color: textColor,
      fontSize: fontSize,
      letterSpacing: 0.5,
      fontWeight: FontWeight.w400,
    );

    final menuItemContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            color: active ? activeColor : Colors.white,
            size: 30.0 * (item.iconScale ?? 1),
          ),
          const SizedBox(height: 2),
          Text(
            (item.caption?.call() ?? '').toUpperCase(),
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: itemStyle,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                error.toUpperCase(),
                style: TextStyle(
                  color: !enabled
                      ? settings.colors.danger.withAlpha(150)
                      : settings.colors.danger,
                  fontSize: 11,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white24,
          onTap: () async {
            final result = await (item.onTap?.call() ?? Future.value(null));
            if (result != false) setState(() {});
          },
          child: menuItemContent,
        ),
      ),
    );
  }

  /// =======================================================
  /// Helper: determina si un item está activo
  /// =======================================================
  bool _isItemActive(Anxeb.MenuItem item) {
    return item.active;
  }
}
