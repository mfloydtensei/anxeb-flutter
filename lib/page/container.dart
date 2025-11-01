import 'package:flutter/material.dart' hide Overlay;
import 'package:go_router/go_router.dart';

import '../middleware/application.dart';
import 'page.dart';
import 'scope.dart';

/// =======================================================
/// PageContainer
/// Contenedor genérico para manejar navegación y middleware
/// =======================================================
class PageContainer<A extends Application, M extends PageInfo<A, M>> {

  late final PageMiddleware<A, M> _middleware;
  late final BuildContext _context;
  late final GoRouterState _state;

  /// Método opcional para configuración inicial
  @protected
  Future<void> setup() async {}

  /// Permite envolver el contenido de cada página (opcional)
  Widget build(BuildContext context, GoRouterState state, Widget child) {
    return child;
  }

  /// Devuelve las páginas a registrar en las rutas
  @protected
  List<PageWidget Function()> pages() => [];

  /// Inicializa el middleware
  Future<void> init(PageMiddleware<A, M> middleware) async {
    _middleware = middleware;
    await setup();
  }

  /// Prepara el contexto y el estado actual
  Future<void> prepare(BuildContext context, GoRouterState state) async {
    _context = context;
    _state = state;
  }

  /// Navegación simplificada dentro del scope
  void go(String route) {
    scope.go(route);
  }

  /// Construye las rutas usando GoRouter
  List<RouteBase> getRoutes() {
    final routes = <RouteBase>[];
    final items = pages();

    for (final getPage in items) {
      final page = getPage();
      page.init(_middleware);

      routes.add(
        GoRoute(
          name: page.name,
          path: '/${page.path}',
          pageBuilder: (context, state) {
            page.prepare(context, state, container: this);
            return PageWidget.transitionBuilder(
              context: context,
              state: state,
              child: page,
            );
          },
          redirect: (context, state) async => await page.redirect(context, state),
          routes: page.getRoutes(),
        ),
      );
    }
    return routes;
  }

  /// =======================================================
  /// Getters convenientes
  /// =======================================================
  PageMiddleware<A, M> get middleware => _middleware;
  A get application => _middleware.application;
  PageScope<A, M> get scope => _middleware.scope;
  M get info => _middleware.info;
  BuildContext get context => _context;
  GoRouterState get state => _state;
}
