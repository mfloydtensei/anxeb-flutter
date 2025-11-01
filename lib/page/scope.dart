import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/widgets.dart';
import '../middleware/application.dart';
import '../middleware/scope.dart';
import 'page.dart';

class PageScope<A extends Application, M extends PageInfo<A, M>>
    extends Scope implements IScope {
  final Anxeb.PageView<PageWidget<A, M>, A, M> view;

  PageScope(BuildContext context, this.view) : super(context);

  /// Navegación dentro del PageView
  void go(
    String route, {
    bool force = false,
    Map<String, String>? params,
    Map<String, dynamic>? query,
    void Function(M info)? preload,
  }) async {
    view.go(
      route,
      force: force,
      params: params,
      query: query,
      preload: preload,
    );
  }

  /// Push dentro del PageView
  void push(
    String route, {
    Map<String, String>? params,
    Map<String, dynamic>? query,
  }) async {
    view.push(route, params: params, query: query);
  }

  /// ===========================================================
  /// Overrides de Scope / IScope
  /// ===========================================================
  @override
  A get application => view.application;

  @override
  String get key => view.path;

  @override
  bool get mounted => view.mounted;

  @override
  void rasterize([VoidCallback? fn]) => view.rasterize(fn);
}
