import 'package:flutter/foundation.dart';

/// =======================================================
/// DIALOG PROCESS CONTROLLER — Versión Profesional
/// =======================================================
/// Controla el ciclo de vida de un proceso (carga, éxito, fallo, cancelación)
/// usado en diálogos, uploads, downloads o tareas largas.
class DialogProcessController {
  double? total;
  double? value;

  final ValueNotifier<DialogProcessState> _stateNotifier =
      ValueNotifier(DialogProcessState.idle);
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0);

  VoidCallback? _onCanceled;
  void Function(dynamic result)? _onCompleted;
  String? _failedMessage;

  DialogProcessController({this.total, this.value});

  /// =======================================================
  /// CONTROL DE ESTADO
  /// =======================================================
  DialogProcessState get state => _stateNotifier.value;
  bool get isProcess => state == DialogProcessState.process;
  bool get isCompleted => state == DialogProcessState.completed;
  bool get isSuccess => state == DialogProcessState.success;
  bool get isFailed => state == DialogProcessState.failed;
  bool get isCanceled => state == DialogProcessState.canceled;
  bool get isDone => state == DialogProcessState.done;

  /// =======================================================
  /// SUSCRIPTORES
  /// =======================================================
  ValueListenable<DialogProcessState> get stateListenable => _stateNotifier;
  ValueListenable<double> get progressListenable => _progressNotifier;

  void onCanceled(VoidCallback handler) => _onCanceled = handler;
  void onCompleted(void Function(dynamic result) handler) =>
      _onCompleted = handler;

  /// =======================================================
  /// OPERACIONES DE PROCESO
  /// =======================================================
  void start() {
    value = 0;
    _updateProgress(0);
    _stateNotifier.value = DialogProcessState.process;
  }

  void update({double? total, double? value}) {
    if (total != null) this.total = total;
    if (value != null) this.value = value;
    if (this.total != null && this.total! > 0) {
      _updateProgress((this.value ?? 0) / this.total!);
    }

    if (this.total != null &&
        this.value != null &&
        this.value! >= this.total!) {
      _stateNotifier.value = DialogProcessState.completed;
      Future.delayed(const Duration(milliseconds: 500), () {
        _onCompleted?.call(null);
      });
    }
  }

  void success({dynamic result, bool silent = false}) {
    _stateNotifier.value =
        silent ? DialogProcessState.done : DialogProcessState.success;
    _onCompleted?.call(result);
  }

  void failed({String? message}) {
    _failedMessage = message;
    _stateNotifier.value = DialogProcessState.failed;
  }

  void cancel() {
    if (isProcess && !_stateNotifier.value.isTerminal) {
      _onCanceled?.call();
      _stateNotifier.value = DialogProcessState.canceled;
    }
  }

  void reset() {
    total = 0;
    value = 0;
    _stateNotifier.value = DialogProcessState.idle;
    _updateProgress(0);
  }

  void _updateProgress(double progress) {
    _progressNotifier.value = progress.clamp(0, 1);
  }

  String? get failedMessage => _failedMessage;

  void dispose() {
    _stateNotifier.dispose();
    _progressNotifier.dispose();
  }
}

/// =======================================================
/// ENUM DE ESTADOS
/// =======================================================
enum DialogProcessState {
  idle,
  process,
  completed,
  success,
  failed,
  canceled,
  done,
}

/// =======================================================
/// EXTENSIÓN PARA SABER SI UN ESTADO ES FINAL
/// =======================================================
extension DialogProcessStateX on DialogProcessState {
  bool get isTerminal =>
      this == DialogProcessState.failed ||
      this == DialogProcessState.canceled ||
      this == DialogProcessState.done ||
      this == DialogProcessState.success;
}
