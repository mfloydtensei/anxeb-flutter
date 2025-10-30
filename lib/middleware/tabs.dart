import 'package:flutter/material.dart';
import '../screen/scope.dart';

class ScreenTabs {
  final ScreenScope scope;
  final List<TabItem> items;
  final int? initial;
  final bool rebuild;
  final void Function(TabItem item)? onChange;
  final void Function(TabItem item)? onTap;

  late TabController _controller;
   BuildContext? _context;
  int _currentIndex = 0;

  ScreenTabs({
    required this.scope,
    required this.items,
    this.initial,
    this.onChange,
    this.onTap,
    this.rebuild = false,
  });

  /// Permite sobrescribir si se necesita en subclases
  @protected
  ScreenTabs? tabs() => null;

  /// Cambia manualmente la pestaña activa
  void select(int index) {
    if (_controller.indexIsChanging || index == _controller.index) return;
    _controller.animateTo(index, duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
  }

  /// Construye el header del TabBar
  PreferredSizeWidget header({
    Widget? bottomBody,
    double Function()? height,
  }) {
    final visibleTabs = _filteredItems.map((item) => item.build()).toList();

    return PreferredSize(
      preferredSize: Size.fromHeight(height?.call() ?? 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bottomBody != null) bottomBody,
          TabBar(
            controller: _controller,
            isScrollable: true,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            labelColor: scope.application.settings.colors.active,
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            tabs: visibleTabs,
          ),
        ],
      ),
    );
  }

  /// Construye el contenido de cada pestaña
  Widget build({bool initialized = true}) {
    return TabBarView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: _filteredItems.map((item) {
        Widget content = initialized ? (item.body?.call() ?? const SizedBox.shrink()) : const SizedBox.shrink();

        // Encapsula con refresher y panel si están disponibles
        final refresher = scope.view.parts.refresher;
        final panel = scope.view.parts.panel;
        content = refresher.wrap(content);
        content = panel.wrap(content);

        return content;
      }).toList(),
    );
  }

  /// Inicializa el TabController dentro de un Scaffold
  Widget setup(Scaffold scaffold) {
  return DefaultTabController(
    length: _filteredItems.length,
    initialIndex: initial ?? 0,
    child: Builder(
      builder: (context) {
        _context = context; // ✅ ahora ya está declarada arriba
        _controller = DefaultTabController.of(context);
        _controller.addListener(_controllerListener);
        return scaffold;
      },
    ),
  );
}


  void _controllerListener() {
    if (!_controller.indexIsChanging && _controller.index != _currentIndex) {
      _currentIndex = _controller.index;
      final currentTab = current;

      onTap?.call(currentTab);
      Future.delayed(const Duration(milliseconds: 150), () {
        onChange?.call(currentTab);
        scope.rasterize();
      });
    }
  }

  /// Devuelve los items visibles (según su callback)
  List<TabItem> get _filteredItems => items.where((tab) => tab.isVisible?.call() ?? true).toList();

  /// Devuelve el TabItem actual
  TabItem get current => _filteredItems[_controller.index];

  /// Índice actual
  int get currentIndex => _controller.index;

  /// Datos del tab actual (si aplica)
  dynamic get currentData => current.data;
}

class TabItem {
  final dynamic data;
  final String? name;
  final String Function()? caption;
  final IconData Function()? icon;
  final bool Function()? isVisible;
  final VoidCallback? onPressed;
  final Widget Function()? body;

  const TabItem({
    this.caption,
    this.name,
    this.icon,
    this.isVisible,
    this.onPressed,
    this.body,
    this.data,
  });

  Widget build() {
    final String title = caption?.call() ?? '';
    final IconData? iconData = icon?.call();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(iconData, size: 18),
            ),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
