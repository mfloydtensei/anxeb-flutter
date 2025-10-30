import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/parts/dialogs/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class DialogProgress extends StatefulWidget {
  final DialogProcessController controller;
  final Scope scope;
  final bool isDownload;
  final String? failedMessage;
  final String? successMessage;
  final String? busyMessage;

  const DialogProgress({
    super.key,
    required this.scope,
    required this.controller,
    this.isDownload = false,
    this.failedMessage,
    this.successMessage,
    this.busyMessage,
  });

  @override
  State<DialogProgress> createState() => _DialogProgressState();
}

class _DialogProgressState extends State<DialogProgress> {
  @override
  void initState() {
    super.initState();
    widget.controller._subscribe(() {
      if (mounted) {
        setState(() {});
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = widget.scope.window.horizontal(0.28);
    size = size > 140 ? 140 : size;

    final colors = widget.scope.application.settings.colors;

    if (widget.controller.isFailed) {
      return _buildStatus(
        icon: FontAwesome5.exclamation,
        color: colors.danger,
        message: widget.controller.failedMessage ??
            widget.failedMessage ??
            (widget.isDownload
                ? translate(
                    'anxeb.widgets.components.dialog_progress.download_failed')
                : translate(
                    'anxeb.widgets.components.dialog_progress.upload_failed')),
        size: size,
      );
    }

    if (widget.controller.isSuccess) {
      return _buildStatus(
        icon: Icons.check,
        color: colors.success,
        message: widget.successMessage ??
            (widget.isDownload
                ? translate(
                    'anxeb.widgets.components.dialog_progress.download_success')
                : translate(
                    'anxeb.widgets.components.dialog_progress.upload_success')),
        size: size,
      );
    }

    if (_percent == 0 ||
        (widget.controller.isCompleted && !widget.controller.isDone)) {
      return _buildBusy(
        size: size,
        label: _percent == 0
            ? translate('anxeb.widgets.components.dialog_progress.init_label')
            : (widget.busyMessage ??
                translate(
                    'anxeb.widgets.components.dialog_progress.processing_label')),
        color: colors.success,
      );
    }

    // 🔹 Default progress view
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: size,
                width: size,
                child: CircularProgressIndicator(
                  value: _percent,
                  strokeWidth: 10,
                  backgroundColor: colors.separator,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
              Text(
                '${Utils.convert.fromAnyToNumber(_percent * 100, comma: false, decimals: 1)}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.busyMessage ??
                  translate(
                      'anxeb.widgets.components.dialog_progress.processing_label'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus({
    required IconData icon,
    required Color color,
    required String message,
    required double size,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: size,
                width: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(icon, size: size - 40, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusy({
    required double size,
    required String label,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: 10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }

  double get _percent {
    final total = widget.controller.total ?? 0;
    final value = widget.controller.value ?? 0;
    return total == 0 ? 0 : value / total;
  }
}

enum DialogProcessState {
  idle,
  process,
  completed,
  success,
  failed,
  canceled,
  done,
}

class DialogProcessController {
  double? total;
  double? value;
  DialogProcessState _state = DialogProcessState.idle;

  bool Function()? _refreshHandler;
  void Function(dynamic result)? _completeHandler;
  VoidCallback? _cancelHandler;
  String? _failedMessage;

  void _subscribe(bool Function() refresher) {
    _refreshHandler = refresher;
  }

  void onCompleted(void Function(dynamic result) completer) {
    _completeHandler = completer;
  }

  void onCanceled(VoidCallback canceler) {
    _cancelHandler = canceler;
  }

  void update({double? total, double? value}) {
    this.total = total;
    this.value = value;

    if (this.total != null &&
        this.value != null &&
        this.value! >= this.total! &&
        this.value! > 0) {
      _state = DialogProcessState.completed;
      Future.delayed(const Duration(milliseconds: 800), () {
        _refreshHandler?.call();
      });
    } else {
      _state = DialogProcessState.process;
    }

    if (_refreshHandler?.call() == false) {
      _cancel(pop: false);
    }
  }

  Future<void> cancel() async => _cancel(pop: false);

  Future<void> _cancel({bool pop = true}) async {
    if (_state == DialogProcessState.process) {
      _cancelHandler?.call();
      _state = DialogProcessState.canceled;
      if (pop) await _pop();
    }
  }

  Future<void> failed({String? message}) async {
    _failedMessage = message;
    _state = DialogProcessState.failed;
    _refreshHandler?.call();
  }

  Future<void> _pop({dynamic result, bool quick = false, int delay = 1000}) async {
    try {
      if (_refreshHandler?.call() == true) {
        if (quick) {
          _completeHandler?.call(result);
        } else {
          await Future.delayed(Duration(milliseconds: delay));
          _completeHandler?.call(result);
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } catch (_) {}
  }

  Future<void> pop() async => _pop(quick: true);

  Future<void> success({dynamic result, bool silent = false}) async {
    if (silent) {
      _state = DialogProcessState.done;
      if (!isCanceled) await _pop(quick: true, result: result);
    } else {
      _state = DialogProcessState.success;
      if (!isCanceled) await _pop(result: result);
    }
  }

  String? get failedMessage => _failedMessage;

  bool get isDone => _state == DialogProcessState.done;
  bool get isProcess => _state == DialogProcessState.process;
  bool get isCanceled => _state == DialogProcessState.canceled;
  bool get isFailed => _state == DialogProcessState.failed;
  bool get isCompleted => _state == DialogProcessState.completed;
  bool get isSuccess => _state == DialogProcessState.success;
}
