import 'dart:async';
import 'package:anxeb_flutter/screen/scope.dart';
import 'package:anxeb_flutter/misc/action_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'actions.dart';

class SearchHeader extends ActionsHeader {
  final bool actionRightPositioned;
  final int Function()? submitDelay;
  final String? hint;
  final Future<void> Function(String text)? onSearch;
  final Future<void> Function()? onClear;
  final Future<void> Function(String text)? onCompleted;
  final Future<void> Function()? onBegin;

  late final TextEditingController _inputController;
  late final FocusNode _focusNode;
  String _currentText = '';
  bool _active = false;
  bool _busy = false;
  Timer? _writeTimer;

  SearchHeader({
    required ScreenScope scope,
    Widget Function()? title,
    List<ActionItem>? actions,
    VoidCallback? dismiss,
    VoidCallback? back,
    ActionIcon? leading,
    Widget Function()? bottom,
    double Function()? elevation,
    double Function()? height,
    this.actionRightPositioned = false,
    this.hint,
    this.submitDelay,
    this.onSearch,
    this.onClear,
    this.onCompleted,
    this.onBegin,
  }) : super(
          scope: scope,
          dismiss: dismiss,
          back: back,
          leading: leading,
          title: title,
          bottom: bottom,
          elevation: elevation,
          height: height,
          actions: actions,
        ) {
    // Agregar ícono de búsqueda
    final searchItem = ActionIcon(
      icon: () => Icons.search,
      onPressed: _beginSearch,
    );

    if (actionRightPositioned) {
      super.actions?.add(searchItem);
    } else {
      super.actions?.insert(0, searchItem);
    }

    _init();
  }

  void _init() {
    _inputController = TextEditingController();
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _active && !_busy) {
        _endSearch();
      }
    });

    _inputController.addListener(() {
      final delay = submitDelay?.call() ?? 0;
      final text = _inputController.text;

      if (delay > 0) {
        _writeTimer?.cancel();
        _writeTimer = Timer(Duration(milliseconds: delay), () {
          _lookup(text);
        });
      } else {
        _lookup(text);
      }
    });
  }

  Future<void> _lookup(String text) async {
    if (_currentText != text && onSearch != null) {
      _currentText = text;
      _busy = true;
      if (scope.mounted) scope.rasterize();
      await onSearch!(text);
      _busy = false;
      if (scope.mounted) scope.rasterize();
    }
  }

  Future<void> clear({bool inactivate = false}) async {
    _busy = true;
    if (scope.mounted) scope.rasterize();
    await onClear?.call();
    _inputController.clear();
    _currentText = '';
    _busy = false;
    if (inactivate) _active = false;
    if (scope.mounted) scope.rasterize();
  }

  Future<void> _beginSearch() async {
    _active = true;
    _busy = true;
    if (scope.mounted) scope.rasterize();
    await onBegin?.call();
    _inputController.clear();
    _currentText = '';
    _focusSearch();
    _busy = false;
    if (scope.mounted) scope.rasterize();
  }

  Future<void> _endSearch() async {
    _busy = true;
    if (scope.mounted) scope.rasterize();

    final result = _inputController.text;
    _inputController.clear();
    _currentText = '';
    _active = false;
    _busy = false;

    await onCompleted?.call(result);
    if (scope.mounted) scope.rasterize();
  }

  Future<void> end() async => await _endSearch();

  void _focusSearch() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (scope.mounted) {
        scope.focus(_focusNode);
        _inputController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _inputController.text.length,
        );
      }
    });
  }

  AppBar _buildSearchBar() {
    final List<Widget> actions = [];

    if (_busy) {
      actions.add(
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(right: 15),
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    } else if (_inputController.text.isNotEmpty) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: clear,
        ),
      );
    }

    return AppBar(
      title: TextField(
        controller: _inputController,
        focusNode: _focusNode,
        autofocus: true,
        cursorColor: Colors.white,
        decoration: InputDecoration.collapsed(
          hintText: hint ?? translate('anxeb.parts.headers.search.hint_text'),
          border: InputBorder.none,
          hintStyle: const TextStyle(
            color: Colors.white60,
            fontSize: 20.0,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: const TextStyle(
          decoration: TextDecoration.none,
          textBaseline: TextBaseline.alphabetic,
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w400,
        ),
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        onSubmitted: (_) => _endSearch(),
        onTap: _focusSearch,
        onChanged: (_) {
          if (scope.mounted) scope.rasterize();
        },
      ),
      actions: actions,
      bottom: (scope.view.parts.tabs?.header(
                bottomBody: bottom?.call(),
                height: height,
              )) ??
          (bottom?.call() as PreferredSizeWidget?),
      automaticallyImplyLeading: false,
      leading: BackButton(onPressed: _endSearch),
    );
  }

  String get text => _currentText;

  bool get isActive => _active;
  bool get isNotEmpty => _currentText.isNotEmpty;
  bool get isEmpty => _currentText.isEmpty;

  @override
  PreferredSizeWidget build() => _active ? _buildSearchBar() : super.build();

  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    _writeTimer?.cancel();
  }
}
