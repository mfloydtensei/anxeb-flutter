import 'package:flutter/material.dart';

typedef ReferenceLoaderHandler<T> = Future<List<T>> Function(ReferencerPage<T> page, [T? value]);
typedef ReferenceComparerHandler<T> = bool Function(T a, T b);
typedef ReferenceFilterHandler<T> = bool Function(T item, String lookup);
typedef ReferenceItemWidget<T> = Widget Function(ReferencerPage<T> page, T item);
typedef ReferenceHeaderWidget<T> = Widget Function(ReferencerPage<T> page);
typedef ReferenceCreateWidget<T> = Widget Function(ReferencerPage<T> page);
typedef ReferenceEmptyWidget<T> = Widget Function(ReferencerPage<T> page);

class Referencer<V> {
  final ReferenceLoaderHandler<V> loader;
  final ReferenceComparerHandler<V> comparer;
  final ReferenceFilterHandler<V>? filter;
  VoidCallback? updater; // ✅ ya no es final, ahora puede asignarse dinámicamente
  int currentPage = 0;

  late final PageController _pagesController;
  ReferencerPage<V>? _root;
  Function(List<V> result)? _onSubmit;

  Referencer({
    required this.loader,
    required this.comparer,
    this.filter,
  }) {
    _pagesController = PageController(initialPage: 0);
  }

  Future<void> init() async {
    _root = ReferencerPage<V>(referencer: this);
    await _root!.refresh();
  }

  List<ReferencerPage<V>> get pages {
    final result = <ReferencerPage<V>>[];
    var next = _root;
    while (next != null) {
      result.add(next);
      next = next.next;
    }
    return result;
  }

  Future<void> start() async {
    await controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutExpo,
    );
    updater?.call();
  }

  Future<void> back() async {
    if (currentPage > 0) {
      await controller.animateToPage(
        currentPage - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutExpo,
      );
      updater?.call();
    }
  }

  void onSubmit(Function(List<V> result) onSubmit) => _onSubmit = onSubmit;

  int get count => pages.length;

  PageController get controller => _pagesController;

  void notify() => updater?.call();

  void submit(List<V> result) => _onSubmit?.call(result);
}

class ReferencerPage<V> {
  final Referencer<V> _manager;
  final ReferencerPage<V>? _parent;
  ReferencerPage<V>? _next;
  List<V> _items = [];
  V? _selected;
  bool _busy = false;
  String? lookup;

  ReferencerPage({required Referencer<V> referencer, ReferencerPage<V>? parent})
      : _manager = referencer,
        _parent = parent;

  Future<bool> select(V item) async {
    _selected = _items.firstWhere(
      (e) => _manager.comparer(e, item),
      orElse: () => null as V,
    );

    if (_selected != null) {
      final page = ReferencerPage<V>(referencer: _manager, parent: this);
      _busy = true;
      _manager.notify();

      try {
        final alive = await page.refresh();
        if (!alive) {
          _busy = false;
          _manager.notify();
          _manager.submit(_getValues());
          return true;
        }
      } catch (err) {
        _busy = false;
        _manager.notify();
        rethrow;
      }

      _next = page;
      _busy = false;
      _manager.notify();

      await _next!.show();
      _manager.notify();
    }
    return false;
  }

  void filter(String value) {
    lookup = value;
    _manager.notify();
  }

  Future<void> show() async {
    final pages = _manager.pages;
    for (int i = 0; i < pages.length; i++) {
      if (pages[i] == this) {
        await _manager.controller.animateToPage(
          i,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutExpo,
        );
        _manager.notify();
        break;
      }
    }
  }

  Future<bool> refresh() async {
    _busy = true;
    _manager.notify();

    _items = await _manager.loader(this, _parent?.selected);
    _busy = false;
    _manager.notify();

    return _items.isNotEmpty;
  }

  bool isSelected(V item) => selected != null && _manager.comparer(selected!, item);

  bool isBusy(V item) => busy && isSelected(item);

  List<V> _getValues() {
    final result = <V>[];
    var parent = this;
    while (parent._parent != null) {
      if (parent.selected != null) result.add(parent.selected as V);
      parent = parent._parent;
    }
    return result.reversed.toList();
  }

  ReferencerPage<V>? get parent => _parent;

  ReferencerPage<V>? get next => _next;

  V? get selected => _selected;

  Referencer<V> get referencer => _manager;

  List<V> get items {
    if (lookup == null || _manager.filter == null) return _items;
    return _items.where((e) => _manager.filter!(e, lookup!)).toList();
  }

  bool get busy => _busy;

  bool get idle => !_busy;
}
