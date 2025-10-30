import 'dart:async';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/middleware/window.dart';
import 'package:anxeb_flutter/misc/view_action_locator.dart';
import 'package:anxeb_flutter/parts/headers/search.dart';
import 'package:flutter/material.dart' hide Overlay;
import 'package:flutter_translate/flutter_translate.dart';
import '../misc/after_init.dart';
import '../middleware/action.dart';
import '../middleware/application.dart';
import '../middleware/footer.dart';
import '../middleware/header.dart';
import '../middleware/panel.dart';
import '../middleware/refresher.dart';
import '../middleware/scope.dart';
import '../middleware/tabs.dart';
import '../middleware/view.dart';
import 'scope.dart';
import 'navigator.dart';

enum ScreenPushAction { replace, push }

enum ScreenTransitionType {
  fromBottom,
  fromLeft,
  fromRight,
  fromTop,
  fade,
}

class ScreenWidget<A extends Application> extends StatefulWidget implements IView {
  final String name;
  final String? title;
  final A application;
  final bool root;

  const ScreenWidget(
    this.name, {
    super.key,
    required this.application,
    this.title,
    this.root = false,
  });

  @override
  ScreenView createState() => ScreenView();
}

abstract class ScreenState<T extends ScreenWidget> extends State<T> {
  String get name;
  ScreenScope get scope;

  Future<bool> dismiss();
  Future<bool> submit([dynamic value]);
  Future<bool> pop({dynamic result, bool force = false});
  GlobalKey<ScaffoldState> get scaffold;
}

