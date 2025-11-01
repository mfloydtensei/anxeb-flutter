import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'application.dart';
import 'scope.dart';
import 'package:anxeb_flutter/parts/dialogs/date_time.dart';
import 'package:anxeb_flutter/parts/dialogs/message.dart';
import 'package:anxeb_flutter/parts/dialogs/options.dart';
import 'package:anxeb_flutter/parts/dialogs/panel.dart';
import 'package:anxeb_flutter/parts/dialogs/referencer.dart';
import 'package:anxeb_flutter/parts/dialogs/color.dart';
import 'package:anxeb_flutter/parts/dialogs/form.dart';
import 'package:anxeb_flutter/parts/dialogs/slider.dart';
import 'package:anxeb_flutter/parts/panels/menu.dart';
import 'package:anxeb_flutter/utils/referencer.dart';

/// =======================================================
/// BASE DIALOG CLASS
/// =======================================================
class ScopeDialog<V> {
  final Scope scope;
  @protected
  bool dismissible = false;

  ScopeDialog(this.scope);

  @protected
  Widget build(BuildContext context) => const SizedBox.shrink();

  @protected
  Future<void> setup() async {}

  Future<V?> show() async {
    try {
      scope.unfocus();
      scope.rasterize();
      await scope.idle();
      await setup();
      return showDialog<V>(
        context: scope.context,
        barrierDismissible: dismissible,
        builder: (BuildContext context) => PointerInterceptor(
          child: build(context),
        ),
      );
    } catch (err) {
      await scope.alerts.error(err).show();
      return null;
    }
  }
}

/// =======================================================
/// MAIN DIALOG MANAGER
/// =======================================================
class ScopeDialogs {
  final Scope _scope;
  ScopeDialogs(this._scope);

  /// Reference selector dialog
  ReferencerDialog referencer<V>(
    String title, {
    IconData? icon,
    required ReferenceLoaderHandler<V> loader,
    ReferenceComparerHandler<V>? comparer,
    ReferenceFilterHandler<V>? filter,
    Function()? updater,
    ReferenceItemWidget<V>? itemWidget,
    ReferenceHeaderWidget<V>? headerWidget,
    ReferenceCreateWidget<V>? footerWidget,
    Widget Function(ReferencerPage<V>? page)? emptyWidget,
    double? buttonsWidth,
    double? width,
    double? height,
  }) {
    return ReferencerDialog<V>(
      _scope,
      title: title,
      icon: icon ?? Icons.search,
      referencer: Referencer<V>(
        loader: loader,
        comparer: comparer ?? (a, b) => false,
        filter: filter ?? (item, query) => true,
      ),
      itemWidget: itemWidget ?? (ReferencerPage<V>? page, V? item) => Text(item?.toString() ?? ''),
      headerWidget: headerWidget ?? (ReferencerPage<V>? page) => const SizedBox.shrink(),
      footerWidget: footerWidget ?? (ReferencerPage<V>? page) => const SizedBox.shrink(),
      emptyWidget: emptyWidget ?? (ReferencerPage<V>? page) => const SizedBox.shrink(),
      buttonsWidth: buttonsWidth ?? 0,
      width: width ?? 0,
      height: height ?? 0,
    );
  }

  /// Simple panel dialog
  PanelDialog panel({
    String? title,
    List<PanelMenuItem>? items,
    bool? horizontal,
    double? iconScale,
    double? textScale,
    double? buttonRadius,
  }) {
    return PanelDialog(
      _scope,
      title: title ?? '',
      items: items ?? const [],
      horizontal: horizontal ?? false,
      iconScale: iconScale ?? 1.0,
      textScale: textScale ?? 1.0,
      buttonRadius: buttonRadius ?? 8.0,
    );
  }

  /// Options dialog (single-choice)
  OptionsDialog options<V>(
    String title, {
    IconData? icon,
    List<DialogButton<V>>? options,
    V? selectedValue,
  }) {
    return OptionsDialog<V>(
      _scope,
      title: title,
      icon: icon ?? Icons.list,
      options: options ?? const [],
      selectedValue: selectedValue ?? (null as V),
    );
  }

  /// Information dialog
  MessageDialog information(
    String title, {
    String? message,
    List<DialogButton>? buttons,
    IconData? icon,
    Widget Function(BuildContext context)? body,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.information,
      reference: title,
      description: message ?? '',
    );

    return MessageDialog(
      _scope,
      title: title,
      message: message ?? '',
      body: body ?? (context) => const SizedBox.shrink(),
      icon: icon ?? Icons.info,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.primary,
      iconColor: _scope.application.settings.colors.primary,
      buttons: buttons ?? const [],
    );
  }

  /// Success dialog
  MessageDialog success(
    String title, {
    String? message,
    List<DialogButton>? buttons,
    IconData? icon,
    double? width,
    Widget Function(BuildContext context)? body,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.success,
      reference: title,
      description: message ?? '',
    );

    return MessageDialog(
      _scope,
      title: title,
      message: message ?? '',
      icon: icon ?? Icons.check_circle,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.primary,
      iconColor: _scope.application.settings.colors.success,
      buttons: buttons ?? const [],
      body: body ?? (context) => const SizedBox.shrink(),
      width: width ?? 0.0,
    );
  }

