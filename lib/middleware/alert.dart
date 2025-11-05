import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/parts/alerts/snack.dart';
import 'package:flutter/material.dart';

class ScopeAlert {
  final Scope scope;
  bool _disposed = false;

  ScopeAlert(this.scope);

  Future<void> dispose({bool quick = false}) async {
    _disposed = true;
  }

  @protected
  Future<dynamic> build() async {
    return null;
  }

  Future<dynamic> show() async {
    if (!_disposed) {
      scope.unfocus();
      scope.rasterize();
      await scope.idle();
      final result = await build();
      _disposed = true;
      return result;
    }
    return null;
  }
}


class ScopeAlerts {
  final Scope _scope;
  ScopeAlert? _current;

  ScopeAlerts(this._scope);

  Future<void> dispose({bool quick = false}) async {
    if (_current != null) {
      await _current!.dispose(quick: quick);
    }
  }

  bool get isAny => _current != null && !_current!._disposed;

 Future<ScopeAlert> _initialize(ScopeAlert current) async {
  await dispose();
  _current = current;
  return current;
}

  /// Notification alert
  SnackAlert notification(
    String title, {
    String? message,
    int? delay,
    Color? color,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.notification,
      reference: title,
      description: message ?? '',
    );
    return _initialize(
      SnackAlert(
        _scope,
        title: title,
        message: message ?? '',
        icon: Icons.notifications,
        fillColor: color ?? _scope.application.settings.colors.info,
        delay: delay ?? 0,
      ),
    ) as SnackAlert;
  }

  /// Information alert
  SnackAlert information(
    String title, {
    String? message,
    int? delay,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.information,
      reference: title,
      description: message ?? '',
    );
    return _initialize(
      SnackAlert(
        _scope,
        title: title,
        message: message ?? '',
        icon: Icons.info,
        fillColor: _scope.application.settings.colors.info,
        delay: delay ?? 0,
      ),
    ) as SnackAlert;
  }

  /// Success alert
  SnackAlert success(
    String title, {
    String? message,
    int? delay,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.success,
      reference: title,
      description: message ?? '',
    );
    return _initialize(
      SnackAlert(
        _scope,
        title: title,
        message: message ?? '',
        icon: Icons.check_circle,
        fillColor: _scope.application.settings.colors.success,
        delay: delay ?? 0,
      ),
    ) as SnackAlert;
  }

  /// Event alert
  SnackAlert event(
    String title, {
    String? message,
    int? delay,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.action,
      reference: title,
      description: message ?? '',
    );
    return _initialize(
      SnackAlert(
        _scope,
        title: title,
        message: message ?? '',
        icon: Icons.event,
        fillColor: _scope.application.settings.colors.primary,
        delay: delay ?? 0,
      ),
    ) as SnackAlert;
  }

  /// Asterisk alert
  SnackAlert asterisk(
    String title, {
    String? message,
    int? delay,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.asterisk,
      reference: title,
      description: message ?? '',
    );
    return _initialize(
      SnackAlert(
        _scope,
        title: title,
        message: message ?? '',
        icon: CommunityMaterialIcons.asterisk,
        fillColor: _scope.application.settings.colors.asterisk,
        delay: delay ?? 0,
      ),
    ) as SnackAlert;
  }

  /// Exception alert
  SnackAlert exception(
    String message, {
    String? title,
    int? delay,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.exception,
      reference: title ?? message,
      description: message,
    );
    return _initialize(
      SnackAlert(
        _scope,
        title: title ?? translate('anxeb.common.error'),
        message: message,
        icon: Icons.warning,
        fillColor: _scope.application.settings.colors.danger,
        delay: delay ?? 0,
      ),
    ) as SnackAlert;
  }

  /// Error alert — handles multiple exception types gracefully
  SnackAlert error(
    dynamic err, {
    String? title,
    int? delay,
  }) {
    String message = '';
    dynamic meta;

    try {
      if (err is AssertionError) {
        message = err.message?.toString() ?? err.toString();
        debugPrint('\n-----------[ ASSERTION ERROR ]-----------\n$message\n${err.stackTrace}');
      } else if (err is Error) {
        message = err.toString();
        debugPrint('\n-----------[ INTERNAL ERROR ]-----------\n$message\n${err.stackTrace}');
      } else if (err is ApiException) {
        message = err.message;
        meta = err.meta;
      } else if (err is NetworkImageLoadException) {
        message = err.toString();
      } else if (err is Exception) {
        message = err.toString();
      } else if (err is String) {
        message = err;
      } else {
        // Intenta obtener mensaje genérico
        message = (err?.message ?? err?.data?.message ?? err?.toString()) ?? 'Unknown error';
      }
    } catch (_) {
      message = err?.toString() ?? 'Unknown error';
    }

    _scope.application.onEvent.call(
      ApplicationEventType.error,
      reference: title ?? message,
      description: message,
      data: err,
    );

    return _initialize(
      SnackAlert(
        _scope,
        title: title ?? translate('anxeb.common.error'),
        message: message,
        meta: meta,
        icon: Icons.warning,
        fillColor: _scope.application.settings.colors.danger,
        delay: delay ?? 0,
      ),
    ) as SnackAlert;
  }
}
