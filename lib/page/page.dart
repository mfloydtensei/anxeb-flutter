import 'dart:async';
import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:flutter/material.dart' hide Overlay;
import '../misc/after_init.dart';

enum PagePushAction { replace, push }

/// =======================================================
/// PageMiddleware
/// =======================================================
class PageMiddleware<A extends Application, M extends PageInfo<A, M>> {
  final A application;
  final Future<String?> Function(
    BuildContext context,
    GoRouterState state,
    PageScope<A, M> scope, [
    M? info,
  ])? redirect;

  late M info;

  PageScope<A, M> get scope => info.scope!;

  PageMiddleware({
    required this.application,
    this.redirect,
  });
}

/// =======================================================
/// PageWidget
/// =======================================================
class PageWidget<A extends Application, M extends PageInfo<A, M>>
    extends StatefulWidget implements IView {
  final String name;
  final String path;
  final _PageArgs<A, M> _meta = _PageArgs<A, M>();

   PageWidget(
    this.name, {
    super.key,
    required this.path,
  });

  @override
  PageView<PageWidget<A, M>, A, M> createState() => PageView<PageWidget<A, M>, A, M>();


  @protected
  List<PageWidget Function()> childs() => [];

  Future<void> init(
    PageMiddleware<A, M> middleware, {
    BuildContext? context,
    GoRouterState? state,
    M? parent,
  }) async {
    _meta.middleware = middleware;
    prepare(context, state, parent: parent);
  }

  void prepare(
    BuildContext? context,
    GoRouterState? state, {
    PageContainer<A, M>? container,
    M? parent,
  }) {
    _meta.info = _meta.info;

    _meta.info
      .._name = state?.name
      .._context = context
      .._state = state
      .._container = container
      .._parent = parent;
    middleware.info = _meta.info;

    // 🔹 Ejecutar preload si existe
    final extra = state?.extra;
    if (extra is Map && extra['preload'] is Function) {
      if (state?.matchedLocation == state?.uri.toString()) {
        extra['preload'](_meta.info);
        extra['preload'] = null;
      }
    }
  }

  @protected
  M? setup(GoRouterState? state) => null;

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    if (middleware.redirect == null) return null;
    return await middleware.redirect!(
      context,
      state,
      info.scope ?? middleware.scope,
      info,
    );
  }

  List<RouteBase> getRoutes([String? prefix]) {
    final items = childs();
    final routes = <RouteBase>[];

    for (final getPage in items) {
      final page = getPage();
      page.init(middleware);

      final name = page.name.startsWith('_')
          ? '${prefix ?? this.name}${page.name}'
          : page.name;

      routes.add(
        GoRoute(
          name: name,
          path: page.path,
          pageBuilder: (context, state) {
            page.prepare(context, state, parent: info);
            return transitionBuilder(context: context, state: state, child: page);
          },
          redirect: (context, state) async => await page.redirect(context, state),
          routes: page.getRoutes(name),
        ),
      );
    }
    return routes;
  }

  static CustomTransitionPage transitionBuilder<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 50),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  M get info => _meta.info;
  PageMiddleware<A, M> get middleware => _meta.middleware;
  A get application => middleware.application;
}

/// =======================================================
/// PageState / PageView
/// =======================================================
abstract class PageState<
    T extends PageWidget<A, dynamic>,
    A extends Application,
    M extends PageInfo<A, dynamic>>
    extends State<T> {
  Future<bool> dismiss();
  Future<bool> submit([dynamic value]);
  Future<bool> pop({dynamic result, bool force});
}

