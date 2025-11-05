import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../screen/scope.dart';
import 'package:go_router/go_router.dart';
import 'api.dart';
import 'application.dart';
import 'auth.dart';
import 'dialog.dart';
import 'disk.dart';
import 'analytics.dart';
import 'form.dart';
import 'alert.dart';
import 'sheet.dart';
import 'window.dart';

typedef RefreshCallback = void Function(VoidCallback fn);

abstract class IScope {
  Application get application;
  String get key;
  String get title;
  bool get mounted;
  int get tick;

  void rasterize([VoidCallback? fn]);
  void retick();
  Future<bool> dismiss();
}

class Scope {
  final BuildContext _context;
  final Window _window;
  BuildContext? _busyContext;

  late final ScopeDialogs _dialogs;
  late final ScopeAlerts _alerts;
  late final ScopeSheets _sheets;
  late final ScopeForms _forms;

  bool _idling = false;
  bool _busying = false;
  int _busyCountDown = 0;
  int tick = DateTime.now().toUtc().millisecondsSinceEpoch;

  dynamic box;

  Scope(BuildContext context)
      : _context = context,
        _window = Window(ScopePlaceholder()) {
    _dialogs = ScopeDialogs(this);
    _alerts = ScopeAlerts(this);
    _sheets = ScopeSheets(this);
    _forms = ScopeForms(this);
  }

  /// ============================================================
  /// BASE GETTERS (to be overridden by ScreenScope, DialogScope, etc.)
  /// ============================================================
  Application get application => throw UnimplementedError('application not implemented');
  String get key => '';
  String get title => '';

  /// ============================================================
  /// ACCESSORS
  /// ============================================================
  BuildContext get context => _context;
  Window get window => _window;
  ScopeDialogs get dialogs => _dialogs;
  ScopeAlerts get alerts => _alerts;
  ScopeSheets get sheets => _sheets;
  ScopeForms get forms => _forms;

  Analytics? get analytics => application.analytics;
  Api get api => application.api;
  Disk get disk => application.disk;
  AuthProviders get auths => application.auths;

  /// ============================================================
  /// STATUS
  /// ============================================================
  bool get isBusy => _busyContext != null;
  bool get isIdle => _busyContext == null;
  bool get mounted => Navigator.canPop(context);

  /// ============================================================
  /// UI REFRESH
  /// ============================================================
  void rasterize([VoidCallback? fn]) {
    if (fn != null) fn();
  }

  /// ============================================================
  /// DISMISS DIALOG / VIEW
  /// ============================================================
  Future<bool> dismiss() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return true;
    }
    return false;
  }

  /// ============================================================
  /// TICK REFRESH
  /// ============================================================
  void retick() {
    tick = DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  /// ============================================================
  /// SETUP
  /// ============================================================
  Future<void> setup() async {
    if (application.settings.analytics.available == true) {
      application.analytics?.setup(scope: this);
    }
    application.onEvent(ApplicationEventType.view, reference: key);
  }

  void dispose() {
    if (application.settings.analytics.available == true) {
      application.analytics?.reset();
    }
  }

  /// ============================================================
  /// BUSY DIALOG
  /// ============================================================
  Future<void> busy({
    int timeout = 0,
    String? text,
    bool dismissable = true,
  }) async {
    if (_busying || _busyContext != null) return;

    _busying = true;
    final hasText = text != null && text.isNotEmpty;
    final completer = Completer<void>();

    await alerts.dispose();

    showGeneralDialog(
  context: context,
  barrierDismissible: false,
  barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  barrierColor: hasText
      ? Colors.transparent
      : application.settings.colors.backdrop,
  transitionDuration: const Duration(milliseconds: 150),
  pageBuilder: (context, animation, secondaryAnimation) {
    return PopScope(
  canPop: dismissable,
  onPopInvokedWithResult: (didPop, result) {
    if (didPop && dismissable) {
      idle(); // cerrar correctamente el busy si se permite back
    }
  },
  child: SafeArea(
    child: Builder(
      builder: (ctx) {
        var size = window.horizontal(0.16);
        size = size > 60 ? 60 : size;

        Future.delayed(const Duration(milliseconds: 100), () {
          _busying = false;
          _busyContext = ctx;
          if (!completer.isCompleted) completer.complete();
        });

        if (hasText) {
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: application.settings.colors.busybox,
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 8),
                    blurRadius: 20,
                    spreadRadius: -10,
                    color: Color(0x98000000),
                  )
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        application.settings.colors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      color: application.settings.colors.foreground,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: SizedBox(
              height: size,
              width: size,
              child: const CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xffefefef),
                ),
              ),
            ),
          );
        }
      },
    ),
  ),
);

  },
).then((_) {
  Future.delayed(const Duration(milliseconds: 100), () {
    _busyContext = null;
    _idling = false;
    rasterize();
  });
});


    if (timeout > 0) {
      _busyCountDown = timeout;
      _checkBusyCountDown();
    }

    return completer.future;
  }

  /// ============================================================
  /// CHECK TIMEOUT
  /// ============================================================
  Future<void> _checkBusyCountDown() async {
    if (_busyCountDown <= 0) return;

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      _busyCountDown--;
      if (_busyCountDown <= 0) {
        timer.cancel();
        await idle();
        alerts
            .exception(
              translate('anxeb.middleware.scope.busy_timeout'),
              title: translate('anxeb.middleware.scope.process_error'),
            )
            .show();
      }
    });
  }

  /// ============================================================
  /// IDLE (Close busy dialog)
  /// ============================================================
  Future<void> idle() async {
    _busyCountDown = 0;
    if (_idling) return;

    _idling = true;
    final completer = Completer<void>();

    if (_busyContext != null) {
      try {
        if (this is ScreenScope) {
          Navigator.of(_busyContext!).pop();
        } else {
          GoRouter.of(_busyContext!).pop();
        }
      } catch (_) {}
      _busyContext = null;
    }

    rasterize();
    completer.complete();
    return completer.future;
  }

  /// ============================================================
  /// FOCUS HELPERS
  /// ============================================================
  final FocusNode _focusNode = FocusNode();

  void unfocus() {
    if (mounted && !_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void focus(FocusNode node) {
    if (mounted && node.context != null && !node.hasFocus) {
      FocusScope.of(context).requestFocus(node);
    }
  }
}

/// ============================================================
/// Placeholder for Window initialization
/// ============================================================
class ScopePlaceholder extends Scope {
  ScopePlaceholder() : super(GlobalKey<NavigatorState>().currentContext!);
  @override
  Application get application => throw UnimplementedError();
}