class ScreenView<T extends ScreenWidget, A extends Application> extends ScreenState<T> with AfterInitMixin<T> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  late ScreenScope _scope;
  late A _application;
  late ScreenHeader? _header;
  late ScreenRefresher? _refresher;
  late ScreenPanel? _panel;
  late ScreenAction? _action;
  late ScreenTabs? _tabs;
  late ScreenFooter? _footer;
  late FloatingActionButtonLocation _locator;
  late _ScreenParts _parts;

  ScreenScope? _parent;

  bool _initialized = false;
  bool _initializing = false;
  bool _postinitialized = false;

  dynamic value;

  @protected
  bool? resizeToAvoidBottomInset;

  void rasterize([VoidCallback? fn]) {
    if (!mounted) {
      fn?.call();
    } else {
      setState(() {
        fn?.call();
      });
    }
  }

  @protected
  Future<void> init() async {}

  @protected
  void setup() {}

  @override
  void didInitState() => _init();

  Future<void> _init() async {
    final args = arguments;
    _application = args.application;
    _parent = args.scope is ScreenScope ? args.scope as ScreenScope : null;
    _scope = ScreenScope(context, this);

    _header = header();
    _refresher = refresher();
    _panel = panel();
    _action = action();
    _tabs = tabs();
    _footer = footer();

    await _scope.setup();
    setup();
    _scope.window.overlay.apply();
  }

  @override
  void initState() {
    super.initState();
    rasterize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkParts();
    _locator = _action?.locator ?? ScreenActionLocator();

    prebuild();
    final $drawer = drawer();

    final scaffoldContent = Scaffold(
      key: _scaffold,
      appBar: _header?.build(),
      drawer: $drawer == true
          ? application.drawer(scope)
          : ($drawer is Drawer || $drawer is ScreenNavigator ? $drawer : null),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      floatingActionButton: _action?.build(),
      floatingActionButtonLocation: _locator,
      bottomNavigationBar: _footer?.build(),
      backgroundColor: _scope.window.overlay.background ?? _scope.application.settings.colors.background,
      extendBody: _scope.window.overlay.extendBody,
      extendBodyBehindAppBar: _scope.window.overlay.extendBodyBehindAppBar,
      body: WillPopScope(
        onWillPop: () async {
          if (_scope.isBusy) return false;
          if (_scope.alerts.isAny) {
            await _scope.alerts.dispose();
            return false;
          }
          if (scaffold.currentState?.isDrawerOpen == true) {
            scaffold.currentState?.openEndDrawer();
            return false;
          }
          if (_header is SearchHeader && (_header as SearchHeader).isActive) {
            (_header as SearchHeader).end();
            return false;
          }

          final result = await beforePop();
          if (result == true) await _beginPop(null);
          return result;
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            _scope.window.update(constraints: viewportConstraints);
            return GestureDetector(
              onTap: () {
                _scope.unfocus();
                _scope.alerts.dispose();
              },
              child: _initializeContent(),
            );
          },
        ),
      ),
    );

    return _tabs?.setup(scaffoldContent) ?? scaffoldContent;
  }

  @protected
  void prebuild() {}

  @protected
  void postinit() {}

  @protected
  dynamic drawer() => null;

  @protected
  Widget content() => const SizedBox.shrink();

  @protected
  ScreenHeader? header() => null;

  @protected
  ScreenRefresher? refresher() => null;

  @protected
  ScreenPanel? panel() => null;

  @protected
  ScreenTabs? tabs() => null;

  @protected
  ScreenAction? action() => null;

  @protected
  ScreenFooter? footer() => null;

  @protected
  Future<bool> beforePop() async => !scope.isBusy;

  @protected
  Future<void> closing() async {}

  @protected
  Future<void> closed() async {}

  @override
  Future<bool> dismiss() async => await pop();

  @override
  Future<bool> submit([dynamic value]) async => await pop(result: value, force: true);

  @override
  Future<bool> pop({dynamic result, bool force = false}) async {
    scope.idle();
    await scope.alerts.dispose(quick: true);

    if (force) {
      await _beginPop(result);
      return true;
    }

    try {
      if (await beforePop()) {
        await _beginPop(result);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<T?> push<T>(
    ScreenWidget screen, {
    ScreenTransitionType transition = ScreenTransitionType.fade,
    int delay = 200,
    ScreenPushAction action = ScreenPushAction.push,
  }) async {
    scope.idle();
    await scope.alerts.dispose(quick: true);

    final settings = RouteSettings(
      name: screen.name,
      arguments: _PushedScreenArguments<A>(
        application: application,
        scope: _scope,
      ),
    );

    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      settings: settings,
      transitionDuration: Duration(milliseconds: delay),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (transition == ScreenTransitionType.fade) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(animation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: .5).animate(secondaryAnimation),
              child: child,
            ),
          );
        }

        Offset from = Offset.zero;
        Offset to = Offset.zero;

        switch (transition) {
          case ScreenTransitionType.fromBottom:
            from = const Offset(0, 1);
            to = const Offset(0, -.5);
            break;
          case ScreenTransitionType.fromLeft:
            from = const Offset(-1, 0);
            to = const Offset(.5, 0);
            break;
          case ScreenTransitionType.fromRight:
            from = const Offset(1, 0);
            to = const Offset(-.5, 0);
            break;
          case ScreenTransitionType.fromTop:
            from = const Offset(0, -1);
            to = const Offset(0, .5);
            break;
          case ScreenTransitionType.fade:
            break;
        }

        return SlideTransition(
          position: Tween<Offset>(begin: from, end: Offset.zero).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset.zero, end: to).animate(secondaryAnimation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0.5).animate(secondaryAnimation),
              child: child,
            ),
          ),
        );
      },
    );

    final result = action == ScreenPushAction.replace
        ? await Navigator.of(_scope.context).pushReplacement(route)
        : await Navigator.of(_scope.context).push(route);

    await _scope.setup();
    if (mounted) {
      setup();
      _scope.window.overlay.apply();
      Future.delayed(const Duration(milliseconds: 150), rasterize);
      Future.delayed(const Duration(milliseconds: 250), rasterize);
    }
    return result as T?;
  }

  void _checkParts() {
    _tabs = _tabs?.rebuild == true ? tabs() : _tabs;
    _header = _header?.rebuild == true ? header() : _header;
    _refresher = _refresher?.rebuild == true ? refresher() : _refresher;
    _panel = _panel?.rebuild == true ? panel() : _panel;
    _action = _action?.rebuild == true ? action() : _action;
    _footer = _footer?.rebuild == true ? footer() : _footer;

    _parts = _ScreenParts(
      header: _header,
      refresher: _refresher,
      panel: _panel,
      action: _action,
      footer: _footer,
      tabs: _tabs,
    );
  }

  Widget _initializeContent() {
    final contentResult = _tabs?.build() ?? content();

    if (!_initialized && !_initializing) {
      _initializing = true;
      Future.microtask(() async {
        await init();
        _initialized = true;
        _initializing = false;
        rasterize();
      });
    } else if (_initialized && !_postinitialized) {
      Future.microtask(() async {
        postinit();
        _postinitialized = true;
        rasterize();
      });
    }
    return contentResult;
  }

  Future<void> _beginPop(dynamic result) async {
    if (scaffold.currentState?.isDrawerOpen == true) {
      scaffold.currentState?.openEndDrawer();
    }
    value = result ?? value;
    await closing();
    if (!widget.root) {
      Navigator.of(_scope.context).pop(value);
    }
    await closed();
  }

  Future<void> process(Future<void> Function() func, {String? busyLabel}) async {
    await scope.busy(text: busyLabel ?? translate('anxeb.common.loading'));
    try {
      await func();
    } catch (err) {
      await scope.alerts.error(err).show();
    } finally {
      await scope.idle();
    }
  }

  bool equals(String name) => this.name == name;

  @override
  String get name => widget.name;

  @override
  ScreenScope get scope => _scope;

  ScreenScope? get parent => _parent;
  Window get window => _scope.window;
  A get application => _application;
  Settings get settings => application.settings;
  @override
  GlobalKey<ScaffoldState> get scaffold => _scaffold;
  String? get title => widget.title;

  bool get isFooter => _footer != null;
  bool get isHeader => _header != null;
  FloatingActionButtonLocation get locator => _locator;
  _PushedScreenArguments<A> get arguments => ModalRoute.of(context)!.settings.arguments as _PushedScreenArguments<A>;
  _ScreenParts get parts => _parts;
}

class _ScreenParts {
  final ScreenHeader? header;
  final ScreenRefresher? refresher;
  final ScreenPanel? panel;
  final ScreenAction? action;
  final ScreenFooter? footer;
  final ScreenTabs? tabs;

  const _ScreenParts({
    this.header,
    this.refresher,
    this.panel,
    this.action,
    this.footer,
    this.tabs,
  });
}

class _PushedScreenArguments<A extends Application> {
  final A application;
  final Scope scope;

  const _PushedScreenArguments({
    required this.application,
    required this.scope,
  });
}