class PageView<T extends PageWidget<A, M>, A extends Application, M extends PageInfo<A, M>>
    extends PageState<T, A, M> with AfterInitMixin<T> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  late final PageScope<A, M> _scope;

  bool _initialized = false;
  bool _initializing = false;
  bool _postinitialized = false;

  void rasterize([VoidCallback? fn]) {
    if (!mounted) return;
    setState(() => fn?.call());
  }

  @protected
  Future<void> init() async {}

  @override
  void initState() {
    super.initState();
  }

  @protected
  Future<void> setup([dynamic value]) async {}

  @override
  void didInitState() {
    _init();
  }

  Future<void> _init() async {
    _scope = PageScope<A, M>(context, this);
    widget.info._scope = _scope;

    await _scope.setup();
    widget.info._onChildPoped = ([value]) async {
      await setup();
      rasterize();
    };

    if (!_initialized && !_initializing) {
      _initializing = true;
      await init();
      if (info.state?.matchedLocation == info.state?.uri.toString()) {
        await setup();
        rasterize();
      }
      _initialized = true;
      _initializing = false;
    } else if (_initialized && !_postinitialized) {
      postinit();
      _postinitialized = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    prebuild();

    final drawerWidget = drawer();

    final scaffoldContent = Scaffold(
      key: _scaffold,
      resizeToAvoidBottomInset: true,
      drawer: drawerWidget == true
          ? application.drawer(scope)
          : (drawerWidget is Drawer ? drawerWidget : null),
      backgroundColor: application.settings.colors.background,
      extendBody: _scope.window.overlay.extendBody,
      extendBodyBehindAppBar: _scope.window.overlay.extendBodyBehindAppBar,
    body: PopScope(
  canPop: true,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;

    if (_scope.isBusy) return;

    if (_scope.alerts.isAny) {
      await _scope.alerts.dispose();
      return;
    }

    if (_scaffold.currentState?.isDrawerOpen == true) {
      _scaffold.currentState?.openEndDrawer();
      return;
    }

    final shouldPop = await beforePop();
    if (shouldPop) {
      await _beginPop(null);
    }
  },
  child: LayoutBuilder(
    builder: (context, constraints) {
      _scope.window.update(constraints: constraints);
      return GestureDetector(
        onTap: () {
          _scope.unfocus();
          _scope.alerts.dispose();
        },
        child: _initialized ? content() : const SizedBox.shrink(),
      );
    },
  ),
),


    );

    return scaffoldContent;
  }

  /// =======================================================
  /// Lifecycle helpers
  /// =======================================================
  @protected
  void prebuild() {}

  @protected
  void postinit() {}

  @protected
  dynamic drawer() => null;

  @protected
  Widget content() => const SizedBox.shrink();

  @protected
  Future<bool> beforePop() async => !scope.isBusy;

  @protected
  Future<void> closing() async {}

  @protected
  Future<void> closed() async {}

  Future<bool> dismiss() async => await pop();

  Future<bool> submit([dynamic value]) async => await pop(result: value, force: true);

  Future<bool> pop({dynamic result, bool force = false}) async {
    await scope.idle();
    await scope.alerts.dispose(quick: true);

    if (force) {
      await _beginPop(result);
      return true;
    }

    try {
      final value = await beforePop();
      if (value) {
        await _beginPop(result);
        return true;
      }
    } catch (_) {}
    return false;
  }

  void go(
    String route, {
    bool force = false,
    Map<String, String>? params,
    Map<String, dynamic>? query,
    void Function(M info)? preload,
  }) async {
    await scope.idle();
    final value = force ? true : await beforePop();

    if (value) {
      await scope.alerts.dispose(quick: true);
      scope.context.goNamed(
        route,
        pathParameters: params ?? const {},
        queryParameters: query ?? const {},
        extra: {'preload': preload},
      );
    }
  }

  Future<void> push(
    String route, {
    bool force = false,
    Map<String, String>? params,
    Map<String, dynamic>? query,
  }) async {
    await scope.idle();
    final value = force ? true : await beforePop();

    if (value) {
      await scope.alerts.dispose(quick: true);
      scope.context.pushNamed(
        route,
        pathParameters: params ?? const {},
        queryParameters: query ?? const {},
      );
    }
  }

  Future<void> _beginPop(dynamic result) async {
    await closing();
    if (info.parent != null) {
      info.parent!._onChildPoped?.call(result);
    }
    _scope.context.pop();
    await closed();
  }

  Future<void> process(Future<void> Function() func, {String? busyLabel}) async {
    await scope.busy(text: busyLabel ?? translate('anxeb.common.loading'));
    try {
      await func();
    } catch (err) {
      scope.alerts.error(err).show();
    } finally {
      await scope.idle();
    }
  }

  bool equals(String path) => widget.path == path;

  // Getters
  String get path => widget.path;
  PageScope<A, M> get scope => _scope;
  Window get window => _scope.window;
  A get application => widget.middleware.application;
  Settings get settings => application.settings;
  M get info => widget.info;
  PageContainer<A, M> get container => info.container!;
  GlobalKey<ScaffoldState> get scaffold => _scaffold;
}

/// =======================================================
/// _PageArgs & PageInfo
/// =======================================================
class _PageArgs<A extends Application, M extends PageInfo<A, M>> {
  late M info;
  late PageMiddleware<A, M> middleware;
}

class PageInfo<A extends Application, M extends PageInfo<A, M>> {
  String? _name;
  BuildContext? _context;
  GoRouterState? _state;
  PageContainer<A, M>? _container;
  PageInfo<A, M>? _parent;
  PageScope<A, M>? _scope;
  Future<void> Function([dynamic value])? _onChildPoped;

  String? get name => _name;
  BuildContext? get context => _context;
  GoRouterState? get state => _state;
  PageContainer<A, M>? get container => _container;
  PageInfo<A, M>? get parent => _parent;
  PageScope<A, M>? get scope => _scope;
}