  /// Error dialog
  MessageDialog error(
    dynamic err, {
    List<DialogButton>? buttons,
    IconData? icon,
    double? width,
  }) {
    final title = err is FormatException ? err.message : err.toString();

    _scope.application.onEvent.call(
      ApplicationEventType.error,
      reference: title,
      data: err,
    );

    return MessageDialog(
      _scope,
      title: title,
      icon: icon ?? Icons.error,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.danger,
      iconColor: _scope.application.settings.colors.danger,
      buttons: buttons ?? const [],
      width: width ?? 0.0,
    );
  }

  /// Exception alert
  MessageDialog exception(
    String title, {
    String? message,
    List<DialogButton>? buttons,
    IconData? icon,
    bool? dismissible,
    double? width,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.exception,
      reference: title,
      description: message ?? '',
    );

    return MessageDialog(
      _scope,
      title: title,
      message: message ?? '',
      icon: icon ?? Icons.error,
      dismissible: dismissible ?? false,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.danger,
      iconColor: _scope.application.settings.colors.danger,
      buttons: buttons ?? const [],
      width: width ?? 0.0,
    );
  }

  /// Confirm dialog
  MessageDialog confirm(
    String message, {
    String? title,
    String? yesLabel,
    String? noLabel,
    Widget Function(BuildContext context)? body,
    bool? swap,
  }) {
    _scope.application.onEvent.call(
      ApplicationEventType.prompt,
      reference: title ?? message,
      description: message,
    );

    return MessageDialog(
      _scope,
      title: title ?? translate('anxeb.middleware.dialog.confirm.title'),
      message: message,
      icon: Icons.help,
      iconSize: 48,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      body: body ?? (context) => const SizedBox.shrink(),
      iconColor: _scope.application.settings.colors.info,
      buttons: swap == true
          ? [
              DialogButton(noLabel ?? translate('anxeb.common.no'), false),
              DialogButton(yesLabel ?? translate('anxeb.common.yes'), true),
            ]
          : [
              DialogButton(yesLabel ?? translate('anxeb.common.yes'), true),
              DialogButton(noLabel ?? translate('anxeb.common.no'), false),
            ],
    );
  }

  /// QR dialog
  MessageDialog qr(
    String value, {
    IconData? icon,
    String? title,
    List<DialogButton>? buttons,
    String? tip,
    double? size,
  }) {
    final qrSize = size ?? _scope.window.available.width * 0.6;

    return MessageDialog(
      _scope,
      icon: icon ?? Icons.qr_code_2,
      title: title ?? '',
      iconSize: 65,
      messageColor: _scope.application.settings.colors.text,
      titleColor: _scope.application.settings.colors.info,
      buttons: buttons ?? const [],
      body: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: qrSize,
            height: qrSize,
            child: QrImage(
              data: value,
              version: QrVersions.auto,
              foregroundColor: _scope.application.settings.colors.text,
              size: qrSize,
            ),
          ),
          if (tip != null)
            Container(
              width: qrSize,
              padding: const EdgeInsets.all(6),
              child: Text(
                tip,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _scope.application.settings.colors.primary,
                ),
              ),
            ),
        ],
      ),
      iconColor: _scope.application.settings.colors.primary,
      dismissible: true,
    );
  }

  /// Date-time picker
  DateTimeDialog dateTime({DateTime? value, bool pickTime = false}) {
    return DateTimeDialog(
      _scope,
      value: value ?? DateTime.now(),
      pickTime: pickTime,
    );
  }

  /// Slider dialog
  SliderDialog slider({List<SliderItem>? slides}) {
    return SliderDialog(_scope, slides: slides ?? const []);
  }

  /// Color picker
  ColorDialog color({Color? value, IconData? icon, String? title}) {
    return ColorDialog(
      _scope,
      value: value ?? Colors.transparent,
      icon: icon ?? Icons.color_lens,
      title: title ?? '',
    );
  }

  /// ✅ Added Prompt dialog (for text input)
  Future<String?> prompt(
    String title, {
    String? hint,
    String? value,
    IconData? icon,
  }) async {
    final controller = TextEditingController(text: value ?? '');

    final result = await MessageDialog(
      _scope,
      title: title,
      icon: icon ?? Icons.text_fields,
      message: '',
      dismissible: true,
      body: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint ?? ''),
        ),
      ),
      buttons: [
        DialogButton(translate('anxeb.common.accept'), true),
        DialogButton(translate('anxeb.common.cancel'), false),
      ],
    ).show();

    return result == true ? controller.text : null;
  }
}

/// =======================================================
/// SUPPORT CLASSES
/// =======================================================
class DialogButton<T> {
  final String caption;
  final T? value;
  final Color? fillColor;
  final Color? textColor;
  final IconData? icon;
  final Future<T?> Function(BuildContext context)? onTap;
  final bool? swapIcon;
  final bool? visible;

  const DialogButton(
    this.caption,
    this.value, {
    this.onTap,
    this.fillColor,
    this.textColor,
    this.icon,
    this.swapIcon,
    this.visible,
  });
}

class FormButton {
  final String caption;
  final Color? fillColor;
  final Color? textColor;
  final IconData? icon;
  final Future<dynamic> Function(FormScope scope)? onTap;
  final bool? swapIcon;
  final bool? visible;
  final bool? enabled;
  final bool? rightDivisor;
  final bool? leftDivisor;

  const FormButton({
    required this.caption,
    this.onTap,
    this.fillColor,
    this.textColor,
    this.icon,
    this.swapIcon,
    this.visible,
    this.enabled,
    this.rightDivisor,
    this.leftDivisor,
  });
}
