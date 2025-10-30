import 'package:anxeb_flutter/parts/sheets/notification.dart';
import 'package:anxeb_flutter/parts/sheets/tip.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'scope.dart';

/// =======================================================
/// BASE CLASS FOR SHEETS
/// =======================================================
class ScopeSheet {
  final Scope scope;

  const ScopeSheet(this.scope);

  @protected
  Widget build(BuildContext context) => const SizedBox.shrink();

  Future<void> show() async {
    return showModalBottomSheet<void>(
      context: scope.context,
      elevation: elevation,
      barrierColor: barrierColor,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) => build(context),
    );
  }

  @protected
  double get elevation => 10.0;

  @protected
  Color get barrierColor => Colors.black54;
}

/// =======================================================
/// SHEET MANAGER
/// =======================================================
class ScopeSheets {
  final Scope _scope;

  const ScopeSheets(this._scope);

  /// ✅ Success Sheet
  TipSheet success(
    String title, {
    String? message,
    Widget? body,
  }) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.success,
      foreground: Colors.white,
      message: message ?? '',
      body: body ?? const SizedBox.shrink(),
      icon: Icons.check_circle,
    );
  }

  /// ✅ Information Sheet
  TipSheet information(
    String title, {
    String? message,
    Widget? body,
  }) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.info,
      foreground: Colors.white,
      message: message ?? '',
      body: body ?? const SizedBox.shrink(),
      icon: Icons.info,
    );
  }

  /// 💡 Tip Sheet
  TipSheet tip(
    String title, {
    String? message,
    Widget? body,
  }) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.tip,
      message: message ?? '',
      body: body ?? const SizedBox.shrink(),
      icon: Ionicons.bulb,
    );
  }

  /// ⚠️ Warning Sheet
  TipSheet warning(
    String title, {
    String? message,
    Widget? body,
  }) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.danger,
      foreground: Colors.white,
      message: message ?? '',
      body: body ?? const SizedBox.shrink(),
      icon: Icons.warning,
    );
  }

  /// 💬 Neutral Sheet
  TipSheet neutral(
    String title, {
    String? message,
    Widget? body,
  }) {
    return TipSheet(
      _scope,
      title: title,
      fill: Colors.white,
      message: message ?? '',
      body: body ?? const SizedBox.shrink(),
      icon: Icons.chat,
    );
  }

  /// 🪶 Flat Sheet
  TipSheet flat(
    String title, {
    String? message,
    Widget? body,
    IconData? icon,
  }) {
    return TipSheet(
      _scope,
      title: title,
      fill: _scope.application.settings.colors.navigation,
      message: message ?? '',
      body: body ?? const SizedBox.shrink(),
      flat: true,
      foreground: Colors.white,
      icon: icon ?? Icons.info_outline,
    );
  }

  /// 🛎 Notification Sheet
  NotificationSheet notification({
    String? title,
    String? message,
    String? imageUrl,
    Widget? body,
    IconData? icon,
    List<NotificationSheetAction>? actions,
    VoidCallback? onDelete,
    DateTime? date,
  }) {
    return NotificationSheet(
      _scope,
      title: title ?? '',
      message: message ?? '',
      body: body ?? const SizedBox.shrink(),
      actions: actions ?? const [],
      onDelete: onDelete ?? () {},
      icon: icon ?? Icons.notifications,
      date: date ?? DateTime.now(),
      imageUrl: imageUrl ?? '',
    );
  }
}
