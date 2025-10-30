import 'package:flutter/material.dart';
import 'view.dart';

typedef MenuCallback = Future<dynamic> Function();
typedef ActiveStateCallback = bool Function();
typedef EnabledStateCallback = bool Function();
typedef DisabledStateCallback = bool Function();
typedef VisibleStateCallback = bool Function();
typedef ErrorStateCallback = String? Function();

/// =======================================================
/// MENU ITEM (base class)
/// =======================================================
class MenuItem {
  final String key;
  final Future<IView>? Function(Key key)? view;
  final Function(dynamic data)? result;
  final double? iconScale;
  final double? iconVOffset;
  final double? iconHOffset;
  final MenuCallback? onTap;
  final ActiveStateCallback? isActive;
  final EnabledStateCallback? isEnabled;
  final DisabledStateCallback? isDisabled;
  final VisibleStateCallback? isVisible;
  final ErrorStateCallback? isError;
  final List<String>? roles;
  final bool home;

  final String Function()? caption;
  final String? hint;
  final IconData? icon;
  bool active;
  String? error;
  bool enabled;
  bool visible;
  bool divider;

  MenuItem({
    required this.key,
    this.caption,
    this.hint,
    this.view,
    this.result,
    this.icon,
    this.iconScale,
    this.iconVOffset,
    this.iconHOffset,
    this.active = false,
    this.isActive,
    this.error,
    this.isError,
    this.enabled = true,
    this.isEnabled,
    this.isDisabled,
    this.visible = true,
    this.isVisible,
    this.divider = false,
    this.onTap,
    this.roles,
    this.home = false,
  });

  /// Determina si el ítem debe mostrarse en la UI
  bool get canShow => isVisible?.call() ?? visible;

  /// Determina si el ítem está habilitado
  bool get canTap => isEnabled?.call() ?? enabled;

  /// Determina si el ítem está marcado como activo
  bool get isSelected => isActive?.call() ?? active;

  /// Devuelve un mensaje de error si aplica
  String? get currentError => isError?.call() ?? error;
}

/// =======================================================
/// MENU GROUP (agrupador de items)
/// =======================================================
class MenuGroup extends MenuItem {
  List<MenuItem> items;

  MenuGroup({
    required String Function() caption,
    required String key,
    required IconData icon,
    String? hint,
    Future<IView>? Function(Key key)? view,
    Function(dynamic data)? result,
    double? iconScale,
    double? iconVOffset,
    double? iconHOffset,
    bool active = false,
    ActiveStateCallback? isActive,
    String? error,
    ErrorStateCallback? isError,
    bool enabled = true,
    EnabledStateCallback? isEnabled,
    DisabledStateCallback? isDisabled,
    bool visible = true,
    VisibleStateCallback? isVisible,
    bool divider = false,
    MenuCallback? onTap,
    List<String>? roles,
    bool home = false,
    this.items = const <MenuItem>[],
  }) : super(
          caption: caption,
          hint: hint,
          key: key,
          view: view,
          result: result,
          icon: icon,
          iconScale: iconScale,
          iconVOffset: iconVOffset,
          iconHOffset: iconHOffset,
          active: active,
          isActive: isActive,
          error: error,
          isError: isError,
          enabled: enabled,
          isEnabled: isEnabled,
          isDisabled: isDisabled,
          visible: visible,
          isVisible: isVisible,
          divider: divider,
          onTap: onTap,
          roles: roles,
          home: home,
        );

  /// Agrega un nuevo item al grupo
  MenuItem add(MenuItem item) {
    items.add(item);
    return item;
  }

  /// Reemplaza los items actuales del grupo
  void setup(List<MenuItem> newItems) {
    items = newItems;
  }
}
