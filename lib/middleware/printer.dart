//import 'dart:async';
//import 'dart:convert';
//
//import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
////import 'package:bluetooth_print/bluetooth_print.dart';
////import 'package:bluetooth_print/bluetooth_print_model.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_translate/flutter_translate.dart';
//import 'package:permission_handler/permission_handler.dart';
//
//import '../widgets/buttons/text.dart' as AX;
//import 'application.dart';
//import 'device.dart';
//import 'dialog.dart';
//import 'scope.dart';
//import 'utils.dart';
//
//class Printer {
//  final Application application;
// // BluetoothPrint _manager = BluetoothPrint.instance;
//  bool _connected = false;
//
//  Future<void> Function(dynamic)? _persist;
//  dynamic Function()? _fetch;
//
//  int _lastFoundLength = 0;
//  //BluetoothDevice? _device;
//
//  int _autoDiesconnectDelay = 0;
//  int? _tick;
//  bool _isScanning = false;
//
//  Printer(this.application);
//
//  Future<void> init({
//    Future<void> Function(dynamic)? persistDevice,
//    dynamic Function()? fetchDevice,
//    int autoDiesconnectDelay = 0,
//  }) async {
//    _persist = persistDevice;
//    _fetch = fetchDevice;
//    _autoDiesconnectDelay = autoDiesconnectDelay;
//
//   // _manager.state.listen((state) {
//     // switch (state) {
//     //   case BluetoothPrint.CONNECTED:
//      //    _connected = true;
//      //    break;
//   //    case BluetoothPrint.DISCONNECTED:
//      //    _connected = false;
//    //      break;
//    //    default:
//        //  break;
//    //  }
//    //});
//  }
//
//  // Future<bool> _needPermission() async {
//  //   final isEnabled = await _handleFuture<bool>(_manager.isOn) == true;
//  //   final isAvailable = await _handleFuture<bool>(_manager.isAvailable) == true;
//
//    bool grantedScan = true;
//    bool grantedConnect = true;
//    bool grantedBt = true;
//
//    try {
//      grantedScan =
//          await _handleFuture<bool>(Device.permission.bluetoothScan.isDenied) != true;
//      grantedConnect =
//          await _handleFuture<bool>(Device.permission.bluetoothConnect.isDenied) != true;
//      grantedBt = await _handleFuture<bool>(
//              Device.permission.bluetooth.isPermanentlyDenied) !=
//          true;
//    } catch (_) {}
//
//    return !isEnabled || !isAvailable || !grantedScan || !grantedConnect || !grantedBt;
//  }
//
// // Future<BluetoothDevice?> _lookupDevice(String address, [int timeout = 2000]) async {
//   // final completer = Completer<BluetoothDevice?>();
//
//  // try {
//  //   await _manager.startScan(timeout: Duration(milliseconds: timeout));
//
//  //   final sub = _manager.scanResults.listen((devices) async {
//  //     _lastFoundLength = devices.length;
//  //     final found = devices.firstWhere(
//  //       (e) => e.address == address,
//  //       orElse: () => BluetoothDevice(),
//  //     );
//
//  //     if (!completer.isCompleted) {
//  //       try {
//  //         await _manager.stopScan();
//  //       } catch (_) {}
//  //       completer.complete(
//  //           found.address != null && found.address!.isNotEmpty ? found : null);
//  //     }
//  //   });
//
//  //   Future.delayed(Duration(milliseconds: timeout)).then((_) async {
//  //     if (!completer.isCompleted) {
//  //       await _manager.stopScan().catchError((_) {});
//  //       completer.complete(null);
//  //     }
//  //     await sub.cancel();
//  //   });
//  // } catch (e) {
//  //   if (!completer.isCompleted) {
//  //     completer.completeError(e);
//  //   }
//  // }
//
//  // return completer.future;
//  //
//
//  Future<T?> _handleFuture<T>(Future<T> future) async {
//    try {
//      return await future;
//    } catch (_) {
//      return null;
//    }
//  }
//
//  void set({int? autoDiesconnectDelay}) {
//    if (autoDiesconnectDelay != null) {
//      _autoDiesconnectDelay = autoDiesconnectDelay;
//    }
//    if (_autoDiesconnectDelay > 0) {
//      _disconnect();
//    }
//  }
//
//  Future<void> send({
//    required Scope scope,
//    required dynamic data,
//    required String layout,
//  }) async {
//    try {
//      await Device.permission.bluetooth.request();
//      await Device.permission.bluetoothConnect.request();
//      await Device.permission.bluetoothScan.request();
//    } catch (_) {}
//
//    try {
//      if (await _needPermission() == true) {
//        final result = await scope.dialogs
//            .exception(
//              translate('anxeb.middleware.printer.bt_disabled_title'),
//              dismissible: true,
//              message: translate('anxeb.middleware.printer.bt_desabled_message'),
//              icon: Icons.bluetooth_disabled,
//              buttons: [
//                DialogButton(translate('anxeb.common.yes'), 'settings'),
//                DialogButton(translate('anxeb.common.no'), false),
//              ],
//            )
//            .show();
//
//        if (result == 'settings') {
//          await Device.settings.bluetooth();
//          if (await _needPermission() == false) {
//            await send(scope: scope, data: data, layout: layout);
//          }
//        }
//        return;
//      }
//
//      if (!_connected) {
//        await scope.busy(text: translate('anxeb.middleware.printer.connecting_busy_label'));
//
//        await _tryConnect(Anxeb.Device.isAndroid ? 800 : 3000);
//
//        final fetched = _fetch?.call();
//        if (fetched != null) {
//          try {
//             _device = BluetoothDevice(); // 👈 constructor vacío
//             _device!.address = fetched['address'];
//             _device!.name = fetched['name'];
//            _device!.type = fetched['type']; // si existe en tu versión del paquete
//
//            final ok = await _tryConnect();
//            if (!ok) {
//              await scope.idle();
//              await _manager.disconnect().catchError((_) {});
//              _connected = false;
//
//              final act = await scope.dialogs
//                  .exception(
//                    translate('anxeb.middleware.printer.bt_reset_dialog.title'),
//                    dismissible: true,
//                    message:
//                        translate('anxeb.middleware.printer.bt_reset_dialog.message'),
//                    icon: Icons.print_disabled,
//                    buttons: [
//                      DialogButton(translate('anxeb.common.retry'), 'retry'),
//                      DialogButton(translate('anxeb.common.scan'), 'scan'),
//                    ],
//                  )
//                  .show();
//
//              if (act == 'retry') {
//                await send(scope: scope, data: data, layout: layout);
//                return;
//              } else if (act == null) {
//                return;
//              }
//
//              await scope.busy(
//                  text: translate('anxeb.middleware.printer.connecting_busy_label'));
//            }
//          } catch (_) {
//            _device = null;
//          }
//        }
//
//        if (await isConnected() == true) {
//          await scope.idle();
//        }
//      }
//    } catch (_) {
//      scope.alerts.error(Anxeb.translate('anxeb.middleware.printer.error_connecting')).show();
//      return;
//    }
//
//    if (_connected) {
//      _notDisconnect();
//      await scope.busy(text: translate('anxeb.middleware.printer.printing_busy_label'));
//      await Future.delayed(const Duration(milliseconds: 500));
//
//      try {
//        final config = <String, dynamic>{};
//        final list = <LineText>[];
//        final lines = const LineSplitter().convert(layout);
//
//        for (final raw in lines) {
//          if (raw.isEmpty || raw.startsWith('//') || raw.startsWith('#')) continue;
//
//          var align = LineText.ALIGN_LEFT;
//          final params = _parseParams(_parseData(raw, data));
//          var type = params['T'];
//
//          String content = '';
//
//          if (type == 'X') {
//            type = LineText.TYPE_TEXT;
//          } else if (type == 'I') {
//            type = LineText.TYPE_IMAGE;
//          } else if (type == 'B') {
//            type = LineText.TYPE_BARCODE;
//          } else if (type == 'Q') {
//            type = LineText.TYPE_QRCODE;
//          }
//
//          if (type == LineText.TYPE_IMAGE) {
//            final url = scope.application.api.getUri(
//              params['CL'] ?? params['CC'] ?? params['CR'] ?? '',
//            );
//
//            if (params['CL'] != null) align = LineText.ALIGN_LEFT;
//            if (params['CC'] != null) align = LineText.ALIGN_CENTER;
//            if (params['CR'] != null) align = LineText.ALIGN_RIGHT;
//
//            final bundleData = await NetworkAssetBundle(Uri.parse(url)).load(url);
//            final bytes = bundleData.buffer.asUint8List(
//              bundleData.offsetInBytes,
//              bundleData.lengthInBytes,
//            );
//            content = base64Encode(bytes);
//          } else {
//            if (params['CC'] != null) {
//              content = params['CC']!;
//              final pc = _getInt(params['PC']) ?? content.length;
//              if (pc < content.length) content = content.substring(0, pc);
//              align = LineText.ALIGN_CENTER;
//            } else {
//              if (params['CL'] != null) {
//                final cl = params['CL'] ?? '';
//                final pl = _getInt(params['PL']) ?? cl.length;
//                content = _padRight(cl, pl);
//              }
//              if (params['CR'] != null) {
//                final cr = params['CR'] ?? '';
//                final pr = _getInt(params['PR']) ?? cr.length;
//                content = '$content${_padLeft(cr, pr)}';
//                align = LineText.ALIGN_RIGHT;
//              }
//            }
//          }
//
//          list.add(
//            LineText(
//              type: type,
//              content: content,
//              weight: _getInt(params['G']),
//              align: align,
//              height: _getInt(params['H']),
//              width: _getInt(params['W']),
//              linefeed: 1,
//              size: _getInt(params['S']),
//              underline: _getInt(params['U']),
//              x: _getInt(params['X']),
//              y: _getInt(params['Y']),
//            ),
//          );
//
//          final lf = _getInt(params['L']) ?? 1;
//          if (lf > 1) {
//            for (var i = 1; i < lf; i++) {
//              list.add(LineText(linefeed: 1));
//            }
//          }
//        }
//
//        await _handleFuture(_manager.printReceipt(config, list));
//        await Future.delayed(const Duration(milliseconds: 1500));
//        _attemptDisconnect();
//        await scope.idle();
//      } catch (err) {
//        scope.alerts.error(err).show();
//      } finally {
//        await scope.idle();
//      }
//    } else {
//      _connected = false;
//      scope.alerts.error(Anxeb.translate('anxeb.middleware.printer.error_connecting')).show();
//    }
//  }
//
//  void _notDisconnect() {
//    _tick = DateTime.now().millisecondsSinceEpoch;
//  }
//
//  void _attemptDisconnect() {
//    if (_autoDiesconnectDelay > 0) {
//      _tick = DateTime.now().millisecondsSinceEpoch;
//      final current = _tick;
//      Future.delayed(Duration(milliseconds: _autoDiesconnectDelay)).then((_) {
//        if (current == _tick) {
//          _disconnect();
//        }
//      });
//    }
//  }
//
//  void _disconnect() {
//    try {
//      _manager.disconnect();
//      _manager.destroy();
//    } catch (_) {}
//    _manager = BluetoothPrint.instance;
//    _connected = false;
//    _tick = null;
//  }
//
//  Future<void> _persistDeviceInternal() async {
//    if (_persist != null && _device != null) {
//      await _persist!.call({
//        'address': _device!.address,
//        'type': _device!.type,
//        'name': _device!.name,
//      });
//    }
//  }
//
//  Future<bool> _tryConnect([int lookupTimeout = 2000]) async {
//    if (_device == null) {
//      final fetched = _fetch?.call();
//      if (fetched is Map && fetched['address'] is String) {
//         _device = BluetoothDevice(); // 👈 constructor vacío
//         _device!.address = fetched['address'];
//        _device!.name = fetched['name'];
//         _device!.type = fetched['type']; // si existe en tu versión del paquete
//      } else {
//        return false;
//      }
//    }
//
//    if (!_connected && _device?.address != null) {
//      final found = await _lookupDevice(_device!.address!, lookupTimeout);
//      if (found != null) {
//        _device = found;
//      }
//    }
//
//    if ((await _manager.isConnected) != true || !_connected) {
//      _device = await _chooseDevice(application as Scope?) ?? _device;
//      if (_device == null) return false;
//
//      await _manager.connect(_device!);
//      await Future.delayed(const Duration(milliseconds: 800));
//
//      if (await isConnected() != true) {
//        _device = null;
//        return false;
//      }
//
//      await _persistDeviceInternal();
//    }
//
//    return true;
//  }
//
//  dynamic _formatValue(dynamic value, String? format) {
//    if (value == null || (format == null || format.isEmpty)) return value;
//
//    switch (format) {
//      case 'DEC':
//        return Utils.convert.fromAnyToNumber(value, comma: true, decimals: 2);
//      case 'INT':
//        return Utils.convert.fromAnyToNumber(value, comma: true, decimals: 0);
//      case 'DTF':
//        return Utils.convert.fromDateToHumanString(
//          Utils.convert.fromTickToDate(value),
//          withTime: true,
//          complete: false,
//        );
//      case 'DTH':
//        return Utils.convert.fromDateToHumanString(
//          Utils.convert.fromTickToDate(value),
//          withTime: true,
//          complete: true,
//        );
//      case 'TMF':
//        return Utils.convert.fromDateToHumanString(
//          Utils.convert.fromTickToDate(value),
//          withTime: false,
//          complete: false,
//        );
//      case 'TMH':
//        return Utils.convert.fromDateToHumanString(
//          Utils.convert.fromTickToDate(value),
//          withTime: false,
//          complete: true,
//        );
//      case 'TID':
//        return Utils.convert.fromDateToLocalizedTime(
//          Utils.convert.fromTickToDate(value),
//          duration: true,
//        );
//      case 'TIM':
//        return Utils.convert.fromDateToLocalizedTime(
//          Utils.convert.fromTickToDate(value),
//          duration: false,
//        );
//      case 'DAT':
//        return Utils.convert.fromDateToLocalizedDate(
//          Utils.convert.fromTickToDate(value),
//          withTime: false,
//        );
//      case 'DAW':
//        return Utils.convert.fromDateToLocalizedDate(
//          Utils.convert.fromTickToDate(value),
//          withTime: true,
//        );
//      case 'UPC':
//        return value.toString().toUpperCase();
//      case 'LWC':
//        return value.toString().toLowerCase();
//      default:
//        return Anxeb.DateFormat(
//          format,
//          Anxeb.translate('anxeb.formats.date_locale'),
//        ).format(Utils.convert.fromTickToDate(value).toLocal());
//    }
//  }
//
//  int? _getInt(String? value) => value == null ? null : int.tryParse(value);
//  String _padLeft(String text, int pad) =>
//      text.length >= pad ? text.substring(0, pad) : text.padLeft(pad, ' ');
//  String _padRight(String text, int pad) =>
//      text.length >= pad ? text.substring(0, pad) : text.padRight(pad, ' ');
//
//  Map<String, String> _parseParams(String line) {
//    final params = <String, String>{};
//    var working = line;
//
//    while (true) {
//      final leftIndex = working.indexOf('"');
//      final rightIndex = working.indexOf('"', leftIndex + 1);
//      if (leftIndex < 0 || rightIndex < 0) break;
//
//      final type = working.substring(leftIndex - 3, leftIndex - 1);
//      final value = working.substring(leftIndex + 1, rightIndex);
//      params[type] = value;
//      working =
//          '${working.substring(0, leftIndex - 4)}${working.substring(rightIndex + 1)}';
//    }
//
//    final items = working.split(' ').where((e) => e.trim().isNotEmpty);
//    for (final item in items) {
//      final parts = item.trim().split(':');
//      if (parts.length == 2) params[parts[0]] = parts[1];
//    }
//    return params;
//  }
//
//  String _parseData(String line, dynamic data) {
//    var result = line;
//
//    while (true) {
//      final leftIndex = result.indexOf('{{');
//      final rightIndex = result.indexOf('}}', leftIndex + 2);
//      if (leftIndex < 0 || rightIndex < 0) break;
//
//      final key = result.substring(leftIndex + 2, rightIndex);
//      dynamic content = data;
//
//      if (key.startsWith('data.')) {
//        var kcontent = key.substring(5);
//
//        String? format;
//        final fIdx = kcontent.indexOf('|');
//        if (fIdx > -1) {
//          format = kcontent.substring(fIdx + 1);
//          kcontent = kcontent.substring(0, fIdx);
//        }
//
//        final props = kcontent.split('.');
//        for (final p in props) {
//          if (content == null) break;
//          try {
//            content = content[p];
//          } catch (_) {
//            content = null;
//            break;
//          }
//        }
//
//        content = _formatValue(content, format);
//      }
//
//      result =
//          '${result.substring(0, leftIndex)}${content != null ? content.toString() : ''}${result.substring(rightIndex + 2)}';
//    }
//
//    return result;
//  }
//
//  Future<bool> isConnected() {
//    final completer = Completer<bool>();
//
//    Future.delayed(const Duration(seconds: 5)).then((_) {
//      if (!completer.isCompleted) completer.complete(_connected);
//    });
//
//    if (_connected) {
//      if (!completer.isCompleted) completer.complete(true);
//    } else {
//      final sub = _manager.state.listen((state) async {
//        _connected = (state == BluetoothPrint.CONNECTED);
//        if (_connected && !completer.isCompleted) {
//          completer.complete(true);
//        }
//      });
//
//      completer.future.whenComplete(() => sub.cancel());
//    }
//
//    return completer.future;
//  }
//
//  Future<BluetoothDevice?> _chooseDevice(Scope? scope) async {
//    if (scope == null) return null;
//
//    if (_isScanning != true) {
//      _handleFuture(_manager.startScan(timeout: const Duration(seconds: 4)));
//      _manager.isScanning.listen((e) => _isScanning = e);
//    }
//
//    return await showDialog<BluetoothDevice?>(
//      context: scope.context,
//      builder: (context) {
//        return Dialog(
//          child: SingleChildScrollView(
//            child: Padding(
//              padding: const EdgeInsets.all(16.0),
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                children: [
//                  StreamBuilder<bool>(
//                    stream: _manager.isScanning,
//                    initialData: true,
//                    builder: (c, snapshot) {
//                      final scanning = snapshot.data == true;
//                      return Row(
//                        children: <Widget>[
//                          Container(
//                            padding: const EdgeInsets.only(right: 7),
//                            margin: const EdgeInsets.only(right: 12),
//                            decoration: BoxDecoration(
//                              border: Border(
//                                right: BorderSide(
//                                  width: 1.0,
//                                  color: scope.application.settings.colors.separator,
//                                ),
//                              ),
//                            ),
//                            child: scanning
//                                ? SizedBox(
//                                    height: 48,
//                                    width: 48,
//                                    child: CircularProgressIndicator(
//                                      strokeWidth: 5,
//                                      valueColor: AlwaysStoppedAnimation<Color>(
//                                        scope.application.settings.colors.primary,
//                                      ),
//                                    ),
//                                  )
//                                : Icon(
//                                    _lastFoundLength > 0
//                                        ? Icons.print
//                                        : Icons.print_disabled,
//                                    size: 48,
//                                    color: _lastFoundLength > 0
//                                        ? scope.application.settings.colors.primary
//                                        : scope.application.settings.colors.danger,
//                                  ),
//                          ),
//                          Expanded(
//                            child: Text(
//                              scanning
//                                  ? translate('anxeb.middleware.printer.scan_dialog_title')
//                                  : (_lastFoundLength > 0
//                                      ? translate('anxeb.middleware.printer.select_dialog_title')
//                                      : translate('anxeb.middleware.printer.not_found')),
//                              textAlign: TextAlign.left,
//                              style: TextStyle(
//                                fontSize: 16.2,
//                                color: scope.application.settings.colors.primary,
//                                fontWeight: FontWeight.w500,
//                                letterSpacing: 0.4,
//                              ),
//                            ),
//                          ),
//                        ],
//                      );
//                    },
//                  ),
//                  StreamBuilder<List<BluetoothDevice>>(
//                    stream: _manager.scanResults,
//                    initialData: const [],
//                    builder: (c, snapshot) {
//                      final devices = snapshot.data ?? const <BluetoothDevice>[];
//                      _lastFoundLength = devices.length;
//
//                      return Column(
//                        children: devices
//                            .map(
//                              (d) => ListTile(
//                                title: Text(d.name ?? ''),
//                                subtitle: Text(d.address ?? ''),
//                                dense: true,
//                                onTap: () async {
//                                  if (_isScanning == true) {
//                                    try {
//                                      await _manager.stopScan();
//                                    } catch (_) {}
//                                  }
//                                  Navigator.of(context).pop(d);
//                                },
//                                trailing: Icon(
//                                  Icons.bluetooth,
//                                  color: (d.connected == true)
//                                      ? scope.application.settings.colors.success
//                                      : scope.application.settings.colors.primary,
//                                ),
//                              ),
//                            )
//                            .toList(),
//                      );
//                    },
//                  ),
//                  StreamBuilder<bool>(
//                    stream: _manager.isScanning,
//                    initialData: true,
//                    builder: (c, snapshot) {
//                      final scanning = snapshot.data == true;
//                      return Row(
//                        children: [
//                          Expanded(
//                            child: AX.TextButton(
//                              caption: translate('anxeb.common.scan'),
//                              radius: scope.application.settings.dialogs.buttonRadius,
//                              color: scope.application.settings.colors.primary,
//                              enabled: !scanning,
//                              textColor: Colors.white,
//                              margin: const EdgeInsets.only(top: 10, right: 5),
//                              onPressed: () async {
//                                _handleFuture(
//                                  _manager.startScan(timeout: const Duration(seconds: 4)),
//                                ).onError((_, __) {
//                                  Navigator.of(context).pop(null);
//                                  scope.alerts
//                                      .error(Anxeb.translate('anxeb.middleware.printer.error_scanning'))
//                                      .show();
//                                });
//                              },
//                              type: AX.ButtonType.primary,
//                              size: AX.ButtonSize.small,
//                            ),
//                          ),
//                          Expanded(
//                            child: AX.TextButton(
//                              caption: scanning
//                                  ? translate('anxeb.common.cancel')
//                                  : translate('anxeb.common.close'),
//                              radius: scope.application.settings.dialogs.buttonRadius,
//                              color: scope.application.settings.colors.primary,
//                              textColor: Colors.white,
//                              margin: const EdgeInsets.only(top: 10, left: 5),
//                              onPressed: () async {
//                                Navigator.of(context).pop(null);
//                                if (scanning) {
//                                  try {
//                                    await _manager.stopScan();
//                                  } catch (_) {}
//                                }
//                              },
//                              type: AX.ButtonType.primary,
//                              size: AX.ButtonSize.small,
//                            ),
//                          ),
//                        ],
//                      );
//                    },
//                  ),
//                ],
//              ),
//            ),
//          ),
//        );
//      },
//    );
//  }
//}
//